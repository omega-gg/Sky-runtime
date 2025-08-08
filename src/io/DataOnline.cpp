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

#include "DataOnline.h"

// Qt includes
#include <QXmlStreamReader>
#ifndef SK_DEPLOY
#include <QDir>
#endif

// Sk includes
#include <WControllerDownload>
#include <WControllerXml>

//-------------------------------------------------------------------------------------------------
// Static variables

static const QString ONLINE_PATH = "https://omega.gg/get/Sky-runtime/1.0.0/data.xml";

//-------------------------------------------------------------------------------------------------
// Ctor / dtor
//-------------------------------------------------------------------------------------------------

/* explicit */ DataOnline::DataOnline(QObject * parent) : QObject(parent) {}

//-------------------------------------------------------------------------------------------------
// Interface
//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void DataOnline::load()
{
#ifdef SK_DEPLOY
    loadFile();

    startTimer(3600000); // 1 hour
#endif
}

//-------------------------------------------------------------------------------------------------
// Events
//-------------------------------------------------------------------------------------------------

/* virtual */ void DataOnline::timerEvent(QTimerEvent *)
{
    loadFile();
}

//-------------------------------------------------------------------------------------------------
// Private functions
//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void DataOnline::loadFile()
{
    WRemoteData * data = wControllerDownload->getData(ONLINE_PATH, this);

    connect(data, SIGNAL(loaded(WRemoteData *)), this, SLOT(onLoaded(WRemoteData *)));
}

//-------------------------------------------------------------------------------------------------
// Private slots
//-------------------------------------------------------------------------------------------------

void DataOnline::onLoaded(WRemoteData * data)
{
    _version = QString();

    QXmlStreamReader stream(data->reply());

    while (stream.atEnd() == false)
    {
        QXmlStreamReader::TokenType type = stream.readNext();

        if (type != QXmlStreamReader::StartElement) continue;

        if (stream.name() == QString("version"))
        {
            _version = WControllerXml::readNextString(&stream);
        }
    }

    emit dataChanged();
}

//-------------------------------------------------------------------------------------------------
// Properties
//-------------------------------------------------------------------------------------------------

QString DataOnline::version() const
{
    return _version;
}
