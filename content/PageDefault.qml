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
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias currentIndex: list.currentIndex

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    Component.onCompleted: pUpdateList()

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: core

        /* QML_CONNECTION */ function onLoaded() { pUpdateList() }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------
    // Private

    function pUpdateList()
    {
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
    }

    function pApplyPage(index)
    {

    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    TextBase
    {
        id: itemText

        anchors.centerIn: parent

        text: qsTr("Welcome to Sky kit")

        font.pixelSize: st.dp32
    }

    TextBase
    {
        anchors.top: itemText.bottom

        anchors.topMargin: st.dp16

        anchors.horizontalCenter: parent.horizontalCenter

        text: qsTr("Drop a .sky file to begin")

        color: st.text3_color

        font.pixelSize: st.dp20
    }

    ItemUi
    {
        Rectangle
        {
            anchors.fill: list

            opacity: 0.6

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
                function onPress()
                {
                    if (list.currentIndex == index)
                    {
                        list.currentIndex = -1;

                        return;
                    }

                    list.currentIndex = index;
                }
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

            source: (currentIndex == -1) ? "" : Qt.resolvedUrl("PageScript.qml")
        }
    }
}
