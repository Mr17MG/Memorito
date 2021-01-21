import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import "qrc:/Components" as App

Dialog{
    id:busy
    property alias indicator: indicator
    property string message: ""
    closePolicy: Dialog.NoAutoClose
    width: text.width + 100 *size1W
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
    App.BusyIndicator{
        id:indicator
        anchors.bottom: parent.bottom
        anchors.centerIn: parent
        Material.accent: appStyle.primaryColor
    }
    Text{
        id:text
        anchors.top: indicator.bottom
        anchors.topMargin: size1H*10
        anchors.horizontalCenter: indicator.horizontalCenter
        text: message !== ""?message : qsTr("در حال بارگذاری")
        font { family: appStyle.appFont ; pixelSize: size1F*35;bold:true}
        color: appStyle.primaryColor
    }
}
