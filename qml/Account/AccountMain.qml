import QtQuick  // Require for Item And Loader
import QtQuick.Controls  // require for stackview
import QtQuick.Controls.Material  // Require For Material.color
import QtQuick.Window  // Require for Screen
import Memorito.Global
import Memorito.Components// Require for AppButton and ...
import Qt5Compat.GraphicalEffects
import Memorito.Users

Pane {
    id: root

    property bool isSignIn: true
    property bool isPrimaryBackground: !checkSplit(Screen)

    function checkSplit(window)
    {
        if(["android","ios"].indexOf(Qt.platform.os) !== -1)
            return false
        else if(UsefulFunc.rootWindow.width>window.width/3)
            return true;
        else
            return false;
    }

    padding: 0
    focusPolicy: Qt.ClickFocus

    onIsSignInChanged: {
        if(isSignIn)
            authLoader.item.replace("qrc:/Account/SignIn.qml")

        else
            authLoader.item.replace("qrc:/Account/SignUp.qml")
    }

    Component.onCompleted: {
//        LocalDatabase.dropAallLocalTables()
//        LocalDatabase.makeLocalTables()
        UsefulFunc.setAuthLoaderVar(authLoader)
    }

    UsersController{
        id: userController
    }

    Shortcut {
        sequences: ["Esc", "Back"]
        onActivated: {
            if( authLoader.item.depth > 1 )
                authLoader.item.pop();

            else
                UsefulFunc.showConfirm( qsTr("خروج؟") , qsTr("میخوای از برنامه خارج بشی؟"), function(){Qt.quit()} )
        }
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
        x: splashLoader.active ? (isSignIn === !AppStyle.ltr? width
                                                             :0)
                               :0
        sourceComponent: StackView{
            id: authStack;
            anchors.fill: parent

            Connections{
                target: userController
                function onChangePageToAuthentication(isReset,email)
                {
                    authStack.push("qrc:/Account/Authentication.qml",{isReset:isReset,email:email})
                }

                function onUserAuthenticated(){
                    mainLoader.source = "qrc:/StartMemorito.qml"
                }
            }

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
                    if(translator.getCurrentLanguage() !== translator.getLanguages().FA){
                        AppStyle.languageChanged = true
                        translator.updateLanguage(translator.getLanguages().FA) // For Farsi
                        AppStyle.languageChanged = false
                    }
                    else {
                        AppStyle.languageChanged = true
                        translator.updateLanguage(translator.getLanguages().ENG) // For English
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
                    color: isPrimaryBackground ? AppStyle.textOnPrimaryColor
                                               : AppStyle.textColor
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

            initialItem: !splashLoader.active ? "qrc:/Splash/MainSplash.qml"
                                              : isSignIn ? "qrc:/Account/SignIn.qml"
                                                         : "qrc:/Account/SignUp.qml"
        }
    }
}
