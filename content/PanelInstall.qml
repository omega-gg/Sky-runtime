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

Panel
{
    id: panelInstall

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property string fileName
    /* read */ property string name

    //---------------------------------------------------------------------------------------------
    // Private

    property bool pReady: false
    property bool pDone : false

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    width : st.dp480
    height: st.dp320

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function check(fileName)
    {
        if (pReady)
        {
            pReady = false;
            pDone  = false;

            name = "";

            itemConsole.clear();
        }

        panelInstall.fileName = fileName;

        var data = core.checkArchive(fileName);

        pReady = data[0];

        var log = data[2];

        itemConsole.append(log);

        console.debug(log)

        if (pReady == false) return;

        name = data[1];
    }

    function install()
    {
        if (pReady == false) return;

        var data = core.installArchive(fileName, name);

        var log = data[1];

        itemConsole.append(log);

        console.debug(log)

        if (data[0] == false) return;

        pDone = true;

        pageDefault.updateLibrary();
    }

    function showScript()
    {
        hidePanel();

        gui.showUi();

        pageDefault.currentIndex = core.libraryIndexFromName(name);
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    Rectangle
    {
        anchors.fill: itemConsole

        opacity: 0.9

        color: "black"
    }

    Console
    {
        id: itemConsole

        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.top   : parent.top
        anchors.bottom: buttonCheck.top
    }

    ButtonCheckLabel
    {
        id: buttonCheck

        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.bottom: button.top

        enabled: (pReady && pDone == false)

        checked: true

        text: qsTr("I trust the origin and content of this .skz archive")
    }

    ButtonPush
    {
        id: button

        anchors.bottom: parent.bottom

        width: Math.round(parent.width / 2)

        visible: (pDone == false)

        text: qsTr("Cancel")

        onClicked: hidePanel()
    }

    ButtonPush
    {
        anchors.left  : button.right
        anchors.right : parent.right
        anchors.bottom: parent.bottom

        width: Math.round(parent.width / 2)

        visible: (pDone == false)

        enabled: (pReady && buttonCheck.checked)

        text: qsTr("Install")

        onClicked: install()
    }

    ButtonPush
    {
        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.bottom: parent.bottom

        visible: pDone

        text: qsTr("Show ") + name

        onClicked: showScript()
    }
}
