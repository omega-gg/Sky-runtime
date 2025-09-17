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

#include "DataScript.h"

// Sk includes
#include <WControllerFile>

//-------------------------------------------------------------------------------------------------
// Ctor / dtor
//-------------------------------------------------------------------------------------------------

/* explicit */ DataScript::DataScript(QObject * parent) : QObject(parent) {}

//-------------------------------------------------------------------------------------------------
// Interface
//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void DataScript::append(struct DataScriptItem & item)
{
    _items.append(item);

    emit countChanged();
}

/* Q_INVOKABLE */ void DataScript::prepend(struct DataScriptItem & item)
{
    _items.prepend(item);

    emit countChanged();
}

/* Q_INVOKABLE */ void DataScript::reload(int index)
{
    if (index < 0 || index >= count()) return;

    DataScriptItem & item = _items[index];

    item.data = WControllerFile::readAll(item.fileName);
}

/* Q_INVOKABLE */ void DataScript::clear()
{
    _items.clear();

    emit countChanged();
}
//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ QString DataScript::getName(int index) const
{
    if (index < 0 || index >= count()) return QString();

    QString fileName = _items.at(index).fileName.toLower();

    return WControllerFile::fileBaseName(fileName);
}

/* Q_INVOKABLE */ QString DataScript::getVersion(int index) const
{
    if (index < 0 || index >= count()) return QString();

    return _items.at(index).version;
}

/* Q_INVOKABLE */ QString DataScript::getVersionParent(int index) const
{
    if (index < 0 || index >= count()) return QString();

    return _items.at(index).versionParent;
}

/* Q_INVOKABLE */ QByteArray DataScript::getData(int index) const
{
    if (index < 0 || index >= count()) return QByteArray();

    return _items.at(index).data;
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void DataScript::deleteNow()
{
    delete this;
}

//-------------------------------------------------------------------------------------------------
// Properties
//-------------------------------------------------------------------------------------------------

int DataScript::count() const
{
    return _items.count();
}

QString DataScript::name() const
{
    QString name = getName(count() - 1);

    if (name.isEmpty())
    {
        return tr("Sky runtime");
    }
    else return name;
}
