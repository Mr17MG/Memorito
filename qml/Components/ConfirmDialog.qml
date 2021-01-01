import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14

Dialog{
    id:dialog
    property string dialogText: ""
    property string dialogTitle: ""
    property string dialogButtonColor: appStyle.primaryColor
    property alias acceptBtn: acceptBtn
    property alias canselBtn: canselBtn
    property var canseled
    property var accepted
    signal acceptSignal
    property real oneLineWidth
    width: rootWindow.width/2<480*size1W ? 480*size1W:rootWindow.width/2>1000*size1W?1000*size1W:rootWindow.width/2

    height: size1H*280 + text.height
    modal: true
    closePolicy: Dialog.NoAutoClose
    Shortcut {
        sequences: ["Esc", "Back"]
        enabled: dialog.visible
        onActivated: {
            dialog.close()
        }
    }
    x: -parent.x + (parent===null?0:(parent.width- width)/2)
    y: -parent.y + (parent===null?0:(parent.height- height)/2)
    Text {
        id: title
        text: dialogTitle
        color: appStyle.textColor
        font { family: appStyle.appFont; pixelSize: size1F*32;bold: true }
        anchors.top: parent.top
        anchors.topMargin: size1H*10
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        Rectangle{
            color: "#ccc"
            height: 2*size1H
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -size1H*5
            width: parent.width - size1W*40
        }
    }
    Text {
        id: text
        text: dialogText
        color: appStyle.textColor
        font { family: appStyle.appFont; pixelSize: size1F*30 }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        width: parent.width
        anchors{
            top: title.bottom
            topMargin: size1H*40
        }
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    }
    Flow{
        id:flow
        layoutDirection: ltr? Qt.LeftToRight : Qt.RightToLeft
        anchors{
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: size1H*0
        }
        spacing: size1W*30
        ConfirmDialogButton{
            id:acceptBtn
            title: qsTr("بلی")
            onButtonClicked: {
                if(accepted)
                    accepted()
                acceptSignal()
                dialog.close()
            }
            buttonColor:dialogButtonColor
        }
        ConfirmDialogButton{
            id:canselBtn
            title: qsTr("خیر")
            flat:true
            onButtonClicked: {
                if(canseled)
                    canseled()
                dialog.close()
            }
            buttonTextColor: appStyle.textColor
        }
    }
}
