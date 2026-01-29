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

    /* read */ property bool hasRecent: false

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    Component.onCompleted: core.loadRecent()

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: core

        /* QML_CONNECTION */ function onRecentsChanged() { pUpdateRecent() }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
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

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    Item
    {
        anchors.left : parent.left
        anchors.right: parent.right

        anchors.verticalCenter: parent.verticalCenter

        height: buttonBrowse.y + buttonBrowse.height

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

        RowRecent
        {
            id: rowA

            anchors.top: row.bottom

            anchors.topMargin: st.dp32

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

        ButtonPiano
        {
            id: buttonBrowse

            anchors.top: (hasRecent) ? rowB.bottom
                                     : row.bottom

            anchors.topMargin: st.dp16

            anchors.horizontalCenter: parent.horizontalCenter

            width : st.dp192
            height: st.dp48

            borderSize: 0

            text: qsTr("Browse .sky")

            background.radius: st.dp8

            font.pixelSize: st.dp16

            onClicked: pageDefault.page = 1
        }
    }
}
