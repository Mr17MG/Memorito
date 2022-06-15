import QtQuick
import QtQuick.Layouts
import Memorito.Global

import "Header"

Loader {
    id: sortLoader

    height: active?(listId === Memorito.Calendar ? 300*AppStyle.size1H
                                                : 100*AppStyle.size1H)
                  :0

    active: internalModel.count>0 || listId === Memorito.Calendar
    clip: true
    anchors {
        top: parent.top
        topMargin: 10*AppStyle.size1H
    }

    sourceComponent: ColumnLayout {
        spacing: 0
        Loader{
            Layout.preferredHeight: 200*AppStyle.size1H
            Layout.rightMargin: 25*AppStyle.size1W
            Layout.leftMargin: 25*AppStyle.size1W
            active: listId === Memorito.Calendar
            visible: active
            asynchronous: true
            Layout.fillWidth: true
            sourceComponent: Calendar {
                anchors.fill: parent
            }
        }

        Search {
            Layout.fillWidth: true
            Layout.preferredHeight: 100*AppStyle.size1H
            Layout.rightMargin: 25*AppStyle.size1W
            Layout.leftMargin: 25*AppStyle.size1W
        }
    }
}
