import QtQuick 2.14 // Require for Item and FontLoader
import QtQuick.Controls.Material 2.14 // Require for Material.Color

Item {
    property color textColor : getAppTheme()?"white":"#0f110f"
    property color primaryColor : Material.color(primaryInt)
    property color shadowColor : getAppTheme()?"#171717":"#EAEAEA"

    property bool languageChanged: false

    property int primaryInt : appSetting.value("AppColor",5)
    onPrimaryIntChanged: {
        if(!languageChanged)
            appSetting.setValue("AppColor",primaryInt)
    }

    property alias appFont: appFont.name

    FontLoader{
        id:appFont
        name: "appFont"
        source: ltr?"qrc:/Gilroy.otf":"qrc:/Shabnam.ttf"
    }

}
