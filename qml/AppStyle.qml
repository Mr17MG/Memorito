import QtQuick 2.14 // Require for Item and FontLoader
import QtQuick.Controls.Material 2.14 // Require for Material.Color

Item {
    property color textColor : getAppTheme()?"white":"black"
    property color primaryColor : Material.color(primaryInt)
    property color shadowColor : getAppTheme()?"#171717":"#EAEAEA"

    property int primaryInt : appSetting.value("AppColor",5)
    onPrimaryIntChanged: {
        appSetting.setValue("AppColor",primaryInt)
    }

    property alias shabnam: shabnamFont.name

    FontLoader{
        id:shabnamFont
        name: "shabnam"
        source: "qrc:/Shabnam.ttf"
    }
}
