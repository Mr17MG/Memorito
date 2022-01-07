import QtQuick 
import QtQuick.Controls.Material 
import QtQuick.Controls.Material.impl 
import Memorito.Global

Item {
    id: indicator
    implicitWidth: 38*AppStyle.size1W
    implicitHeight: 32*AppStyle.size1H

    property Item control
    property alias handle: handle

    Material.elevation: 1

    Rectangle {
        width: parent.width
        height: AppStyle.size1H*25
        radius: height / 2
        y: (parent.height - height ) / 2
        color: control.enabled ? (control.checked ? control.Material.switchCheckedTrackColor : control.Material.switchUncheckedTrackColor)
                               : control.Material.switchDisabledTrackColor
    }

    Rectangle {
        id: handle
        x: Math.max(0, Math.min(parent.width - width, control.visualPosition * parent.width - (width / 2)))
        y: (parent.height - height) / 2
        width: AppStyle.size1W*30
        height: AppStyle.size1H*30
        radius: width / 2
        color: control.enabled ? (control.checked ? control.Material.switchCheckedHandleColor : control.Material.switchUncheckedHandleColor)
                               : control.Material.switchDisabledHandleColor

        Behavior on x {
            enabled: !control.pressed
            SmoothedAnimation {
                duration: 300
            }
        }
        layer.enabled: indicator.Material.elevation > 0
        layer.effect: ElevationEffect {
            elevation: indicator.Material.elevation
        }
    }
}
