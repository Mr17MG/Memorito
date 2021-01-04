import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtQuick.Controls.Material.impl 2.14
import "qrc:/Components/" as App
import QtQuick.Templates 2.14 as T

Item {
    id:item
    width: parent.width
    height:  190*size1H
    property string placeholderText : ""
    property alias text: detailInput.text
    property bool areaInDialog: false
    property int maximumLength : 65535
    property alias detailInput: detailInput
    Rectangle{anchors{fill:control}width: control.width;height: control.height;border.width: 2*size1W; border.color: detailInput.focus? appStyle.primaryColor : appStyle.borderColor;color: "transparent";radius: 15*size1W}

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
            rightPadding: 30*size1W
            leftPadding: 12*size1W
            topPadding: 20*size1H
            bottomPadding: 20*size1H
            font{family: appStyle.appFont;pixelSize:  25*size1F;bold:false}
            color: appStyle.textColor
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            placeholderTextColor: appStyle.borderColor
            placeholderText: item.placeholderText
            Material.accent: enabled ?appStyle.primaryColor: Material.hintTextColor
            selectionColor: Material.accentColor
            selectedTextColor: Material.primaryHighlightedTextColor
            cursorDelegate: CursorDelegate { }
            font{family: appStyle.appFont;pixelSize:20*size1F}
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
            width: hovered || pressed?18*size1W:12*size1W
        }
    }
    Label {
        text: detailInput.placeholderText
        color: detailInput.focus || detailInput.text!==""?appStyle.textColor: appStyle.placeholderColor
        anchors{
            top: control.top
            topMargin: detailInput.focus || detailInput.text!==""?-5*size1H:height-10*size1H
            right:  control.right
            rightMargin: detailInput.rightPadding
        }
        font{family: appStyle.appFont;pixelSize:( detailInput.focus || detailInput.text!=""?20*size1F:25*size1F);bold:detailInput.focus || detailInput.text}
        Behavior on anchors.topMargin {
            NumberAnimation{ duration: 160}
        }
        Rectangle{
            width: parent.width + 30*size1W
            anchors.right: parent.right
            anchors.rightMargin: -15*size1W
            height: parent.height
            z:-1
            color: item.areaInDialog? appStyle.dialogBackgroundColor
                                    : appStyle.appBackgroundColor
            visible: detailInput.focus || detailInput.text!==""
            radius: 15*size1W
        }
    }
    Label {
        id: counterLabel
        text: detailInput.length+" / "+ item.maximumLength
        color: appStyle.placeholderColor
        anchors{
            left: control.left
            leftMargin: 30 *size1W
            bottom: control.bottom
            bottomMargin: -15*size1H
        }
        font{family: appStyle.appFont;pixelSize:( 20*size1F);bold:true}
        Rectangle{
            width: parent.width + 30*size1W
            anchors.right: parent.right
            anchors.rightMargin: -15*size1W
            height: parent.height
            z:-1
            color: item.areaInDialog? appStyle.dialogBackgroundColor
                                    : appStyle.appBackgroundColor
            radius: 15*size1W
        }
    }
}
