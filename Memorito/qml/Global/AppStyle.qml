pragma Singleton
import QtQuick 2.15 // Require for Item and FontLoader
import QtQuick.Controls.Material 2.15 // Require for Material.Color
import Qt.labs.settings 1.1               // Require For SettingDrivers

QtObject {

    property real size1W: UiFunctions.getFontSize  (1) * AppStyle.scaleW
    property real size1H: UiFunctions.getWidthSize (1) * AppStyle.scaleH
    property real size1F: UiFunctions.getHeightSize(1) * AppStyle.scaleF

    property int appTheme: Number(SettingDriver.value("AppTheme",0))
    onAppThemeChanged: { SettingDriver.setValue("AppTheme",appTheme) }

    function setAppTheme(index)
    {
        //statusBar.color = index?"#EAEAEA":"#171717"
        appTheme = index
    }

    function getAppTheme()
    {
        return appTheme
    }

    function setFontSizes(scale)
    {
        AppStyle.scaleF = scale
    }
    function setWidthSizes(scale)
    {
        AppStyle.scaleW = scale
    }
    function setHeightSizes(scale)
    {
        AppStyle.scaleH = scale
    }

    property color textColor                : appTheme ?   "#FFFFFF"     : "#0F110F"
    property color shadowColor              : appTheme ?   "#5c5c5c"   :   "#d6d6d6"
    property color borderColor              : appTheme ?   "#ADFFFFFF" :   "#8D000000"
    property color borderColorOnPrimary     : Material.color(primaryInt,Material.Shade200)
    property color rippleColor              : appTheme ?   "#22171717" :   "#224D4D4D"
    property color primaryColor             : Material.color(primaryInt)
    property color placeholderColor         : appTheme ?   "#B3FFFFFF" :   "#B3000000"
    property color appBackgroundColor       : appTheme ?   "#2F2F2F"   :   "#FAFAFA"
    property color dialogBackgroundColor    : appTheme ?   "#3F3F3F"   :   "#FFFFFF"
    property color textOnPrimaryColor       : textOnPrimaryInt ? "#0F110F": "#FFFFFF"

    property bool languageChanged: false

    property int textOnPrimaryInt : SettingDriver.value("TextOnPrimary",0)
    onTextOnPrimaryIntChanged: {
        if(!languageChanged){
            SettingDriver.setValue("TextOnPrimary",textOnPrimaryInt)
        }
    }

    property int primaryInt : SettingDriver.value("AppColor",5)
    onPrimaryIntChanged: {
        if(!languageChanged){
            SettingDriver.setValue("AppColor",primaryInt)}
    }

    property real scaleF: SettingDriver.value("scaleF",1)
    onScaleFChanged: {
        if(!languageChanged) {
            SettingDriver.setValue("scaleF",scaleF)
        }
    }

    property real scaleW: SettingDriver.value("scaleW",1)
    onScaleWChanged: {
        if(!languageChanged) {
            SettingDriver.setValue("scaleW",scaleW)
        }
    }

    property real scaleH: SettingDriver.value("scaleH",1)
    onScaleHChanged: {
        if(!languageChanged) {
            SettingDriver.setValue("scaleH",scaleH)
        }
    }

    property bool ltr: translator?translator.getCurrentLanguage() === translator.getLanguages().ENG:false

    property var font: FontLoader{ name: "appFont";    source: ltr?"qrc:/Mulish-Regular.ttf":"qrc:/Nahid.ttf" }
    property string appFont: font.name
}
