import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Material.impl 2.15

import Global 1.0
import QDateConvertor 1.0

TabButton{
    id: tempButton;
    QDateConvertor{id:dateConvertor}
    property date modelData
    font{family: AppStyle.appFont;pixelSize:  25*AppStyle.size1F;bold:true}
    text: {
        if(!AppStyle.ltr)
        {
            var jalali = dateConvertor.toJalali(modelData.getFullYear(),modelData.getMonth()+1,modelData.getDate())
            return jalali[2]+" "+ jalali[3]

        }
        else
             modelData.getDate() +" "+ ["January","February","March","April","May","June","July","August","September","October","November","December"][modelData.getMonth()]
    }
    width: 200*AppStyle.size1W;
    onClicked: {
        internalModel.clear()

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

        internalModel.append(ThingsApi.getThingByDate(fromDate,toDate))

    }
}
