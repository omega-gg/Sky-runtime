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

    property list<QtObject> objects: []

    property bool ui: false

    property int stateConsole: 1
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

    function loadScript(index)
    {
        var data = core.getData(index);

        var parent = getParent(index - 1);

        var root;

        if (parent)
        {
            if (parent.onPatch)
            {
                data = parent.onPatch(data, core.getVersion(index));
            }

            if (parent.getLoader)
            {
                root = parent.getLoader();
            }
            else root = loader;
        }
        else root = loader;

        var object = Qt.createQmlObject(data, root, Qt.resolvedUrl("Gui.qml"));

        object.anchors.fill = root;

        root.source = "";

        objects.push(object);
    }

    function load()
    {
        for (var i = 0; i < objects.length; i++)
        {
            objects[i].destroy();
        }

        objects = [];

        loader.source = "";

        var argument = core.argument;

        if (argument)
        {
            core.loadSource(argument);

            for (var i = 0; i < core.count; i++)
            {
                loadScript(i);
            }
        }
        else loader.source = Qt.resolvedUrl("PageDefault.qml");

        setFocus();

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
        else if (command == "reload")
        {
            /* var */ argument = core.argument;

            if (argument == "") return;

            core.argument = "";
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
        var object = getObjectHelp();

        if (object)
        {
            object.onHelp();

            return;
        }

        console.debug("Welcome to Sky kit runtime");
    }

    //---------------------------------------------------------------------------------------------

    function setFocus()
    {
        var object = getObject();

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

    function getObject()
    {
        var length = objects.length;

        if (length)
        {
            return objects[length - 1];
        }
        else return null;
    }

    function getObjectHelp()
    {
        for (var i = objects.length - 1; i >= 0; i--)
        {
            var object = objects[i];

            // NOTE: We check if the 'onHelp' function is defined.
            if (object && object.onHelp)
            {
                return object;
            }
        }

        return null;
    }

    function getParent(index)
    {
        if (index < 0 || index >= objects.length) return null;

        return objects[index];
    }

    //---------------------------------------------------------------------------------------------
    // Keys

    function onKeyPressed(event)
    {
        if (event.key == Qt.Key_twosuperior)
        {
            if (ui && stateConsole) return;

            event.accepted = true;

            ui = true;

            showConsole();

            setFocusConsole();
        }
        else if (event.key == Qt.Key_Tab || event.key == Qt.Key_Backtab)
        {
            event.accepted = true;

            setFocusConsole();
        }
        else if (event.key == Qt.Key_F1)
        {
            event.accepted = true;

            ui = !ui;

            setFocusConsole();
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

            source: (stateConsole != 0) ? Qt.resolvedUrl("PageConsole.qml") : ""

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
