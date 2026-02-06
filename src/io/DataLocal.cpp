//=================================================================================================
/*
    Copyright (C) 2015-2020 MotionBox authors united with omega. <http://omega.gg/about>

    Author: Benjamin Arnaud. <http://bunjee.me> <bunjee@omega.gg>

    This file is part of the Sky kit runtime.

    - GNU General Public License Usage:
    This file may be used under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation and appearing in the LICENSE.md file included in the packaging
    of this file. Please review the following information to ensure the GNU General Public License
    requirements will be met: https://www.gnu.org/licenses/gpl.html.

    - Private License Usage:
    MotionBox licensees holding valid private licenses may use this file in accordance with the
    private license agreement provided with the Software or, alternatively, in accordance with the
    terms contained in written agreement between you and MotionBox authors. For further information
    contact us at contact@omega.gg.
*/
//=================================================================================================

#include "DataLocal.h"

// Qt includes
#include <QXmlStreamWriter>
#include <QFile>

// Sk includes
#include <WControllerApplication>
#include <WControllerXml>
#include <WAbstractThreadAction>

//-------------------------------------------------------------------------------------------------
// Functions declarations

void DataLocal_patch(QString & data, const QString & api);

//-------------------------------------------------------------------------------------------------
// Static variables

// NOTE: Defaut streaming port for Sky-runtime.
static const int DATALOCAL_PORT = 8400;

// NOTE: Defaut broadcasting port.
static const int DATALOCAL_BROADCAST_PORT = 9400;

//=================================================================================================
// DataLocalWrite
//=================================================================================================

class DataLocalWrite : public WAbstractThreadAction
{
    Q_OBJECT

public:
    DataLocalWrite(DataLocal * data)
    {
        this->data = data;
    }

protected: // WAbstractThreadAction reimplementation
    /* virtual */ WAbstractThreadReply * createReply() const;

protected: // WAbstractThreadAction implementation
    /* virtual */ bool run();

public: // Variables
    DataLocal * data;

    QString path;

    QString name;
    QString version;

    QString locale;

    int style;

    bool vsync;

#ifndef SK_NO_TORRENT
    int torrentPort;

    int torrentConnections;

    int torrentUpload;
    int torrentDownload;

    int torrentCache;
#endif

    int broadcastPort;
};

//=================================================================================================
// DataLocalWrite
//=================================================================================================

/* virtual */ WAbstractThreadReply * DataLocalWrite::createReply() const
{
    return new WLocalObjectReplySave(data);
}

/* virtual */ bool DataLocalWrite::run()
{
    QFile file(path);

    if (file.open(QIODevice::WriteOnly) == false)
    {
        qWarning("DataLocalWrite::run: Failed to open file %s.", path.C_STR);

        return false;
    }

    QXmlStreamWriter stream(&file);

    stream.setAutoFormatting(true);

    stream.writeStartDocument();

    stream.writeStartElement(name);

    stream.writeTextElement("version", version);

    stream.writeTextElement("locale", locale);

    stream.writeTextElement("style", QString::number(style));

    stream.writeTextElement("vsync", QString::number(vsync));

#ifndef SK_NO_TORRENT
    stream.writeTextElement("torrentPort", QString::number(torrentPort));

    stream.writeTextElement("torrentConnections", QString::number(torrentConnections));

    stream.writeTextElement("torrentUpload",   QString::number(torrentUpload));
    stream.writeTextElement("torrentDownload", QString::number(torrentDownload));

    stream.writeTextElement("torrentCache", QString::number(torrentCache));
#endif

    stream.writeTextElement("broadcastPort", QString::number(broadcastPort));

    stream.writeEndElement(); // name

    stream.writeEndDocument();

    qDebug("DATA LOCAL SAVED");

    return true;
}

//=================================================================================================
// DataLocal
//=================================================================================================

/* explicit */ DataLocal::DataLocal(QObject * parent) : WLocalObject(parent)
{
    // NOTE: We default to night.
    _style = 0;

#ifdef QT_4
    _vsync = false;
#else
    // NOTE Qt5: Without vsync animations are messed up.
    _vsync = true;
#endif

#ifndef SK_NO_TORRENT
    _torrentPort = DATALOCAL_PORT;

    // FIXME: Let's try 400 because why not ?
    _torrentConnections = 400;

    _torrentUpload   = 0;
    _torrentDownload = 0;

    _torrentCache = 2000;
#endif

    _broadcastPort = DATALOCAL_BROADCAST_PORT;
}

//-------------------------------------------------------------------------------------------------
// WLocalObject reimplementation
//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE virtual */ bool DataLocal::load(bool)
{
    QString path = getFilePath();

    QFile file(path);

    if (file.exists() == false) return false;

    if (file.open(QIODevice::ReadOnly) == false)
    {
        qWarning("DataLocal::load: Failed to open file %s.", path.C_STR);

        return false;
    }

    return extract(file.readAll());
}

/* Q_INVOKABLE virtual */ QString DataLocal::getFilePath() const
{
    return getParentPath() + "/data.xml";
}

//-------------------------------------------------------------------------------------------------
// Protected WLocalObject reimplementation
//-------------------------------------------------------------------------------------------------

