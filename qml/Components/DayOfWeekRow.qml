import QtQuick 2.14
import Qt.labs.calendar 1.0

DayOfWeekRow {
    id: control

    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             contentItem.implicitHeight + topPadding + bottomPadding)

    spacing: 6
    topPadding: 6
    bottomPadding: 6
    font.bold: true

    //! [delegate]
    delegate: Text {
        text: model.shortName
        font: control.font
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    //! [delegate]

    //! [contentItem]
    contentItem: Row {
        spacing: control.spacing
        Repeater {
            model: control.source
            delegate: control.delegate
        }
    }
    //! [contentItem]
}
