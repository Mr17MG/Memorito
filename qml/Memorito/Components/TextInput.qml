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
    property alias controlPlaceHolder: controlPlaceHolder

    property color bgUnderItem

    placeholderText: ""
    padding: AppStyle.size1H*10
    topPadding: 8*AppStyle.size1H

    selectByMouse: true
    selectionColor: Material.accentColor
    selectedTextColor: Material.primaryHighlightedTextColor
    Material.accent: AppStyle.primaryColor

    verticalAlignment: TextInput.AlignVCenter

    color: fieldInPrimary ? AppStyle.textOnPrimaryColor
                          : AppStyle.textColor

    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            controlPlaceHolder ? controlPlaceHolder.implicitWidth + leftPadding + rightPadding : 0)
                   || contentWidth + leftPadding + rightPadding
    implicitHeight: Math.max(contentHeight + topPadding + bottomPadding,
                             background ? background.implicitHeight : 0,
                             controlPlaceHolder.implicitHeight + topPadding + bottomPadding)
    font {
        family: AppStyle.appFont;
        pixelSize: AppStyle.size1F*25;
    }

    cursorDelegate: CursorDelegate { }

    onTextChanged: {
        controlPlaceHolder.y = (control.focus || control.text.length>0) ? -10*AppStyle.size1H
                                                                        : height-10*AppStyle.size1H
    }

    Label {
        id: controlPlaceHolder

        elide: Qt.ElideRight
        text: control.placeholderText
        color: fieldInPrimary ? AppStyle.textOnPrimaryColor
                              : (control.focus || control.text.length > 0 ? AppStyle.textColor
                                                                          : AppStyle.placeholderColor)

        y: (control.focus || control.text.length>0) ? -10*AppStyle.size1H
                                                    : height-10*AppStyle.size1H

        anchors {
            right:  control.right
            rightMargin: parent.padding + 10*AppStyle.size1W
        }

        font {
            family: AppStyle.appFont;
            pixelSize:( control.activeFocus || control.text.length> 0?20*AppStyle.size1F:25*AppStyle.size1F);
            bold:control.activeFocus || control.text
        }

        Behavior on y {
            NumberAnimation{ duration: 160}
        }

        Rectangle{
            width: parent.width + 30*AppStyle.size1W
            anchors.right: parent.right
            anchors.rightMargin: -15*AppStyle.size1W
            height: parent.height
            z:-1
            color: fieldInDialog ? AppStyle.dialogBackgroundColor
                                 : (fieldInPrimary ? bgUnderItem
                                                   : AppStyle.appBackgroundColor)
            visible: control.focus || control.text.length > 0
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

        font{
            family: AppStyle.appFont;
            pixelSize:20*AppStyle.size1F;
            bold:true
        }

        Rectangle{
            z:-1
            height: parent.height
            radius: 15*AppStyle.size1W
            width: parent.width + 30*AppStyle.size1W
            color: fieldInDialog? AppStyle.dialogBackgroundColor
                                : (fieldInPrimary ? bgUnderItem
                                                  : AppStyle.appBackgroundColor)

            anchors {
                right: parent.right
                rightMargin: -15*AppStyle.size1W
            }
        }
    }
    background: Rectangle {
        id: bgRect

        anchors.fill: parent
        border.color: control.activeFocus? AppStyle.primaryColor
                                         : (fieldInPrimary ? AppStyle.borderColorOnPrimary
                                                           : AppStyle.borderColor)
        radius: 15*AppStyle.size1W
        color: "transparent"
    }
}

