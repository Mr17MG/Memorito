import QtQuick 2.14
import QtQuick.Window 2.14
import QtGraphicalEffects 1.14 // Require for ColorOverlay
import QtQuick.Controls 2.14 // Require For Drawer and other
import QtQuick.Controls.Material 2.14 // // Require For Material Theme
import "qrc:/AppBase" as Base
import "qrc:/Functions" as F

Page {
    property int nRow : uiFunctions.checkDisplayForNumberofRows(Screen)
    onNRowChanged: {
        if(nRow >= 2)
            staticDrawer.active = true
        else
            staticDrawer.active = false
    }

    property real staticDrawerMinSize: 140*size1W
    property real staticDrawerMaxWidth: nRow ==2?rootWindow.width*2.5/8:rootWindow.width*1.80/8

    onWidthChanged: {
        if( width === (Qt.platform.os === "android" || Qt.platform.os === "ios"?width:appSetting.value("AppWidth" ,640)))
            return

        if( ( rootWindow.width>Screen.width/3 || rootWindow.width>450 )  && drawerLoader.active )
        {
            if(drawerLoader.item.visible)
            {
                drawerLoader.item.close()
                drawerLoader.item.modal=false
            }
        }

        if(!staticDrawer.active)
            staticDrawer.width = 0
        else if(staticDrawer.width  < staticDrawerMinSize )
            staticDrawer.width = staticDrawerMinSize
        else if(staticDrawer.width > staticDrawerMaxWidth)
            staticDrawer.width = staticDrawerMaxWidth
        appSetting.setValue("staticDrawerWidth",staticDrawer.width)
    }

    FilesApi            {   id: filesApi    }
    ThingsApi           {   id: thingsApi   }
    FriendsAPI          {   id: friendsApi  }
    ContextsApi         {   id: contextApi  }
    CategoriesApi       {   id: categoryApi }
    InitLocalDatabase   {   id: localDB     }
    UserAPI             {   id: userApi     }
    F.UsefulFunctions   {   id: usefulFunc  }

    ListModel { id: doneModel             ;dynamicRoles: true  }
    ListModel { id: stackPages            ;dynamicRoles: true  }
    ListModel { id: thingModel            ;dynamicRoles: true  }
    ListModel { id: trashModel            ;dynamicRoles: true  }
    ListModel { id: friendModel           ;dynamicRoles: true  }
    ListModel { id: waitingModel          ;dynamicRoles: true  }
    ListModel { id: somedayModel          ;dynamicRoles: true  }
    ListModel { id: projectModel          ;dynamicRoles: true  }
    ListModel { id: contextModel          ;dynamicRoles: true  }
    ListModel { id: calendarModel         ;dynamicRoles: true  }
    ListModel { id: refrenceModel         ;dynamicRoles: true  }
    ListModel { id: nextActionModel       ;dynamicRoles: true  }
    ListModel { id: refrenceCategoryModel ;dynamicRoles: true  }
    ListModel { id: somedayCategoryModel  ;dynamicRoles: true  }
    ListModel { id: projectCategoryModel  ;dynamicRoles: true  }

    ListModel{
        id: priorityModel
        ListElement{ Id:1; Text:qsTr("کم"); iconSource: "qrc:/priorities/low.svg";}
        ListElement{ Id:2; Text:qsTr("متوسط"); iconSource: "qrc:/priorities/medium.svg";}
        ListElement{ Id:3; Text:qsTr("زیاد"); iconSource: "qrc:/priorities/high.svg";}
        ListElement{ Id:4; Text:qsTr("فوری"); iconSource: "qrc:/priorities/higher.svg";}
    }

    ListModel{
        id: energyModel
        ListElement{ Id:1; Text:qsTr("کم"); iconSource: "qrc:/energies/low.svg";}
        ListElement{ Id:2; Text:qsTr("متوسط"); iconSource: "qrc:/energies/medium.svg";}
        ListElement{ Id:3; Text:qsTr("زیاد");  iconSource: "qrc:/energies/high.svg";}
        ListElement{ Id:4; Text:qsTr("خیلی زیاد"); iconSource: "qrc:/energies/higher.svg";}
    }

    Component.onCompleted: {
        stackPages.append({"page":"","title":qsTr("مموریتو")})
        localDB.makeLocalTables()
        if(currentUser.id)
        {
            localDB.getLastChanges()
        }else appSetting.setValue("last_date",decodeURIComponent(new Date().toString()))
    }

    //Header
    property string mainHeaderTitle: qsTr("مموریتو")
    Base.AppHeader{ id:header }

    StaticDrawer{   id:staticDrawer; anchors.right: parent.right; active: nRow>1 }

    MainPage{
        id:mainPage
        height: parent.height - header.height
        anchors.top: header.bottom
        anchors.right: staticDrawer.active?staticDrawer.left:parent.right
        anchors.left: parent.left
    }


    //Drawer if nRow = 1 // one Column
    Loader{
        id:drawerLoader
        active: nRow===1
        width: rootWindow.width*2/3
        height: mainPage.height
        y: header.height
        sourceComponent: Drawer{
            Base.DrawerBody{}
            Overlay.modal: Rectangle {
                color: appStyle.appTheme?"#aa606060":"#80000000"
            }
            y: header.height
            height: drawerLoader.height
            width: drawerLoader.width
            edge: ltr?Qt.LeftEdge:Qt.RightEdge
            dragMargin:0
            background:Rectangle{
                color: appStyle.appTheme?"#424242":"#f5f5f5"
                LinearGradient {
                    anchors.fill: parent
                    start: Qt.point(ltr?0:drawerLoader.width, 0)
                    end: Qt.point(ltr?drawerLoader.width:0, 0)
                    gradient: Gradient {
                        GradientStop {position: 0.0;color: appStyle.appTheme?"#202020":"#ffffff"}
                        GradientStop {position: 1.0;color: "transparent"}
                    }
                }
            }
        }
    }
}
