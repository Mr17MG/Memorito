import QtQuick
import QtQuick.Window
import Qt5Compat.GraphicalEffects // Require for ColorOverlay
import QtQuick.Controls  // Require For Drawer and other
import QtQuick.Controls.Material  // // Require For Material Theme
import "qrc:/AppBase" as Base
import Memorito.Components
import Memorito.Global

Item {
    id:page
    Component.onCompleted: {
//        LocalDatabase.makeLocalTables()

//        if(User.isSet)
//        {
//            LocalDatabase.getLastChanges
//                    (
//                        function()
//                        {
//                            FriendsApi.getFriendsChanges()
//                            FriendsApi.syncFriendsChanges()
//                            ContextsApi.getContextsChanges()
//                            ContextsApi.syncContextsChanges()
//                            CategoriesApi.getCategoriesChanges()
//                            CategoriesApi.syncCategoriesChanges()
//                            ThingsApi.getThingsChanges()
//                            ThingsApi.syncThingsChanges()
//                            FilesApi.getFilesChanges()
//                            FilesApi.syncFilesChanges()
//                            LogsApi.getLogsChanges()
//                            LogsApi.syncLogsChanges()

//                            UserApi.getUsersChanges()
//                        })
//        }
//        else
//            SettingDriver.setValue("last_date",decodeURIComponent(new Date().toString()))
    }

    ListModel { id: friendModel   }
    ListModel { id: contextModel  }

    ListModel{  id: priorityModel
        ListElement{ Id:1; Text:qsTr("کم")   ; iconSource: "qrc:/priorities/low.svg"    ;   }
        ListElement{ Id:2; Text:qsTr("متوسط"); iconSource: "qrc:/priorities/medium.svg" ;   }
        ListElement{ Id:3; Text:qsTr("زیاد") ; iconSource: "qrc:/priorities/high.svg"   ;   }
        ListElement{ Id:4; Text:qsTr("فوری") ; iconSource: "qrc:/priorities/higher.svg" ;   }
    }

    ListModel{  id: energyModel
        ListElement{ Id:1; Text:qsTr("کم")          ; iconSource: "qrc:/energies/low.svg"   ;   }
        ListElement{ Id:2; Text:qsTr("متوسط")       ; iconSource: "qrc:/energies/medium.svg";   }
        ListElement{ Id:3; Text:qsTr("زیاد")        ; iconSource: "qrc:/energies/high.svg"  ;   }
        ListElement{ Id:4; Text:qsTr("خیلی زیاد")   ; iconSource: "qrc:/energies/higher.svg";   }
    }

    property int nRow : UiFunctions.checkDisplayForNumberofRows(Screen)

    AppSplitView{
        id:splitView
        anchors{ fill: parent }
        orientation: Qt.Horizontal

        property real staticDrawerWidth: 0
        Binding{
            target: splitView
            property: "staticDrawerWidth"
            value:  AppStyle.ltr?staticDrawer.width:staticDrawer2.width
        }
        /************************ Save and restore state **********************/

        Component.onCompleted: splitView.restoreState(SettingDriver.value("ui/splitview"))
        Component.onDestruction: SettingDriver.setValue("ui/splitview", splitView.saveState())

        /******* Views ***********/

        Loader{ // Left For Left to Right Languages
            id:staticDrawer
            sourceComponent: Base.DrawerBody{}
            active: nRow>1 && AppStyle.ltr
            visible: active
            SplitView.minimumWidth: 150*AppStyle.size1W
            SplitView.maximumWidth: nRow ==2?UsefulFunc.rootWindow.width*2.5/8:UsefulFunc.rootWindow.width*1.80/8
        }

        MainPage{ id:mainPage; SplitView.fillWidth: true}

        Loader{ // Right For Right to Left Languages
            id:staticDrawer2
            sourceComponent: Base.DrawerBody{}
            active: nRow>1  && !AppStyle.ltr
            visible: active
            SplitView.minimumWidth: 150*AppStyle.size1W
            SplitView.maximumWidth: nRow ==2?UsefulFunc.rootWindow.width*2.5/8:UsefulFunc.rootWindow.width*1.80/8
        }
    }
}
