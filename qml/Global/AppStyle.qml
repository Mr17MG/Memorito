pragma Singleton
import QtQuick 2.14 // Require for Item and FontLoader
import QtQuick.Controls.Material 2.14 // Require for Material.Color
import Qt.labs.settings 1.1               // Require For SettingDrivers

QtObject {

    property real size1W//: UiFunctions.getWidthSize(1,Screen)
    property real size1H//: UiFunctions.getHeightSize(1,Screen)
    property real size1F//: UiFunctions.getFontSize(1,Screen)

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


    property color textColor                : appTheme ?   "#FFFFFF"     : "#0F110F"
    property color shadowColor              : appTheme ?   "#171717"   :   "#EAEAEA"
    property color borderColor              : appTheme ?   "#ADFFFFFF" :   "#8D000000"
    property color rippleColor              : appTheme ?   "#22171717" :   "#224D4D4D"
    property color primaryColor             : Material.color(primaryInt)
    property color placeholderColor         : appTheme ?   "#B3FFFFFF" :   "#B3000000"
    property color appBackgroundColor       : appTheme ?   "#2F2F2F"   :   "#FAFAFA"
    property color dialogBackgroundColor    : appTheme ?   "#3F3F3F"   :   "#FFFFFF"
    property color textOnPrimaryColor       : textOnPrimaryInt ? "#0F110F": "#FFFFFF"

    property bool languageChanged: false

    property int textOnPrimaryInt : SettingDriver.value("TextOnPrimary",0)
    onTextOnPrimaryIntChanged: {
        if(!languageChanged)
            SettingDriver.setValue("TextOnPrimary",textOnPrimaryInt)
    }

    property int primaryInt : SettingDriver.value("AppColor",5)
    onPrimaryIntChanged: {
        if(!languageChanged)
            SettingDriver.setValue("AppColor",primaryInt)
    }

//    property aSettingDrivernt: appFont.name
    property bool ltr: translator?translator.getCurrentLanguage() === translator.getLanguages().ENG:false

    property var font: FontLoader{ name: "appFont";    source: ltr?"qrc:/Gilroy.otf":"qrc:/Shabnam.ttf" }
    property string appFont: font.name
}
