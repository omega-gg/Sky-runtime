//=================================================================================================
/*
    Copyright (C) 2015-2020 MotionBox authors united with omega. <http://omega.gg/about>

    Author: Benjamin Arnaud. <http://bunjee.me> <bunjee@omega.gg>

    This file is part of MotionBox.

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

#ifndef DATAONLINE_H
#define DATAONLINE_H

// Qt includes
#include <QObject>

// Forward declarations
class WRemoteData;

class DataOnline : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString version READ version NOTIFY dataChanged)

public:
    explicit DataOnline(QObject * parent = NULL);

public: // Interface
    Q_INVOKABLE void load();

protected: // Events
    /* virtual */ void timerEvent(QTimerEvent * event);

private: // Functions
    void loadFile();

    QString generateUrl(const QString & string) const;

private slots:
    void onLoaded(WRemoteData * data);

signals:
    void dataChanged();

public: // Properties
    QString version() const;

private: // Variables
    QString _version;

private:
    Q_DISABLE_COPY(DataOnline)

    friend class ControllerCore;
};

#endif // DATAONLINE_H
