import QtQuick 2.14 // require for Item
import QtQuick.Controls 2.14 // require for Swipwiew
import QtQuick.Controls.Material 2.14 //Require for Material.color
import QtGraphicalEffects 1.14
import "qrc:/Components" as App

Item {
    LayoutMirroring.enabled: false
    LayoutMirroring.childrenInherit: true
    Rectangle{
        anchors.fill: parent
        color: Material.color(appStyle.primaryInt,Material.Shade400)
    }
    SwipeView{
        id:view
        anchors.fill: parent
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
        anchors.bottomMargin: size1H*40
        anchors.horizontalCenter: parent.horizontalCenter
        delegate: Rectangle {
            implicitWidth: size1W*9
            implicitHeight: size1H*9
            radius: width
            color: appStyle.textColor
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
    App.Button{
        id:backBtn
        width: size1W*60
        height: width
        anchors.left: parent.left
        anchors.leftMargin: size1W*25
        anchors.verticalCenter: flat?parent.verticalCenter:pageIndicator.verticalCenter
        flat: (Qt.platform.os !== "android" && Qt.platform.os !== "ios" && splashLoader.active !== false)
        Material.background: flat?"transparent":Material.color(appStyle.primaryInt,Material.Shade900)
        radius: 20*size1W
        Image {
            id:prevBtn
            source: "qrc:/next.svg"
            anchors.centerIn: parent
            width: 25*size1W
            height: width
            visible: false
        }
        ColorOverlay{
            rotation: 180
            source: prevBtn
            anchors.fill: prevBtn
            color: backBtn.flat?appStyle.textColor:"white"
        }
        onClicked: {
            if(autoMoveTimer.running)
                autoMoveTimer.restart()
            view.currentIndex= (view.currentIndex-1)%view.count<0?(view.currentIndex-1)%view.count+view.count:(view.currentIndex-1)%view.count;
        }
    }
    App.Button{
        id:forwardBtn
        width: size1W*60
        height: width
        anchors.verticalCenter: flat?parent.verticalCenter:pageIndicator.verticalCenter
        anchors.right: parent.right
        flat: (Qt.platform.os !== "android" && Qt.platform.os !== "ios" && splashLoader.active !== false)
        Material.background: flat?"transparent":Material.color(appStyle.primaryInt,Material.Shade900)
        radius: 15*size1W
        anchors.rightMargin: size1W*25
        Image {
            id:nextBtn
            source: (view.currentIndex === view.count-1 && (Qt.platform.os === "android" || Qt.platform.os === "ios" || splashLoader.active === false))?
                        "qrc:/check.svg":"qrc:/next.svg"
            anchors.centerIn: parent
            width: 25*size1W
            height: width
            visible: false
        }
        ColorOverlay{
            source: nextBtn
            anchors.fill: nextBtn
            color: forwardBtn.flat?appStyle.textColor:"white"
        }

        onClicked: {
            if(autoMoveTimer.running)
                autoMoveTimer.restart()
            if(view.currentIndex === view.count-1 && (Qt.platform.os === "android" || Qt.platform.os === "ios" || splashLoader.active === false))
                closeSplash = true
            view.currentIndex= ((view.currentIndex+1)%view.count);
        }
    }
    App.Button{
        flat: true
        anchors.top: parent.top
        width: parent.width
        text: qsTr("English Version")
        visible: splashLoader.active === false
        onClicked: {
            if(!ltr)
                translator.updateLanguage(31)
            else translator.updateLanguage(89)
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
