//=================================================================================================
/*
    Copyright (C) 2015-2020 Sky kit authors. <http://omega.gg/Sky>

    Author: Benjamin Arnaud. <http://bunjee.me> <bunjee@omega.gg>

    This file is part of the Sky kit runtime.

    - GNU Lesser General Public License Usage:
    This file may be used under the terms of the GNU Lesser General Public License version 3 as
    published by the Free Software Foundation and appearing in the LICENSE.md file included in the
    packaging of this file. Please review the following information to ensure the GNU Lesser
    General Public License requirements will be met: https://www.gnu.org/licenses/lgpl.html.

    - Private License Usage:
    Sky kit licensees holding valid private licenses may use this file in accordance with the
    private license agreement provided with the Software or, alternatively, in accordance with the
    terms contained in written agreement between you and Sky kit authors. For further information
    contact us at contact@omega.gg.
*/
//=================================================================================================

#include "ControllerCore.h"

// Qt includes
#include <QPainter>
#include <QTranslator>
#ifdef QT_4
#include <QCoreApplication>
#include <QDeclarativeEngine>
#else
#include <QQmlEngine>
#endif
//#include <QNetworkDiskCache>
#ifdef SK_DESKTOP
#include <QFileDialog>
#else
#include <QDir>
#if defined(Q_OS_ANDROID) && defined(QT_5) && QT_VERSION >= QT_VERSION_CHECK(5, 10, 0)
    #include <QtAndroid>
#endif
#endif
#ifndef QT_OLD
#include <QCollator>
#endif


// Sk includes
#include <WControllerApplication>
#include <WControllerDeclarative>
#include <WControllerView>
#include <WControllerFile>
#include <WControllerNetwork>
#include <WControllerDownload>
#include <WControllerPlaylist>
#include <WControllerMedia>
#include <WControllerTorrent>
#include <WView>
#include <WViewResizer>
#include <WViewDrag>
#include <WWindow>
#include <WCache>
#include <WUnzipper>
#include <WActionCue>
#include <WInputCue>
#include <WScriptBash>
#include <WLoaderNetwork>
#include <WLoaderVbml>
#include <WLoaderBarcode>
//#include <WLoaderWeb>
#include <WLoaderTorrent>
#include <WLoaderSuggest>
#include <WLoaderRecent>
#include <WLoaderTracks>
#include <WHookOutputBarcode>
#include <WHookTorrent>
#include <WLibraryFolderRelated>
#include <WAbstractTabs>
#include <WAbstractTab>
#include <WTabsTrack>
#include <WTabTrack>
#include <WVlcEngine>
#include <WBackendVlc>
#include <WBackendSubtitle>
#include <WBackendIndex>
#include <WBackendTorrent>
#include <WBackendUniversal>
#ifndef QT_4
#include <WFilterBarcode>
#endif
#include <WModelRange>
#include <WModelList>
#include <WModelOutput>
#include <WModelLibraryFolder>
#include <WModelPlaylist>
#include <WModelCompletionGoogle>
#include <WModelContextual>
#include <WModelTabs>
#include <WImageFilterColor>
#include <WDeclarativeApplication>
#include <WDeclarativeMouseArea>
#include <WDeclarativeMouseWatcher>
#include <WDeclarativeListView>
#include <WDeclarativeContextualPage>
#include <WDeclarativeAnimated>
#include <WDeclarativeBorders>
#include <WDeclarativeImage>
#include <WDeclarativeImageSvg>
#include <WDeclarativeBorderImage>
#include <WDeclarativeTextSvg>
#include <WDeclarativeAmbient>
#include <WDeclarativeBarcode>
#include <WDeclarativeScanner>
#ifdef SK_DESKTOP
#include <WDeclarativeScannerHover>
#endif
#include <WBarcodeWriter>

// Application includes
#include <DataOnline>
#include <DataScript>

W_INIT_CONTROLLER(ControllerCore)

//-------------------------------------------------------------------------------------------------
// Static variables

// NOTE: Also check DataLocal_patch, version_windows.
static const QString CORE_VERSION = "3.0.0-2";

static const int CORE_CACHE        = 1048576 * 100; // 100 megabytes
static const int CORE_CACHE_PIXMAP = 1048576 *  30; //  30 megabytes

#ifndef SK_DEPLOY
#ifdef Q_OS_MACOS
static const QString PATH_STORAGE = "/../../../storage";
static const QString PATH_LOCALE  = "../../../locale";
static const QString PATH_BACKEND = "../../../../../backend";
static const QString PATH_SCRIPT  = "../../../../script";
static const QString PATH_BASH    = "../../../../bash";
#else
static const QString PATH_STORAGE = "/storage";
static const QString PATH_LOCALE  = "locale";
static const QString PATH_BACKEND = "../../backend";
static const QString PATH_SCRIPT  = "../script";
static const QString PATH_BASH    = "../bash";
#endif
#endif

static const int CORE_WATCHER_INTERVAL = 200;

//=================================================================================================
// ControllerCoreReadRecent
//=================================================================================================

class ControllerCoreReadRecent : public WAbstractThreadAction
{
    Q_OBJECT

public: // Static functions
    static QStringList loadRecents(const QString & path);

protected: // WAbstractThreadAction reimplementation
    /* virtual */ WAbstractThreadReply * createReply() const;

protected: // WAbstractThreadAction implementation
    /* virtual */ bool run();

public: // Variables
    QString path;
};

class ControllerCoreReadReply : public WAbstractThreadReply
{
    Q_OBJECT

protected: // WAbstractThreadReply reimplementation
    /* virtual */ void onCompleted(bool ok);

signals:
    void loaded(const QStringList & recents);

public: // Variables
    QStringList recents;
};

/* static */ QStringList ControllerCoreReadRecent::loadRecents(const QString & path)
{
    QString content = WControllerFile::readAll(path);

    return WControllerApplication::split(content, '\n');
}

/* virtual */ WAbstractThreadReply * ControllerCoreReadRecent::createReply() const
{
    return new ControllerCoreReadReply;
}

/* virtual */ bool ControllerCoreReadRecent::run()
{
    ControllerCoreReadReply * reply = qobject_cast<ControllerCoreReadReply *> (this->reply());

    if (QFile::exists(path) == false) return true;

    reply->recents = loadRecents(path);

    return true;
}

/* virtual */ void ControllerCoreReadReply::onCompleted(bool)
{
    emit loaded(recents);
}

//=================================================================================================
// ControllerCoreWriteRecent
//=================================================================================================

class ControllerCoreWriteRecent : public WControllerFileAction
{
    Q_OBJECT

protected: // WAbstractThreadAction implementation
    /* virtual */ bool run();

public: // Variables
    QString path;

    QString fileName;
};

