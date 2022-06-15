import QtQuick
import QtQuick.Controls  // Require For Drawer and other

import Memorito.Components // Require For AppSplitView
import Memorito.Global // Require For SettingDriver

import "qrc:/AppBase" as Base // Require For DrawerBody

Item {
    id:page

    property int nRow : UiFunctions.checkDisplayForNumberofRows(Screen)

    AppSplitView{
        id:splitView

        orientation: Qt.Horizontal
        anchors {
            fill: parent
        }

        property real staticDrawerWidth: 0
        Binding{
            target: splitView
            property: "staticDrawerWidth"
            value:  AppStyle.ltr ? staticDrawer.width
                                 : staticDrawer2.width
        }
        /************************ Save and restore state **********************/

        Component.onCompleted: splitView.restoreState(SettingDriver.value("ui/splitview"))
        Component.onDestruction: SettingDriver.setValue("ui/splitview", splitView.saveState())

        /******* Views ***********/

        Loader { // Left For Left to Right Languages
            id:staticDrawer

            sourceComponent: Base.DrawerBody{}
            active: nRow>1 && AppStyle.ltr
            visible: active
            SplitView.minimumWidth: 150*AppStyle.size1W
            SplitView.maximumWidth: nRow ==2 ? UsefulFunc.rootWindow.width*2.5/8
                                             : UsefulFunc.rootWindow.width*1.80/8
        }

        MainPage {
            id: mainPage;
            SplitView.fillWidth: true
        }

        Loader { // Right For Right to Left Languages
            id:staticDrawer2

            sourceComponent: Base.DrawerBody{}
            active: nRow>1  && !AppStyle.ltr
            visible: active
            SplitView.minimumWidth: 150*AppStyle.size1W
            SplitView.maximumWidth: nRow ==2 ? UsefulFunc.rootWindow.width*2.5/8
                                             : UsefulFunc.rootWindow.width*1.80/8
        }
    }
}
