import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import Components 1.0
import Global 1.0

AppDialog{
    id:busy
    property alias indicator: indicator
    property string message: ""
    onVisibleChanged: {
        if(!visible)
            destroy()
    }
    closePolicy: Dialog.NoAutoClose
    width: text.width + 100 *AppStyle.size1W
    height: width
    background: Rectangle{color: "transparent"}
    x: -parent.x + (parent===null?0:(parent.width- width)/2)
    y: -parent.y + (parent===null?0:(parent.height- height)/2)
    modal : true
    property var callback
    Shortcut {
        sequences: ["Esc", "Back"]
        enabled: busy.visible
        onActivated: {
            callback()
        }
    }
    AppBusyIndicator{
        id:indicator
        anchors.bottom: parent.bottom
        anchors.centerIn: parent
        Material.accent: AppStyle.primaryColor
    }
    Text{
        id:text
        anchors.top: indicator.bottom
        anchors.topMargin: AppStyle.size1H*10
        anchors.horizontalCenter: indicator.horizontalCenter
        text: message !== ""?message : qsTr("در حال بارگذاری")
        font { family: AppStyle.appFont ; pixelSize: AppStyle.size1F*35;bold:true}
        color: AppStyle.primaryColor
        style: Text.Raised;
        styleColor: AppStyle.textOnPrimaryColor
    }
}
