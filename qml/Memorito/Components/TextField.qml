import QtQuick 
import QtQuick.Controls 
import QtQuick.Controls.Material 
import Memorito.Global

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
        color: enabled?textField.activeFocus || textField.text!==""?AppStyle.textColor: AppStyle.placeholderColor:textField.color
        y: textField.activeFocus || textField.text!==""?0:height/2
        anchors.right:  textField.right
        font{family: AppStyle.appFont;pixelSize:( textField.activeFocus || textField.text!=""?20*AppStyle.size1F:25*AppStyle.size1F);bold:textField.activeFocus || textField.text}
    }
}
