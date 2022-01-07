import QtQuick 
import QtQuick.Controls.Material 
import QtQuick.Controls.Material.impl 
import Memorito.Global

Item {
    property string pageSource: ""
    property string title:""
    property string iconSource: ""
    property bool flat: false
    property string buttonColor: ""
    property string buttonTextColor: "white"
    property bool buttonEnabled: true
    property int radiusBtn: AppStyle.size1H*15
    property int fontSize: AppStyle.size1F*25
    property alias icon: itemImage
    width: AppStyle.size1W*200
    height: AppStyle.size1H*80
    signal buttonClicked
    Rectangle{
        id:root
        width: parent.width
        height: parent.height
        radius: radiusBtn
        border.color: flat?AppStyle.textColor:"transparent"
        border.width: AppStyle.size1W
        color: flat?"transparent":(buttonEnabled?buttonColor:"#cbcbcb")
        Text {
            id: name
            text: title
            font { family: AppStyle.appFont; pixelSize: fontSize;bold: true }
            color: buttonEnabled?buttonTextColor:"#ebebeb"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: iconSource?AppStyle.size1W*5:0
        }
        Image {
            id: itemImage
            source:iconSource
            visible: iconSource?true:false
            width: AppStyle.size1W*10
            height: iconSource?AppStyle.size1H*12:0
            sourceSize.width: width*2
            sourceSize.height: height*2
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: -AppStyle.size1W*22
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
