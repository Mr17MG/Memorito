import QtQuick 2.14
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.14
import Global 1.0

Drawer {
    id:root
    property alias text : text.text
    property bool isError: true
    property var callAfterClose
    property int index: 0
    property int index2: 0
    property int endTime : 5000
    property int now: 1000
    onVisibleChanged: {
        try{
            if(!visible && typeof destroy === "function")
                destroy()
        }catch(e){console.trace()}
    }
    modal: false
    closePolicy: Dialog.NoAutoClose
    width: 360*AppStyle.size1W
    height: AppStyle.size1H*30 + text.height
    onClosed: {
        if(typeof callAfterClose === "function")
            callAfterClose()
    }
    edge: !AppStyle.ltr ? Qt.LeftEdge : Qt.RightEdge
    Behavior on y{
        enabled: visible
        NumberAnimation{duration: 160}
    }

    background: Rectangle{
        color: isError?"#F44336":"#8BC34A"
        radius: AppStyle.size1W*10
        border.width: 0
    }
    Timer{
        id:timer2
        interval: 1000;running: root.visible;repeat: true
        onTriggered: {
            root.now += 1000
        }
    }
    Timer{
        id:timer
        interval: endTime;running: root.visible;repeat: false
        onTriggered: {root.visible=false}
    }
    MouseArea{anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { root.visible=false } }
    Image{
        id:close
        anchors{
            right: parent?parent.right:undefined
            rightMargin: AppStyle.size1W*20
            verticalCenter: text.verticalCenter
        }
        width: AppStyle.size1W*30
        height: width
        sourceSize.width: width*2
        sourceSize.height: height*2
        source: "qrc:/close.svg"
        visible: false
    }
    ColorOverlay{
        color: "white"
        anchors.fill: close
        source: close
        MouseArea{
            cursorShape:Qt.PointingHandCursor
            anchors{
                fill: parent
                top: parent?parent.top:undefined
                topMargin: -10*AppStyle.size1H
                bottom: parent?parent.bottom:undefined
                bottomMargin: -10*AppStyle.size1H
                left: parent?parent.left:undefined
                leftMargin: -10*AppStyle.size1W
                right: parent?parent.right:undefined
                rightMargin: -10*AppStyle.size1W
            }
            onClicked: {
                root.visible=false
            }
        }
    }

    Text{
        id:text
        text: "محل نمایش خطا"
        color: "white"
        width: parent.width - close.width
        anchors{
            right: close.left
            rightMargin: AppStyle.size1W*10
            left: parent?parent.left:undefined
            leftMargin: AppStyle.size1W*5
            verticalCenter: parent?parent.verticalCenter:undefined
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
        font { family: AppStyle.appFont; pixelSize: AppStyle.size1F*30;bold:false }
    }
}
