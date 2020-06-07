import QtQuick 2.12
import QtQuick.Controls.Material 2.14
import QtQuick.Controls.Material.impl 2.14


Item {
    property string pageSource: ""
    property string title:""
    property string iconSource: ""
    property bool flat: false
    property string buttonColor: ""
    property string buttonTextColor: "white"
    property bool buttonEnabled: true
    property int radius‌Btn: size1H*5
    property int fontSize: size1F*15
    property alias icon: itemImage
    width: size1W*120
    height: size1H*40
    signal buttonClicked
    Rectangle{
        id:root
        width: parent.width
        height: parent.height
        radius: radius‌Btn
        border.color: flat?textColor:"transparent"
        border.width: size1W
        color: flat?"transparent":(buttonEnabled?buttonColor:"#cbcbcb")
        Text {
            id: name
            text: title
            font { family: appStyle.shabnam; pixelSize: fontSize;bold: true }
            color: buttonEnabled?buttonTextColor:"#ebebeb"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: iconSource?size1W*5:0
        }
        Image {
            id: itemImage
            source:iconSource
            visible: iconSource?true:false
            width: size1W*10
            height: iconSource?size1H*12:0
            sourceSize.width: width*2
            sourceSize.height: height*2
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: -size1W*22
        }
    }
    MouseArea{
        id:control
        cursorShape:Qt.PointingHandCursor
        anchors.fill: root
        onClicked: {
            buttonClicked()
        }
        enabled: buttonEnabled
    }
    Ripple {
        clipRadius: 2
        width: parent.width
        height: parent.height
        pressed: control.pressed
        anchor: control
        active: control.focus
        color: "#0D000000"
    }
}
