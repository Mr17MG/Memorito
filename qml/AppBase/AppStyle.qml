import QtQuick 2.14 // Require for Item and FontLoader
import QtQuick.Controls.Material 2.14 // Require for Material.Color

Item {
    property bool  appTheme: getAppTheme()
    property color textColor                : appTheme ?   "#FFFFFF"     : "#0F110F"
    property color shadowColor              : appTheme ?   "#171717"   :   "#EAEAEA"
    property color borderColor              : appTheme ?   "#ADFFFFFF" :   "#8D000000"
    property color rippleColor              : appTheme ?   "#22171717" :   "#224D4D4D"
    property color primaryColor             : Material.color(primaryInt)
    property color placeholderColor         : appTheme ?   "#B3FFFFFF" :   "#B3000000"
    property color appBackgroundColor       : appTheme ?   "#2F2F2F"   :   "#FAFAFA"
    property color dialogBackgroundColor    : appTheme ?   "#3F3F3F"   :   "#FFFFFF"
    property bool languageChanged: false

    property int primaryInt : appSetting.value("AppColor",5)
    onPrimaryIntChanged: {
        if(!languageChanged)
            appSetting.setValue("AppColor",primaryInt)
    }

    property alias appFont: appFont.name

    FontLoader{ id:appFont; name: "appFont";    source: ltr?"qrc:/Gilroy.otf":"qrc:/Shabnam.ttf" }

}
