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
        color: enabled ? (textField.focus || textField.text.length>0 ? AppStyle.textColor
                                                                      : AppStyle.placeholderColor)
                       : textField.color
        y: textField.focus || textField.text.length>0?0:height/2

        anchors {
            right:  textField.right
        }
        font {
            family: AppStyle.appFont;
            pixelSize:( textField.focus || textField.text.length > 0?20*AppStyle.size1F:25*AppStyle.size1F);
            bold:textField.focus || textField.text
        }
        Behavior on y {
            NumberAnimation{ duration: 160}
        }
    }
}
