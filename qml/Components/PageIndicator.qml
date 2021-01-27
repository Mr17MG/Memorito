import QtQuick 2.14
import QtQuick.Templates 2.14 as T
import QtQuick.Controls.Material 2.14

T.PageIndicator {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    padding: 6*AppStyle.size1W
    spacing: 6*AppStyle.size1W

    delegate: Rectangle {
        implicitWidth: 8*AppStyle.size1W
        implicitHeight: 8*AppStyle.size1H

        radius: width / 2*AppStyle.size1W
        color: control.enabled ? control.Material.foreground : control.Material.hintTextColor

        opacity: index === currentIndex ? 0.95 : pressed ? 0.7 : 0.45
        Behavior on opacity { OpacityAnimator { duration: 100 } }
    }

    contentItem: Row {
        spacing: control.spacing

        Repeater {
            model: control.count
            delegate: control.delegate
        }
    }
}
