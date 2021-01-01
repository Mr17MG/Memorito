import QtQuick 2.14
import QtQuick.Templates 2.14 as T
import QtQuick.Controls 2.14
import QtQuick.Controls.impl 2.14
import QtQuick.Controls.Material 2.14
import QtQuick.Controls.Material.impl 2.14

T.TextField {
    id: control
    property bool hasCounter: true
    property bool filedInDialog: false
    color: appStyle.textColor
    padding: size1H*10
    font { family: appStyle.appFont; pixelSize: size1F*25;}
    placeholderText: ""
    Material.accent: appStyle.primaryColor
    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            controlPlaceHolder ? controlPlaceHolder.implicitWidth + leftPadding + rightPadding : 0)
                   || contentWidth + leftPadding + rightPadding
    implicitHeight: Math.max(contentHeight + topPadding + bottomPadding,
                             background ? background.implicitHeight : 0,
                             controlPlaceHolder.implicitHeight + topPadding + bottomPadding)

    topPadding: 8*size1H
    selectionColor: Material.accentColor
    selectedTextColor: Material.primaryHighlightedTextColor
    selectByMouse: true
    verticalAlignment: TextInput.AlignVCenter
    cursorDelegate: CursorDelegate { }
    horizontalAlignment: ltr?Text.AlignLeft:Text.AlignRight
    Label {
        id: controlPlaceHolder
        text: control.placeholderText
        color: control.focus || control.text!==""?appStyle.textColor: appStyle.placeholderColor
        y: control.focus || control.text!==""?-10*size1H:height-10*size1H
        anchors.right:  control.right
        anchors.rightMargin: parent.padding + 10*size1W
        font{family: appStyle.appFont;pixelSize:( control.focus || control.text!=""?20*size1F:25*size1F);bold:control.focus || control.text}
        Behavior on y {
            NumberAnimation{ duration: 160}
        }
        Rectangle{
            width: parent.width + 30*size1W
            anchors.right: parent.right
            anchors.rightMargin: -15*size1W
            height: parent.height
            z:-1
            color: filedInDialog?appStyle.dialogBackgroundColor
                                 :appStyle.appBackgroundColor
            visible: control.focus || control.text!==""
            radius: 15*size1W
        }
    }
    Label {
        id: counterLabel
        text: control.length+" / "+control.maximumLength
        color: appStyle.placeholderColor
        y: control.height-15*size1H
        visible: hasCounter
        anchors{
            left: control.left
            leftMargin: 30 *size1W
        }
        font{family: appStyle.appFont;pixelSize:( 20*size1F);bold:true}
        Rectangle{
            width: parent.width + 30*size1W
            anchors.right: parent.right
            anchors.rightMargin: -15*size1W
            height: parent.height
            z:-1
            color: filedInDialog? appStyle.dialogBackgroundColor
                                : appStyle.appBackgroundColor
            radius: 15*size1W
        }
    }
    background: Rectangle {
        id: bgRect
        anchors.fill: parent
        border.color: control.focus? appStyle.primaryColor : appStyle.borderColor
        radius: 15*size1W
        color: "transparent"
    }
}

