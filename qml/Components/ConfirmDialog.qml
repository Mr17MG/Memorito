import QtQuick 2.14
import QtQuick.Controls.Material 2.14
import "./" as App
App.Dialog{
    id:dialog
    property string dialogText: ""
    property string dialogButtonColor: Material.color(primaryColor)
    property alias acceptBtn: acceptBtn
    property alias canselBtn: canselBtn
    signal canseled
    signal accepted
    property var acceptAction
    width: size1W*320
    height: size1H*180 + text.lineCount * 20*size1H
    dialogTitle: qsTr("انصراف")
    anchors.centerIn: parent
    hasTitle: false
    hasCloseIcon: false
    Text {
        id: title
        text: dialogTitle
        color: textColor
        font { family: appStyle.appFont; pixelSize: size1F*17;bold: true }
        anchors.top: parent.top
        anchors.topMargin: size1H*10
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        Rectangle{
            color: "#ccc"
            height: size1H
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -size1H*5
            width: parent.width - size1W*40
        }
    }
    Text {
        id: text
        text:dialogText
        color: textColor
        font { family: appStyle.appFont; pixelSize: size1F*17 }
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
        anchors.top: title.bottom
        anchors.topMargin: size1H*25
        wrapMode: Text.WordWrap
    }
    Flow{
        layoutDirection: "RightToLeft"
        anchors.right: parent.right
        anchors.rightMargin: size1W*25
        anchors.bottom: parent.bottom
        anchors.bottomMargin: size1H*20
        spacing: size1W*30

        ConfirmDialogButton{
            id:acceptBtn
            title: qsTr("بلی")
            onButtonClicked: {
                if(acceptAction!==undefined )
                    acceptAction();
                else
                    accepted()
                dialog.close()
            }
            buttonColor:dialogButtonColor
        }
        ConfirmDialogButton{
            id:canselBtn
            title: qsTr("خیر")
            flat:true
            onButtonClicked: {
                canseled()
                dialog.close()
            }
            buttonTextColor: textColor
        }
    }
}
