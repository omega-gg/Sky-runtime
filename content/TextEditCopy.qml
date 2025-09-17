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

BaseTextEdit
{
    id: textEditCopy

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

//#QT_4
    height: Math.max(st.dp56, paintedHeight)
//#ELSE
    height: Math.max(st.dp56, contentHeight)
//#END

    readOnly: true

    wrapMode: TextEdit.NoWrap

    //---------------------------------------------------------------------------------------------
    // Style

    color      : st.baseConsole_color
    colorCursor: color

    font.family   : st.baseConsole_fontFamily
    font.pixelSize: st.baseConsole_pixelSize
    font.bold     : st.baseConsole_bold

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    Rectangle
    {
        anchors.fill: parent

        z: -1

        opacity: 0.9

        color: "#161616"
    }

    ButtonPush
    {
        anchors.right: parent.right
        anchors.top  : parent.top

        anchors.margins: st.dp8

        visible: (textEditCopy.width >= st.dp96)

        text: qsTr("Copy")

        onClicked: gui.setClipboard(text, qsTr("Text copied to the clipboard"))
    }
}
