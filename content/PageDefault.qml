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
    id: pageDefault

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool hasRecent: false

    /* read */ property string template
    /* read */ property string help

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias currentIndex: list.currentIndex

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    Component.onCompleted:
    {
        updateLibrary();

        core.loadRecent();

//#DESKTOP+!LINUX
//#WINDOWS
        if (sk.isUwp || core.associateSky) return;
//#ELSE
        if (core.associateSky) return;
//#END

        areaPanel.showPanel("PanelAssociate.qml");
//#END
    }

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: core

        /* QML_CONNECTION */ function onSourceChanged() { updateLibrary() }

        /* QML_CONNECTION */ function onRecentsChanged() { pUpdateRecent() }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function updateLibrary()
    {
        model.clear();

        core.loadLibrary();

        var array = new Array;

        var scripts = core.getLibraryNames();

        for (var i = 0; i < scripts.length; i++)
        {
            array.push({ "title": scripts[i] });
        }

//#QT_4
        // NOTE Qt4: We can only append items one by one.
        for (/* var */ i = 0; i < array.length; i++)
        {
            model.append(array[i]);
        }
//#ELSE
        // NOTE: It's probably better to append everything at once.
        model.append(array);
//#END

        list.currentIndex = 0;
    }

    function install(fileName)
    {
        areaPanel.showPanel("PanelInstall.qml", false);

        areaPanel.loader.item.check(fileName);
    }

    function openScript()
    {
        var fileName = core.openScript();

        if (fileName == "") return;

        gui.run(fileName);
    }

    function getTemplate(name)
    {
        return "// " + name + "\n" +
               "\n" +
               "import QtQuick 2.0\n" +
               "import Sky     1.0\n\n" +
               "Item\n" +
               "{\n" +
               "    function onRun(ui) {}\n"+
               "}\n"
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pUpdateRecent()
    {
        var recents = core.recents;

        pApplyRow(rowA, recents, 0);
        pApplyRow(rowB, recents, 4);

        hasRecent = (recents.length);
    }

    function pApplyRow(row, recents, index)
    {
        for (var i = 0; index < recents.length && i < 4; i++)
        {
            var item = row.repeater.itemAt(i);

            item.text = controllerFile.fileBaseName(recents[index]);

            item.enabled = true;

            index++;
        }
    }

    function pApplyPage(index)
    {
        template = "";
        help     = "";

        if (index == -1) return;

        if (index == 0)
        {
            var name = "sky " + sk.versionSky;

            template = getTemplate(name);

            help = gui.onHelp();

            return;
        }

        var fileName = core.getLibraryFileName(index);

        var script = core.loadScript(fileName);

        if (script == null) return;

        var count = script.count;

        var objects = new Array;

        for (var i = 0; i < script.count; i++)
        {
            gui.loadObjects(objects, script, i);
        }

        if (objects.length != count)
        {
            script.deleteNow();

            return;
        }

        index = script.count - 1;

        var object = objects[count - 1];

        if (object.onTemplate == undefined)
        {
            /* var */ name = script.getName(index) + " " + script.getVersion(index);

            template = getTemplate(name);
        }
        else template = object.onTemplate();

        if (object.onHelp) help = object.onHelp();

        for (/* var */ i = 0; i < objects.length; i++)
        {
            objects[i].destroy();
        }

        script.deleteNow();
    }

    function pGetSource()
    {
        if (currentIndex == -1)
        {
            return "";
        }
        else if (currentIndex == 0)
        {
            return Qt.resolvedUrl("PageScriptDefault.qml");
        }
        else return Qt.resolvedUrl("PageScript.qml");
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    Item
    {
        id: itemTitle

        anchors.centerIn: parent

        width: row.width

        height: row.y + row.height

        TextBase
        {
            id: itemText

            anchors.horizontalCenter: parent.horizontalCenter

            text: qsTr("Welcome to Sky kit")

            font.pixelSize: st.dp32
        }

        Row
        {
            id: row

            anchors.top: itemText.bottom

            anchors.topMargin: st.dp16

            anchors.horizontalCenter: parent.horizontalCenter

            spacing: st.dp6

            TextBase
            {
                text: qsTr("Drop or")

                color: st.text3_color

                font.pixelSize: st.dp20
            }

            TextLink
            {
                text: qsTr("open")

                font.pixelSize: st.dp20

                onClicked: openScript()
            }

            TextBase
            {
                id: itemTextDrop

                text: qsTr("a .sky file")

                color: st.text3_color

                font.pixelSize: st.dp20
            }
        }
    }

    RowRecent
    {
        id: rowA

        anchors.top: itemTitle.bottom

        anchors.topMargin: st.dp48

        anchors.horizontalCenter: parent.horizontalCenter

        visible: hasRecent

        function onClick(index) { gui.run(core.recents[index]) }
    }

    RowRecent
    {
        id: rowB

        anchors.top: rowA.bottom

        anchors.topMargin: st.dp8

        anchors.horizontalCenter: parent.horizontalCenter

        visible: hasRecent

        function onClick(index) { gui.run(core.recents[4 + index]) }
    }

    ItemUi
    {
        Rectangle
        {
            anchors.fill: list

            opacity: 0.9

            color: "#161616"
        }

        ScrollList
        {
            id: list

            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            width: st.dp256

            model: ListModel { id: model }

            delegate: ComponentList
            {
                function onPress() { list.currentIndex = index }
            }

            onCurrentIndexChanged: pApplyPage(currentIndex)
        }

        BorderHorizontal
        {
            id: borderA

            anchors.left  : list.left
            anchors.right : list.right
            anchors.bottom: list.top
        }

        BorderVertical
        {
            id: borderB

            anchors.left  : list.right
            anchors.top   : list.top
            anchors.bottom: list.bottom
        }

        Loader
        {
            id: loader

            anchors.left  : borderB.right
            anchors.right : parent.right
            anchors.top   : borderA.top
            anchors.bottom: list.bottom

            source: pGetSource()
        }
    }

    AreaPanel
    {
        id: areaPanel

        anchors.fill: parent

        marginTop: st.dp48
    }
}
