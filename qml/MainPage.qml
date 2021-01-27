import QtQuick 2.14 // Require For Loader
import QtQuick.Controls 2.14 // Require For Stackview
import QtGraphicalEffects 1.14 // Require For ColorOverlay
import "qrc:/AppBase" as Base
import Global 1.0

Loader{
    id:mainPage
    active: true
    asynchronous: true
    onStatusChanged: {
        if(status === Loader.Loading)
        {
            UsefulFunc.setMainPageVar(mainPage)
            UsefulFunc.stackPages.append({"page":"","title":qsTr("مموریتو")})
        }
    }

    sourceComponent: Item {
        clip: true
        property alias mainStackView: mainStackView
        Rectangle{
            id: disconnectRect
            width: parent.width
            height: 100*AppStyle.size1W
            color: "yellow"
            visible: false
        }
        Base.AppHeader{ id: header }

        StackView{
            id:mainStackView
            anchors{
                top: header.bottom
                right: parent.right
                left: parent.left
                bottom: parent.bottom
            }
            clip: true
            initialItem: Item{}

            function callWhenPop(object)
            {
                if(typeof currentItem.cameBackToPage === "function"){
                    return currentItem.cameBackToPage(object)
                }
            }
            function callWhenPush(object)
            {
                if(typeof currentItem.cameInToPage === "function"){
                    return currentItem.cameInToPage(object)
                }
            }

            function callForGetDataBeforePop()
            {
                if(typeof currentItem.sendToPreviousPage === "function"){
                    return currentItem.sendToPreviousPage()
                }
            }
        }

        Loader{
            id:drawerLoader
            active: nRow===1
            width: rootWindow.width*2/3
            height: mainPage.height
            y:header.height
            sourceComponent: Drawer{
                width: drawerLoader.width
                height: drawerLoader.height
                y:header.height
                edge: AppStyle.ltr?Qt.LeftEdge:Qt.RightEdge
                dragMargin:0
                Overlay.modal: Rectangle { color: AppStyle.appTheme?"#aa606060":"#80000000" }
                background:Rectangle{
                    color: AppStyle.appTheme?"#424242":"#f5f5f5"
                    LinearGradient {
                        anchors.fill: parent
                        start: Qt.point(AppStyle.ltr?0:drawerLoader.width, 0)
                        end  : Qt.point(AppStyle.ltr?drawerLoader.width:0, 0)
                        gradient: Gradient {
                            GradientStop {position: 0.0; color: AppStyle.appTheme?"#202020":"#ffffff"}
                            GradientStop {position: 1.0; color: "transparent"                        }
                        }
                    }
                }
                Base.DrawerBody{isDrawer:true}
            }
        }

    }
}

