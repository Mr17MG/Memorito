import QtQuick  // require for Item
import QtQuick.Controls  // require for Swipwiew
import QtQuick.Controls.Material  //Require for Material.color
import Qt5Compat.GraphicalEffects

import Memorito.Components
import Memorito.Global

Rectangle{
    property bool singlePage: (["android","ios"].indexOf(Qt.platform.os) !== -1 || splashLoader.active === false)

    color: Material.color(AppStyle.primaryInt,Material.Shade400)

    LayoutMirroring.enabled: false
    LayoutMirroring.childrenInherit: true

    SwipeView{
        id:view

        width: parent.width
        clip: true

        anchors {
            top: parent.top
            bottom: pageIndicator.top
        }

        SplashItem{
            imageSource: "qrc:/Splash/computer_display_monochromatic.svg"
            title: qsTr("متناسب با هر صفحه نمایشی که داری")
        }

        SplashItem{
            imageSource: "qrc:/Splash/great_idea_monochromatic.svg"
            title: qsTr("ایده هات رو جمع کن")
        }

        SplashItem{
            imageSource: "qrc:/Splash/information_carousel_monochromatic.svg"
            title: qsTr("ذهنت رو خالی و مثل آب جاری کن")
        }

        SplashItem{
            imageSource: "qrc:/Splash/online_storage_monochromatic.svg"
            title: qsTr("اطلاعاتت به صورت آنلاین و امن همیشه در اختیارته")
        }

        SplashItem{
            imageSource: "qrc:/Splash/settings_monochromatic.svg"
            title: qsTr("اختیار همه چی دست خودته")
        }
    }

    PageIndicator {
        id:pageIndicator

        count: view.count
        currentIndex: view.currentIndex
        spacing: 10*AppStyle.size1W

        anchors {
            bottom:  parent.bottom
            bottomMargin: AppStyle.size1H*40
            horizontalCenter: parent.horizontalCenter
        }

        delegate: Rectangle {
            width: AppStyle.size1W*20
            height: AppStyle.size1W*20
            radius: width
            color: AppStyle.textOnPrimaryColor
            opacity: index === pageIndicator.currentIndex ?1 : 0.30
            MouseArea{
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    view.currentIndex = index
                }
            }
            Behavior on opacity {
                OpacityAnimator {
                    duration: 300
                }
            }
        }
    }


    AppButton{
        id:backBtn

        width: AppStyle.size1W*160
        height: AppStyle.size1W*60
        radius: 20*AppStyle.size1W

        flat: !singlePage
        font.bold: AppStyle.ltr

        contentMirorred: icon.source.toString() === "qrc:/skip.svg"

        Material.foreground: AppStyle.textOnPrimaryColor
        Material.background: flat ? "transparent"
                                  : Material.color(AppStyle.primaryInt,Material.Shade900)

        text:  (view.currentIndex === 0 && singlePage)? qsTr("رد شدن")
                                                      : qsTr("قبلی")

        anchors{
            left: parent.left
            leftMargin: AppStyle.size1W*25
            verticalCenter: pageIndicator.verticalCenter
        }

        icon{
            width: 25*AppStyle.size1W
            height: 25*AppStyle.size1W
            color: AppStyle.textOnPrimaryColor
            source: (view.currentIndex === 0 && singlePage)? "qrc:/skip.svg"
                                                           : "qrc:/previous.svg"

        }
        onClicked: {
            if(autoMoveTimer.running)
                autoMoveTimer.restart()
            if(view.currentIndex === 0 && singlePage)
            {
                UsefulFunc.authLoader.item.replace("qrc:/Account/SignIn.qml")
            }
            else view.currentIndex = ( view.currentIndex-1 ) % view.count + ( ( view.currentIndex-1 ) % view.count < 0 ? view.count : 0 )
        }
    }

    AppButton{
        id:forwardBtn

        width: AppStyle.size1W*160
        height: AppStyle.size1W*60
        radius: 15*AppStyle.size1W

        flat: !singlePage
        contentMirorred: true
        font.bold: AppStyle.ltr

        anchors{
            right: parent.right
            rightMargin: AppStyle.size1W*30
            verticalCenter: pageIndicator.verticalCenter
        }

        Material.foreground: AppStyle.textOnPrimaryColor
        Material.background: flat ? "transparent" : Material.color(AppStyle.primaryInt,Material.Shade900)


        text: view.currentIndex === view.count-1 && singlePage ? qsTr("اتمام")
                                                               : qsTr("بعدی")
        icon {
            width: 25*AppStyle.size1W
            height: 25*AppStyle.size1W
            color: AppStyle.textOnPrimaryColor
            source: view.currentIndex === view.count-1 && singlePage ? "qrc:/check.svg"
                                                                     : "qrc:/next.svg"

        }

        onClicked: {
            if(autoMoveTimer.running)
                autoMoveTimer.restart()
            if( view.currentIndex === view.count-1 && singlePage)
            {
                UsefulFunc.authLoader.item.replace("qrc:/Account/SignIn.qml")
            }
            else view.currentIndex= ((view.currentIndex+1)%view.count);
        }
    }


    Timer {
        id:autoMoveTimer
        interval: 5000
        repeat: true
        running: !singlePage
        onTriggered: {
            view.currentIndex = ((view.currentIndex+1)%view.count);
        }
    }

}
