import QtQuick
import QtQuick.Controls

import Memorito.Global

TabButton{
    id: root

    property date modelData

    width:200*AppStyle.size1W
    font {
        family: AppStyle.appFont;
        pixelSize:  25*AppStyle.size1F;
        bold:true
    }

    text: {
        var date = UsefulFunc.convertDateToLocale(root.modelData)
        return "%1".arg(date[0])
    }


    onClicked: {
        var thisLocaleDate = UsefulFunc.convertDateToLocale(root.modelData)

        var fromDate = UsefulFunc.convertLocaleDateToGregotian(thisLocaleDate[0],1,1)
        var toDate = UsefulFunc.convertLocaleDateToGregotian(Number(thisLocaleDate[0])+1,1,1)

        queryList.due_date.fromDate = fromDate.toISOString()
        queryList.due_date.toDate = toDate.toISOString()
    }
}
