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

import QtQuick 1.0
import Sky     1.0

Row
{
    id: rowCheck

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* mandatory */ property ItemCheck itemCheck

    property int size: width

    property int margins: st.dp8

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias buttonInstall: buttonInstall

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.margins: margins

    height: st.dp32 + margins

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: itemCheck

        /* QML_CONNECTION */ function onStateCheckChanged()
        {
            if (itemCheck.isValid)
            {
                buttonInstall.text = qsTr("Remove");
            }
            else if (itemCheck.isInvalid)
            {
                buttonInstall.text = qsTr("Install");
            }
        }
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    ButtonPush
    {
        id: buttonInstall

        width: rowCheck.size

        enabled: itemCheck.isReady

        text: qsTr("Install")

        onClicked:
        {
            if (itemCheck.isValid) itemCheck.remove ();
            else                   itemCheck.install();
        }
    }
}
