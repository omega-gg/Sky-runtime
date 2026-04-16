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
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias column: column

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function browseBin()
    {
        var path = core.getExistingDirectory(qsTr("Select a bin folder"), core.pathBin);

        if (path == "") return;

        editBin.text = core.applyBin(path);
    }

    function applyBin(text)
    {
        editBin.text = core.applyBin(text);
    }

    function resetBin()
    {
        core.resetBin();

        editBin.text = core.pathBin;
    }

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
                borderRight : borderSize
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

                borderRight : borderSize
                borderTop   : borderSize
                borderBottom: borderSize

                padding: st.dp16

                text: qsTr("Open .sky script")

                onClicked: openScript()
            }

            ButtonPianoFull
            {
                id: buttonApplication

                anchors.left: buttonOpen.right

                anchors.leftMargin: st.dp16

                borderLeft  : borderSize
                borderRight : borderSize
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
                id: buttonStorage

                anchors.left: buttonApplication.right
                anchors.top : buttonApplication.top

                borderRight : borderSize
                borderTop   : borderSize
                borderBottom: borderSize

                padding: st.dp16

                icon          : st.icon_external
                iconSourceSize: st.size14x14

                text: qsTr("Storage folder")

                onClicked: gui.openFile(controllerFile.pathStorage)
            }

//#QT_6
            ComboBox
            {
                id: comboLanguages

                anchors.left: buttonStorage.right

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

        TextBase
        {
            anchors.left : parent.left
            anchors.right: parent.right

            anchors.margins: st.dp16

            visible: textHelp.visible

            text: qsTr("SKY_PATH_BIN")

            font.pixelSize: st.dp20
        }

        Row
        {
            anchors.left : parent.left
            anchors.right: parent.right

            anchors.margins: st.dp16

            LineEditBox
            {
                id: editBin

                width: Math.min(parent.width - buttonReset.width - buttonBrowse.width, st.dp640)

                text: core.pathBin

                font.pixelSize: st.dp14

                onIsFocusedChanged: if (isFocused == false) applyBin(text)
            }

            ButtonPianoIcon
            {
                id: buttonReset

                borderLeft  : borderSize
                borderTop   : borderSize
                borderBottom: borderSize

                height: editBin.height

                icon          : st.icon_refresh
                iconSourceSize: st.size16x16

                onClicked: resetBin()
            }

            ButtonPiano
            {
                id: buttonBrowse

                borderLeft  : borderSize
                borderRight : borderSize
                borderTop   : borderSize
                borderBottom: borderSize

                height: editBin.height

                padding: st.dp16

                text: qsTr("Browse")

                onClicked: browseBin()
            }
        }

        TextBase
        {
            anchors.left : parent.left
            anchors.right: parent.right

            anchors.margins: st.dp16

            visible: textHelp.visible

            text: qsTr("Template")

            font.pixelSize: st.dp20
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
