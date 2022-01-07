import QtQuick 
import QtQuick.Controls 
import Qt5Compat.GraphicalEffects

import Memorito.Global

Drawer {
    id:root
    property alias text : text.text
    property var callAfterClose

    property int index: 0
    property int index2: 0
    property int endTime : 5000
    property int now: 1000
    property int logType: Memorito.Info;

    property color baseColor: {
        switch(logType){
        case Memorito.Success:
            return "#4E8C7C";
        case Memorito.Error:
            return "#C12A4B"
        case Memorito.Warning :
            return "#EE8D31"
        case Memorito.Info :
            return "#006FE0"
        }
    }

    modal: false
    edge: AppStyle.ltr ? Qt.LeftEdge
                        : Qt.RightEdge
    closePolicy: Dialog.NoAutoClose

    width: text.width + 150*AppStyle.size1W
    height: AppStyle.size1H*80 + text.height

    background: Rectangle{
        color: baseColor
        radius: AppStyle.size1W*10
        border.width: 0
        Rectangle{
            id:progress
            opacity: 0.5
            color: Qt.lighter(baseColor)
            height: 10*AppStyle.size1H
            anchors{
                bottom: parent.bottom
            }
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

    onVisibleChanged: {
        try{
            if(!visible && typeof destroy === "function")
                destroy()
        }catch(e){}
    }

    onClosed: {
        if(typeof callAfterClose === "function")
            callAfterClose()
    }

    Behavior on y{
        enabled: visible
        NumberAnimation{duration: 160}
    }

    Rectangle{
        id: logTypeIconRect
        width: 50*AppStyle.size1W
        height: width
        radius: width

        anchors{
            right: parent.right
            rightMargin: 10*AppStyle.size1W
            top: parent.top
            topMargin: 20*AppStyle.size1H
        }

        Image {
            id: logTypeIcon
            visible: false
            height: width
            width: parent.width/3*2
            sourceSize: Qt.size(width,height)
            source: {
                switch(logType){
                case Memorito.Success:
                    return "qrc:/check.svg";
                case Memorito.Error:
                    return "qrc:/close.svg";
                case Memorito.Warning :
                case Memorito.Info :
                    return "qrc:/info.svg";
                }
            }
            anchors{
                centerIn: parent
            }
        }

        ColorOverlay{
            source: logTypeIcon
            color: baseColor
            anchors.fill: logTypeIcon
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
            left: parent?parent.left:undefined
            leftMargin: AppStyle.size1W*20
            top: parent.top
            topMargin: AppStyle.size1H*20
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
    }

    Text{
        id: titleText
        color: "white"
        font {
            family: AppStyle.appFont;
            pixelSize: AppStyle.size1F*30;
            bold: true
        }
        text: {
            switch(logType){
            case Memorito.Success:
                return qsTr("موفق!");
            case Memorito.Error:
                return qsTr("خطا!")
            case Memorito.Warning :
                return qsTr("هشدار!")
            case Memorito.Info :
                return qsTr("توجه!")
            }
        }
        anchors{
            right: logTypeIconRect.left
            rightMargin: AppStyle.size1W*10
            left: close.right
            leftMargin: AppStyle.size1W*10
            top: parent.top
            topMargin: AppStyle.size1H*10
        }

    }

    Text{
        id:text
        text: "محل نمایش خطا"
        color: "white"
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

        anchors{
            left: close.right
            rightMargin: AppStyle.size1W*10
            top: titleText.bottom
        }

        font {
            family: AppStyle.appFont;
            pixelSize: AppStyle.size1F*27;
            bold: false
        }

        onTextChanged: {
            if( width > (UsefulFunc.rootWindow.width - 160*AppStyle.size1W))
                width = (UsefulFunc.rootWindow.width - 160*AppStyle.size1W)
            else {
                anchors.right= logTypeIconRect.left
                anchors.rightMargin= AppStyle.size1W*10
            }
        }
    }
}
