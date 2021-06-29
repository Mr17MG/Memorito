import QtQuick 2.15                       // Require For MouseArea and other
import QtQuick.Window 2.15                // Require For Screen
import QtQuick.Controls 2.15              // Require For Drawer and other
import QtQuick.Controls.Material 2.15     // Require For Material Theme
import "qrc:/Splash/" as Splash           // Require For SplashLoader
import Global 1.0

ApplicationWindow {
    id:rootWindow

    /********************************************************************************/
    //////////////////////// ApplicationWindow Settings //////////////////////////////

    visible: true
    title: qsTr("مموریتو")
    width:  Qt.platform.os === "android" || Qt.platform.os === "ios"? width:SettingDriver.value("AppWidth" ,640)
    height: Qt.platform.os === "android" || Qt.platform.os === "ios"? height:SettingDriver.value("AppHeight",480)

    minimumWidth:  Screen.width/ 5< 380? 380  : Screen.width/ 5
    minimumHeight: Screen.height/ 3< 480? 480: Screen.height/ 3

    x: Qt.platform.os === "android" || Qt.platform.os === "ios"?0:SettingDriver.value("AppX",40)
    y: Qt.platform.os === "android" || Qt.platform.os === "ios"?0:SettingDriver.value("AppY",40)

    onClosing: {
        if(Qt.platform.os !== "android" || Qt.platform.os !== "ios")
        {
            SettingDriver.setValue("AppX",rootWindow.x)
            SettingDriver.setValue("AppY",rootWindow.y)

            SettingDriver.setValue("AppWidth", rootWindow.width)
            SettingDriver.setValue("AppHeight",rootWindow.height)
        }
    }

    /********************************************************************************/
    ////////////////////////////// Multi Language ////////////////////////////////////

    LayoutMirroring.enabled: AppStyle.ltr
    LayoutMirroring.childrenInherit: true

    /********************************************************************************/
    ///////////////////////////////// Responsive UI //////////////////////////////////
    Component.onCompleted: {
        UsefulFunc.setRootWindowVar(rootWindow)
    }

    /********************************************************************************/
    ////////////////////////////// Application AppStyle ////////////////////////////////

    Material.theme:   AppStyle.appTheme
    Material.primary: AppStyle.primaryColor
    Material.accent:  AppStyle.primaryColor

    /********************************************************************************/
    ////////////////////////////// useful Component ////////////////////////////////

    /********************************************************************************/
    //////////////////////////////// Main App Loader /////////////////////////////////

    Loader{
        id:mainLoader
        anchors.fill: parent
        asynchronous: false
        active: true        
        Component.onCompleted: {
            UsefulFunc.setMainLoaderVar(mainLoader)
        }
        sourceComponent: Splash.SplashLoader{}
    }
    ////////////////////////////////////////////////////////////////////
    AppShortcut{}
}
