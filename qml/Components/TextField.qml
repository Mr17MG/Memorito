import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14

TextField{
    id:textField
    property alias placeholder: textFieldPlaceHolder
    font{family: appStyle.appFont;pixelSize: 25*size1F;bold:true}
    selectByMouse: true
    renderType:Text.NativeRendering
    placeholderTextColor: "transparent"
    verticalAlignment: Text.AlignBottom
    Material.accent: appStyle.primaryColor

    Label {
        id: textFieldPlaceHolder
        text: textField.placeholderText
        color: textField.focus || textField.text!=""?appStyle.textColor: getAppTheme()?"#B3ffffff":"#B3000000"
        y: textField.focus || textField.text!=""?0:height-10*size1H
        anchors.right:  textField.right
        font{family: appStyle.appFont;pixelSize:( textField.focus || textField.text!=""?20*size1F:25*size1F);bold:textField.focus || textField.text}
        Behavior on y {
            NumberAnimation{ duration: 160}
        }
    }
}
