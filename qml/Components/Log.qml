import QtQuick 2.14
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.14

Drawer {
    id:root
    property alias text : text.text
    property bool isError: true
    modal: false
    closePolicy: Dialog.NoAutoClose
    width: 360*size1W
    height: size1H*30 + text.height
    background: Rectangle{
        color: isError?"#F44336":"#8BC34A"
        radius: size1W*20
        border.width: 0
    }
    Timer{
        interval: 5000;running: root.visible;repeat: false
        onTriggered: root.visible=false
    }
    MouseArea{anchors.fill: parent}
    Image{
        id:close
        anchors.right: parent?parent.right:undefined
        anchors.rightMargin: size1W*20
        anchors.verticalCenter: text.verticalCenter
        width: size1W*20
        height: width
        sourceSize.width: width*2
        sourceSize.height: height*2
        source: "qrc:/close.svg"
        visible: false
    }
    ColorOverlay{
        MouseArea{
            anchors.fill: parent
            anchors.top: parent?parent.top:undefined
            anchors.topMargin: -10*size1H
            anchors.bottom: parent?parent.bottom:undefined
            anchors.bottomMargin: -10*size1H
            anchors.left: parent?parent.left:undefined
            anchors.leftMargin: -10*size1W
            anchors.right: parent?parent.right:undefined
            anchors.rightMargin: -10*size1W
            cursorShape:Qt.PointingHandCursor
            onClicked: {
                root.visible=false
            }
        }
        color: "white"
        anchors.fill: close
        source: close
    }

    Text{
        id:text
        text: "محل نمایش خطا"
        color: "white"
        width: parent.width - close.width
        anchors.right: close.left
        anchors.rightMargin: size1W*10
        anchors.left: parent.left
        anchors.leftMargin: size1W*5
        anchors.verticalCenter: parent?parent.verticalCenter:undefined
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
        font { family: appStyle.appFont; pixelSize: size1F*30;bold:false }
    }
}
