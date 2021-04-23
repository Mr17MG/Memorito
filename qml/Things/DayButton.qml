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

        modelData.setHours(0)
        modelData.setMinutes(0)
        modelData.setSeconds(0)
        modelData.setHours(23)
        modelData.setMinutes(59)
        modelData.setSeconds(59)

        internalModel.append(ThingsApi.getThingByDate(fromDate,toDate))

    }
}
