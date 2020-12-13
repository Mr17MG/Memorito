import QtQuick 2.14
import QtQuick.Templates 2.14 as T
import QtQuick.Controls 2.14
import QtQuick.Controls.impl 2.14
import QtQuick.Controls.Material 2.14
import QtQuick.Controls.Material.impl 2.14

T.TextArea {
    id: control
    property alias placeholder: placeholder
    property bool areaInDialog: false
    implicitWidth: Math.max(contentWidth + leftPadding + rightPadding,
                            implicitBackgroundWidth + leftInset + rightInset,
                            placeholder.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(contentHeight + topPadding + bottomPadding,
                             implicitBackgroundHeight + topInset + bottomInset,
                             placeholder.implicitHeight + 1 + topPadding + bottomPadding)

    color: enabled ? Material.foreground : Material.hintTextColor
    selectionColor: Material.accentColor
    selectedTextColor: Material.primaryHighlightedTextColor
    placeholderTextColor: Material.hintTextColor
    cursorDelegate: CursorDelegate { }
    font{family: appStyle.appFont;pixelSize:20*size1F}
    Label {
        id: placeholder
        text: control.placeholderText
        color: control.focus || control.text!==""?appStyle.textColor: getAppTheme()?"#B3ffffff":"#B3000000"
        y: control.focus || control.text!==""?-5*size1H:height-10*size1H
        anchors.right:  control.right
        anchors.rightMargin: control.rightPadding
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
            color:areaInDialog? (getAppTheme()?"#3f3f3f":"#ffffff")
                              : (getAppTheme()?"#2f2f2f":"#fafafa")
            visible: control.focus || control.text!==""
            radius: 15*size1W
        }
    }

}
