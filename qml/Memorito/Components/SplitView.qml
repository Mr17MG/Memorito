import QtQuick 
import QtQuick.Templates  as T
import QtQuick.Controls 
import QtQuick.Controls.impl 
import QtQuick.Controls.Material 
import Memorito.Global
T.SplitView {
    id: control
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    handle: Rectangle {
        implicitWidth: control.orientation === Qt.Horizontal ? 10*AppStyle.size1W :  5*AppStyle.size1W
        implicitHeight: control.orientation === Qt.Horizontal ?  5*AppStyle.size1H : 10*AppStyle.size1H

        color: control.orientation === Qt.Horizontal?(T.SplitHandle.pressed ? Qt.darker(AppStyle.primaryColor,1.8)
                                                                            :T.SplitHandle.hovered ? Qt.darker(AppStyle.primaryColor,1.4)
                                                                                                   : AppStyle.primaryColor)
                                                    : T.SplitHandle.pressed ? control.Material.background
                                                                            : Qt.lighter(control.Material.background, T.SplitHandle.hovered ? 1.2 : 1.1)
        radius: width
        Rectangle {
            color: control.orientation === Qt.Horizontal ? ( parent.SplitHandle.hovered? Qt.darker(AppStyle.textColor,2.0) : Qt.lighter(AppStyle.textColor,1.0) )
                                                         : control.Material.secondaryTextColor
            radius: height
            width: control.orientation === Qt.Horizontal ? thickness
                                                         : length

            height: control.orientation === Qt.Horizontal ? length
                                                          : thickness
            anchors{ centerIn: parent }

            property int length: control.orientation === Qt.Horizontal ? ( parent.T.SplitHandle.pressed ? 125*AppStyle.size1W : 120*AppStyle.size1W)
                                                                       : ( parent.T.SplitHandle.pressed ? 30*AppStyle.size1H : 25*AppStyle.size1H)
            readonly property int thickness:control.orientation === Qt.Horizontal ? ( parent.T.SplitHandle.pressed ? parent.width *2  : parent.width*2-5*AppStyle.size1W )
                                                                                  : ( parent.T.SplitHandle.pressed ? parent.height*2 : parent.height*2-5*AppStyle.size1H)

            Behavior on length {
                NumberAnimation {
                    duration: 100
                }
            }
        }
    }
}
