import QtQuick 2.15
import QtQuick.Templates 2.15 as T
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Material.impl 2.15
import QtGraphicalEffects 1.14
import Global 1.0

T.Button {
    id: control
    property bool contentMirorred: false
    property bool leftBorder: false
    property bool hasBottomChecker: false
    property bool disableLeftRadius: false
    property bool disableRightRadius: false
    property real radius: AppStyle.size1W*5
    property string borderColor: "transparent"
    property color disableColor: Material.hintTextColor
    property int horizontalAlignment: Qt.AlignHCenter
    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentItem.implicitWidth + leftPadding + rightPadding + 10*AppStyle.size1W)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             contentItem.implicitHeight + topPadding + bottomPadding)
    baselineOffset: contentItem.y + contentItem.baselineOffset

    padding: AppStyle.size1W*12
    leftPadding: padding - AppStyle.size1W*4
    rightPadding: padding - AppStyle.size1W*4
    spacing: AppStyle.size1W*20
    Material.theme: Material.Light
    icon.color: !enabled ? Material.hintTextColor :
                           flat && highlighted ? Material.accentColor :
                                                 highlighted ? Material.primaryHighlightedTextColor : Material.foreground

    Material.elevation: flat ? control.down || control.hovered ? 2 : 0
    : control.down ? 8 : 2
    Material.background: flat ? "transparent"       : AppStyle.primaryInt
    Material.foreground: control.checked ? AppStyle.textOnPrimaryColor : flat ? AppStyle.textColor  : AppStyle.textOnPrimaryColor
    font{
        pixelSize: 25*AppStyle.size1F
        capitalization: Font.MixedCase
        family: AppStyle.appFont
    }
    contentItem: IconLabel {
        spacing: control.spacing
        mirrored: control.contentMirorred
        display: control.display
        alignment: control.horizontalAlignment
        icon: control.icon
        text: control.text
        font: control.font
        color: !control.enabled ? disableColor :
                                  control.flat && control.highlighted ? control.Material.accentColor :
                                                                        control.highlighted ? control.Material.primaryHighlightedTextColor : control.Material.foreground
    }

    background: Rectangle {
        implicitWidth: AppStyle.size1W*64
        implicitHeight: AppStyle.size1H*48

        width: parent.width
        height: parent.height
        radius: control.radius
        color: !control.enabled ? control.Material.buttonDisabledColor :
                                  control.highlighted ? control.Material.highlightedButtonColor
                                                      : control.checked ? control.Material.accent : control.Material.background
        border{
            color: borderColor
            width: AppStyle.size1W
        }
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            enabled: false
        }

        Ripple {
            clipRadius: control.radius
            width: parent.width
            height: parent.height
            pressed: control.pressed
            anchor: control
            active: control.down || control.visualFocus || control.hovered
            color: control.Material.rippleColor
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

}
