import QtQuick 
import QtQuick.Templates  as T
import QtQuick.Controls 
import QtQuick.Controls.impl 
import QtQuick.Controls.Material 
import QtQuick.Controls.Material.impl 
import Memorito.Global

T.TextField {
    id: control
    property bool hasCounter: true
    property bool fieldInDialog: false
    property bool fieldInPrimary : false
    property alias borderColor : bgRect.border
    property color bgUnderItem
    property alias controlPlaceHolder: controlPlaceHolder
    color: fieldInPrimary ? AppStyle.textOnPrimaryColor : AppStyle.textColor
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
    Label {
        id: controlPlaceHolder
        text: control.placeholderText
        color: fieldInPrimary ? (AppStyle.textOnPrimaryColor)

                              :( control.activeFocus || control.text !==""? AppStyle.textColor
                                                                         : AppStyle.placeholderColor)
        y: control.activeFocus || control.text !==""?-10*AppStyle.size1H:height-10*AppStyle.size1H
        anchors.right:  control.right
        anchors.rightMargin: parent.padding + 10*AppStyle.size1W
        elide: Qt.ElideRight
        font{family: AppStyle.appFont;pixelSize:( control.activeFocus || control.text!=""?20*AppStyle.size1F:25*AppStyle.size1F);bold:control.activeFocus || control.text}
        Behavior on y {
            NumberAnimation{ duration: 160}
        }
        Rectangle{
            width: parent.width + 30*AppStyle.size1W
            anchors.right: parent.right
            anchors.rightMargin: -15*AppStyle.size1W
            height: parent.height
            z:-1
            color: fieldInDialog? AppStyle.dialogBackgroundColor
                                : fieldInPrimary ? bgUnderItem
                                                 : AppStyle.appBackgroundColor
            visible: control.activeFocus || control.text !==""
            radius: 15*AppStyle.size1W
        }
    }
    Label {
        id: counterLabel
        text: control.length+" / "+control.maximumLength
        color: fieldInPrimary ? "black":AppStyle.placeholderColor
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
            color: fieldInDialog? AppStyle.dialogBackgroundColor
                                : fieldInPrimary ? bgUnderItem
                                                 : AppStyle.appBackgroundColor
            radius: 15*AppStyle.size1W
        }
    }
    background: Rectangle {
        id: bgRect
        anchors.fill: parent
        border.color: control.activeFocus? AppStyle.primaryColor
                                         : fieldInPrimary ? AppStyle.borderColorOnPrimary
                                                          : AppStyle.borderColor
        radius: 15*AppStyle.size1W
        color: "transparent"
    }
}

