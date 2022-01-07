import QtQuick 
import QtQuick.Templates  as T
import QtQuick.Controls.Material 
import QtQuick.Controls.Material.impl 
import Memorito.Components
import Memorito.Global

T.RadioButton {
    id: control
    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             Math.max(contentItem.implicitHeight,
                                      indicator ? indicator.implicitHeight : 0) + topPadding + bottomPadding)
    baselineOffset: contentItem.y + contentItem.baselineOffset

    spacing: AppStyle.size1W*8
    padding: AppStyle.size1W*8
    topPadding: padding + AppStyle.size1W*6
    bottomPadding: padding + AppStyle.size1W*6
    LayoutMirroring.enabled: !AppStyle.ltr
    Material.accent: AppStyle.primaryInt
    font { family: AppStyle.appFont; pixelSize: AppStyle.size1F*25;}
    indicator: AppRadioIndicator{
        x: text ? (control.mirrored ? control.width - width - control.rightPadding : control.leftPadding) : control.leftPadding + (control.availableWidth - width) / 2
        y: control.topPadding + (control.availableHeight - height) / 2
        control: control

        Ripple {
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            width: AppStyle.size1W*45
            height: AppStyle.size1W*45

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
