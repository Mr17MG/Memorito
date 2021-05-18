import QtQuick 2.15 // Require For Loader
import QtQuick.Controls 2.15 // Require For Stackview
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
        }
    }
    ListModel{
        id: firstPageModel
        ListElement{
            title:qsTr("مموریتو")
            pageSource :"qrc:/HomePage.qml"
            listId: 0
        }
        ListElement{
            title: qsTr("جمع‌آوری")
            pageSource :"qrc:/Things/AddEditThing.qml"
            listId: Memorito.Collect
        }
        ListElement{
            title:qsTr("پردازش نشده‌ها")
            pageSource: "qrc:/Things/ThingList.qml"
            listId: Memorito.Process
        }
        ListElement{
            title:qsTr("عملیات بعدی")
            pageSource: "qrc:/Things/ThingList.qml"
            listId: Memorito.NextAction
        }
        ListElement{
            title:qsTr("تقویم")
            pageSource: "qrc:/Things/ThingList.qml"
            listId: Memorito.Calendar
        }
        ListElement{
            title:qsTr("پروژه‌ها")
            pageSource: "qrc:/Categories/CategoriesList.qml"
            listId: Memorito.Project
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
            Component.onCompleted: {
                var page = UsefulFunc.findInModel(Number(SettingDriver.value("firstPage",0)),"listId",firstPageModel).value
                UsefulFunc.stackPages.append({"page":page.pageSource,"title":page.title})
                push( page.pageSource,{listId:page.listId,pageTitle:page.title} )
                callWhenPush({listId:page.listId,pageTitle:page.title} )
            }

            clip: true


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
            width: UsefulFunc.rootWindow.width*2/3
            height: mainStackView.height
            y: header.height

            sourceComponent: Drawer{
                onOpened: {
                    UsefulFunc.getAndroidAccessToFile()
                }
                y: header.height
                Base.DrawerBody{isDrawer:true}

                width: drawerLoader.width
                height: drawerLoader.height
                dragMargin:0
                edge: AppStyle.ltr?Qt.LeftEdge:Qt.RightEdge
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
            }
        }
    }
}