/* virtual */ bool ControllerCoreWriteRecent::run()
{
    QStringList recents;

    if (QFile::exists(path))
    {
        recents = ControllerCoreReadRecent::loadRecents(path);
    }

    if (recents.contains(fileName))
    {
        recents.removeOne(fileName);
    }

    recents.prepend(fileName);

    QString content;

    foreach (const QString & string, recents)
    {
        content.append(string + '\n');
    }

    WControllerFile::writeFile(path, content.toUtf8());

    return true;
}

//=================================================================================================
// ControllerCore
//=================================================================================================

ControllerCore::ControllerCore() : WController()
{
    _online = NULL;
    _script = NULL;

    _cache = NULL;

    _index = NULL;

    _bash = NULL;

    _translator = NULL;

    //---------------------------------------------------------------------------------------------
    // Settings

    sk->setName("Sky-runtime");

    sk->setVersion(CORE_VERSION);

#ifdef Q_OS_LINUX
#ifdef SK_DEPLOY
    sk->setIcon(":/icons/icon.svg");
#else
    sk->setIcon("icons/icon.svg");
#endif
#endif

#ifdef SK_DEPLOY
    _path = QDir::fromNativeSeparators(WControllerFile::pathWritable());
#else
    _path = QDir::currentPath() + PATH_STORAGE;
#endif

    wControllerFile->setPathStorage(_path);

    wControllerView->setLoadMode(WControllerView::LoadVisible);

    //---------------------------------------------------------------------------------------------
    // QML
    //---------------------------------------------------------------------------------------------
    // Qt

    qmlRegisterUncreatableType<QAbstractItemModel>("Sky", 1,0, "QAbstractItemModel",
                                                   "QAbstractItemModel is abstract");

    //---------------------------------------------------------------------------------------------
    // Global

    qmlRegisterUncreatableType<WControllerApplication>("Sky", 1,0, "Sk", "Sk is not creatable");

    //---------------------------------------------------------------------------------------------
    // Application

    qmlRegisterType<WDeclarativeApplication>("Sky", 1,0, "Application");

    //---------------------------------------------------------------------------------------------
    // Kernel

    qmlRegisterUncreatableType<WAbstractTabs>("Sky", 1,0, "AbstractTabs",
                                              "AbstractTabs is abstract");

    qmlRegisterUncreatableType<WAbstractTab>("Sky", 1,0, "AbstractTab",
                                             "AbstractTab is abstract");

    qmlRegisterType<WActionCue>("Sky", 1,0, "ActionCue");
    qmlRegisterType<WInputCue> ("Sky", 1,0, "InputCue");

    //---------------------------------------------------------------------------------------------
    // View

    qmlRegisterUncreatableType<WView>("Sky", 1,0, "View", "View is abstract");

    qmlRegisterType<WViewResizer>("Sky", 1,0, "ViewResizer");
    qmlRegisterType<WViewDrag>   ("Sky", 1,0, "ViewDrag");

    qmlRegisterType<WWindow>("Sky", 1,0, "BaseWindow");

    //---------------------------------------------------------------------------------------------
    // Image

    qmlRegisterUncreatableType<WImageFilter>("Sky", 1,0, "ImageFilter", "ImageFilter is abstract");

    qmlRegisterType<WImageFilterColor>("Sky", 1,0, "ImageFilterColor");

    qmlRegisterType<WDeclarativeGradient>    ("Sky", 1,0, "ScaleGradient");
    qmlRegisterType<WDeclarativeGradientStop>("Sky", 1,0, "ScaleGradientStop");

    //---------------------------------------------------------------------------------------------
    // Declarative

    qmlRegisterType<WDeclarativeMouseArea>   ("Sky", 1,0, "SkyMouseArea");
    qmlRegisterType<WDeclarativeMouseWatcher>("Sky", 1,0, "MouseWatcher");

    qmlRegisterType<WDeclarativeListHorizontal>("Sky", 1,0, "ListHorizontal");
    qmlRegisterType<WDeclarativeListVertical>  ("Sky", 1,0, "ListVertical");

    qmlRegisterType<WDeclarativeContextualPage>("Sky", 1,0, "ContextualPage");

    qmlRegisterType<WDeclarativeAnimated>("Sky", 1,0, "Animated");

    qmlRegisterType<WDeclarativeBorders>("Sky", 1,0, "Borders");

    qmlRegisterType<WDeclarativeGradient>    ("Sky", 1,0, "ScaleGradient");
    qmlRegisterType<WDeclarativeGradientStop>("Sky", 1,0, "ScaleGradientStop");

    qmlRegisterUncreatableType<WDeclarativeImageBase>("Sky", 1,0, "ImageBase",
                                                      "ImageBase is abstract");

    qmlRegisterType<WDeclarativeImage>     ("Sky", 1,0, "SkyImage");
    qmlRegisterType<WDeclarativeImageScale>("Sky", 1,0, "ImageScale");
    qmlRegisterType<WDeclarativeImageSvg>  ("Sky", 1,0, "ImageSvg");

#ifdef QT_4
    qmlRegisterType<WDeclarativeImageSvgScale>("Sky", 1,0, "ImageSvgScale");
#endif

    qmlRegisterType<WDeclarativeBorderImage>     ("Sky", 1,0, "SkyBorderImage");
    qmlRegisterType<WDeclarativeBorderImageScale>("Sky", 1,0, "BorderImageScale");
    qmlRegisterType<WDeclarativeBorderGrid>      ("Sky", 1,0, "BorderGrid");

    qmlRegisterType<WDeclarativeTextSvg>("Sky", 1,0, "TextSvg");

#ifdef QT_4
    qmlRegisterType<WDeclarativeTextSvgScale>("Sky", 1,0, "TextSvgScale");
#endif

    qmlRegisterType<WDeclarativePlayer> ("Sky", 1,0, "Player");
    qmlRegisterType<WDeclarativeAmbient>("Sky", 1,0, "Ambient");

    qmlRegisterType<WDeclarativeScanner>("Sky", 1,0, "Scanner");

#ifdef SK_DESKTOP
    qmlRegisterType<WDeclarativeScannerHover>("Sky", 1,0, "ScannerHover");
#endif

    qmlRegisterType<WDeclarativeBarcode>("Sky", 1,0, "Barcode");

    //---------------------------------------------------------------------------------------------
    // Models

    qmlRegisterType<WModelRange>("Sky", 1,0, "ModelRange");

    qmlRegisterType<WModelList>("Sky", 1,0, "ModelList");

    qmlRegisterType<WModelOutput>("Sky", 1,0, "ModelOutput");

    qmlRegisterType<WModelLibraryFolder>        ("Sky", 1,0, "ModelLibraryFolder");
    qmlRegisterType<WModelLibraryFolderFiltered>("Sky", 1,0, "ModelLibraryFolderFiltered");

    qmlRegisterType<WModelPlaylist>        ("Sky", 1,0, "ModelPlaylist");
    qmlRegisterType<WModelPlaylistFiltered>("Sky", 1,0, "ModelPlaylistFiltered");

    qmlRegisterType<WModelCompletionGoogle>("Sky", 1,0, "ModelCompletionGoogle");

    qmlRegisterType<WModelContextual>("Sky", 1,0, "ModelContextual");

    qmlRegisterType<WModelTabs>("Sky", 1,0, "ModelTabs");

    //---------------------------------------------------------------------------------------------
    // Multimedia

    qmlRegisterUncreatableType<WBackendNet>("Sky", 1,0, "BackendNet", "BackendNet is abstract");

    qmlRegisterUncreatableType<WAbstractBackend>("Sky", 1,0, "AbstractBackend",
                                                 "AbstractBackend is abstract");

    qmlRegisterUncreatableType<WAbstractHook>("Sky", 1,0, "AbstractHook",
                                              "AbstractHook is abstract");

    qmlRegisterUncreatableType<WHookOutput>("Sky", 1,0, "HookOutput",
                                            "HookOutput is not creatable");

    qmlRegisterUncreatableType<WLocalObject>("Sky", 1,0, "LocalObject", "LocalObject is abstract");

    qmlRegisterUncreatableType<WLibraryItem>("Sky", 1,0, "LibraryItem", "LibraryItem is abstract");

    qmlRegisterType<WLibraryFolder>       ("Sky", 1,0, "LibraryFolder");
    qmlRegisterType<WLibraryFolderRelated>("Sky", 1,0, "LibraryFolderRelated");

    qmlRegisterType<WPlaylist>("Sky", 1,0, "Playlist");

    qmlRegisterType<WTabsTrack>("Sky", 1,0, "BaseTabsTrack");
    qmlRegisterType<WTabTrack> ("Sky", 1,0, "TabTrack");

    qmlRegisterUncreatableType<WBackendIndex>("Sky", 1,0, "BackendIndex",
                                              "BackendIndex is not creatable");

    qmlRegisterType<WBackendVlc>     ("Sky", 1,0, "BackendVlc");
    qmlRegisterType<WBackendSubtitle>("Sky", 1,0, "BackendSubtitle");

#ifndef QT_4
    qmlRegisterType<WFilterBarcode>("Sky", 1,0, "FilterBarcode");
#endif

    //---------------------------------------------------------------------------------------------
    // Events

    qmlRegisterUncreatableType<WDeclarativeDropEvent>("Sky", 1,0, "DeclarativeDropEvent",
                                                      "DeclarativeDropEvent is not creatable");

    qmlRegisterUncreatableType<WDeclarativeKeyEvent>("Sky", 1,0, "DeclarativeKeyEvent",
                                                     "DeclarativeKeyEvent is not creatable");

    //---------------------------------------------------------------------------------------------
    // Sky-runtime

    qmlRegisterType<DataLocal>("Sky", 1,0, "DataLocal");

    //---------------------------------------------------------------------------------------------
    // Context

    wControllerDeclarative->setContextProperty("sk",   sk);

    wControllerDeclarative->setContextProperty("core",  this);
    wControllerDeclarative->setContextProperty("local", &_local);
}

