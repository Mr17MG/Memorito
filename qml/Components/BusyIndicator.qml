import QtQuick 2.14
import QtQuick.Templates 2.14 as T
import QtQuick.Controls.Material 2.14
import QtQuick.Controls.Material.impl 2.14

T.BusyIndicator {
    id: control

    implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding
    implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding

    padding: size1W*5

    contentItem: BusyIndicatorImpl {
        implicitWidth: size1W*50
        implicitHeight: size1W*50
        color: control.Material.accentColor
        running: control.running
        opacity: control.running ? 1 : 0
        Behavior on opacity { OpacityAnimator { duration: 500 } }
    }
    RotationAnimator on rotation {
        running: control.running || contentItem.visible
        from: 0
        to: 360
        duration: 5000
        loops: Animation.Infinite
    }
}