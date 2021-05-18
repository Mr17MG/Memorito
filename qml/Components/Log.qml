import QtQuick 2.15
import QtQuick.Controls 2.15
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
    width:  text.width + 80*AppStyle.size1W
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
        color: isError?"#ff3333":"#4BB543"
        radius: AppStyle.size1W*10
        border.width: 0
        Rectangle{
            id:progress
            opacity: 0.5
            color: "#5c5c5c"
            height: parent.height
            PropertyAnimation {
                    target: progress;
                    properties: "width"
                    from: 0;
                    to: root.width
                    duration: endTime - 800
                    running: root.visible
               }
        }
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
        anchors{
            right: close.left
            rightMargin: AppStyle.size1W*10
            verticalCenter: parent?parent.verticalCenter:undefined
        }
        onTextChanged: {
            if( width > (UsefulFunc.rootWindow.width - 75*AppStyle.size1W))
                width = (UsefulFunc.rootWindow.width - 75*AppStyle.size1W)
        }

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        font { family: AppStyle.appFont; pixelSize: AppStyle.size1F*30;bold:false }

    }
}
