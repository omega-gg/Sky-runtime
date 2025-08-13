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
    // Functions
    //---------------------------------------------------------------------------------------------

    function setFocus()
    {
        lineEdit.setFocus();
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    Rectangle
    {
        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.top   : border.bottom
        anchors.bottom: parent.bottom

        opacity: 0.9

        color: "#161616"
    }

    Console
    {
        id: itemConsole

        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.top   : border.bottom
        anchors.bottom: lineEdit.top

        log: controllerFile.log
    }

    LineEditBox
    {
        id: lineEdit

        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.bottom: parent.bottom

        textDefault: qsTr('>')

        colorA: "transparent"
        colorB: "transparent"

        colorHoverA: "transparent"
        colorHoverB: "transparent"

        colorActive: "transparent"

        colorText: st.baseConsole_color

        colorCursor: colorText

        font.family   : st.baseConsole_fontFamily
        font.pixelSize: st.baseConsole_pixelSize
        font.bold     : st.baseConsole_bold

        //-----------------------------------------------------------------------------------------
        // BaseLineEdit events

        function onKeyPressed(event)
        {
            if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter)
            {
                event.accepted = true;

                gui.process(text);

                clear();
            }
        }
    }

    BorderHorizontal
    {
        id: border

        anchors.bottom: parent.top
    }
}
