import QtQuick 2.14
import QtQuick.Controls.Material 2.14

QtObject {
    property color textColor : getAppTheme()?"white":"black"
    property color primaryColor : Material.color(primaryInt)
    property color shadowColor : getAppTheme()?"#171717":"#EAEAEA"

    property int primaryInt : appSetting.value("AppColor",5)
    onPrimaryIntChanged: {
        appSetting.setValue("AppColor",primaryInt)
    }


}
