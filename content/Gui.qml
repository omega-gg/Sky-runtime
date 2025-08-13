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
    id: gui

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    property bool ui: false

    property int showConsole: 0
    // 0: hidden
    // 1: visible
    // 2: expanded

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: window

        /* QML_CONNECTION */ function onKeyPressed (event) { gui.onKeyPressed (event) }
        /* QML_CONNECTION */ function onKeyReleased(event) { gui.onKeyReleased(event) }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function process(text)
    {
        console.debug("> " + text);

        var list = sk.splitCommand(text);

        var length = list.length;

        if (length == 0) return;

        if (list[0] == "help")
        {
            console.debug("Welcome to Sky kit runtime");

            return;
        }
    }

    function toggleConsole()
    {
        showConsole = (showConsole + 1) % 3;

        focusConsole();
    }

    function showHelp()
    {
        process("help");
    }

    function focusConsole()
    {
        if (showConsole == false) return;

        var item = loader.item;

        if (item) item.setFocus();
    }

    //---------------------------------------------------------------------------------------------
    // Keys

    function onKeyPressed(event)
    {
        if (event.key == Qt.Key_F1)
        {
            ui = !ui;
        }
    }

    function onKeyReleased(event)
    {
        if (event.isAutoRepeat) return;
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    TextBase
    {
        id: itemText

        anchors.centerIn: parent

        text: qsTr("Welcome to Sky kit")

        font.pixelSize: st.dp32
    }

    TextBase
    {
        anchors.top: itemText.bottom

        anchors.topMargin: st.dp16

        anchors.horizontalCenter: parent.horizontalCenter

        text: qsTr("Drop a .sky file to begin")

        color: st.text3_color

        font.pixelSize: st.dp20
    }

    TextBase
    {
        anchors.left: parent.left
        anchors.top : parent.top

        anchors.margins: st.dp8

        visible: (opacity != 0.0)

        opacity: (ui == false)

        text: qsTr("Press F1 for UI")

        color: st.text3_color

        font.pixelSize: st.dp16

        Behavior on opacity
        {
            PropertyAnimation
            {
                duration: st.duration_fast

                easing.type: st.easing
            }
        }
    }

    Item
    {
        anchors.fill: parent

        visible: (opacity != 0.0)
        opacity: (ui)

        Behavior on opacity
        {
            PropertyAnimation
            {
                duration: st.duration_fast

                easing.type: st.easing
            }
        }

        Loader
        {
            id: loader

            anchors.left  : parent.left
            anchors.right : parent.right
            anchors.bottom: parent.bottom

            height:
            {
                if (showConsole == 0)
                {
                    return 0;
                }
                else if (showConsole == 1)
                {
                    return Math.round(parent.height / 3)
                }
                else return parent.height - buttonsWindow.height
            }

            visible: (opacity != 0.0)

            opacity: (showConsole != 0)

            source: (visible) ? Qt.resolvedUrl("PageConsole.qml") : ""

            Behavior on opacity
            {
                PropertyAnimation
                {
                    duration: st.duration_fast

                    easing.type: st.easing
                }
            }

            onItemChanged: focusConsole()
        }

        ButtonPianoFull
        {
            anchors.right: buttonConsole.left

            borderLeft  : borderSize
            borderBottom: borderSize

            height: buttonsWindow.height

            padding: st.dp16

            text: qsTr("Help")

//#QT_4
            onPressed: showHelp()
//#ELSE
            onPressed: Qt.callLater(showHelp)
//#END
        }

        ButtonPianoFull
        {
            id: buttonConsole

            anchors.right: buttonsWindow.left

            anchors.rightMargin: st.dp16

            height: buttonsWindow.height

            borderBottom: borderSize

            padding: st.dp16

            checkable: true
            checked  : (showConsole != 0)

            text: qsTr("Console")

//#QT_4
            onPressed: toggleConsole()
//#ELSE
            onPressed: Qt.callLater(toggleConsole)
//#END
        }

        ButtonsWindow
        {
            id: buttonsWindow

            anchors.right: parent.right
        }
    }
}
