import QtQuick 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Material.impl 2.15
import Global 1.0

Rectangle {
    implicitWidth: AppStyle.size1W*40
    implicitHeight: AppStyle.size1W*40
    radius: width / 2
    border.width: 2
    border.color: !control.enabled ? control.Material.hintTextColor
        : control.checked || control.down ? control.Material.accentColor : control.Material.secondaryTextColor
    color: "transparent"

    property Item control

    Rectangle {
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: AppStyle.size1W*20
        height: AppStyle.size1W*20
        radius: width / 2
        color: parent.border.color
        visible: control.checked || control.down
    }
}
