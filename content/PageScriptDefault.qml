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

//#QT_6
import QtQuick.Controls.Fusion
//#END

Item
{
    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    property string pathBin: sk.getEnv("SKY_PATH_BIN")

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias column: column

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------
    // Private

//#QT_6
    function pUpdateLanguages()
    {
        var array = new Array;

        var languages = sk.getLanguages();

        var count = languages.length;

        array.push({ "text": qsTr("Default langauge") });

        for (var i = 0; i < count; i++)
        {
            array.push({ "text": languages[i] });
        }

        model.append(array);

        var index = languages.indexOf(sk.localeToLanguage(local.locale));

        comboLanguages.currentIndex = index + 1;
    }

    function pApplyLanguage(currentIndex)
    {
        if (currentIndex == -1) return;

        var locale;

        if (currentIndex != 0)
        {
            locale = model.get(currentIndex).text;

            locale = sk.localeFromLanguage(locale);
        }
        else locale = "";

        if (local.locale == locale) return;

        sk.locale = locale;

        local.locale = locale;

        pageBrowse.reload();
    }
//#END

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
        id: column

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
                borderTop   : borderSize
                borderBottom: borderSize

                padding: st.dp16

                text: qsTr("New .sky")

                onClicked: gui.create(template, "")
            }

            ButtonPiano
            {
                id: buttonOpen

                anchors.left: buttonNew.right

                borderTop   : borderSize
                borderBottom: borderSize

                padding: st.dp16

                text: qsTr("Open .sky script")

                onClicked: openScript()
            }

            ButtonPianoFull
            {
                id: buttonFolder

                anchors.left: buttonOpen.right

                anchors.leftMargin: st.dp16

                borderLeft  : borderSize
                borderTop   : borderSize
                borderBottom: borderSize

                padding: st.dp16

                icon          : st.icon_external
                iconSourceSize: st.size14x14

                text: qsTr("User folder")

                onClicked: gui.openFile(controllerFile.pathStorage)
            }

            ButtonPianoFull
            {
                id: buttonApplication

                anchors.left: buttonFolder.right
                anchors.top : buttonFolder.top

                borderTop   : borderSize
                borderBottom: borderSize

                padding: st.dp16

                icon          : st.icon_external
                iconSourceSize: st.size14x14

                text: qsTr("Application folder")

                onClicked: gui.openFile(controllerFile.pathApplication)
            }

            ButtonPianoFull
            {
                id: buttonBin

                anchors.left: buttonApplication.right
                anchors.top : buttonApplication.top

                borderTop   : borderSize
                borderBottom: borderSize

                padding: st.dp16

                enabled: (pathBin != "")

                icon          : st.icon_external
                iconSourceSize: st.size14x14

                text: qsTr("SKY_PATH_BIN")

                // FIXME Qt5.14: Sometimes sk.textWidth() is too short.
                itemText.elide: Text.ElideNone

                onClicked: gui.openFile(pathBin)
            }

//#QT_6
            ComboBox
            {
                id: comboLanguages

                anchors.left: buttonBin.right

                anchors.leftMargin: st.dp16

                anchors.verticalCenter: parent.verticalCenter

                width: st.dp128

                height: st.dp28

                model: ListModel { id: model }

                Component.onCompleted: pUpdateLanguages()

                onCurrentIndexChanged: pApplyLanguage(currentIndex)
            }
//#END
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
