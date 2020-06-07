import QtQuick 2.14
import QtQuick.Templates 2.14 as T
import QtQuick.Controls 2.14
import QtQuick.Controls.impl 2.14
import QtQuick.Controls.Material 2.14
import QtQuick.Controls.Material.impl 2.14

T.TextField {
    property color primaryTextColor: "#444"
    property color hintTextColor: "#444"
    property bool hasBottomBorder: true
    property color bottomBorderColor: "red"
    property bool bottomBorderColorChanged : false
    id: control
    color: textColor
    horizontalAlignment: Text.AlignHCenter
    bottomPadding: size1H*10
    font { /*family: appStyle.iransansBold.name;*/ pixelSize: size1F*12;}
    placeholderText: ""
    Material.accent: appStyle.accentColor1
    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            placeholderText ? placeholder.implicitWidth + leftPadding + rightPadding : 0)
                            || contentWidth + leftPadding + rightPadding
    implicitHeight: Math.max(contentHeight + topPadding + bottomPadding,
                             background ? background.implicitHeight : 0,
                             placeholder.implicitHeight + topPadding + bottomPadding)

    topPadding: 8*size1H
    selectionColor: Material.accentColor
    selectedTextColor: Material.primaryHighlightedTextColor
    selectByMouse: true
    verticalAlignment: TextInput.AlignVCenter
    cursorDelegate: CursorDelegate { }

    onTextChanged: {
        text = functions.faToEnNumber(text)
    }

    PlaceholderText {
        id: placeholder
        x: control.leftPadding
        y: control.topPadding
        width: control.width - (control.leftPadding + control.rightPadding)
        height: control.height - (control.topPadding + control.bottomPadding)
        text: control.placeholderText
        font: control.font
        color: control.hintTextColor
        verticalAlignment: control.verticalAlignment
        elide: Text.ElideRight
        visible: !control.length && !control.preeditText && (!control.activeFocus) //|| control.horizontalAlignment !== Qt.AlignHCenter)

    }

    background: Rectangle {
        visible: hasBottomBorder
        y: control.height - height - control.bottomPadding + size1H*8
        width: parent.width
        height: control.text === "" ?
                    control.activeFocus || control.hovered ? size1H*2:size1H
        :size1H*2
        color: bottomBorderColorChanged?bottomBorderColor:
                                         control.activeFocus ? control.Material.accentColor
                                   : (control.hovered ? control.Material.accentColor:
                                                        control.text‌===""?control.hintTextColor:control.Material.accentColor)
    }
}

