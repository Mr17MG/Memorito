import QtQuick 2.14
import QtQuick.Templates 2.14 as T
import QtQuick.Controls 2.14
import QtQuick.Controls.impl 2.14
import QtQuick.Controls.Material 2.14
import QtQuick.Controls.Material.impl 2.14
import QtGraphicalEffects 1.14

T.Button {
    id: control
    property bool leftBorder: false
    property bool disableLeftRadius: false
    property bool disableRightRadius: false
    property real radius: size1W*5
    property string borderColor: "transparent"
    property color disableColor: Material.hintTextColor
    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentItem.implicitWidth + leftPadding + rightPadding + 10*size1W)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             contentItem.implicitHeight + topPadding + bottomPadding)
    baselineOffset: contentItem.y + contentItem.baselineOffset

    // external vertical padding is 6 (to increase touch area)
    padding: size1W*12
    leftPadding: padding - size1W*4
    rightPadding: padding - size1W*4
    spacing: size1W*20
    Material.theme: Material.Light
    icon.color: !enabled ? Material.hintTextColor :
                           flat && highlighted ? Material.accentColor :
                                                 highlighted ? Material.primaryHighlightedTextColor : Material.foreground

    Material.elevation: flat ? control.down || control.hovered ? 2 : 0
    : control.down ? 8 : 2
    Material.background: flat ? "transparent"       : appStyle.primaryInt
    Material.foreground: flat ? appStyle.textColor  : appStyle.textOnPrimaryColor
    font.capitalization: Font.MixedCase
    font.family: appStyle.appFont
    contentItem: IconLabel {
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display

        icon: control.icon
        text: control.text
        font: control.font
        color: !control.enabled ? disableColor :
                                  control.flat && control.highlighted ? control.Material.accentColor :
                                                                        control.highlighted ? control.Material.primaryHighlightedTextColor : control.Material.foreground
    }

    // TODO: Add a proper ripple/ink effect for mouse/touch input and focus state
    background: Rectangle {
        implicitWidth: size1W*64
        implicitHeight: size1H*48

        // external vertical padding is 6 (to increase touch area)
        //y: 6
        width: parent.width
        height: parent.height
        radius: control.radius
        color: !control.enabled ? control.Material.buttonDisabledColor :
                                  control.highlighted ? control.Material.highlightedButtonColor : control.Material.background
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            enabled: false
        }

        PaddedRectangle {
            //            y: parent.height - size1H*4
            //            width: parent.width
            //            height: size1H*4

            radius: control.radius
            //            topPadding: -size1H*2
            anchors.fill: parent
            clip: true
            visible: control.checkable && (!control.highlighted || control.flat)
            color: control.checked && control.enabled ? control.Material.accentColor : control.Material.primary
            PaddedRectangle {
                visible: disableLeftRadius
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                width: parent.radius
                clip: true
                color: parent.color
            }
            PaddedRectangle {
                visible: disableRightRadius
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                width: parent.radius
                clip: true
                color: parent.color
            }
        }
        PaddedRectangle {
            visible: leftBorder
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            width: size1W
            clip: true
            color: control.Material.accentColor
        }
        // The layer is disabled when the button color is transparent so you can do
        // Material.background: "transparent" and get a proper flat button without needing
        // to set Material.elevation as well
        layer.enabled: control.enabled && control.Material.buttonColor.a > 0
        layer.effect: ElevationEffect {
            elevation: control.Material.elevation
        }

        Ripple {
            clipRadius: control.radius
            //radius: control.radius
            width: parent.width
            height: parent.height
            pressed: control.pressed
            anchor: control
            active: control.down || control.visualFocus || control.hovered
            color: control.Material.rippleColor
            // apply rounded corners mask
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    x: control.x
                    y: control.y
                    width: control.width
                    height: control.height
                    radius: control.radius
                }
            }
        }
    }
    Rectangle{
        id:border
        anchors.fill: parent
        color: "transparent"
        border.color: borderColor
        border.width: size1W
        radius: radius
    }
}
