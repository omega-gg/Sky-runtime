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

Rectangle
{
    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    opacity: 0.9

    color: "#161616"

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    TextBase
    {
        id: itemTitle

        anchors.left : parent.left
        anchors.right: parent.right
        anchors.top  : parent.top

        anchors.margins: st.dp16

        text: core.getLibraryName(currentIndex)

        font.pixelSize: st.dp32
    }

    ButtonPiano
    {
        id: buttonNew

        anchors.left: itemTitle.left
        anchors.top : itemTitle.bottom

        anchors.topMargin: st.dp16

        borderLeft  : borderSize
        borderBottom: borderSize

        padding: st.dp16

        text: qsTr("New .sky")
    }

    ButtonPiano
    {
        id: buttonRun

        anchors.left: buttonNew.right
        anchors.top : buttonNew.top

        anchors.leftMargin: st.dp16

        borderLeft  : borderSize
        borderBottom: borderSize

        padding: st.dp16

        text: qsTr("Run script")

        onClicked: core.argument = core.getLibraryFileName(currentIndex)
    }

    ButtonPiano
    {
        anchors.left: buttonRun.right
        anchors.top : buttonRun.top

        borderBottom: borderSize

        padding: st.dp16

        text: qsTr("Open folder")

        onClicked: gui.openFile(core.pathLibrary)
    }
}