//-------------------------------------------------------------------------------------------------
// Interface
//-------------------------------------------------------------------------------------------------

#ifdef SK_DESKTOP

/* Q_INVOKABLE */ int ControllerCore::applyArguments(int & argc, char ** argv)
{
    if (argc < 2) return -1;

    for (int i = 1; i < argc; i++)
    {
        QString string = argv[i];

        if (string.startsWith("--"))
        {
            QString name = string;

            name = name.remove(0, 2).toLower();

            if (name == "cli")
            {
                sk->setCli(true);
            }
            else if (name == "help")
            {
                help();

                return 0;
            }
        }
        else _argument = string;
    }

    return -1;
}

#endif

/* Q_INVOKABLE */ void ControllerCore::load()
{
    if (_cache) return;

    //---------------------------------------------------------------------------------------------
    // Environment

    loadEnvironment();

    _pathBin = qgetenv("SKY_PATH_BIN");

    if (_pathBin.isEmpty())
    {
        _pathBin = _path + "/bin/sky";

        if (QFile::exists(_pathBin) == false && QDir().mkpath(_pathBin) == false)
        {
            qWarning("ControllerCore::run: Failed to create folder %s.", _pathBin.C_STR);
        }

        qputenv("SKY_PATH_BIN", _pathBin.toUtf8());
    }
    else _pathBin += "/sky";

#ifdef Q_OS_MACOS
    // FIXME Qt6/macOS: This seems required for the WebView to load when deploying the application.
    qputenv("QTWEBENGINE_DISABLE_SANDBOX", "1");
#endif

    //---------------------------------------------------------------------------------------------
    // DataLocal

    // NOTE: We make sure the storage folder is created.
    _local.createPath();

    //---------------------------------------------------------------------------------------------
    // Message handler

    // FIXME Qt4.8.7: qInstallMsgHandler breaks QML 'Keys' events.
#ifndef QT_4
    wControllerFile->initMessageHandler();
#endif

    //---------------------------------------------------------------------------------------------
    // Paths

    qDebug("Sky runtime %s", sk->version().C_STR);

    qDebug("Path storage: %s", _path.C_STR);
    qDebug("Path log:     %s", wControllerFile->pathLog().C_STR);
    qDebug("Path config:  %s", _local.getFilePath().C_STR);

    //---------------------------------------------------------------------------------------------
    // Controllers

    W_CREATE_CONTROLLER(WControllerPlaylist);

#ifdef Q_OS_WIN
    QStringList options = WVlcEngine::getOptions();

    // NOTE VLC Windows: This is useful if we want a specific volume for each player.
    options.append("--aout=directsound");

    W_CREATE_CONTROLLER_1(WControllerMedia, options);
#else
    W_CREATE_CONTROLLER(WControllerMedia);
#endif

#ifndef SK_NO_TORRENT
    W_CREATE_CONTROLLER_2(WControllerTorrent, _path + "/torrents", _local._torrentPort);
#endif

    //---------------------------------------------------------------------------------------------
    // Log

#ifndef SK_DEPLOY
    wControllerMedia->startLog();
#endif

    //---------------------------------------------------------------------------------------------
    // Cache

    _cache = new WCache(_path + "/cache", CORE_CACHE);

    wControllerFile->setCache(_cache);

    //---------------------------------------------------------------------------------------------
    // PixmapCache

    WPixmapCache::setSizeMax(CORE_CACHE_PIXMAP);

    //---------------------------------------------------------------------------------------------
    // LoaderVbml

    wControllerPlaylist->registerLoader(WBackendNetQuery::TypeVbml, new WLoaderVbml(this));

    //---------------------------------------------------------------------------------------------
    // LoaderBarcode

    wControllerPlaylist->registerLoader(WBackendNetQuery::TypeImage, new WLoaderBarcode(this));

#ifndef SK_NO_TORRENT
    //---------------------------------------------------------------------------------------------
    // LoaderTorrent

    WLoaderTorrent * loaderTorrent = new WLoaderTorrent(this);

    wControllerPlaylist->registerLoader(WBackendNetQuery::TypeTorrent, loaderTorrent);
    wControllerTorrent ->registerLoader(WBackendNetQuery::TypeTorrent, loaderTorrent);

    //---------------------------------------------------------------------------------------------
    // Torrents

    applyTorrentOptions(_local._torrentConnections,
                        _local._torrentUpload, _local._torrentDownload, _local._torrentCache);
#endif

    //---------------------------------------------------------------------------------------------
    // Backends

    QString path = _path + "/backend";

    if (QFile::exists(path) == false)
    {
        if (QDir().mkpath(path) == false)
        {
            qWarning("ControllerCore::run: Failed to create folder %s.", path.C_STR);

            return;
        }

        WControllerFileReply * reply = copyBackends(path);

        connect(reply, SIGNAL(complete(bool)), this, SLOT(onLoaded()));
    }
    else createIndex();

    //---------------------------------------------------------------------------------------------
    // Bash

    _bash = new WScriptBash(this);

#ifdef Q_OS_WIN
    _bash->setPathBash(WControllerFile::applicationPath("Git/usr/bin/bash.exe"));
#endif

    //---------------------------------------------------------------------------------------------
    // DataOnline

    _online = new DataOnline(this);

    //---------------------------------------------------------------------------------------------
    // Watcher

    wControllerFile->setWatcherInterval(CORE_WATCHER_INTERVAL);

    //---------------------------------------------------------------------------------------------
    // QML

    qmlRegisterType<DataOnline>("Sky", 1,0, "DataOnline");
    qmlRegisterType<DataScript>("Sky", 1,0, "DataScript");

    wControllerDeclarative->setContextProperty("controllerFile",     wControllerFile);
    wControllerDeclarative->setContextProperty("controllerNetwork",  wControllerNetwork);
    wControllerDeclarative->setContextProperty("controllerPlaylist", wControllerPlaylist);

    wControllerDeclarative->setContextProperty("online", _online);

    //---------------------------------------------------------------------------------------------
    // Translation

    QString locale = _local.locale();

    if (locale.isEmpty() == false)
    {
        sk->setLocale(locale);
    }

    _translator = new QTranslator(this);

    path = getPathLocale(sk->locale());

    if (QFile::exists(path) && _translator->load(path))
    {
        qApp->installTranslator(_translator);
    }

    //---------------------------------------------------------------------------------------------
    // Signals

    connect(sk, SIGNAL(localeChanged()), this, SLOT(onLocaleChanged()));

    connect(&_watcher, SIGNAL(filesModified(const QString &, const QStringList &)),
            this,      SLOT(onFilesModified(const QString &, const QStringList &)));
}

