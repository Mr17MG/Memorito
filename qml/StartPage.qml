import QtQuick                       // Require For MouseArea and other
import QtQuick.Window                // Require For Screen
import QtQuick.Controls              // Require For Drawer and other
import QtQuick.Controls.Material     // Require For Material Theme

import Memorito.Global

import "qrc:/Splash/" as Splash      // Require For SplashLoader

ApplicationWindow {
    id:rootWindow

    /********************************************************************************/
    //////////////////////// ApplicationWindow Settings //////////////////////////////

    visible: true
    title: qsTr("مموریتو")
    width:  ["android","ios"].indexOf(Qt.platform.os) !== -1? width:SettingDriver.value("AppWidth" ,640)
    height: ["android","ios"].indexOf(Qt.platform.os) !== -1? height:SettingDriver.value("AppHeight",480)

    minimumWidth:  Math.max(Screen.width/ 5,380)
    minimumHeight: Math.max(Screen.height/ 3,480)

    x: ["android","ios"].indexOf(Qt.platform.os) !== -1?0:SettingDriver.value("AppX",40)
    y: ["android","ios"].indexOf(Qt.platform.os) !== -1?0:SettingDriver.value("AppY",40)

    onClosing: {
        if(["android","ios"].indexOf(Qt.platform.os) === -1)
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

    Connections{
        target: translator
        function onLanguageChanged() {
            AppStyle.ltr = translator ? translator.getCurrentLanguage() === translator.getLanguages().ENG
                                      : false
        }
    }

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

    AppShortcut{}

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

    /********************************************************************************/
    ////////////////////////////////////////////////////////////////////

    Connections{
        target: logger
        property var busyLoader
        function onSuccessLog(message) {
            UsefulFunc.showLog(message,Memorito.Success)
        }

        function onErrorLog(message) {
            UsefulFunc.showLog(message,Memorito.Error)

        }

        function onWarningLog(message) {
            UsefulFunc.showLog(message,Memorito.Warning)

        }

        function onInfoLog(message) {
            UsefulFunc.showLog(message,Memorito.Info)

        }

        function onLoading(title)
        {
            UsefulFunc.setRootWindowVar(rootWindow)
            logger.busyLoader = UsefulFunc.showBusy(title??"")
        }

        function onLoaded()
        {
            if(logger.busyLoader)
                logger.busyLoader.close()
        }
    }

}
