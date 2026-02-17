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
    id: itemCheck

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool isCheckable: (script != ""
                                           &&
                                           stateCheck != ControllerCore.StateChecking)

    property bool autoCheck: true

    property int stateCheck: 0
    // 0: StateDefault
    // 1: StateChecking
    // 2: StateInvalid
    // 3: StateWarning
    // 4: StateValid

    property string script

    property int scriptId: -1

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias text     : itemTitle.text
    property alias textState: itemState.text

    property alias itemTitle: itemTitle
    property alias itemColor: itemColor
    property alias itemState: itemState

    property alias buttonCheck: buttonCheck

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    height: st.dp48

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    Component.onCompleted: if (autoCheck) check()

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: core

        /* QML_CONNECTION */ function onBashFinished(result)
        {
            itemCheck.onBashFinished(result);
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function check()
    {
        if (isCheckable == false) return;

        stateCheck = ControllerCore.StateChecking;

        onCheck();
    }

    //---------------------------------------------------------------------------------------------
    // Events

    /* virtual */ function onCheck()
    {
        if (scriptId != -1)
        {
            core.bashStop(scriptId);
        }

        scriptId = core.bashAsync(core.resolveBash(script)).id;
    }

    /* virtual */ function onGetState()
    {
        if (stateCheck == ControllerCore.StateChecking)
        {
            return qsTr("Checking");
        }
        else if (stateCheck == ControllerCore.StateInvalid)
        {
            return qsTr("Invalid");
        }
        else if (stateCheck == ControllerCore.StateIncomplete)
        {
            return qsTr("Incomplete");
        }
        else if (stateCheck == ControllerCore.StateValid)
        {
            return qsTr("Valid");
        }
        else return qsTr("Default");
    }

    /* virtual */ function onGetColor()
    {
        if (stateCheck == ControllerCore.StateInvalid)
        {
            return "#c80000";
        }
        else if (stateCheck == ControllerCore.StateIncomplete)
        {
            return "#c86400";
        }
        else if (stateCheck == ControllerCore.StateValid)
        {
            return "#00c800";
        }
        else return st.text3_color;
    }

    /* virtual */ function onBashFinished(result)
    {
        if (result.id != scriptId) return;

        scriptId = -1;

        onBashCheck(result);
    }

    /* virtual */ function onBashCheck(result)
    {
        if (result.ok) stateCheck = ControllerCore.StateValid;
        else           stateCheck = ControllerCore.StateInvalid;
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

        anchors.left : parent.left
        anchors.right: itemColor.left

        anchors.leftMargin: st.dp12

        anchors.verticalCenter: buttonCheck.verticalCenter

        color: st.text3_color

        font.pixelSize: st.dp16
    }

    Rectangle
    {
        id: itemColor

        anchors.right: itemState.left

        anchors.rightMargin: st.dp8

        anchors.verticalCenter: buttonCheck.verticalCenter

        width : st.dp8
        height: width

        radius: height

        color: onGetColor()
    }

    TextBase
    {
        id: itemState

        anchors.right: buttonCheck.left

        anchors.rightMargin: st.dp8

        anchors.verticalCenter: buttonCheck.verticalCenter

        text: onGetState()

        color: st.text3_color
    }

    ButtonPushIcon
    {
        id: buttonCheck

        anchors.right: parent.right
        anchors.top  : parent.top

        anchors.margins: st.dp4

        radius: height

        enabled: isCheckable

        icon          : st.icon_refresh
        iconSourceSize: st.size16x16

        onClicked: check()
    }
}
