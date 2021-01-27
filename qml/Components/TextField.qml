import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import Global 1.0

TextField{
    id:textField
    property alias placeholder: textFieldPlaceHolder
    font{family: AppStyle.appFont;pixelSize: 25*AppStyle.size1F;bold:true}
    selectByMouse: true
    renderType:Text.NativeRendering
    placeholderTextColor: "transparent"
    verticalAlignment: Text.AlignBottom
    Material.accent: AppStyle.primaryColor

    Label {
        id: textFieldPlaceHolder
        text: textField.placeholderText
        color: textField.focus || textField.text!=""?AppStyle.textColor: AppStyle.placeholderColor
        y: textField.focus || textField.text!=""?0:height-10*AppStyle.size1H
        anchors.right:  textField.right
        font{family: AppStyle.appFont;pixelSize:( textField.focus || textField.text!=""?20*AppStyle.size1F:25*AppStyle.size1F);bold:textField.focus || textField.text}
        Behavior on y {
            NumberAnimation{ duration: 160}
        }
    }
}
