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

    property QtObject object

    property bool ui: false

    property int stateConsole: 0
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
        if (object)
        {
            object.destroy();

            object = null;
        }

        var argument = core.argument;

        if (argument)
        {
            console.debug("LOADING " + argument);

            var data = controllerFile.readAll(argument);

            // PATCH

            object = Qt.createQmlObject(data, loader, Qt.resolvedUrl("Gui.qml"));

            if (object)
            {
                object.anchors.fill = loader;

                loader.source = "";

                object.forceActiveFocus();

                showHelp();

                return;
            }
        }

        loader.source = Qt.resolvedUrl("PageDefault.qml");

        loader.item.forceActiveFocus();

        showHelp();
    }

    function process(text)
    {
        console.debug("> " + text);

        var list = sk.splitCommand(text);

        var length = list.length;

        if (length == 0) return;

        var command = list[0];

        if (command == "load")
        {
            var argument = list[1];

            if (argument == "") return;

            core.argument = argument;
        }
        else if (command == "unload")
        {
            core.argument = "";
        }
        else if (command == "clear")
        {
            var item = loaderConsole.item;

            if (item) item.clear();
        }
        else if (command == "help")
        {
            showHelp();
        }
        else if (command == "exit")
        {
            window.close();
        }
    }

    function showConsole()
    {
        if (stateConsole == 0) stateConsole = 1;
    }

    function toggleConsole()
    {
        stateConsole = (stateConsole + 1) % 3;

        setFocusConsole();
    }

    function showHelp()
    {
        showConsole();

        // NOTE: We check if the 'showHelp' function is defined.
        if (object && object.showHelp)
        {
            object.showHelp();

            return;
        }

        console.debug("Welcome to Sky kit runtime");
    }

    //---------------------------------------------------------------------------------------------

    function setFocus()
    {
        if (object)
        {
            object.forceActiveFocus();

            return;
        }

        var item = loader.item;

        if (item) item.forceActiveFocus();
    }

    function setFocusConsole()
    {
        if (stateConsole == 0) return;

        var item = loaderConsole.item;

        if (item) item.setFocus();
    }

    //---------------------------------------------------------------------------------------------
    // Keys

    function onKeyPressed(event)
    {
        if (event.key == Qt.Key_twosuperior)
        {
            ui = true;

            showConsole();

            setFocusConsole();
        }
        else if (event.key == Qt.Key_Tab || event.key == Qt.Key_Backtab)
        {
            setFocusConsole();
        }
        else if (event.key == Qt.Key_F1)
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

    TextDefault
    {
        anchors.left: parent.left
        anchors.top : parent.top

        text: qsTr("Press F1 for UI")
    }

    TextDefault
    {
        anchors.right: parent.right
        anchors.top  : parent.top

        text: qsTr("ESCAPE to quit")
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
                if (stateConsole == 0)
                {
                    return 0;
                }
                else if (stateConsole == 1)
                {
                    return Math.round(parent.height / 3)
                }
                else return parent.height - buttonsWindow.height
            }

            visible: (opacity != 0.0)

            opacity: (stateConsole != 0)

            source: (visible) ? Qt.resolvedUrl("PageConsole.qml") : ""

            Behavior on opacity
            {
                PropertyAnimation
                {
                    duration: st.duration_fast

                    easing.type: st.easing
                }
            }

            onItemChanged: setFocusConsole()
        }

        ButtonPianoFull
        {
            id: buttonConsole

            anchors.right: buttonsWindow.left

            anchors.rightMargin: st.dp16

            height: buttonsWindow.height

            borderLeft  : borderSize
            borderBottom: borderSize

            padding: st.dp16

            checkable: true
            checked  : (stateConsole != 0)

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
