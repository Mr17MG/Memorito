import QtQuick
import QtQuick.Controls

import Memorito.Global

TabButton{
    id: root

    property date modelData

    width: Math.max(monthLoader.width/12 , 300*AppStyle.size1W)
    font {
        family: AppStyle.appFont;
        pixelSize:  25*AppStyle.size1F;
        bold:true
    }

    text: {
        var date = UsefulFunc.convertDateToLocale(root.modelData)
        return "%1 %2".arg(date[4]).arg(date[0])
    }


    onClicked: {
        var thisLocaleDate = UsefulFunc.convertDateToLocale(root.modelData)

        var fromDate = UsefulFunc.convertLocaleDateToGregotian(thisLocaleDate[0],thisLocaleDate[1],1)
        var toDate = UsefulFunc.convertLocaleDateToGregotian(thisLocaleDate[0],Number(thisLocaleDate[1])+1,1)

        queryList.due_date.fromDate = fromDate.toISOString()
        queryList.due_date.toDate = toDate.toISOString()
    }
}
