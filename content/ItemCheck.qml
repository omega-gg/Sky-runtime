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

Item
{
    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    property int stateCheck: 0
    // 0: StateDefault
    // 1: StateChecking
    // 2: StateInvalid
    // 3: StateWarning
    // 4: StateValid

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias text     : itemTitle.text
    property alias textState: itemState.text

    property alias itemTitle: itemTitle
    property alias itemState: itemState

    property alias buttonRefresh: buttonRefresh

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    height: st.dp48

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------
    // Events

    /* virtual */ function onGetState()
    {
        if (stateCheck == core.StateChecking)
        {
            return qsTr("Checking...");
        }
        else if (stateCheck == core.StateInvalid)
        {
            return qsTr("Invalid");
        }
        else if (stateCheck == core.StateIncomplete)
        {
            return qsTr("Incomplete");
        }
        else if (stateCheck == core.StateValid)
        {
            return qsTr("Valid");
        }
        else return qsTr("Default");
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    Rectangle
    {
        id: background

        anchors.fill: parent

        radius: st.dp8

        color: st.buttonPush_colorA
    }

    TextBase
    {
        id: itemTitle

        anchors.left: parent.left

        anchors.leftMargin: st.dp12

        anchors.verticalCenter: buttonRefresh.verticalCenter

        color: st.text3_color

        font.pixelSize: st.dp16
    }

    TextBase
    {
        id: itemState

        anchors.right: buttonRefresh.left

        anchors.rightMargin: st.dp8

        anchors.verticalCenter: buttonRefresh.verticalCenter

        text: onGetState()

        color: st.text3_color
    }

    ButtonPushIcon
    {
        id: buttonRefresh

        anchors.right: parent.right
        anchors.top  : parent.top

        anchors.margins: st.dp4

        radius: height

        icon          : st.icon_refresh
        iconSourceSize: st.size16x16
    }
}
