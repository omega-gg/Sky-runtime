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

#ifndef CONTROLLERCORE_H
#define CONTROLLERCORE_H

// Qt includes
#include <QImage>

// Sk includes
#include <WController>
#include <WFileWatcher>

// Application includes
#include <DataLocal>

// Defines
#define core ControllerCore::instance()

#ifdef QT_4
typedef QDeclarativeItem QQuickItem;
#endif

// Forward declarations
class QQuickItem;
class WControllerFileReply;
class WWindow;
class WCache;
class WScriptBash;
class WBackendIndex;
class WDeclarativeImage;
class WDeclarativePlayer;
class DataOnline;
class DataScript;

//-------------------------------------------------------------------------------------------------
// ControllerCoreItem
//-------------------------------------------------------------------------------------------------

struct ControllerCoreItem
{
    QString fileName;
    QString name;
};

//-------------------------------------------------------------------------------------------------
// ControllerCoreFile
//-------------------------------------------------------------------------------------------------

struct ControllerCoreFile
{
    QString origin;
    QString target;
};

//-------------------------------------------------------------------------------------------------
// ControllerCore
//-------------------------------------------------------------------------------------------------

class ControllerCore : public WController
{
    Q_OBJECT

#ifdef SK_DESKTOP
    Q_PROPERTY(QString argument READ argument CONSTANT)
#endif

    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)

    Q_PROPERTY(QString path READ path NOTIFY sourceChanged)

    Q_PROPERTY(int count READ count NOTIFY sourceChanged)

    Q_PROPERTY(QString name READ name NOTIFY sourceChanged)

    Q_PROPERTY(int libraryCount READ libraryCount NOTIFY libraryLoaded)

#if defined(SK_DESKTOP) && defined(SK_CONSOLE) == false
    Q_PROPERTY(bool associateSky READ associateSky WRITE setAssociateSky
               NOTIFY associateSkyChanged)
#endif

private:
    ControllerCore();

public: // Interface
#ifdef SK_DESKTOP
    Q_INVOKABLE void applyArguments(int & argc, char ** argv);
#endif

    Q_INVOKABLE void load();

    Q_INVOKABLE DataScript * loadScript(const QString & fileName);

    Q_INVOKABLE void loadLibrary();

    Q_INVOKABLE void reloadScript(int index);

    Q_INVOKABLE bool bash(const QString & fileName, const QStringList & arguments = QStringList());

    Q_INVOKABLE QString bashResolve(const QString & source) const;

    Q_INVOKABLE bool render(const QString      & name,
                            const QVariantList & objects,
                            int                  width,
                            int                  height,
                            qreal                x,
                            qreal                y,
                            qreal                scale,
                            qreal                upscale      = 1.0,
                            bool                 asynchronous = true,
                            const QColor       & background   = Qt::white);

    Q_INVOKABLE bool saveImage(const QString & name,
                               const QImage  & image, bool asynchronous = true);

    Q_INVOKABLE bool saveShot(const QString & name,
                              WWindow       * window, bool asynchronous = true);
#ifdef QT_4
    Q_INVOKABLE bool saveItemShot(const QString   & name,
                                  QGraphicsObject * item, bool asynchronous = true);
#else
    Q_INVOKABLE bool saveItemShot(const QString & name,
                                  QQuickItem    * item, bool asynchronous = true);
#endif

    Q_INVOKABLE bool saveFrame(const QString      & name,
                               WDeclarativePlayer * player, bool asynchronous = true);

    Q_INVOKABLE void updateBackends() const;
    Q_INVOKABLE void resetBackends () const;

    Q_INVOKABLE void clearComponentCache() const;

    Q_INVOKABLE void clearScripts();

    Q_INVOKABLE void addWatcher(const QString & fileName);

    Q_INVOKABLE void clearWatchers();

    Q_INVOKABLE QString getName(int index) const;

    Q_INVOKABLE QString getVersion      (int index) const;
    Q_INVOKABLE QString getVersionParent(int index) const;

    Q_INVOKABLE QByteArray getData(int index) const;

    Q_INVOKABLE QStringList getLibraryNames() const;

    Q_INVOKABLE QString getLibraryFileName(int index) const;
    Q_INVOKABLE QString getLibraryPath    (int index) const;
    Q_INVOKABLE QString getLibraryName    (int index) const;

public: // Static functions
    Q_INVOKABLE static QString createScript(const QString & text);

    Q_INVOKABLE static QQuickItem * pickItem(const QVariantList & objects, qreal x, qreal y);

#ifndef SK_NO_TORRENT
    Q_INVOKABLE static void applyTorrentOptions(int connections,
                                                int upload, int download, int cache);
#endif

    Q_INVOKABLE static void applyBackend(WDeclarativePlayer * player);

    Q_INVOKABLE static QImage generateTagSource(const QString & source);
    Q_INVOKABLE static QImage generateTagPath  (const QString & path);

    Q_INVOKABLE static bool renameFile(const QString & oldPath, const QString & newPath);

private: // Functions
    bool createPath(const QString & path) const;

    void createIndex();

    WControllerFileReply * copyBackends(const QString & path) const;
    WControllerFileReply * copyScripts (const QString & path) const;
    WControllerFileReply * copyBash    (const QString & path) const;

    void loadData(DataScript * script, const QString & fileName);

    void loadScripts(const QString & path);

private slots:
    void onLoaded     ();
    void onIndexLoaded();

    void onReload();

    void onComplete(bool ok);

    void onFilesModified(const QString & path, const QStringList & fileNames);

signals:
    void libraryLoaded();

    void refresh(const QStringList & fileNames);

    void sourceChanged();

    void scriptsChanged();

#if defined(SK_DESKTOP) && defined(SK_CONSOLE) == false
    void associateSkyChanged();
#endif

public: // Properties
#ifdef SK_DESKTOP
    QString argument() const;
#endif

    QString source() const;
    void    setSource(const QString & source);

    QString path() const;

    int count() const;

    QString name() const;

    int libraryCount() const;

#if defined(SK_DESKTOP) && defined(SK_CONSOLE) == false
    bool associateSky   () const;
    void setAssociateSky(bool associate);
#endif

private: // Variables
    QString _argument;

    QString _source;

    DataLocal    _local;
    DataOnline * _online;
    DataScript * _script;

    WCache * _cache;

    QString _path;

    WBackendIndex * _index;

    WScriptBash * _bash;

    QList<ControllerCoreItem> _library;

    QHash<WControllerFileReply *, ControllerCoreFile> _replies;

    WFileWatcher _watcher;

private:
    Q_DISABLE_COPY      (ControllerCore)
    W_DECLARE_CONTROLLER(ControllerCore)
};

#endif // CONTROLLERCORE_H
