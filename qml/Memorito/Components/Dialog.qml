import QtQuick 
import QtQuick.Controls 
import QtQuick.Controls.Material 
import Qt5Compat.GraphicalEffects

import Memorito.Components
import Memorito.Global

Dialog {
    id: dialog
    width: AppStyle.size1W*310
    height: AppStyle.size1H*185
    modal: true
    padding: 0
    Overlay.modal: Rectangle {
        color: AppStyle.appTheme?"#aa606060":"#80000000"
    }
    x: -parent.x + (parent.parent===null?0:(parent.parent.width- width)/2)
    y: -parent.y + (parent.parent===null?0:(parent.parent.height- height)/2)
    property string dialogTitle: qsTr("انصراف")
    property string buttonTitle: qsTr("ثبت")
    property bool hasButton: false
    property bool hasTitle: false
    property bool hasCloseIcon: false
    property int btnRightPadding: AppStyle.size1W*25
    property int btnIconRightPadding: AppStyle.ltr?15*AppStyle.size1W:AppStyle.size1W*30
    property int btnWidth: AppStyle.size1W*300
    property string iconSource: "qrc:/check.svg"
    property alias dialogButton: dialogButton
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
        width: AppStyle.size1W*20
        height: width
        source: "qrc:/close.svg"
        sourceSize.width: width*2
        sourceSize.height: height*2
        visible: false
        anchors{
            right: parent.right
            rightMargin: AppStyle.size1W*20
            top: parent.top
            topMargin: -parent.y + AppStyle.size1W*15

        }
    }

    ColorOverlay{
        visible: hasCloseIcon
        anchors.fill: close
        source: close
        color: AppStyle.textColor
        MouseArea{
            anchors{
                fill: parent
                rightMargin: -AppStyle.size1W*10
                leftMargin: -AppStyle.size1W*10
                bottomMargin: -AppStyle.size1W*10
                topMargin: -AppStyle.size1W*10
            }
            cursorShape:Qt.PointingHandCursor
            onClicked: dialog.close()
        }
    }

    Text {
        visible: hasTitle
        text: dialogTitle
        color: AppStyle.textColor
        anchors{
            verticalCenter: close.verticalCenter
            right: close.left
            rightMargin: AppStyle.size1W*10
        }
        font { family: AppStyle.appFont; pixelSize: AppStyle.size1F*25 }
        MouseArea{
            anchors{
                rightMargin: -AppStyle.size1W*10
                leftMargin: -AppStyle.size1W*10
                bottomMargin: -AppStyle.size1W*10
                topMargin: -AppStyle.size1W*10
                fill: parent
            }
            cursorShape:Qt.PointingHandCursor
            onClicked: dialog.close()
        }
    }

    AppButton{
        id: dialogButton
        visible: hasButton
        text: buttonTitle
        rightPadding: btnRightPadding
        width: btnWidth
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: AppStyle.size1H*35
        radius: 30*AppStyle.size1W
        icon{
            source: iconSource
            color: AppStyle.textOnPrimaryColor
            width: AppStyle.size1W*30
            height: AppStyle.size1W*30
        }
    }

}
