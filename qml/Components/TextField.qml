import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtQuick.Controls.impl 2.14

TextField{
    id:textField
    property alias placeholder: textFieldPlaceHolder
    property alias toolTip: tooltip
    Material.accent: appStyle.primaryColor
    font{family: appStyle.appFont;pixelSize: 25*size1F;bold:true}
    selectByMouse: true
    renderType:Text.NativeRendering
    placeholderTextColor: "transparent"
    verticalAlignment: Text.AlignBottom
    ToolTip{
        id:tooltip
        timeout: 6000
        x:textField.width-width
        y:(textField.height-height)/2
        font{family: appStyle.appFont;pixelSize: 20*size1F;bold:true}
    }
    PlaceholderText {
        id: textFieldPlaceHolder
        text: textField.placeholderText
        color: textField.focus || textField.text!=""? getAppTheme()?"#B3ffffff":"#B3000000":appStyle.textColor
        y: textField.focus || textField.text!=""?0:height-10*size1H
        anchors.right:  textField.right
        font{family: appStyle.appFont;pixelSize:( textField.focus || textField.text!=""?20*size1F:25*size1F);bold:true}
        Behavior on y {
            NumberAnimation{ duration: 160}
        }
    }
}
