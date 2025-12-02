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

    property variant objects: null

    property variant user: null

    /* read */ property bool ui: false

    property int stateConsole: 1
    // 0: hidden
    // 1: visible
    // 2: expanded

    property int topMargin: st.dp40

    property int popupMargin: st.dp32

    //---------------------------------------------------------------------------------------------
    // Private

    property bool pVersion: (online.version && online.version != sk.version)

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

//#QT_4
    Component.onCompleted: run(core.argument)
//#ELSE
    // NOTE: callLater seems required to avoid resizing freezes when calling a bash script.
    Component.onCompleted: Qt.callLater(run, core.argument)
//#END

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: core

        /* QML_CONNECTION */ function onRefresh(fileNames) { gui.onRefreshCheck(fileNames) }
    }

    Connections
    {
        target: window

        /* QML_CONNECTION */ function onKeyPressed (event) { gui.onKeyPressed (event) }
        /* QML_CONNECTION */ function onKeyReleased(event) { gui.onKeyReleased(event) }

        /* QML_CONNECTION */ function onDragEntered(event) { gui.onDragEntered(event) }
        /* QML_CONNECTION */ function onDragExited (event) { gui.onDragExited (event) }
        /* QML_CONNECTION */ function onDrop       (event) { gui.onDrop       (event) }

        /* QML_CONNECTION */ function onDragEnded() { gui.onDragEnded() }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------
    // Interface

    function run(source)
    {
        if (ui)
        {
            // NOTE: Avoid opacity animations when hiding the ui before loading.

            st.animate = false;

            hideUi();

            st.animate = true;
        }

        if (objects)
        {
            for (var i = 0; i < objects.length; i++)
            {
                objects[i].destroy();
            }
        }

        objects = new Array;

        loader.source = "";

        if (core.fileIsArchive(source))
        {
            core.source = "";

            loader.source = Qt.resolvedUrl("PageDefault.qml");

            loader.item.install(source);
        }
        else
        {
            core.source = source;

            if (source)
            {
                for (/* var */ i = 0; i < core.count; i++)
                {
                    loadScript(i);
                }
            }
            else loader.source = Qt.resolvedUrl("PageDefault.qml");
        }

        setFocus();

        // NOTE: When it's a command line interface run we quit right away.
        if (sk.cli)
        {
            sk.quit();

            return;
        }

//#DEPLOY
        help();
//#ELSE
        // NOTE: Make sure we show the help after the loading messages in the console.
        timer.start();
//#END
    }

    function bash(fileName)
    {
        var args = new Array;

        for (var i = 1; i < arguments.length; ++i)
        {
            args.push(String(arguments[i]))
        }

        return core.bash(core.bashResolve(fileName), args);
    }

    function refresh()
    {
        var length = objects.length;

        if (length == 0) return;

        core.clearWatchers();

        var index = length - 1;

        core.reloadScript(index);

        objects[index].destroy();

        objects.pop();

        for (var i = 0; i < objects.length; i++)
        {
            var object = objects[i];

            if (object.onRefresh) object.onRefresh();
        }

        reloadScript(index);

        setFocus();
    }

    function reload()
    {
        var source = core.source;

        if (source == "") return;

        run("");
        run(source);
    }

    function unload()
    {
        run("");

        hideConsole();
    }

    function clear()
    {
        var item = loaderConsole.item;

        if (item) item.clear();
    }

    function help()
    {
        console.debug("-------\n" + onHelp());

        for (var i = 0; i < objects.length; i++)
        {
            var object = objects[i];

            // NOTE: We check if the 'onHelp' function is defined.
            if (object && object.onHelp)
            {
                console.debug("\n-------");

                console.debug(object.onHelp());
            }
        }
    }

    function exit()
    {
        window.close();
    }

    //---------------------------------------------------------------------------------------------

    function create(text)
    {
        var name = core.createScript(text);

        if (name) run(name);
    }

    function createObject(fileName)
    {
        var object;

        var data = controllerFile.readAll(fileName);

        try
        {
            object = Qt.createQmlObject(data, gui, Qt.resolvedUrl("Gui.qml"));
        }
        catch (error)
        {
            console.debug(error);
        }

        return object;
    }

    function loadScript(index)
    {
        var parent = getParent(index - 1);

        var object = loadObject(parent, index);

        if (object.onCreate) object.onCreate(parent);
        if (object.onRun)    object.onRun   (parent);
    }

    function reloadScript(index)
    {
        var parent = getParent(index - 1);

        var object = loadObject(parent, index);

        if (object.onRefresh) object.onRefresh(parent);
        if (object.onRun)     object.onRun    (parent);
    }

    function loadObject(parent, index)
    {
        var data = core.getData(index);

        var root;

        if (parent)
        {
            if (parent.onPatch)
            {
                data = parent.onPatch(data, core.getVersionParent(index));
            }

            if (parent.onLoader)
            {
                root = parent.onLoader();
            }
            else root = loader;
        }
        else root = loader;

        var object;

        try
        {
            object = Qt.createQmlObject(data, root, Qt.resolvedUrl("Gui.qml"));
        }
        catch (error)
        {
            console.debug(error);
        }

        if (object == null)
        {
            object = Qt.createQmlObject("import QtQuick 2.0; Item {}", root);
        }

        object.anchors.fill = root;

        root.source = "";

        objects.push(object);

        return object;
    }

    function loadObjects(objects, script, index)
    {
        var data = script.getData(index);

        var parent = getParent(index - 1);

        if (parent && parent.onPatch)
        {
            data = parent.onPatch(data, script.getVersionParent(index));
        }

        var object;

        try
        {
            object = Qt.createQmlObject(data, gui, Qt.resolvedUrl("Gui.qml"));
        }
        catch (error)
        {
            console.debug(error);
        }

        if (object == null)
        {
            object = Qt.createQmlObject("import QtQuick 2.0; Item {}", gui);
        }

        object.visible = false;

        objects.push(object);

        if (object.onRun) object.onRun(parent);
    }

    function process(text)
    {
        console.debug("> " + text);

        var list = sk.splitCommand(text);

        var length = list.length;

        if (length == 0) return;

        var command = list[0];

        if (command == "run")
        {
            if (length != 2) return;

            run(list[1]);
        }
        else if (command == "bash")
        {
            if (length < 2) return;

            var args = new Array;

            for (var i = 1; i < list.length; ++i)
            {
                args.push(String(list[i]));
            }

            bash.apply(this, args);
        }
        else if (command == "refresh")
        {
            refresh();
        }
        else if (command == "reload")
        {
            reload();
        }
        else if (command == "unload")
        {
            unload();
        }
        else if (command == "clear")
        {
            clear();
        }
        else if (command == "help")
        {
            help();
        }
        else if (command == "exit")
        {
            exit();
        }
        else
        {
            for (var i = 0; i < objects.length; i++)
            {
                var object = objects[i];

                if (object.onConsole && object.onConsole(list)) return;
            }

            console.debug(qsTr("sky: " + command + ": command not found"));
        }
    }

    //---------------------------------------------------------------------------------------------

    function showUi()
    {
        if (ui) return;

        ui = true;

        window.clearFocus();
    }

    function hideUi()
    {
        ui = false;
    }

    function toggleUi()
    {
        if (ui) hideUi();
        else    showUi();
    }

    function showConsole()
    {
        if (stateConsole != 0) return;

        stateConsole = 1;

        setFocusConsole();
    }

    function hideConsole()
    {
        stateConsole = 0;
    }

    function toggleConsole()
    {
        stateConsole = (stateConsole + 1) % 3;

        if (stateConsole == 0) return;

        setFocusConsole();
    }

    function toggleLocked()
    {
        window.locked = !(window.locked);
    }

    function openUrl(url)
    {
        url = controllerNetwork.generateScheme(url);

        Qt.openUrlExternally(controllerNetwork.encodedUrl(url));
    }

    function openFile(url)
    {
        Qt.openUrlExternally(controllerFile.fileUrl(url));
    }

    function setClipboard(text, description)
    {
        sk.setClipboardText(text);

        if (description) popup.showText(description);
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
        if (objects == null) return null;

        var length = objects.length;

        if (length)
        {
            return objects[length - 1];
        }
        else return null;
    }

    function getParent(index)
    {
        if (index < 0 || index >= objects.length) return null;

        return objects[index];
    }

    //---------------------------------------------------------------------------------------------
    // Events

    function onHelp()
    {
        return "Welcome to Sky kit runtime " + sk.versionSky + "\n\n" +
               "keyboard:\n" +
               "- F1           toggle the user inteface\n" +
               "- F5           refresh the top level script\n" +
               "- F11          switch to fullscreen\n" +
               "- Ctrl + F1    toggle and focus the console\n" +
               "- Ctrl + F5    reload everthing in cascade\n" +
               "- Ctrl + W     unload the current script\n" +
               "- Escape       quit the application\n" +
               "\n" +
               "console:\n" +
               "> run <source>           run a .sky source\n" +
               "> bash <source> <...>    run the bash script\n" +
               "> refresh                refresh the top level script\n" +
               "> reload                 reload everthing in cascade\n" +
               "> unload                 unload everthing\n" +
               "> clear                  clear the console\n" +
               "> help                   show the help\n" +
               "> exit                   quit the application\n" +
               "\n" +
               "api:\n" +
               "- void setClipboard(text, description)    set the clipboard";
    }

    function onRefreshCheck(fileNames)
    {
        for (var i = 0; i < objects.length; i++)
        {
            var object = objects[i];

            if (object.onRefreshCheck && object.onRefreshCheck(fileNames)) return;
        }

        refresh();
    }

    function onDragEntered(event)
    {
        event.accepted = true;

        bordersDrop.setItem(gui);
    }

    function onDragExited(event)
    {
        bordersDrop.clear();
    }

    function onDrop(event)
    {
        var text = event.text;

        console.debug("> load " + text);

        run(text);
    }

    function onDragEnded()
    {
        bordersDrop.clear();
    }

    //---------------------------------------------------------------------------------------------
    // Keys

    function onKeyPressed(event)
    {
        if (event.key == Qt.Key_Tab || event.key == Qt.Key_Backtab)
        {
            event.accepted = true;

            setFocusConsole();
        }
        else if (event.key == Qt.Key_F1)
        {
            event.accepted = true;

            if (event.modifiers == Qt.ControlModifier)
            {
                var item = loaderConsole.item;

                if (item && item.visible && item.isFocused)
                {
                    hideUi();

                    return;
                }

                event.accepted = true;

                ui = true;

                showConsole();

                setFocusConsole();
            }
            else toggleUi();
        }
        else if (event.key == Qt.Key_F5)
        {
            event.accepted = true;

            if (event.modifiers == Qt.ControlModifier)
            {
                reload();
            }
            else refresh();
        }
        else if (event.key == Qt.Key_W && event.modifiers == Qt.ControlModifier)
        {
            event.accepted = true;

            unload();
        }
//#!DEPLOY
        else if (event.key == Qt.Key_P && event.modifiers == Qt.ControlModifier)
        {
            event.accepted = true;

            pTakeShot();
        }
//#END
    }

    function onKeyReleased(event)
    {
        if (event.isAutoRepeat) return;
    }

//#!DEPLOY
    //---------------------------------------------------------------------------------------------
    // Dev

    function pTakeShot() // Desktop
    {
        var width = 1024;

        window.width  = width;
        window.height = width * 0.5625; // 16:9 ratio

        sk.wait(1000);

        var path = "../dist/pictures/Sky-runtime.png";

        window.saveShot(path);

        window.compressShot(path);
    }
//#END

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

//#!DEPLOY
    Timer
    {
        id: timer

        interval: 3000

        onTriggered: help()
    }
//#END

    Loader
    {
        id: loader

        anchors.fill: parent
    }

    ViewDrag
    {
        id: viewDrag

        anchors.left : parent.left
        anchors.right: parent.right

        height: topMargin

        dragEnabled: (window.fullScreen == false)

        // NOTE: Clear the focus to retrieve keyboard events from a WebView or else.
        onPressed: window.clearFocus()

        onDoubleClicked: toggleMaximized()
    }

    TextDefaultLink
    {
        anchors.left: parent.left
        anchors.top : parent.top

        text: (pVersion) ? qsTr("Update available")
                         : qsTr("Press F1 for UI")

        // NOTE: Since the text is fading out on press, we keep it underlined when pressed.
        font.underline: isHovered

        onClicked:
        {
            if (pVersion)
            {
                openUrl("https://omega.gg/Sky/get");
            }
            else toggleUi();
        }
    }

    TextDefaultLink
    {
        anchors.right: parent.right
        anchors.top  : parent.top

        text: qsTr("ESCAPE to quit")

        // NOTE: Since the text is fading out on press, we keep it underlined when pressed.
        font.underline: isHovered

        onClicked: window.close()
    }

    Item
    {
        id: itemUi

        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.top   : parent.top
        anchors.bottom: parent.bottom

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

        ButtonPiano
        {
            id: buttonApplication

            maximumWidth: (st.isTight) ? buttonConsole.x - st.dp16
                                       : buttonConsole.x - buttonEject.width - st.dp16

            borderBottom: borderSize

            checkable: true
            checked  : true

            text: core.name

            font.pixelSize: st.dp14

            onClicked: toggleUi()
        }

        ButtonPianoFull
        {
            id: buttonEject

            anchors.top : buttonApplication.top
            anchors.left: buttonApplication.right

            borderBottom: borderSize

            spacing: 0

            visible: (st.isTight == false)

            enabled: (core.source != "")

            icon          : st.icon_eject
            iconSourceSize: st.size12x12

            text: qsTr("Eject")

            onClicked: unload()
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
                else return parent.height - buttonApplication.height
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
        }

        ButtonPiano
        {
            id: buttonConsole

            anchors.right : buttonLock.left
            anchors.top   : buttonsWindow.top
            anchors.bottom: buttonsWindow.bottom

            anchors.rightMargin: st.dp16

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

        ButtonPianoWindow
        {
            id: buttonLock

            anchors.right : buttonsWindow.left
            anchors.top   : buttonsWindow.top
            anchors.bottom: buttonsWindow.bottom

            borderLeft  : borderSize
            borderRight : 0
            borderBottom: borderSize

            checkable: true
            checked  : window.locked

            icon          : st.icon_lock
            iconSourceSize: st.size12x12

            onPressed: toggleLocked()
        }

        ButtonsWindow
        {
            id: buttonsWindow

            anchors.right: parent.right

            buttonIconify.borderLeft: 0
        }
    }

    Popup
    {
        id: popup

        anchors.bottom: parent.bottom

        anchors.bottomMargin: popupMargin

        anchors.horizontalCenter: parent.horizontalCenter
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
