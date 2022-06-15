import QtQuick 
import QtQuick.Controls.Material 
import QtQuick.Controls.Material.impl 
import Memorito.Global

Rectangle {
    id: indicatorItem
    implicitWidth: 38*AppStyle.size1W
    implicitHeight: 38*AppStyle.size1W
    color: "transparent"
    border.color: !control.enabled ? control.Material.hintTextColor
        : checkState !== Qt.Unchecked ? control.Material.accentColor : control.Material.secondaryTextColor
    border.width: checkState !== Qt.Unchecked ? width : 5*AppStyle.size1W
    radius: 5*AppStyle.size1W

    property Item control
    property int checkState: control.checkState

    Behavior on border.width {
        NumberAnimation {
            duration: 100
            easing.type: Easing.OutCubic
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: 100
            easing.type: Easing.OutCubic
        }
    }

    Image {
        id: checkImage
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: 30*AppStyle.size1W
        height: width
        source: "qrc:/qt-project.org/imports/QtQuick/Controls/Material/images/check.png"
        fillMode: Image.PreserveAspectFit
        sourceSize.width: width*2
        sourceSize.height: height*2
        scale: checkState === Qt.Checked ? 1 : 0
        Behavior on scale { NumberAnimation { duration: 100 } }
    }

    Rectangle {
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: 24*AppStyle.size1W
        height: 3*AppStyle.size1W

        scale: checkState === Qt.PartiallyChecked ? 1 : 0
        Behavior on scale { NumberAnimation { duration: 100 } }
    }

    states: [
        State {
            name: "checked"
            when: checkState === Qt.Checked
        },
        State {
            name: "partiallychecked"
            when: checkState === Qt.PartiallyChecked
        }
    ]

    transitions: Transition {
        SequentialAnimation {
            NumberAnimation {
                target: indicatorItem
                property: "scale"
                // Go down 2 pixels in size.
                to: 1 - 2 / indicatorItem.width
                duration: 120
            }
            NumberAnimation {
                target: indicatorItem
                property: "scale"
                to: 1
                duration: 120
            }
        }
    }
}
