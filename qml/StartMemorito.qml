import QtQuick 2.14
import QtQuick.Window 2.14
import QtGraphicalEffects 1.14 // Require for ColorOverlay
import QtQuick.Controls 2.14 // Require For Drawer and other
import QtQuick.Controls.Material 2.14 // // Require For Material Theme
import "qrc:/AppBase" as Base
import Components 1.0
import Global 1.0

Page {
    id:page
    Component.onCompleted: {
        LocalDatabase.makeLocalTables()

        if(User.isSet)
        {
            LocalDatabase.getLastChanges
                    (
                        function()
                        {
                            FriendsApi.getFriendsChanges()
                            FriendsApi.syncFriendsChanges()
                            ContextsApi.getContextsChanges()
                            ContextsApi.syncContextsChanges()
                            CategoriesApi.getCategoriesChanges()
                            CategoriesApi.syncCategoriesChanges()
                            ThingsApi.getThingsChanges()
                            ThingsApi.syncThingsChanges()
                            FilesApi.getFilesChanges()
                            FilesApi.syncFilesChanges()
                            LogsApi.getLogsChanges()
                            LogsApi.syncLogsChanges()

                            UserApi.getUsersChanges()
                        })
        }
        else
            SettingDriver.setValue("last_date",decodeURIComponent(new Date().toString()))
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


    SplitView{
        id:splitView
        anchors{ fill: parent }
        orientation: Qt.Horizontal

        property real staticDrawerWidth: 0
        Binding{
            target: splitView
            property: "staticDrawerWidth"
            value:  AppStyle.ltr?staticDrawer.width:staticDrawer2.width
        }
        /********************* Customise SplitHandle ************************/
        handle: Rectangle {
            implicitWidth : 5*AppStyle.size1W
            implicitHeight: 5*AppStyle.size1H
            color: SplitHandle.pressed ? Qt.darker(AppStyle.primaryColor,1.8)
                                       :SplitHandle.hovered ? Qt.darker(AppStyle.primaryColor,1.4)
                                                            : AppStyle.primaryColor
            Rectangle {
                color: parent.SplitHandle.hovered? Qt.darker(AppStyle.textColor,2.0): Qt.lighter(AppStyle.textColor,1.0)
                width: parent.width*2
                height: 100*AppStyle.size1W
                radius: height
                anchors{ centerIn: parent }
            }
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
            SplitView.maximumWidth: nRow ==2?rootWindow.width*2.5/8:rootWindow.width*1.80/8
        }

        MainPage{ id:mainPage; SplitView.fillWidth: true}

        Loader{ // Right For Right to Left Languages
            id:staticDrawer2
            sourceComponent: Base.DrawerBody{}
            active: nRow>1  && !AppStyle.ltr
            visible: active
            SplitView.minimumWidth: 150*AppStyle.size1W
            SplitView.maximumWidth: nRow ==2?rootWindow.width*2.5/8:rootWindow.width*1.80/8
        }
    }

}