/* virtual */ WAbstractThreadAction * DataLocal::onSave(const QString & path)
{
    DataLocalWrite * action = new DataLocalWrite(this);

    action->path = path;

    action->name    = sk->name   ();
    action->version = sk->version();

    action->locale = _locale;

    action->style = _style;

    action->vsync = _vsync;

#ifndef SK_NO_TORRENT
    action->torrentPort = _torrentPort;

    action->torrentConnections = _torrentConnections;

    action->torrentUpload   = _torrentUpload;
    action->torrentDownload = _torrentDownload;

    action->torrentCache = _torrentCache;
#endif

    action->broadcastPort = _broadcastPort;

    return action;
}

//-------------------------------------------------------------------------------------------------
// Private functions
//-------------------------------------------------------------------------------------------------

bool DataLocal::extract(const QByteArray & array)
{
    QXmlStreamReader stream(array);

    //---------------------------------------------------------------------------------------------
    // version

    if (WControllerXml::readNextStartElement(&stream, "version") == false) return false;

    _version = WControllerXml::readNextString(&stream);

    if (Sk::versionIsHigher(sk->version(), _version))
    {
        QString content = array;

        DataLocal_patch(content, _version);

        return extract(content.toUtf8());
    }

    //---------------------------------------------------------------------------------------------
    // locale

    if (WControllerXml::readNextStartElement(&stream, "locale") == false) return false;

    _locale = WControllerXml::readNextString(&stream);

    //---------------------------------------------------------------------------------------------
    // style

    if (WControllerXml::readNextStartElement(&stream, "style") == false) return false;

    _style = WControllerXml::readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // vsync

    if (WControllerXml::readNextStartElement(&stream, "vsync") == false) return false;

    _vsync = WControllerXml::readNextInt(&stream);

#ifndef SK_NO_TORRENT
    //---------------------------------------------------------------------------------------------
    // torrentPort

    if (WControllerXml::readNextStartElement(&stream, "torrentPort") == false) return false;

    _torrentPort = WControllerXml::readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // torrentConnections

    if (WControllerXml::readNextStartElement(&stream, "torrentConnections") == false) return false;

    _torrentConnections = WControllerXml::readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // torrentUpload

    if (WControllerXml::readNextStartElement(&stream, "torrentUpload") == false) return false;

    _torrentUpload = WControllerXml::readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // torrentDownload

    if (WControllerXml::readNextStartElement(&stream, "torrentDownload") == false) return false;

    _torrentDownload = WControllerXml::readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // torrentCache

    if (WControllerXml::readNextStartElement(&stream, "torrentCache") == false) return false;

    _torrentCache = WControllerXml::readNextInt(&stream);
#endif

    //---------------------------------------------------------------------------------------------
    // broadcastPort

    if (WControllerXml::readNextStartElement(&stream, "broadcastPort") == false) return false;

    _broadcastPort = WControllerXml::readNextInt(&stream);

    qDebug("DATA LOCAL LOADED");

    return true;
}

//-------------------------------------------------------------------------------------------------
// Properties
//-------------------------------------------------------------------------------------------------

QString DataLocal::locale() const
{
    return _locale;
}

void DataLocal::setLocale(const QString & name)
{
    if (_locale == name) return;

    _locale = name;

    emit localeChanged();

    save();
}

int DataLocal::style() const
{
    return _style;
}

void DataLocal::setStyle(int style)
{
    _style = style;

    emit styleChanged();

    save();
}

bool DataLocal::vsync() const
{
    return _vsync;
}

void DataLocal::setVsync(bool enabled)
{
    if (_vsync == enabled) return;

    _vsync = enabled;

    emit vsyncChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

#ifndef SK_NO_TORRENT

int DataLocal::torrentPort() const
{
    return _torrentPort;
}

void DataLocal::setTorrentPort(int port)
{
    if (_torrentPort == port) return;

    _torrentPort = port;

    emit torrentPortChanged();

    save();
}

int DataLocal::torrentConnections() const
{
    return _torrentConnections;
}

void DataLocal::setTorrentConnections(int connections)
{
    if (_torrentConnections == connections) return;

    _torrentConnections = connections;

    emit torrentConnectionsChanged();

    save();
}

int DataLocal::torrentUpload() const
{
    return _torrentUpload;
}

void DataLocal::setTorrentUpload(int upload)
{
    if (_torrentUpload == upload) return;

    _torrentUpload = upload;

    emit torrentUploadChanged();

    save();
}

int DataLocal::torrentDownload() const
{
    return _torrentDownload;
}

void DataLocal::setTorrentDownload(int download)
{
    if (_torrentDownload == download) return;

    _torrentDownload = download;

    emit torrentDownloadChanged();

    save();
}

int DataLocal::torrentCache() const
{
    return _torrentCache;
}

void DataLocal::setTorrentCache(int cache)
{
    if (_torrentCache == cache) return;

    _torrentCache = cache;

    emit torrentCacheChanged();

    save();
}

#endif // SK_NO_TORRENT

//-------------------------------------------------------------------------------------------------

int DataLocal::broadcastPort() const
{
    return _broadcastPort;
}

void DataLocal::setBroadcastPort(int port)
{
    if (_broadcastPort == port) return;

    _broadcastPort = port;

    emit broadcastPortChanged();

    save();
}

#include "DataLocal.moc"