/* Q_INVOKABLE */ DataScript * ControllerCore::loadScript(const QString & fileName)
{
    if (fileName.isEmpty()) return NULL;

    DataScript * script = new DataScript(this);

    loadData(script, fileName);

    return script;
}

/* Q_INVOKABLE */ void ControllerCore::loadLibrary()
{
    _library.clear();

    //---------------------------------------------------------------------------------------------
    // NOTE: We want an empty 'sky' item at the top.

    ControllerCoreItem item;

    item.name = "sky";

    _library.append(item);

    //---------------------------------------------------------------------------------------------

    QList<QFileInfo> entries;

#ifdef SK_DEPLOY
#ifdef Q_OS_ANDROID
    loadFolder(entries, "assets:/script");
#else
    loadFolder(entries, WControllerFile::applicationPath("script"));
#endif
#else
    loadFolder(entries, WControllerFile::applicationPath(PATH_SCRIPT));
#endif

    loadFolder(entries, _pathBin + "/script");

#ifndef QT_OLD
    // NOTE: We want test.sky to be listed before test-extra.sky.

    QCollator collator;

    collator.setNumericMode(true);

    std::sort(entries.begin(), entries.end(), [&](const QFileInfo & a, const QFileInfo & b)
    {
        return collator.compare(a.fileName(), b.fileName()) < 0;
    });
#endif

    QStringList names;

    foreach (const QFileInfo & info, entries)
    {
        QString name = WControllerFile::fileBaseName(info.fileName().toLower());

        if (names.contains(name)) continue;

        ControllerCoreItem item;

        item.fileName = info.absoluteFilePath();

        item.name = name;

        _library.append(item);
    }

    emit libraryLoaded();
}

/* Q_INVOKABLE */ void ControllerCore::reloadScript(int index)
{
    if (_script) _script->reload(index);
}

/* Q_INVOKABLE */ QVariantList ControllerCore::installArchive(const QString & fileName,
                                                              const QString & name)
{
    QString log;

    QString filePath = WControllerFile::filePath(fileName);

    if (QFile::exists(filePath) == false)
    {
        log.append(QString(tr("The script file does not exist %1\n")).arg(filePath));

        return getVariantInstall(false, log);
    }

    log.append(tr("\n"
                  "Install in progress...\n"));

    QList<QFileInfo> entries;

    loadFolder(entries, _pathBin + "/script");

    QString match = name + '-';

    foreach (const QFileInfo & info, entries)
    {
        QString baseName = WControllerFile::fileBaseName(info.fileName().toLower());

        if (baseName != name && baseName.startsWith(match) == false) continue;

        log.append(QString(tr("rm %1.sky\n")).arg(baseName));

        WControllerFile::deleteFile(info.absoluteFilePath());
    }

    QString path = _pathBin + "/bash/" + name + '/';

    if (QFile::exists(path))
    {
        log.append(QString(tr("rm -rf script/%1\n")).arg(path));

        WControllerFile::deleteFolder(path);
    }

    QStringList list = WUnzipper::getFileNames(filePath);

    foreach (const QString & string, list)
    {
        log.append(QString(tr("cp %1\n")).arg(string));
    }

    WUnzipper::extract(filePath, _pathBin);

    log.append(tr("---\n"
                  "Install complete"));

    return getVariantInstall(true, log);
}

/* Q_INVOKABLE */ bool ControllerCore::bash(const QString & fileName, const QStringList & arguments)
{
    if (_bash == NULL) return false;

    qDebug("BASH %s", fileName.C_STR);

    return _bash->run(fileName, arguments, false);
}

/* Q_INVOKABLE */ void ControllerCore::skip()
{
    if (_bash == NULL) return;

    _bash->stop();
}

