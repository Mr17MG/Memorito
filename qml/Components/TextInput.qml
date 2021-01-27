import QtQuick 2.14
import QtQuick.Templates 2.14 as T
import QtQuick.Controls 2.14
import QtQuick.Controls.impl 2.14
import QtQuick.Controls.Material 2.14
import QtQuick.Controls.Material.impl 2.14
import Global 1.0

T.TextField {
    id: control
    property bool hasCounter: true
    property bool filedInDialog: false
    color: AppStyle.textColor
    padding: AppStyle.size1H*10
    font { family: AppStyle.appFont; pixelSize: AppStyle.size1F*25;}
    placeholderText: ""
    Material.accent: AppStyle.primaryColor
    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            controlPlaceHolder ? controlPlaceHolder.implicitWidth + leftPadding + rightPadding : 0)
                   || contentWidth + leftPadding + rightPadding
    implicitHeight: Math.max(contentHeight + topPadding + bottomPadding,
                             background ? background.implicitHeight : 0,
                             controlPlaceHolder.implicitHeight + topPadding + bottomPadding)

    topPadding: 8*AppStyle.size1H
    selectionColor: Material.accentColor
    selectedTextColor: Material.primaryHighlightedTextColor
    selectByMouse: true
    verticalAlignment: TextInput.AlignVCenter
    cursorDelegate: CursorDelegate { }
    horizontalAlignment: AppStyle.ltr?Text.AlignLeft:Text.AlignRight
    Label {
        id: controlPlaceHolder
        text: control.placeholderText
        color: control.focus || control.text!==""?AppStyle.textColor: AppStyle.placeholderColor
        y: control.focus || control.text!==""?-10*AppStyle.size1H:height-10*AppStyle.size1H
        anchors.right:  control.right
        anchors.rightMargin: parent.padding + 10*AppStyle.size1W
        font{family: AppStyle.appFont;pixelSize:( control.focus || control.text!=""?20*AppStyle.size1F:25*AppStyle.size1F);bold:control.focus || control.text}
        Behavior on y {
            NumberAnimation{ duration: 160}
        }
        Rectangle{
            width: parent.width + 30*AppStyle.size1W
            anchors.right: parent.right
            anchors.rightMargin: -15*AppStyle.size1W
            height: parent.height
            z:-1
            color: filedInDialog?AppStyle.dialogBackgroundColor
                                 :AppStyle.appBackgroundColor
            visible: control.focus || control.text!==""
            radius: 15*AppStyle.size1W
        }
    }
    Label {
        id: counterLabel
        text: control.length+" / "+control.maximumLength
        color: AppStyle.placeholderColor
        y: control.height-15*AppStyle.size1H
        visible: hasCounter
        anchors{
            left: control.left
            leftMargin: 30 *AppStyle.size1W
        }
        font{family: AppStyle.appFont;pixelSize:( 20*AppStyle.size1F);bold:true}
        Rectangle{
            width: parent.width + 30*AppStyle.size1W
            anchors.right: parent.right
            anchors.rightMargin: -15*AppStyle.size1W
            height: parent.height
            z:-1
            color: filedInDialog? AppStyle.dialogBackgroundColor
                                : AppStyle.appBackgroundColor
            radius: 15*AppStyle.size1W
        }
    }
    background: Rectangle {
        id: bgRect
        anchors.fill: parent
        border.color: control.focus? AppStyle.primaryColor : AppStyle.borderColor
        radius: 15*AppStyle.size1W
        color: "transparent"
    }
}

