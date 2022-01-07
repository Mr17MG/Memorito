import QtQuick 
import QtQuick.Templates  as T
import QtQuick.Controls.Material 
import QtQuick.Controls.Material.impl 
import Memorito.Global

T.BusyIndicator {
    id: control

    implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding
    implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding

    padding: AppStyle.size1W*5

    contentItem: BusyIndicatorImpl {
        implicitWidth: AppStyle.size1W*50
        implicitHeight: AppStyle.size1W*50
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
