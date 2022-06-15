import QtQuick
import QtQuick.Controls

import Memorito.Global

TabButton{
    id: root;

    property date modelData

    width: 200*AppStyle.size1W;

    font {
        family: AppStyle.appFont;
        pixelSize:  25*AppStyle.size1F
        ;bold:true
    }

    text: {
            var date = UsefulFunc.convertDateToLocale(root.modelData)
            return "%1 %2 %3".arg(date[3]).arg(date[2]).arg(date[4])
    }
    onClicked: {

        var fromDate = new Date(modelData)
        var toDate = new Date(modelData)

        fromDate.setHours(0)
        fromDate.setMinutes(0)
        fromDate.setSeconds(0)

        toDate.setHours(23)
        toDate.setMinutes(59)
        toDate.setSeconds(59)

        queryList.due_date.fromDate = fromDate.toISOString()
        queryList.due_date.toDate = toDate.toISOString()

    }
}
