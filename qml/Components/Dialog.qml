import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import "qrc:/Components" as App
import QtGraphicalEffects 1.14
Dialog {
    id: dialog
    width: size1W*310
    height: size1H*185
    modal: true
    padding: 0
    Overlay.modal: Rectangle {
        color: appStyle.appTheme?"#aa606060":"#80000000"
    }
    x: -parent.x + (parent.parent===null?0:(parent.parent.width- width)/2)
    y: -parent.y + (parent.parent===null?0:(parent.parent.height- height)/2)
    property string dialogTitle: qsTr("انصراف")
    property string buttonTitle: qsTr("ثبت")
    property bool hasButton: false
    property bool hasTitle: false
    property bool hasCloseIcon: false
    property int btnRightPadding: size1W*25
    property int btnIconRightPadding: ltr?15*size1W:size1W*30
    property int btnWidth: size1W*300
    property string iconSource: "qrc:/check.svg"
    property alias dialogButton: dialogButton
    property alias buttonIcon: buttonIcon
    Material.background: Material.White
    Shortcut {
        sequences: ["Esc", "Back"]
        enabled: dialog.visible
        onActivated: {
            dialog.close()
        }
    }
    Image {
        id: close
        width: size1W*20
        height: width
        source: "qrc:/close.svg"
        sourceSize.width: width*2
        sourceSize.height: height*2
        visible: false
        anchors{
            right: parent.right
            rightMargin: size1W*20
            top: parent.top
            topMargin: -parent.y + size1W*15

        }
    }

    ColorOverlay{
        visible: hasCloseIcon
        anchors.fill: close
        source: close
        color: appStyle.textColor
        MouseArea{
            anchors{
                fill: parent
                rightMargin: -size1W*10
                leftMargin: -size1W*10
                bottomMargin: -size1W*10
                topMargin: -size1W*10
            }
            cursorShape:Qt.PointingHandCursor
            onClicked: dialog.close()
        }
    }

    Text {
        visible: hasTitle
        text: dialogTitle
        color: appStyle.textColor
        anchors{
            verticalCenter: close.verticalCenter
            right: close.left
            rightMargin: size1W*10
        }
        font { family: appStyle.appFont; pixelSize: size1F*25 }
        MouseArea{
            anchors{
                rightMargin: -size1W*10
                leftMargin: -size1W*10
                bottomMargin: -size1W*10
                topMargin: -size1W*10
                fill: parent
            }
            cursorShape:Qt.PointingHandCursor
            onClicked: dialog.close()
        }
    }

    App.Button{
        id: dialogButton
        visible: hasButton
        text: buttonTitle
        rightPadding: btnRightPadding
        width: btnWidth
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: size1H*35
        font { family: appStyle.appFont; pixelSize: size1F*30 }
        Material.background: appStyle.primaryColor
        Material.foreground: "white"
        radius: 30*size1W
        Image {
            id: buttonIcon
            source: iconSource
            width: size1W*40
            height: width
            sourceSize.width: width*2
            sourceSize.height: height*2
            anchors.right: parent.right
            anchors.rightMargin: btnIconRightPadding
            anchors.verticalCenter: parent.verticalCenter
            visible: false
        }
        ColorOverlay{
            anchors.fill: buttonIcon
            source: buttonIcon
            color: "white"
        }
    }


}
