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

#ifndef DATASCRIPT_H
#define DATASCRIPT_H

// Qt includes
#include <QObject>

//-------------------------------------------------------------------------------------------------
// DataScriptItem
//-------------------------------------------------------------------------------------------------

struct DataScriptItem
{
    QString fileName;
    QString fileLocale;

    QString version;
    QString versionParent;

    QByteArray data;
};

//-------------------------------------------------------------------------------------------------
// DataScript
//-------------------------------------------------------------------------------------------------

class DataScript : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit DataScript(QObject * parent = NULL);

public: // Interface
    Q_INVOKABLE void append (struct DataScriptItem & item);
    Q_INVOKABLE void prepend(struct DataScriptItem & item);

    Q_INVOKABLE void reload(int index);

    Q_INVOKABLE void clear();

    Q_INVOKABLE QString getName(int index) const;

    Q_INVOKABLE QString getVersion      (int index) const;
    Q_INVOKABLE QString getVersionParent(int index) const;

    Q_INVOKABLE QByteArray getData(int index) const;

    Q_INVOKABLE QStringList getLocaleFiles() const;

    Q_INVOKABLE void deleteNow();

signals:
    void countChanged();

public: // Properties
    int count() const;

    QString name() const;

private: // Variables
    QList<DataScriptItem> _items;

private:
    Q_DISABLE_COPY(DataScript)
};

#endif // DATASCRIPT_H
