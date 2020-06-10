import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtQuick.Templates 2.14 as T
import QtQuick.Controls.Material.impl 2.14
import QtGraphicalEffects 1.14

ComboBox {
    Material.background: "transparent"
    property int popupX: 0
    property int popupY: popupCenter?(-(rootWindow.height-height)/2)-control.y:50
    property bool popupCenter: false
    property int popupWidth: width
    property int popupHeight: rootWindow.height>= delegateModel.count*size1H*85?delegateModel.count*size1H*85:rootWindow.height-size1H*85
    property bool hasBottomBorder: true
    property alias contentItemText: contentItemText
    property int textAlign: Text.AlignRight
    property string placeholderText: ""
    property color errorColor: "red"
    property alias imageIndicator: imageIndicator
    property color bottomBorderColor : appStyle.primaryColor
    signal error();
    signal resetColor()

    onError: {
        bottomBorder.color = errorColor
    }
    onResetColor: {
        bottomBorder.color = bottomBorderColor
    }

    id:control
    height: size1H*30
    font { family: appStyle.appFont; pixelSize: size1F*35}
    indicator: Image {
        id:imageIndicator
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10*size1W
        source: "qrc:/arrow.svg"
        width: size1W*35
        height: width
        sourceSize.width: width*2
        sourceSize.height: height*2
        visible: false
    }
    ColorOverlay{
        source: imageIndicator
        anchors.fill: imageIndicator
        color: appStyle.primaryColor
    }

    contentItem: Rectangle {
        id:contentItem
        anchors.fill: parent
        color: "transparent"
        Label{
            id:contentItemText
            text: parent.parent.displayText?parent.parent.displayText:placeholderText
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.fill: parent
            font: control.font
            color: appStyle.textColor
        }
        Rectangle{
            id:bottomBorder
            color: appStyle.primaryColor
            height: size1H*2;
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            visible: hasBottomBorder
        }
    }
    delegate: MenuItem {
        id: delegateItem
        width: parent?parent.width:0
        text: control.textRole ? (Array.isArray(control.model) ? modelData[control.textRole] : model[control.textRole]) : modelData
        Material.foreground: parent?control.currentIndex === index ? parent.Material.accent : parent.Material.foreground:"white"
        highlighted: control.highlightedIndex === index
        hoverEnabled: control.hoverEnabled
        font: control.font
        height: size1H*85
        contentItem: Text {
            id: name
            text: parent.text
            font: parent.font
            width: parent.width
            anchors.rightMargin: size1W*15
            anchors.leftMargin: size1W*15
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: textAlign
            wrapMode: Text.WordWrap
            color: appStyle.textColor
        }
    }
    popup: T.Popup {
        y: popupY
        x: popupCenter?(+(rootWindow.width-popupWidth)/2)-(popupX/2)-(control.x):popupX
        width: control.popupWidth
        height: popupHeight
        transformOrigin: Item.Top
        topMargin: size1H*12
        bottomMargin: size1H*12

        Material.theme: control.Material.theme
        Material.accent: control.Material.accent
        Material.primary: control.Material.primary

        enter: Transition {
            // grow_fade_in
            NumberAnimation { property: "scale"; from: 0.9; to: 1.0; easing.type: Easing.OutQuint; duration: 220 }
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; easing.type: Easing.OutCubic; duration: 150 }
        }

        exit: Transition {
            // shrink_fade_out
            NumberAnimation { property: "scale"; from: 1.0; to: 0.9; easing.type: Easing.OutQuint; duration: 220 }
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; easing.type: Easing.OutCubic; duration: 150 }
        }

        contentItem: ListView {
            clip: true

            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex
            highlightMoveDuration: 0
            T.ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: Rectangle {
            radius: size1W*5
            color: control.popup.Material.dialogColor
            layer.enabled: control.enabled
            layer.effect: ElevationEffect {
                elevation: 8
            }
        }
    }
}

