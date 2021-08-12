import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Material.impl 2.15
import QtQuick.Templates 2.15 as T
import Components 1.0
import Global 1.0

Item {
    id:item
    property string placeholderText : ""
    property alias text: detailInput.text
    property bool areaInDialog: false
    property int maximumLength : 65535
    property alias detailInput: detailInput
    Rectangle{anchors{fill:control}width: control.width;height: control.height;border.width: 2*AppStyle.size1W; border.color: detailInput.focus? AppStyle.primaryColor : AppStyle.borderColor;color: "transparent";radius: 15*AppStyle.size1W}

    Flickable{
        id: control
        anchors{
            fill: parent
        }
        //        width: parent.width
        //        height: parent.height
        clip: true
        flickableDirection: Flickable.VerticalFlick
        onContentYChanged: {
            if(contentY<0 || contentHeight < control.height)
                contentY = 0
            else if(contentY > (contentHeight - control.height))
                contentY = (contentHeight - control.height)
        }
        onContentXChanged: {
            if(contentX<0 || contentWidth < control.width)
                contentX = 0
            else if(contentX > (contentWidth-control.width))
                contentX = (contentWidth-control.width)

        }
        contentWidth: detailInput.width
        contentHeight: detailInput.height
        TextArea.flickable:T.TextArea {
            id: detailInput
            rightPadding: 30*AppStyle.size1W
            leftPadding: 12*AppStyle.size1W
            topPadding: 30*AppStyle.size1H
            bottomPadding: 20*AppStyle.size1H
            font{family: AppStyle.appFont;pixelSize:  25*AppStyle.size1F;bold:false}
            color: AppStyle.textColor
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            placeholderTextColor: AppStyle.borderColor
            placeholderText: item.placeholderText
            Material.accent: enabled ?AppStyle.primaryColor: Material.hintTextColor
            selectionColor: Material.accentColor
            selectedTextColor: Material.primaryHighlightedTextColor
            cursorDelegate: CursorDelegate { }
            font{family: AppStyle.appFont;pixelSize:20*AppStyle.size1F}
            selectByMouse: true
            selectByKeyboard: true
            mouseSelectionMode: TextEdit.SelectWords
            onTextChanged: {
                if(maximumLength < control.length)
                {
                    control.text = control.text.slice(0,control.length-1)
                    control.cursorPosition = control.length
                }
            }
        }
        ScrollBar.vertical: ScrollBar {
            hoverEnabled: true
            active: hovered || pressed
            orientation: Qt.Vertical
            anchors{
                right: control.right
            }
            height: parent.height
            width: hovered || pressed?18*AppStyle.size1W:12*AppStyle.size1W
        }
    }
    Label {
        text: detailInput.placeholderText
        color: detailInput.focus || detailInput.text!==""?AppStyle.textColor: AppStyle.placeholderColor
        anchors{
            top: control.top
            topMargin: detailInput.focus || detailInput.text!==""?-5*AppStyle.size1H:height-10*AppStyle.size1H
            right:  control.right
            rightMargin: detailInput.rightPadding
        }
        font{family: AppStyle.appFont;pixelSize:( detailInput.focus || detailInput.text!=""?20*AppStyle.size1F:25*AppStyle.size1F);bold:detailInput.focus || detailInput.text}
        Behavior on anchors.topMargin {
            NumberAnimation{ duration: 160}
        }
        Rectangle{
            width: parent.width + 30*AppStyle.size1W
            anchors.right: parent.right
            anchors.rightMargin: -15*AppStyle.size1W
            height: parent.height
            z:-1
            color: item.areaInDialog? AppStyle.dialogBackgroundColor
                                    : AppStyle.appBackgroundColor
            visible: detailInput.focus || detailInput.text!==""
            radius: 15*AppStyle.size1W
        }
    }
    Label {
        id: counterLabel
        text: detailInput.length+" / "+ item.maximumLength
        color: AppStyle.placeholderColor
        anchors{
            left: control.left
            leftMargin: 30 *AppStyle.size1W
            bottom: control.bottom
            bottomMargin: -15*AppStyle.size1H
        }
        font{family: AppStyle.appFont;pixelSize:( 20*AppStyle.size1F);bold:true}
        Rectangle{
            width: parent.width + 30*AppStyle.size1W
            anchors.right: parent.right
            anchors.rightMargin: -15*AppStyle.size1W
            height: parent.height
            z:-1
            color: item.areaInDialog? AppStyle.dialogBackgroundColor
                                    : AppStyle.appBackgroundColor
            radius: 15*AppStyle.size1W
        }
    }
}
