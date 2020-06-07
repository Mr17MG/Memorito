import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import "./" as App
Dialog {
    id: messageDialog
    width: size1W*310
    height: size1H*185
    modal: true
    padding: 0
    x: -parent.x + (parent.parent===null?0:(parent.parent.width- width)/2)
    y: -parent.y + (parent.parent===null?0:(parent.parent.height- height)/2)
    property string dialogTitle: ""
    property string buttonTitle: ""
    property bool hasBotton: false
    property bool hasTitle: false
    property bool hasCloseIcon: false
    property int btnRightPadding: size1W*25
    property int btnIconRightPadding: ltr?15*size1W:size1W*30
    property int btnWidth: size1W*115
    property string iconSource: "qrc:/Icons/success.svg"
    property alias dialogButton: dialogButton
    property alias buttonIcon: buttonIcon
    Material.background: Material.White
    Image {
        id: close
        visible: hasCloseIcon
        source: "qrc:/Icons/close-thin.svg"
        width: size1W*10
        height: size1H*10
        anchors.right: parent.right
        anchors.rightMargin: size1W*20
        anchors.top: parent.top
        anchors.topMargin: -parent.y + size1W*15
        sourceSize.width: width*2
        sourceSize.height: height*2
        MouseArea{
            anchors.rightMargin: -size1W*10
            anchors.leftMargin: -size1W*10
            anchors.bottomMargin: -size1W*10
            anchors.topMargin: -size1W*10
            anchors.fill: parent
            cursorShape:Qt.PointingHandCursor
            onClicked: messageDialog.close()
        }
    }
    Text {
        visible: hasTitle
        text: dialogTitle
        color: textColor
        anchors.top: parent.top
        anchors.topMargin: -parent.y +size1H*10
        anchors.right: close.left
        anchors.rightMargin: size1W*10
        font { family: appStyle.shabnam; pixelSize: size1F*12 }
        MouseArea{
            anchors.rightMargin: -size1W*10
            anchors.leftMargin: -size1W*10
            anchors.bottomMargin: -size1W*10
            anchors.topMargin: -size1W*10
            anchors.fill: parent
            cursorShape:Qt.PointingHandCursor
            onClicked: messageDialog.close()
        }
    }
    App.Button{
        visible: hasBotton
        text: buttonTitle
        rightPadding: btnRightPadding
        highlighted: true
        implicitHeight: size1H*33
        width: btnWidth
        padding: 0
        id: dialogButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: size1H*35
        font { family: appStyle.shabnam; pixelSize: size1F*12 }
        Material.background: primaryColor
        Image {
            id: buttonIcon
            source: iconSource
            width: size1W*22
            height: size1H*22
            sourceSize.width: width*2
            sourceSize.height: height*2
            anchors.right: parent.right
            anchors.rightMargin: btnIconRightPadding
            z: 2
            anchors.verticalCenter: parent.verticalCenter
        }
    }


}
