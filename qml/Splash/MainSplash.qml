import QtQuick 2.14 // require for Item
import QtQuick.Controls 2.14 // require for Swipwiew
import QtQuick.Controls.Material 2.14 //Require for Material.color
import QtGraphicalEffects 1.14
import Components 1.0
import Global 1.0
Item {
    LayoutMirroring.enabled: false
    LayoutMirroring.childrenInherit: true
    Rectangle{
        anchors.fill: parent
        color: Material.color(AppStyle.primaryInt,Material.Shade400)
    }
    AppButton{
        id:languageBtn
        flat: true
        radius: 20*AppStyle.size1W
        anchors.top: parent.top
        width: parent.width
        text: qsTr("English Version")
        visible: splashLoader.active === false
        onClicked: {
            if(!AppStyle.ltr)
                translator.updateLanguage(31)
            else translator.updateLanguage(89)
        }
    }
    SwipeView{
        id:view
        width: parent.width
        anchors{
            top:languageBtn.visible?languageBtn.bottom:parent.top
            bottom: pageIndicator.top
        }
        clip: true
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
            title: qsTr("ذهنت رو خالی و مثل آب جاریش کن")
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
        anchors.bottom:  parent.bottom
        anchors.bottomMargin: AppStyle.size1H*40
        anchors.horizontalCenter: parent.horizontalCenter
        delegate: Rectangle {
            width: AppStyle.size1W*9
            height: AppStyle.size1H*9
            radius: width
            color: AppStyle.textColor
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
        anchors.left: parent.left
        anchors.leftMargin: AppStyle.size1W*25
        anchors.verticalCenter: pageIndicator.verticalCenter
        flat: (Qt.platform.os !== "android" && Qt.platform.os !== "ios" && splashLoader.active !== false)
        Material.background: flat?"transparent":Material.color(AppStyle.primaryInt,Material.Shade900)
        radius: 20*AppStyle.size1W
        text:  (view.currentIndex === 0 && (Qt.platform.os === "android" || Qt.platform.os === "ios" || splashLoader.active === false))?
                   qsTr("رد شدن"):qsTr("قبلی")
        rightPadding:  prevBtn.source.toString() === "qrc:/skip.svg"?40*AppStyle.size1W:0
        leftPadding:   prevBtn.source.toString() === "qrc:/skip.svg"?0:5*AppStyle.size1W
        font.bold: AppStyle.ltr
        Image {
            id:prevBtn
            LayoutMirroring.enabled: prevBtn.source.toString() === "qrc:/skip.svg"
            source: (view.currentIndex === 0 && (Qt.platform.os === "android" || Qt.platform.os === "ios" || splashLoader.active === false))?
                        "qrc:/skip.svg":"qrc:/next.svg"
            anchors.left: parent.left
            anchors.leftMargin: 25*AppStyle.size1W
            anchors.verticalCenter: parent.verticalCenter
            width: 25*AppStyle.size1W
            height: width
            visible: false
        }
        ColorOverlay{
            rotation: prevBtn.source.toString() === "qrc:/skip.svg"?0:180
            source: prevBtn
            anchors.fill: prevBtn
            color: backBtn.flat?AppStyle.textColor:"white"
        }
        onClicked: {
            if(autoMoveTimer.running)
                autoMoveTimer.restart()
            if(view.currentIndex === 0 && (Qt.platform.os === "android" || Qt.platform.os === "ios" || splashLoader.active === false))
            {
                UsefulFunc.authLoader.item.replace("qrc:/Account/SignIn.qml")
            }
            else view.currentIndex= (view.currentIndex-1)%view.count<0?(view.currentIndex-1)%view.count+view.count:(view.currentIndex-1)%view.count;
        }
    }
    AppButton{
        id:forwardBtn
        width: AppStyle.size1W*160
        height: AppStyle.size1W*60
        anchors.verticalCenter: pageIndicator.verticalCenter
        anchors.right: parent.right
        flat: (Qt.platform.os !== "android" && Qt.platform.os !== "ios" && splashLoader.active !== false)
        Material.background: flat?"transparent":Material.color(AppStyle.primaryInt,Material.Shade900)
        radius: 15*AppStyle.size1W
        anchors.rightMargin: AppStyle.size1W*30
        rightPadding: 25*AppStyle.size1W
        text: (view.currentIndex === view.count-1 && (Qt.platform.os === "android" || Qt.platform.os === "ios" || splashLoader.active === false))?
                  qsTr("اتمام"):qsTr("بعدی")
        font.bold: AppStyle.ltr
        Image {
            id:nextBtn
            source: (view.currentIndex === view.count-1 && (Qt.platform.os === "android" || Qt.platform.os === "ios" || splashLoader.active === false))?
                        "qrc:/check.svg":"qrc:/next.svg"
            anchors.right: parent.right
            anchors.rightMargin: 30*AppStyle.size1W
            anchors.verticalCenter: parent.verticalCenter
            width: 25*AppStyle.size1W
            height: width
            visible: false
        }
        ColorOverlay{
            source: nextBtn
            anchors.fill: nextBtn
            color: forwardBtn.flat?AppStyle.textColor:"white"
        }

        onClicked: {
            if(autoMoveTimer.running)
                autoMoveTimer.restart()
            if(view.currentIndex === view.count-1 && (Qt.platform.os === "android" || Qt.platform.os === "ios" || splashLoader.active === false))
            {
                UsefulFunc.authLoader.item.replace("qrc:/Account/SignIn.qml")
            }
            else view.currentIndex= ((view.currentIndex+1)%view.count);
        }
    }
    Timer{
        id:autoMoveTimer
        interval: 5000
        repeat: true
        running: (Qt.platform.os !== "android" && Qt.platform.os !== "ios" && splashLoader.active !== false)
        onTriggered: {
            view.currentIndex= ((view.currentIndex+1)%view.count);
        }
    }
}
