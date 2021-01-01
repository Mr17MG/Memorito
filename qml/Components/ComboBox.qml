import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtQuick.Templates 2.14 as T
import QtQuick.Controls.Material.impl 2.14
import QtGraphicalEffects 1.14

ComboBox {
    id:control
    Material.background: "transparent"
    property int popupX: 0
    property int popupY: popupCenter?(-(rootWindow.height-height)/2)-control.y:95*size1H
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
    property string iconRole: ""
    property string placeholderIcon: ""
    property string displayIcon:  iconRole?"":""
    property bool hasClear: true
    Material.accent: appStyle.primaryColor

    signal error();
    signal resetColor()

    onError: {
        bottomBorder.color = errorColor
    }
    onResetColor: {
        bottomBorder.color = bottomBorderColor
    }

    height: size1H*100
    font { family: appStyle.appFont; pixelSize: size1F*30}
    indicator: Image {
        id:imageIndicator
        anchors{
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 10*size1W
        }
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
    Image {
        id: trashIcon
        source: "qrc:/trash.svg"
        width: 35*size1W
        height: width
        sourceSize.width: width*2
        sourceSize.height: height*2
        anchors{
            left: parent.right
            verticalCenter: parent.verticalCenter
        }
        visible: false
    }
    ColorOverlay{
        source: trashIcon
        anchors.fill: trashIcon
        color: appStyle.textColor
        visible: control.currentIndex>=0 && hasClear
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                control.currentIndex = -1
            }
        }
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
            elide: ltr?Text.ElideLeft:Text.ElideRight
            anchors{
                left: parent.left
                leftMargin: 55*size1W
                right: parent.right
            }
        }
        Rectangle{
            id:bottomBorder
            color: control.activeFocus ? control.Material.accentColor
                                       : (control.hovered ? control.Material.primaryTextColor : control.Material.hintTextColor)
            height: size1H*3;
            anchors{
                right: parent.right
                left: parent.left
                top: parent.bottom
                topMargin: -10*size1H
            }
            visible: hasBottomBorder
        }
        Image {
            id: iconImg
            visible: source !== ""
            anchors{
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 10*size1W
            }
            source: control.iconRole === ""?"":control.currentIndex === -1?placeholderIcon:control.model.get(control.currentIndex)[iconRole]
            width: size1W*35
            height: width
            sourceSize.width: width*2
            sourceSize.height: height*2
        }
    }
    delegate: MenuItem {
        id: delegateItem
        width: parent?parent.width:0
        text: control.textRole ? (Array.isArray(control.model) ? modelData[control.textRole] : model[control.textRole]) : modelData
        Material.foreground: parent?control.currentIndex === index ? appStyle.primaryColor: parent.Material.foreground:"white"
        highlighted: control.highlightedIndex === index
        hoverEnabled: control.hoverEnabled
        font: control.font
        height: size1H*85
        contentItem: Item{
            anchors.fill: parent
            Image {
                id: displayIconImg
                visible: source !== ""
                anchors{
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 10*size1W
                }
                source: control.iconRole ===""?"":model[control.iconRole]
                width: size1W*35
                height: width
                sourceSize.width: width*2
                sourceSize.height: height*2
            }
            Text {
                id: name
                text: delegateItem.text
                font: delegateItem.font
                width: delegateItem.width
                anchors{
                    right: displayIconImg.visible?displayIconImg.left:parent.right
                    rightMargin: size1W*15
                    leftMargin: size1W*15
                    verticalCenter: parent.verticalCenter

                }
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: textAlign
                wrapMode: Text.WordWrap
                color: delegateItem.Material.foreground
            }
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
            id:list
            clip: true
            onContentYChanged: {
                if(contentY<0 || contentHeight < list.height)
                    contentY = 0
                else if(contentY > ((contentHeight + (model.count * spacing))-list.height))
                    contentY = (contentHeight + (model.count * spacing))-list.height
            }
            onContentXChanged: {
                if(contentX<0 || contentWidth < list.width)
                    contentX = 0
                else if(contentX > (contentWidth-list.width))
                    contentX = (contentWidth-list.width)

            }
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