/* Q_INVOKABLE */ QString ControllerCore::bashResolve(const QString & source) const
{
    QString name = source;

    if (WControllerNetwork::extractUrlExtension(name) != "sh") name += ".sh";

#ifdef SK_DEPLOY
#ifdef Q_OS_ANDROID
    QString fileName = "assets:/bash/" + name;
#else
    QString fileName = WControllerFile::applicationPath("bash/" + name);
#endif
#else
    QString fileName = WControllerFile::applicationPath(PATH_BASH + "/" + name);
#endif

    if (QFile::exists(fileName)) return fileName;

    fileName = _pathBin + "/bash/" + name;

    if (QFile::exists(fileName)) return fileName;

    return source;
}

/* Q_INVOKABLE */ bool ControllerCore::render(const QString      & fileName,
                                              const QVariantList & items,
                                              qreal                x,
                                              qreal                y,
                                              qreal                width,
                                              qreal                height,
                                              qreal                scale,
                                              qreal                upscale,
                                              const QColor       & background,
                                              bool                 asynchronous)
{
    qreal gapX = (width  - width  * scale) / 2.0;
    qreal gapY = (height - height * scale) / 2.0;

    x = x * scale + gapX;
    y = y * scale + gapY;

    QSizeF size(width, height);

    size.scale(width * upscale, height, Qt::KeepAspectRatioByExpanding);

    QImage result(size.toSize(), QImage::Format_ARGB32);

    result.fill(background);

    QPainter painter(&result);

    painter.setRenderHint(QPainter::SmoothPixmapTransform);
    painter.setRenderHint(QPainter::Antialiasing);

    foreach (const QVariant & variant, items)
    {
        WDeclarativeImage * item = variant.value<WDeclarativeImage *>();

        if (item == NULL) continue;

        QImage image(item->source());

        painter.save();

        painter.setOpacity(item->opacity());

        qreal sizeX = item->width () * scale * upscale;
        qreal sizeY = item->height() * scale * upscale;

        Qt::AspectRatioMode ratio = WDeclarativeImage::ratioFromFill(item->fillMode());

        image = image.scaled(qRound(sizeX),
                             qRound(sizeY), ratio, Qt::SmoothTransformation);

        qreal positionX = (x + item->x() * scale) * upscale + (sizeX - image.width ()) / 2;
        qreal positionY = (y + item->y() * scale) * upscale + (sizeY - image.height()) / 2;

#ifdef QT_OLD
        painter.drawImage(QPoint(qRound(positionX),
                                 qRound(positionY)), image);
#else
        qreal rotation = item->rotation();

        if (rotation)
        {
            painter.translate(qRound(positionX),
                              qRound(positionY));

#ifdef QT_5
            int rotateX = qRound(sizeX * 0.5);
            int rotateY = qRound(sizeY * 0.5);
#else
            QPointF origin = item->transformOriginPoint();

            int rotateX = qRound(origin.x() * scale * upscale);
            int rotateY = qRound(origin.y() * scale * upscale);
#endif

            painter.translate(rotateX, rotateY);

            painter.rotate(rotation);

            painter.translate(-rotateX, -rotateY);

            painter.drawImage(QPoint(0, 0), image);
        }
        else painter.drawImage(QPoint(qRound(positionX),
                                      qRound(positionY)), image);

        painter.restore();
#endif
    }

    return saveImage(fileName, result, asynchronous);
}

/* Q_INVOKABLE */ bool ControllerCore::renderBox(const QString      & fileName,
                                                 const QVariantList & items,
                                                 qreal                x,
                                                 qreal                y,
                                                 qreal                width,
                                                 qreal                height,
                                                 const QVariant     & itemFocus,
                                                 bool                 isolate,
                                                 const QColor       & background,
                                                 bool                 asynchronous)
{
    qreal scale;

    if (itemFocus.isValid())
    {
        WDeclarativeImage * item = itemFocus.value<WDeclarativeImage *>();

        if (item)
        {
            scale = item->pixmapWidth() / item->width();

            if (isolate)
            {
                x *= scale;
                y *= scale;

                width  *= scale;
                height *= scale;

                QImage result(qRound(width), qRound(height), QImage::Format_ARGB32);

                result.fill(background);

                QPainter painter(&result);

                painter.setRenderHint(QPainter::SmoothPixmapTransform);
                painter.setRenderHint(QPainter::Antialiasing);

                QRectF rect(x, y, width, height);

                renderItem(painter, item, rect, x, y, scale);

                return saveImage(fileName, result, asynchronous);
            }
        }
        else scale = 1.0;
    }
    else scale = 1.0;

    x *= scale;
    y *= scale;

    width  *= scale;
    height *= scale;

    QImage result(qRound(width), qRound(height), QImage::Format_ARGB32);

    result.fill(background);

    QPainter painter(&result);

    painter.setRenderHint(QPainter::SmoothPixmapTransform);
    painter.setRenderHint(QPainter::Antialiasing);

    QRectF rect(x, y, width, height);

    foreach (const QVariant & variant, items)
    {
        WDeclarativeImage * item = variant.value<WDeclarativeImage *>();

        if (item == NULL) continue;

        renderItem(painter, item, rect, x, y, scale);
    }

    return saveImage(fileName, result, asynchronous);
}

/* Q_INVOKABLE */ bool ControllerCore::saveImage(const QString & name,
                                                 const QImage  & image, bool asynchronous)
{
    QString fileName = QDir::fromNativeSeparators(name);

    QString path = QFileInfo(fileName).absolutePath();

    if (QFile::exists(path) || QDir().mkpath(path))
    {
        QString extension = WControllerNetwork::extractUrlExtension(name);

        QString path = wControllerFile->pathPictures() + "/hypergonar/temp_"
                       +
                       sk->currentDateString() + "." + extension;

        if (asynchronous)
        {
            if (_replies.count() > 10)
            {
                qWarning("ControllerCore::saveImage: Too many asynchronous requests");

                return false;
            }

            ControllerCoreFile file;

            file.origin = path;
            file.target = fileName;

            WControllerFileReply * reply = wControllerView->startWriteImage(path, image);

            _replies.insert(reply, file);

            connect(reply, SIGNAL(complete(bool)), this, SLOT(onComplete(bool)));

            return true;
        }
        else if (image.save(path, "png"))
        {
            QFile::remove(name);

            WControllerFile::renameFile(path, name);

            return true;
        }
        else return false;
    }
    else return false;
}

/* Q_INVOKABLE */ bool ControllerCore::saveShot(const QString & name,
                                                WWindow       * window, bool asynchronous)
{
    return saveImage(name, window->takeShot(), asynchronous);
}

#ifdef QT_4
/* Q_INVOKABLE static */ bool ControllerCore::saveItemShot(const QString   & name,
                                                           QGraphicsObject * item,
                                                           bool              asynchronous)
