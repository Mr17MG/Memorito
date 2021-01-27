import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import Components 1.0
import Global 1.0

AppDialog {
    id: messageDialog
    x: (parent.width- width)/2
    y: (parent.height- height)/2
    property alias text : textContainer.text
    property var callback
    property string msgTitle :""
    onVisibleChanged: {
        if(!visible && typeof destroy === "function")
            destroy()
    }
    height: 160*AppStyle.size1W + textContainer.lineCount * 21*AppStyle.size1W
    hasButton: true
    dialogButton.onClicked: {close()}
    onClosed: {
        if(callback!==undefined )
            callback();
    }
    Shortcut {
        sequences: ["Esc", "Back"]
        enabled: messageDialog.visible
        onActivated: {
            messageDialog.close()
        }
    }
    buttonTitle: qsTr("تایید")
    dialogButton.anchors.bottomMargin: AppStyle.size1W*25
    Text {
        id: title
        text: msgTitle?msgTitle:qsTr("خطا")
        font { family: AppStyle.appFont; pixelSize: AppStyle.size1F*17;bold: true }
        anchors.top: parent.top
        anchors.topMargin: AppStyle.size1H*10
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        color: textColor
        Rectangle{
            color: "#ccc"
            height: AppStyle.size1H
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -AppStyle.size1H*5
            width: parent.width - AppStyle.size1W*40
        }
    }
    Text {
        id: textContainer
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        anchors.top: title.bottom
        anchors.topMargin: AppStyle.size1H*25
        anchors.right: parent.right
        anchors.rightMargin: AppStyle.size1W*15
        anchors.left: parent.left
        anchors.leftMargin: AppStyle.size1W*15
        font { family: AppStyle.appFont; pixelSize: AppStyle.size1F*14 }
        color: textColor
    }

}
