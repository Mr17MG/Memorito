import QtQuick 2.14
import QtQuick.Window 2.14
import QtGraphicalEffects 1.14 // Require for ColorOverlay
import QtQuick.Controls 2.14 // Require For Drawer and other
import QtQuick.Controls.Material 2.14 // // Require For Material Theme
import "qrc:/AppBase" as Base

Page {

    property int nRow : uiFunctions.checkDisplayForNumberofRows(Screen)
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
    }

    //Header
    Base.AppHeader{id:header}
    FirstColumn{id:firstColumn;anchors.right: parent.right;}

    Row {
        id:mainRow
        layoutDirection: Qt.RightToLeft
        height: parent.height - header.height
        anchors.top: header.bottom
        anchors.right: firstColumn.active?firstColumn.left:parent.right
        anchors.left: parent.left
        MainColumn{id:mainColumn}
        ThirdColumn{id:thirdColumn}

    }


    //Drawer if nRow = 1 // one Column
    Loader{
        id:drawerLoader
        active: nRow===1
        width: rootWindow.width*2/3
        height: mainRow.height
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
            dragMargin:50*size1W
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
