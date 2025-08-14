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
    // Events
    //---------------------------------------------------------------------------------------------

    Component.onCompleted: load()

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: core

        /* QML_CONNECTION */ function onArgumentChanged() { load() }
    }

    Connections
    {
        target: window

        /* QML_CONNECTION */ function onKeyPressed (event) { gui.onKeyPressed (event) }
        /* QML_CONNECTION */ function onKeyReleased(event) { gui.onKeyReleased(event) }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function load()
    {
        var argument = core.argument;

        if (argument)
        {
             loader.source = Qt.resolvedUrl(argument);
        }
        else loader.source = Qt.resolvedUrl("PageDefault.qml");

        loader.item.forceActiveFocus();
    }

    function process(text)
    {
        console.debug("> " + text);

        var list = sk.splitCommand(text);

        var length = list.length;

        if (length == 0) return;

        var command = list[0];

        if (command == "clear")
        {
            var item = loaderConsole.item;

            if (item) item.clear();
        }
        else if (command == "help")
        {
            var item = loader.item;

            // NOTE: We check if the 'showHelp' function is defined.
            if (item && item.showHelp)
            {
                item.showHelp();

                return;
            }

            console.debug("Welcome to Sky kit runtime");
        }
        else if (command == "exit")
        {
            window.close();
        }
    }

    function toggleConsole()
    {
        showConsole = (showConsole + 1) % 3;

        focusConsole();
    }

    function showHelp()
    {
        if (showConsole == 0) showConsole = 1;

        process("help");
    }

    function focusConsole()
    {
        if (showConsole == false) return;

        var item = loaderConsole.item;

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

    Loader
    {
        id: loader

        anchors.fill: parent
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
            id: loaderConsole

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

    RectangleBordersDrop
    {
        id: bordersDrop

        opacity: (visible)

        Behavior on opacity
        {
            PropertyAnimation
            {
                duration: st.duration_fast

                easing.type: st.easing
            }
        }
    }
}
