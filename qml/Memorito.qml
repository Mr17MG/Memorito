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
            firstColumn.active = true
        else
            firstColumn.active = false
    }

    property real firstColumnMinSize: 140*size1W
    property real firstColumnMaxWidth: nRow ==2?rootWindow.width*2.5/8:rootWindow.width*1.80/8

    onWidthChanged: {
        if(rootWindow.width>Screen.width/3 && drawerLoader.active && drawerLoader.item.visible)
        {
            drawerLoader.item.close()
            drawerLoader.item.modal=false
        }

        if(!firstColumn.active)
            firstColumn.width = 0
        else if(firstColumn.width  < firstColumnMinSize )
            firstColumn.width = firstColumnMinSize
        else if(firstColumn.width > firstColumnMaxWidth)
            firstColumn.width = firstColumnMaxWidth
        appSetting.setValue("firstColumnWidth",firstColumn.width)
    }

    F.UsefulFunctions{id:usefulFunc}
    //Header
    property string mainHeaderTitle: qsTr("مموریتو")
    property string anotherHeaderTitle: ""
    Base.AppHeader{id:header}


    FirstColumn{id:firstColumn;anchors.right: parent.right;}

    ListModel{ id: stackPages }
    property var pagesCanShowInThird : ["qrc:/Flow/Collect.qml"]

    Component.onCompleted: {
        stackPages.append({"page":"","title":qsTr("مموریتو")})
    }

    MainColumn{
        id:mainColumn
        height: parent.height - header.height
        anchors.top: header.bottom
        anchors.right: firstColumn.active?firstColumn.left:parent.right
        anchors.left: parent.left

    }


    //Drawer if nRow = 1 // one Column
    Loader{
        id:drawerLoader
        active: nRow===1
        width: rootWindow.width*2/3
        height: mainColumn.height
        y: header.height
        sourceComponent: Drawer{
            Base.DrawerBody{}
            Overlay.modal: Rectangle {
                color: getAppTheme()?"#aa606060":"#80000000"
            }
            y: header.height
            height: drawerLoader.height
            width: drawerLoader.width
            edge: ltr?Qt.LeftEdge:Qt.RightEdge
            dragMargin:0
            background:Rectangle{
                color: getAppTheme()?"#424242":"#f5f5f5"
                LinearGradient {
                    anchors.fill: parent
                    start: Qt.point(ltr?0:drawerLoader.height, 0)
                    end: Qt.point(ltr?drawerLoader.height:0, 0)
                    gradient: Gradient {
                        GradientStop {position: 0.0;color: getAppTheme()?"#30300":"#ffffff"}
                        GradientStop {position: 1.0;color: "transparent"}
                    }
                }
            }
        }
    }
}
