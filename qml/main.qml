import QtQuick 2.14 // Require For MouseArea and other
import QtQuick.Window 2.14 // Require For Screen
import QtQuick.Controls 2.14 // Require For Drawer and other
import QtQuick.Controls.Material 2.14 // // Require For Material Theme
import Qt.labs.settings 1.1 // Require For appSettings
import QtGraphicalEffects 1.14 // Require for DropShadow
import "qrc:/AppBase/" as Base
import "qrc:/Functions/" as F

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
        size1W= uiFunctions.getWidthSize(1,Screen)
        size1H= uiFunctions.getHeightSize(1,Screen)
        size1F= uiFunctions.getFontSize(1,Screen)
    }

    /********************************************************************************/
    ////////////////////////////// Application appStyle ////////////////////////////////
    Base.AppStyle{id:appStyle}

    Material.theme: Number(appSetting.value("AppTheme",0))
    Material.onThemeChanged: {
        appSetting.setValue("AppTheme",Material.theme)
    }

    Material.primary: appStyle.primaryColor

    function setAppTheme(index)
    {
        //        statusBar.color = index?"#EAEAEA":"#171717"
        Material.theme = index
    }

    function getAppTheme()
    {
        return Material.theme
    }

    /********************************************************************************/
    ////////////////////////////// useful Component ////////////////////////////////

    F.UiFunctions { id : uiFunctions }
    F.UsefulFunctions{id:usefulFunc}
    Settings{id:appSetting}

    /********************************************************************************/
    //////////////////////////////// Splash Screen /////////////////////////////////
    Image {
        id:iconLogo
        source: "qrc:/icon.png"
        width: 150*size1W
        height: width
        anchors.centerIn: parent
        visible: mainLoader.status !== Loader.Ready
    }
    DropShadow {
        id:dropShadow
        anchors.fill: iconLogo
        horizontalOffset: 0*size1W
        verticalOffset: 0*size1H
        radius: 50*size1W
        samples: 30*size1W
        color: Material.color(appStyle.primaryInt,Material.Shade200)
        source: iconLogo
        visible: mainLoader.status !== Loader.Ready
    }

    Text {
        id: waitText
        text: qsTr("ساخته شده با ♥")
        font{family: appStyle.appFont;pixelSize: 30*size1F;bold: true}
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40*size1W
        anchors.horizontalCenter: parent.horizontalCenter
        color: appStyle.textColor
        visible: mainLoader.status !== Loader.Ready
    }

    /********************************************************************************/
    //////////////////////////////// Main App Loader /////////////////////////////////
    //---------------------- Load Memorito as Main Page -----------------------------/

    Loader{
        id:mainLoader
        anchors.fill: parent
        asynchronous: false
        active: true
//        sourceComponent: Memorito{id:memorito}
        source: "qrc:/Account/AccountMain.qml"
    }

}