#else
/* Q_INVOKABLE static */ bool ControllerCore::saveItemShot(const QString & name,
                                                           QQuickItem    * item,
                                                           bool            asynchronous)
#endif
{
    return saveImage(name, WView::takeItemShot(item).toImage(), asynchronous);
}

/* Q_INVOKABLE */ bool ControllerCore::saveFrame(const QString      & name,
                                                 WDeclarativePlayer * player, bool asynchronous)
{
    if (player == NULL) return false;

    return saveImage(name, player->getFrame(), asynchronous);
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void ControllerCore::updateBackends() const
{
    if (_index == NULL) return;

    _index->update();
}

/* Q_INVOKABLE */ void ControllerCore::resetBackends() const
{
    WControllerFileReply * reply = copyBackends(_path + "/backend");

    connect(reply, SIGNAL(complete(bool)), this, SLOT(onReload()));
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void ControllerCore::clearComponentCache() const
{
    wControllerDeclarative->engine()->clearComponentCache();
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void ControllerCore::clearScripts()
{
    if (_script) _script->clear();
}

/* Q_INVOKABLE */ void ControllerCore::addWatcher(const QString & fileName)
{
    _watcher.addFile(fileName);
}

/* Q_INVOKABLE */ void ControllerCore::clearWatchers()
{
    _watcher.clearFiles();

    if (_source.isEmpty() == false)
    {
        _watcher.addFile(_source);
    }
}

/* Q_INVOKABLE */ void ControllerCore::loadRecent()
{
    ControllerCoreReadRecent * action = new ControllerCoreReadRecent;

    action->path = _path + "/recent.txt";

    ControllerCoreReadReply * reply = qobject_cast<ControllerCoreReadReply *>
                                      (wControllerFile->startReadAction(action));

    connect(reply, SIGNAL(loaded(const QStringList &)),
            this,  SLOT(onRecent(const QStringList &)));
}

/* Q_INVOKABLE */ void ControllerCore::saveRecent(const QString & fileName)
{
    ControllerCoreWriteRecent * action = new ControllerCoreWriteRecent;

    action->path = _path + "/recent.txt";

    action->fileName = fileName;

    wControllerFile->startWriteAction(action);
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ QString ControllerCore::getName(int index) const
{
    if (_script)
    {
        return _script->getName(index);
    }
    else return QString();
}

/* Q_INVOKABLE */ QString ControllerCore::getVersion(int index) const
{
    if (_script)
    {
        return _script->getVersion(index);
    }
    else return QString();
}

/* Q_INVOKABLE */ QString ControllerCore::getVersionParent(int index) const
{
    if (_script)
    {
        return _script->getVersionParent(index);
    }
    else return QString();
}

/* Q_INVOKABLE */ QByteArray ControllerCore::getData(int index) const
{
    if (_script)
    {
        return _script->getData(index);
    }
    else return QByteArray();
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ QStringList ControllerCore::getLibraryNames() const
{
    QStringList list;

    foreach (const ControllerCoreItem & item, _library)
    {
        list.append(item.name);
    }

    return list;
}

/* Q_INVOKABLE */ QString ControllerCore::getLibraryFileName(int index) const
{
    if (index < 0 || index >= _library.count()) return QString();

    return _library.at(index).fileName;
}

/* Q_INVOKABLE */ QString ControllerCore::getLibraryPath(int index) const
{
    if (index < 0 || index >= _library.count()) return QString();

    return WControllerFile::folderPath(_library.at(index).fileName);
}

/* Q_INVOKABLE */ QString ControllerCore::getLibraryName(int index) const
{
    if (index < 0 || index >= _library.count()) return QString();

    return _library.at(index).name;
}

/* Q_INVOKABLE */ int ControllerCore::libraryIndexFromName(const QString & name)
{
    for (int i = 0; i < _library.count(); i++)
    {
        if (_library.at(i).name == name) return i;
    }

    return -1;
}

//-------------------------------------------------------------------------------------------------
// Static functions
//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE static */ QString ControllerCore::createScript(const QString & text,
                                                              const QString & name)
{
#ifdef SK_DESKTOP
    if (text.isEmpty()) return QString();

    QString result = QFileDialog::getSaveFileName(NULL, tr("Create .sky"),
                                                  WControllerFile::pathDocuments() + '/' + name,
                                                  tr("Sky script (*.sky)"));

    if (result.isEmpty() || WControllerFile::writeFile(result, text.toUtf8()) == false)
    {
        return QString();
    }

    return result;
#else
    Q_UNUSED(text); Q_UNUSED(name);

    return QString();
#endif
}

/* Q_INVOKABLE static */ QString ControllerCore::createShortcut(const QString & text,
                                                                const QString & name)
{
#ifdef SK_DESKTOP
    if (text.isEmpty()) return QString();

    QString result = QFileDialog::getSaveFileName(NULL, tr("Create shortcut"),
                                                  WControllerFile::pathDesktop() + '/' + name,
                                                  tr("Sky script (*.sky)"));

    if (result.isEmpty() || WControllerFile::writeFile(result, text.toUtf8()) == false)
    {
        return QString();
    }

    return result;
#else
    Q_UNUSED(text); Q_UNUSED(name);

    return QString();
#endif
}

/* Q_INVOKABLE static */ QString ControllerCore::openScript()
{
#ifdef SK_DESKTOP
    return QFileDialog::getOpenFileName(NULL, tr("Open .sky"),
                                        WControllerFile::pathDocuments(),
                                        tr("Sky (*.sky *.skz)"));
#else
    return QString();
#endif
}


/* Q_INVOKABLE static */ bool ControllerCore::fileIsArchive(const QString & fileName)
{
    return fileName.endsWith(".skz", Qt::CaseInsensitive);
}

/* Q_INVOKABLE static */ QVariantList ControllerCore::checkArchive(const QString & fileName)
{
    QString log;

    QStringList list = WUnzipper::getFileNames(WControllerFile::filePath(fileName));

    list.removeOne("script/");
    list.removeOne("bash/");

    QStringList scripts;

    int index = 0;

    while (index < list.count())
    {
        QString string = list.at(index);

        if (string.startsWith("script/"))
        {
            scripts.append(list.takeAt(index));
        }
        else index++;
    }

    if (scripts.isEmpty())
    {
        log.append(tr("The script folder is absent from the archive.\n"));

        return getVariantCheck(false, "", log);
    }

    QString name = scripts.first();

    if (name.contains('-'))
    {
         name = Sk::sliceIn(name, "/", "-");
    }
    else name = Sk::sliceIn(name, "/", ".");

    if (name.isLower() == false)
    {
        log.append(tr("The script name is not lower case.\n"));

        return getVariantCheck(false, "", log);
    }

    log.append(QString(tr("Script name: %1\n")).arg(name));

    foreach (const QString & string, scripts)
    {
        log.append(string + '\n');
    }

    QString startBash = "bash/";
    QString startDoc  = "doc/";

    list.removeOne(startBash);
    list.removeOne(startDoc);

    QString path = name + '/';

    startBash += path;
    startDoc  += path;

    list.removeOne(startBash);
    list.removeOne(startDoc);

    foreach (const QString & string, list)
    {
        if (string.startsWith(startBash) || string.startsWith(startDoc)) continue;

        log.append(QString(tr("Invalid file: %1\n")).arg(string));

        return getVariantCheck(false, "", log);
    }

    log.append(tr("---\n"
                  "Valid folder structure\n"));

    return getVariantCheck(true, name, log);
}

/* Q_INVOKABLE static */ QVariantList ControllerCore::getVariantCheck(bool            ok,
                                                                      const QString & name,
                                                                      const QString & log)
{
    QVariantList variants;

    variants.append(ok);
    variants.append(name);
    variants.append(log);

    return variants;
}

/* Q_INVOKABLE static */ QVariantList ControllerCore::getVariantInstall(bool            ok,
                                                                        const QString & log)
{
    QVariantList variants;

    variants.append(ok);
    variants.append(log);

    return variants;
}

/* Q_INVOKABLE static */ QQuickItem * ControllerCore::pickItem(const QVariantList & items,
                                                               qreal                x,
                                                               qreal                y)
{
    for (int i = items.count() - 1; i >= 0; i--)
    {
        QVariant variant = items.at(i);

        QQuickItem * item = variant.value<QQuickItem *>();

        if (item == NULL) continue;

        int width  = item->width ();
        int height = item->height();

        int positionX = item->x();
        int positionY = item->y();

        if (QRect(positionX, positionY, width, height).contains(x, y) == false) continue;

        WDeclarativeImage * itemImage = variant.value<WDeclarativeImage *>();

        if (itemImage == NULL) return item;

        QImage image(itemImage->source());

        Qt::AspectRatioMode ratio = WDeclarativeImage::ratioFromFill(itemImage->fillMode());

        image = image.scaled(width, height, ratio, Qt::FastTransformation);

        positionX = x - positionX - (width  - image.width ()) / 2;
        positionY = y - positionY - (height - image.height()) / 2;

        if (image.rect().contains(positionX, positionY) == false
            ||
            // NOTE: When we pick a transparent pixel we skip the item.
            qAlpha(image.pixel(positionX, positionY)) == 0) continue;

        return item;
    }

    return NULL;
}

#ifndef SK_NO_TORRENT

/* Q_INVOKABLE static */ void ControllerCore::applyTorrentOptions(int connections,
                                                                  int upload, int download,
                                                                  int cache)
{
    wControllerTorrent->setOptions(connections, upload * 1024, download * 1024);

    wControllerTorrent->setSizeMax(qint64(cache) * 1048576);
}

#endif

/* Q_INVOKABLE static */ void ControllerCore::applyBackend(WDeclarativePlayer * player)
{
    Q_ASSERT(player);

#ifdef SK_NO_TORRENT
    WBackendManager * backend = new WBackendManager;
#else
    WBackendTorrent * backend = new WBackendTorrent;
#endif

    player->setBackend(backend);
}

/* Q_INVOKABLE static */ QImage ControllerCore::generateTagSource(const QString & source)
{
    // NOTE: We don't want margins surrounding our QR code.
    return WBarcodeWriter::write(source, WBarcodeWriter::Text, QString(), 0).image;
}

/* Q_INVOKABLE static */ QImage ControllerCore::generateTagPath(const QString & path)
{
    return generateTagSource("https://omega.gg/" + path);
}

/* Q_INVOKABLE static */ bool ControllerCore::renameFile(const QString & oldPath,
                                                         const QString & newPath)
{
    return WControllerFile::renameFile(oldPath, newPath);
}

//-------------------------------------------------------------------------------------------------
// Functions private
//-------------------------------------------------------------------------------------------------

void ControllerCore::help() const
{
    createPath(_path);

    // FIXME Qt4.8.7: qInstallMsgHandler breaks QML 'Keys' events.
#ifndef QT_4
    wControllerFile->initMessageHandler();
#endif

    qInfo("sky %s\n", sk->version().C_STR);

    qInfo("Usage: sky <script> [options]\n"
          "\n"
          "--help    Print the help\n"
          "--cli     Run the script headless");
}

bool ControllerCore::createPath(const QString & path) const
{
    if (QFile::exists(path) || QDir().mkpath(path)) return true;

    qWarning("ControllerCore::createPath: Failed to create folder %s.", path.C_STR);

    return false;
}

void ControllerCore::createIndex()
{
#ifdef SK_NO_TORRENT
    _index = new WBackendIndex(WControllerFile::fileUrl(_path + "/backend/indexLite.vbml"));
#else
    _index = new WBackendIndex(WControllerFile::fileUrl(_path + "/backend/index.vbml"));
#endif

    connect(_index, SIGNAL(loaded()), this, SLOT(onIndexLoaded()));
}

WControllerFileReply * ControllerCore::copyBackends(const QString & path) const
{
#ifdef SK_DEPLOY
#ifdef Q_OS_ANDROID
    return WControllerPlaylist::copyBackends("assets:/backend", path);
#else
    return WControllerPlaylist::copyBackends(WControllerFile::applicationPath("backend"), path);
#endif
#else
    return WControllerPlaylist::copyBackends(WControllerFile::applicationPath(PATH_BACKEND), path);
#endif
}

void ControllerCore::loadEnvironment()
{
    QString fileName = WControllerFile::applicationPath("env");

    if (QFile::exists(fileName) == false) return;

    QString data = WControllerFile::readAll(fileName);

    data.remove('\r');

    QStringList lines = Sk::split(data, '\n');

    foreach (const QString & line, lines)
    {
        int index = line.indexOf('=');

        if (index < 1) continue;

        QString key = line.left(index).trimmed();

        QString value = line.mid(index + 1).trimmed();

        Sk::setEnv(key, value.toUtf8());
    }
}

void ControllerCore::loadData(DataScript * script, const QString & fileName)
{
    qDebug("LOADING %s", fileName.C_STR);

    QByteArray data = WControllerFile::readAll(fileName);

    QString line = Sk::getLine(data);

    //qDebug(line.C_STR);

    line = line.mid(line.indexOf('/') + 2).toLower();

    QStringList list = Sk::split(line, ':');

    if (list.isEmpty()) return;

    int index;

    if (list.count() == 1) index = 0;
    else                   index = 1;

    QStringList pair = Sk::split(list.at(index).simplified(), ' ');

    if (pair.count() != 2) return;

    QString parent = pair.at(0);

    DataScriptItem item;

    item.fileName = fileName;

    item.versionParent = pair.at(1);

    QString version = list.at(0).simplified();

    if (index)
    {
        pair = Sk::split(version, ' ');

        if (pair.count() == 2)
        {
            item.version = pair.at(1);
        }
        else item.version = version;
    }
    else item.version = "1.0.0";

    item.data = data;

    script->prepend(item);

    if (parent == "sky") return;

    QString name = parent + ".sky";

#ifdef SK_DEPLOY
#ifdef Q_OS_ANDROID
    QString path = "assets:/script/" + name;
#else
    QString path = WControllerFile::applicationPath("script/" + name);
#endif
#else
    QString path = WControllerFile::applicationPath(PATH_SCRIPT + "/" + name);
#endif

    if (QFile::exists(path))
    {
        loadData(script, path);
    }
    else loadData(script, _pathBin + "/script/" + name);
}

void ControllerCore::loadFolder(QList<QFileInfo> & entries, const QString & path)
{
    foreach (const QFileInfo & info, QDir(path).entryInfoList(QDir::Files))
    {
        if (info.suffix().toLower() != "sky") continue;

        entries.append(info);
    }
}

void ControllerCore::renderItem(QPainter          & painter,
                                WDeclarativeImage * item,
                                const QRectF      & rect, qreal x, qreal y, qreal scale) const
{
    qreal itemX = item->x() * scale;
    qreal itemY = item->y() * scale;

    qreal sizeX = item->width () * scale;
    qreal sizeY = item->height() * scale;

    if (QRectF(itemX, itemY, sizeX, sizeY).intersects(rect) == false) return;

    painter.save();

    painter.setOpacity(item->opacity());

    QImage image(item->source());

    Qt::AspectRatioMode ratio = WDeclarativeImage::ratioFromFill(item->fillMode());

    image = image.scaled(qRound(sizeX),
                         qRound(sizeY), ratio, Qt::SmoothTransformation);

    qreal positionX = itemX - x;
    qreal positionY = itemY - y;

#ifdef QT_OLD
    painter.drawImage(QPoint(qRound(x), qRound(y)), image);
#else
    qreal rotation = item->rotation();

    if (rotation)
    {
        painter.translate(qRound(positionX), qRound(positionY));

#ifdef QT_5
        int rotateX = qRound(sizeX * 0.5);
        int rotateY = qRound(sizeY * 0.5);
#else
        QPointF origin = item->transformOriginPoint();

        int rotateX = qRound(origin.x() * scale);
        int rotateY = qRound(origin.y() * scale);
#endif

        painter.translate(rotateX, rotateY);

        painter.rotate(rotation);

        painter.translate(-rotateX, -rotateY);

        painter.drawImage(QPoint(0, 0), image);
    }
    else painter.drawImage(QPoint(positionX, positionY), image);

    painter.restore();
#endif
}

QString ControllerCore::getPathLocale(const QString & name) const
{
#ifdef SK_DEPLOY
    return "qrc:/locale/" + name + ".qm";
#else
    return "locale/" + name + ".qm";
#endif
}

//-------------------------------------------------------------------------------------------------
// Private slots
//-------------------------------------------------------------------------------------------------

void ControllerCore::onLoaded()
{
    createIndex();
}

void ControllerCore::onIndexLoaded()
{
    disconnect(_index, SIGNAL(loaded()), this, SLOT(onIndexLoaded()));

#if defined(SK_BACKEND_LOCAL) && defined(SK_DEPLOY) == false
    // NOTE: This makes sure that we have the latest local vbml loaded.
    resetBackends();

    // NOTE: We want to reload backends when the folder changes.
    _watcher.addFolder(WControllerFile::applicationPath(PATH_BACKEND));

    connect(&_watcher, SIGNAL(foldersModified(const QString &, const QStringList &)),
            this,      SLOT(resetBackends()));
#else
    _index->update();
#endif
}

void ControllerCore::onReload()
{
    if (_index == NULL) return;

    _index->clearCache();

    _index->reload();

    _index->reloadBackends();

    WBackendUniversal::clearCache();
}

void ControllerCore::onComplete(bool ok)
{
    WControllerFileReply * reply = static_cast<WControllerFileReply *> (sender());

    if (_replies.contains(reply) == false) return;

    ControllerCoreFile file = _replies.take(reply);

    if (ok == false) return;

    QString target = file.target;

    QFile::remove(target);

    WControllerFile::renameFile(file.origin, target);
}

void ControllerCore::onRecent(const QStringList & recents)
{
    _recents = recents;

    emit recentsChanged();
}

void ControllerCore::onFilesModified(const QString & path, const QStringList & fileNames)
{
    QStringList list;

    QString base = path + '/';

    foreach (const QString & name, fileNames)
    {
        list.append(base + name);
    }

    emit refresh(list);
}

void ControllerCore::onLocaleChanged()
{
    qApp->removeTranslator(_translator);

    QString path = getPathLocale(sk->locale());

    if (QFile::exists(path) && _translator->load(path))
    {
        qApp->installTranslator(_translator);
    }
}

//-------------------------------------------------------------------------------------------------
// Properties
//-------------------------------------------------------------------------------------------------

#ifdef SK_DESKTOP

QString ControllerCore::argument() const
{
    return _argument;
}

#endif

QString ControllerCore::source() const
{
    return _source;
}

void ControllerCore::setSource(const QString & source)
{
    // NOTE: fromNativeSeparators is important for fileBaseName.
    QString string = QDir::fromNativeSeparators(source);

    if (_source == string) return;

    _source = string;

    _watcher.clearFiles();

    if (_script)
    {
        _script->clear();
    }
    else _script = new DataScript(this);

    if (string.isEmpty() == false)
    {
        loadData(_script, QDir::fromNativeSeparators(string));

        saveRecent(string);

        _watcher.addFile(string);
    }

    emit sourceChanged();
}

QString ControllerCore::path() const
{
    return WControllerFile::folderPath(_source);
}

int ControllerCore::count() const
{
    if (_script)
    {
        return _script->count();
    }
    else return 0;
}

QString ControllerCore::name() const
{
    if (_script)
    {
        return _script->name();
    }
    else return tr("Sky runtime");
}

int ControllerCore::libraryCount() const
{
    return _library.count();
}

QStringList ControllerCore::recents() const
{
    return _recents;
}

#if defined(SK_DESKTOP) && defined(SK_CONSOLE) == false

bool ControllerCore::associateSky() const
{
    return (Sk::typeIsAssociated("sky") && Sk::typeIsAssociated("skz"));
}

void ControllerCore::setAssociateSky(bool associate)
{
    if (Sk::associateType("sky", associate) != associate) return;
    if (Sk::associateType("skz", associate) != associate) return;

    emit associateSkyChanged();
}

#endif

#include "ControllerCore.moc"
