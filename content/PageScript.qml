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
    // Children
    //---------------------------------------------------------------------------------------------

    Rectangle
    {
        anchors.fill: parent

        opacity: 0.9

        color: "#242424"
    }

    ColumnScroll
    {
        anchors.fill: parent

        column.padding: st.dp16
        column.spacing: st.dp16

        TextBase
        {
            id: itemTitle

            anchors.left : parent.left
            anchors.right: parent.right

            anchors.margins: st.dp16

            text: core.getLibraryName(currentIndex)

            font.pixelSize: st.dp32
        }

        Item
        {
            anchors.left : parent.left
            anchors.right: parent.right

            anchors.margins: st.dp16

            height: buttonNew.height

            ButtonPiano
            {
                id: buttonNew

                borderLeft  : borderSize
                borderBottom: borderSize

                padding: st.dp16

                text: qsTr("New .sky")

                onClicked: gui.create(template)
            }

            ButtonPiano
            {
                id: buttonRun

                anchors.left: buttonNew.right

                anchors.leftMargin: st.dp16

                borderLeft  : borderSize
                borderBottom: borderSize

                padding: st.dp16

                // NOTE: We hide this for the default sky script.
                visible: (currentIndex != 0)

                text: qsTr("Run script")

                onClicked: gui.run(core.getLibraryFileName(currentIndex))
            }

            ButtonPiano
            {
                anchors.left: buttonRun.right
                anchors.top : buttonRun.top

                borderBottom: borderSize

                padding: st.dp16

                visible: buttonRun.visible

                text: qsTr("Open folder")

                onClicked: gui.openFile(core.pathLibrary)
            }
        }

        TextEditCopy
        {
            id: textTemplate

            anchors.left : parent.left
            anchors.right: parent.right

            anchors.margins: st.dp16

            visible: (template != "")

            text: template
        }

        TextBase
        {
            id: itemHelp

            anchors.left : parent.left
            anchors.right: parent.right

            anchors.margins: st.dp16

            visible: textHelp.visible

            text: qsTr("Help")

            font.pixelSize: st.dp20
        }

        TextEditCopy
        {
            id: textHelp

            anchors.left : parent.left
            anchors.right: parent.right

            anchors.margins: st.dp16

            visible: (help != "")

            text: help
        }
    }
}
