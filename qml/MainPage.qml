import QtQuick  // Require For Loader
import QtQuick.Controls  // Require For Stackview
import Qt5Compat.GraphicalEffects  // Require For ColorOverlay
import "qrc:/AppBase" as Base
import Memorito.Global

Loader{
    id:mainPage

    active: true
    asynchronous: true

    onStatusChanged: {
        if(status === Loader.Loading)
        {
            UsefulFunc.setMainPageVar(mainPage)
        }
    }

    sourceComponent: Page {
        clip: true

        property alias mainStackView: mainStackView

        header: Base.AppHeader{
            id: headerItem
        }

        StackView{
            id:mainStackView

            clip: true

            anchors {
                fill: parent
            }

            Component.onCompleted: {
                var page = UsefulFunc.findInModel(Number(SettingDriver.value("firstPage",0)),"listId",Constants.firstPageModel).value
                UsefulFunc.stackPages.append({"page":page.pageSource,"title":page.title})
                push( page.pageSource/*,{listId:page.listId,pageTitle:page.title}*/ )
                callWhenPush({listId:page.listId,pageTitle:page.title} )
            }

            function callWhenPop(object)
            {
                if(typeof currentItem.cameBackToPage === "function") {
                    return currentItem.cameBackToPage(object)
                }
            }
            function callWhenPush(object)
            {
                if(typeof currentItem.cameInToPage === "function") {
                    return currentItem.cameInToPage(object)
                }
            }

            function callForGetDataBeforePop()
            {
                if(typeof currentItem.sendToPreviousPage === "function") {
                    return currentItem.sendToPreviousPage()
                }
            }
        }

        Loader{
            id:drawerLoader

            active: nRow===1
            width: UsefulFunc.rootWindow.width*2/3
            height: mainStackView.height
            y: header.height

            sourceComponent: Drawer {

                dragMargin:0
                y: header.height
                width: drawerLoader.width
                height: drawerLoader.height
                edge: AppStyle.ltr ? Qt.LeftEdge
                                   : Qt.RightEdge

                onOpened: {
                    UsefulFunc.getAndroidAccessToFile()
                }

                Overlay.modal: Rectangle {
                    color: AppStyle.appTheme ? "#aa606060"
                                             : "#80000000"
                }

                background: Rectangle {
                    color: AppStyle.appTheme ? "#424242"
                                             : "#f5f5f5"
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

                Base.DrawerBody{
                    isDrawer:true
                }
            }
        }
    }
}

