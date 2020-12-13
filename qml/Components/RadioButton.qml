import QtQuick 2.14
import QtQuick.Templates 2.14 as T
import QtQuick.Controls.Material 2.14
import QtQuick.Controls.Material.impl 2.14
import "./" as App

T.RadioButton {
    id: control
    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             Math.max(contentItem.implicitHeight,
                                      indicator ? indicator.implicitHeight : 0) + topPadding + bottomPadding)
    baselineOffset: contentItem.y + contentItem.baselineOffset

    spacing: size1W*8
    padding: size1W*8
    topPadding: padding + size1W*6
    bottomPadding: padding + size1W*6
    LayoutMirroring.enabled: !ltr
    Material.accent: appStyle.primaryInt
    font { family: appStyle.appFont; pixelSize: size1F*25;}
    indicator: App.RadioIndicator{
        x: text ? (control.mirrored ? control.width - width - control.rightPadding : control.leftPadding) : control.leftPadding + (control.availableWidth - width) / 2
        y: control.topPadding + (control.availableHeight - height) / 2
        control: control

        Ripple {
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            width: size1W*45
            height: size1W*45

            anchor: control
            pressed: control.pressed
            active: control.down || control.visualFocus || control.hovered
            color: control.checked ? control.Material.highlightedRippleColor : control.Material.rippleColor
        }
    }

    contentItem: Text {
        leftPadding: control.indicator && !control.mirrored ? control.indicator.width + control.spacing : 0
        rightPadding: control.indicator && control.mirrored ? control.indicator.width + control.spacing : 0

        text: control.text
        font: control.font
        color: control.enabled ? control.Material.foreground : control.Material.hintTextColor
//        elide: Text.ElideRight
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
    }
}
