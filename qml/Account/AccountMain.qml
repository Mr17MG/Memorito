import QtQuick 2.15 // Require for Item And Loader
import QtQuick.Controls 2.15 // require for stackview
import QtQuick.Controls.Material 2.15 // Require For Material.color
import QtQuick.Window 2.15 // Require for Screen
import Global 1.0
import Components 1.0// Require for AppButton and ...
import QtGraphicalEffects 1.14

Pane {
    id:item1
    property bool isSignIn: true
    property bool isPrimaryBackground: !checkSplit(Screen)
    Component.onCompleted: {
        LocalDatabase.dropAallLocalTables()
        LocalDatabase.makeLocalTables()
        UsefulFunc.setAuthLoaderVar(authLoader)
    }
    padding: 0
    focusPolicy: Qt.ClickFocus
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

    Loader{
        id: authLoader
        width: parent.width - splashLoader.width
        height: parent.height
        Behavior on x { NumberAnimation{ duration: 160} }
        x: splashLoader.active ? ( splashLoader.active? ( isSignIn === !AppStyle.ltr? width :0 ) :0 ) :0

        sourceComponent: StackView{
            id: authStack;
            anchors.fill: parent
            AppButton{
                id:languageBtn
                anchors{
                    top: parent.top
                    topMargin: 20*AppStyle.size1H
                    right: parent.right
                    rightMargin: 20*AppStyle.size1W
                }
                z:1
                width: 100*AppStyle.size1W
                height: width
                radius: width
                flat: true
                Image{
                    id:transalteIcon
                    source: "qrc:/translate.svg"
                    width: 60*AppStyle.size1W
                    height: width
                    sourceSize: Qt.size(width*2,height*2)
                    anchors.centerIn: parent
                    visible: false
                }
                ColorOverlay{
                    source: transalteIcon
                    anchors.fill: transalteIcon
                    color: settingBtn.icon.color
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
                    left: parent.left
                    leftMargin: 20*AppStyle.size1W
                }
                width: 100*AppStyle.size1W
                height: width
                radius: width
                flat: true
                z:1
                icon{
                    source: "qrc:/setting.svg"
                    width: 60*AppStyle.size1W
                    color: isPrimaryBackground?AppStyle.textOnPrimaryColor:AppStyle.textColor
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

                Loader{
                    id: appSettingPage
                    active: setting.visible
                    width: parent.width
                    height: parent.height
                    source: "qrc:/AppBase/AppSettings.qml"
                }
            }
            onBusyChanged: isPrimaryBackground = false

            initialItem: splashLoader.active === false ? "qrc:/Splash/MainSplash.qml"
                                                       : isSignIn? "qrc:/Account/SignIn.qml"
                                                                 : "qrc:/Account/SignUp.qml"
        }
    }
}
