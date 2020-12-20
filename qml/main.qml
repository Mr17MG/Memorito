import QtQuick 2.14 // Require For MouseArea and other
import QtQuick.Window 2.14 // Require For Screen
import QtQuick.Controls 2.14 // Require For Drawer and other
import QtQuick.Controls.Material 2.14 // // Require For Material Theme
import Qt.labs.settings 1.1 // Require For appSettings
import "qrc:/AppBase/" as Base
import "qrc:/Functions/" as F
import QtQuick.LocalStorage 2.14 /*as SQLITE*/
import "qrc:/Splash/" as Splash
import MTools 1.0
ApplicationWindow {
    id:rootWindow

    /********************************************************************************/
    //////////////////////// ApplicationWindow Settings //////////////////////////////

    visible: true
    title: qsTr("مموریتو")
    width: Qt.platform.os === "android" || Qt.platform.os === "ios"?width:appSetting.value("AppWidth" ,640)
    height: Qt.platform.os === "android" || Qt.platform.os === "ios"?height:appSetting.value("AppHeight",480)

    minimumWidth: Screen.width/5<380?380:Screen.width/5
    minimumHeight: Screen.height/3<480?480:Screen.height/3

    x:Qt.platform.os === "android" || Qt.platform.os === "ios"?0:appSetting.value("AppX",40)
    y:Qt.platform.os === "android" || Qt.platform.os === "ios"?0:appSetting.value("AppY",40)

    onClosing: {
        if(Qt.platform.os !== "android" || Qt.platform.os !== "ios")
        {
            appSetting.setValue("AppX",rootWindow.x)
            appSetting.setValue("AppY",rootWindow.y)

            appSetting.setValue("AppWidth", rootWindow.width)
            appSetting.setValue("AppHeight",rootWindow.height)
        }
    }

    /********************************************************************************/
    ////////////////////////////////// Multi Language ////////////////////////////////

    property bool ltr: translator?translator.getCurrentLanguage() === translator.getLanguages().ENG:false
    LayoutMirroring.enabled: ltr
    LayoutMirroring.childrenInherit: true

    /********************************************************************************/
    ///////////////////////////////// Responsive UI //////////////////////////////////

    property real size1W//: uiFunctions.getWidthSize(1,Screen)
    property real size1H//: uiFunctions.getHeightSize(1,Screen)
    property real size1F//: uiFunctions.getFontSize(1,Screen)
    Component.onCompleted: {
        //For one Display
        size1W= uiFunctions.getWidthSize(1,Screen)
        size1H= uiFunctions.getHeightSize(1,Screen)
        size1F= uiFunctions.getFontSize(1,Screen)
    }
    /********************************************************************************/
    ////////////////////////////// Application appStyle ////////////////////////////////
    Base.AppStyle{id:appStyle}
    MTools{id:myTools}
    Material.theme: Number(appSetting.value("AppTheme",0))
    Material.onThemeChanged: {
        appSetting.setValue("AppTheme",Material.theme)
    }

    Material.primary: appStyle.primaryColor

    function setAppTheme(index)
    {
        //statusBar.color = index?"#EAEAEA":"#171717"
        Material.theme = index
    }

    function getAppTheme()
    {
        return Material.theme
    }

    /********************************************************************************/
    ////////////////////////////// useful Component ////////////////////////////////

    F.UiFunctions { id: uiFunctions }
    F.UsefulFunctions{ id: usefulFunc }
    F.UserDatabase{ id: userDbFunc }

    Settings{ id: appSetting }

    /********************************************************************************/
    //////////////////////////////// Main App Loader /////////////////////////////////

    property string domain: isDebug?Qt.platform.os === "android"?"http://192.168.0.117"
                                                                :"http://memorito.local"
                                   :"https://memorito.ir"

    property var dataBase: LocalStorage.openDatabaseSync("Memorito_database","1.0","a GTD based Project",10000)
    ListModel{ id: users }
    property var currentUser

    Loader{
        id:mainLoader
        anchors.fill: parent
        asynchronous: false
        active: true
        sourceComponent: Splash.SplashLoader{}
    }

}
