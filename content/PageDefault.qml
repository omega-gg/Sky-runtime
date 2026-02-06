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

    property int page: 0
    // 0: PageWelcome
    // 1: PageBrowse

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    Component.onCompleted:
    {
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
    // Functions
    //---------------------------------------------------------------------------------------------

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

    function updateLibrary()
    {
        if (page != 1) return;

        loader.item.updateLibrary();
    }

    function showScript(name)
    {
        page = 1;

        loader.item.currentIndex = core.libraryIndexFromName(name);
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    Loader
    {
        id: loader

        anchors.fill: parent

        visible: (areaPanel.source != "PanelInstall.qml")

        source: (page == 1) ? Qt.resolvedUrl("PageBrowse.qml")
                            : Qt.resolvedUrl("PageWelcome.qml")
    }

    AreaPanel
    {
        id: areaPanel

        anchors.fill: parent

        marginTop: st.dp48
    }
}
