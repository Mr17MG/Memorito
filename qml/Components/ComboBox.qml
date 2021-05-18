import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Templates 2.15 as T
import QtQuick.Controls.Material.impl 2.15
import QtGraphicalEffects 1.14
import Global 1.0

ComboBox {
    id:control
    Material.background: "transparent"
    property int popupX: 0
    property int popupY: popupCenter?(-(UsefulFunc.rootWindow.height-height)/2)-control.y:height
    property bool popupCenter: false
    property int popupWidth: width
    property int popupHeight: UsefulFunc.rootWindow.height>= delegateModel.count*AppStyle.size1H*85?delegateModel.count*AppStyle.size1H*85:UsefulFunc.rootWindow.height-AppStyle.size1H*85
    property bool hasBottomBorder: true
    property alias contentItemText: contentItemText
    property int textAlign: Text.AlignRight
    property string placeholderText: ""
    property color errorColor: "red"
    property alias imageIndicator: imageIndicator
    property color bottomBorderColor : AppStyle.primaryColor
    property string iconRole: ""
    property string placeholderIcon: ""
    property string displayIcon:  iconRole?"":""
    property bool hasClear: true
    property real iconSize: AppStyle.size1W*35
    property string iconColor
    Material.accent: AppStyle.primaryColor

    signal error();
    signal resetColor()

    onError: {
        bottomBorder.color = errorColor
    }
    onResetColor: {
        bottomBorder.color = bottomBorderColor
    }

    height: AppStyle.size1H*100
    font { family: AppStyle.appFont; pixelSize: AppStyle.size1F*30}
    indicator: Image {
        id:imageIndicator
        anchors{
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 10*AppStyle.size1W
        }
        source: "qrc:/arrow.svg"
        width: AppStyle.size1W*35
        height: width
        sourceSize: Qt.size(width*4,height*4)
        visible: false
    }

    ColorOverlay{
        source: imageIndicator
        anchors.fill: imageIndicator
        color: control.activeFocus ? control.Material.accentColor
                                   : AppStyle.textColor
    }

    AppButton {
        id: trashIcon
        width: iconSize*2
        height: iconSize*2
        radius: iconSize*2
        visible: control.currentIndex>=0 && hasClear
        flat: true
        icon {
            source: "qrc:/trash.svg"
            color: AppStyle.textColor
            width: iconSize
            height: iconSize
        }

        anchors{
            left: parent.right
            verticalCenter: parent.verticalCenter
        }
        onClicked: {
            control.currentIndex = -1
        }
    }

    contentItem: Rectangle {
        id:contentItem
        anchors.fill: parent
        color: "transparent"
        Text{
            id:contentItemText
            text: control.displayText? control.displayText
                                     : placeholderText
            font: control.font
            height: parent.height
            color: AppStyle.textColor
            elide: AppStyle.ltr ? Text.ElideLeft
                                : Text.ElideRight

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            anchors{
                left: parent.left
                leftMargin: 55*AppStyle.size1W
                right: try{iconImg.visible || iconColor !== ""? iconImg.left
                                                          : parent.right}catch(e){parent.right}
                rightMargin: 5*AppStyle.size1W
            }
        }
        Rectangle{
            id:bottomBorder
            color: control.activeFocus ? control.Material.accentColor
                                       : (control.hovered ? control.Material.primaryTextColor : control.Material.hintTextColor)
            height: AppStyle.size1H*3;
            anchors{
                right: parent.right
                left: parent.left
                top: parent.bottom
                topMargin: -10*AppStyle.size1H
            }
            visible: hasBottomBorder
        }
        Image {
            id: iconImg
            visible: source !== "" && iconColor === ""
            anchors{
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 10*AppStyle.size1W
            }
            source: control.iconRole === "" ?
                        (placeholderIcon ? placeholderIcon : "" )
                      :(control.currentIndex === -1 ? placeholderIcon
                                                    :control.model.get(control.currentIndex)[iconRole])
            width: iconSize
            height: iconSize
            sourceSize: Qt.size(width*4,height*4)
        }
        ColorOverlay{
            visible: iconColor !== ""
            source : iconImg
            anchors.fill: iconImg
            color: iconColor
        }
    }

    delegate: MenuItem {
        id: delegateItem
        width: parent?parent.width:0
        text: control.textRole ? (Array.isArray(control.model) ? modelData[control.textRole] : model[control.textRole]) : modelData
        Material.foreground: parent?control.currentIndex === index ? AppStyle.primaryColor: parent.Material.foreground: AppStyle.textColor
        highlighted: control.highlightedIndex === index
        hoverEnabled: control.hoverEnabled
        font: control.font
        height: AppStyle.size1H*90
        contentItem: Item{
            anchors.fill: parent
            Image {
                id: displayIconImg
                visible: source !== "" && iconColor === ""
                anchors{
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 10*AppStyle.size1W
                }
                source: control.iconRole ===""?"":model[control.iconRole]
                width: iconSize
                height: iconSize
                sourceSize: Qt.size(width*4,height*4)
            }
            ColorOverlay{
                visible: iconColor !== ""
                source : displayIconImg
                anchors.fill: displayIconImg
                color: iconColor
            }
            Text {
                id: name
                text: delegateItem.text
                font: delegateItem.font
                anchors{
                    right: control.iconRole !==""?displayIconImg.left
                                                 :parent.right
                    rightMargin: AppStyle.size1W*15
                    left: parent.left
                    leftMargin: AppStyle.size1W*15
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
        x: popupCenter?(+(UsefulFunc.rootWindow.width-popupWidth)/2)-(popupX/2)-(control.x):popupX
        width: control.popupWidth
        height: popupHeight
        transformOrigin: Item.Top
        topMargin: AppStyle.size1H*12
        bottomMargin: AppStyle.size1H*12

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
            radius: AppStyle.size1W*5
            color: control.popup.Material.dialogColor
            layer.enabled: control.enabled
            layer.effect: ElevationEffect {
                elevation: 8
            }
        }
    }
}

