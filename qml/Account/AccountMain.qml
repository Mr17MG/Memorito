import QtQuick 2.14 // Require for Item And Loader
import QtQuick.Controls 2.14 // require for stackview
import QtQuick.Controls.Material 2.14 // Require For Material.color
import QtQuick.Window 2.14 // Require for Screen
import Global 1.0
import Components 1.0// Require for AppButton and ...
import QtGraphicalEffects 1.14

Item {
    id:item1
    property bool isSignIn: true

    Component.onCompleted: {
        LocalDatabase.dropAallLocalTables()
        LocalDatabase.makeLocalTables()
        UsefulFunc.setAuthLoaderVar(authLoader)
    }

    onIsSignInChanged: {
        if(isSignIn)
            authLoader.item.replace("qrc:/Account/SignIn.qml")

        else
            authLoader.item.replace("qrc:/Account/SignUp.qml")
    }

    Shortcut {
        sequences: ["Esc", "Back"]
        onActivated: {
            if( authLoader.item.depth > 1 )
                authLoader.item.pop();

            else
                UsefulFunc.showConfirm( qsTr("خروج؟") , qsTr("آیا مایلید از نرم‌افزار خارج شوید؟"), function(){Qt.quit()} )
        }
    }

    function checkSplit(window)
    {
        if(Qt.platform.os === "android" || Qt.platform.os === "ios")
            return false

        if(UsefulFunc.rootWindow.width>window.width/3)
            return true;

        else
            return false;

    }

    AppButton{
        id:languageBtn
        anchors{
            top: parent.top
            topMargin: 20*AppStyle.size1H
            right: authLoader.right
            rightMargin: 20*AppStyle.size1W
        }
        width: 100*AppStyle.size1W
        height: width
        radius: width
        flat: true
        Image{
            id:transalteIcon
            source: "qrc:/translate.svg"
            width: 60*AppStyle.size1W
            height: width
            sourceSize: Qt.size(width,height)
            anchors.centerIn: parent
            visible: false
        }
        ColorOverlay{
            source: transalteIcon
            anchors.fill: transalteIcon
            color: AppStyle.textColor
        }

        onClicked: {
            if(!AppStyle.ltr){
                AppStyle.languageChanged = true
                translator.updateLanguage(31) // For Farsi
                AppStyle.languageChanged = false
            }
            else {
                AppStyle.languageChanged = true
                translator.updateLanguage(89) // For English
                AppStyle.languageChanged = false
            }
        }
    }

    AppButton{
        id: settingBtn
        anchors{
            top: parent.top
            topMargin: 20*AppStyle.size1H
            left: authLoader.left
            leftMargin: 20*AppStyle.size1W
        }
        width: 100*AppStyle.size1W
        height: width
        radius: width
        flat: true
        icon{
            source: "qrc:/setting.svg"
            width: 60*AppStyle.size1W
        }

        onClicked: {
            setting.open()
        }
    }
    AppDialog{
        id:setting
        parent: UsefulFunc.mainLoader
        width: parent.width*0.8
        height: parent.height*0.8
        Flickable{
            id: mainFlick
            height: parent.height
            width:  parent.width
            clip: true
            contentHeight: appSettingPage.height*2
            flickableDirection: Flickable.VerticalFlick

            anchors{
                right: parent.right
                top: parent.top
            }

            onContentYChanged: {
                if(contentY<0 || contentHeight < mainFlick.height)
                    contentY = 0
                else if(contentY > (contentHeight-mainFlick.height))
                    contentY = contentHeight-mainFlick.height
            }
            onContentXChanged: {
                if(contentX<0 || contentWidth < mainFlick.width)
                    contentX = 0
                else if(contentX > (contentWidth-mainFlick.width))
                    contentX = (contentWidth-mainFlick.width)
            }

            ScrollBar.vertical: ScrollBar {
                visible: mainFlick.height < mainFlick.contentHeight
                hoverEnabled: true
                active: (hovered || pressed || parent.flicking)
                orientation: Qt.Vertical
                anchors.right: mainFlick.right
                height: parent.height
                width: hovered || pressed?18*AppStyle.size1W:8*AppStyle.size1W
                contentItem: Rectangle {
                    visible: parent.active
                    radius: parent.pressed || parent.hovered ?20*AppStyle.size1W:8*AppStyle.size1W
                    color: parent.pressed ?Material.color(AppStyle.primaryInt,Material.Shade900):Material.color(AppStyle.primaryInt,Material.Shade600)
                }
            }

            Loader{
                id: appSettingPage
                active: setting.visible
                width: parent.width
                height: 400*AppStyle.size1H
                source: "qrc:/AppBase/AppSettings.qml"
            }
        }
    }

    Loader{
        id: authLoader
        x: splashLoader.active ? ( splashLoader.active? ( isSignIn === !AppStyle.ltr? width :0 ) :0 ) :0
        width: parent.width - splashLoader.width
        height: parent.height


        sourceComponent: StackView{
            id: authStack   ;   anchors.fill: parent;
            initialItem: splashLoader.active === false?"qrc:/Splash/MainSplash.qml"
                                                      :isSignIn?"qrc:/Account/SignIn.qml"
                                                               :"qrc:/Account/SignUp.qml"
        }
        Behavior on x { NumberAnimation{ duration: 160} }
    }

    Loader{
        id: splashLoader
        x: isSignIn == !AppStyle.ltr ?0:width
        width: active?parent.width/2:0
        height: parent.height
        source: "qrc:/Splash/MainSplash.qml"
        active: checkSplit(Screen)
        onActiveChanged:{
            if(active)
            {
                if(isSignIn)
                    authLoader.item.replace("qrc:/Account/SignIn.qml")

                else
                    authLoader.item.replace("qrc:/Account/SignUp.qml")
            }
        }

        Behavior on x { NumberAnimation{ duration: 160} }
    }
}
