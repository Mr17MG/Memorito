import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Material.impl 2.15

import Global 1.0
import QDateConvertor 1.0

TabButton{
    QDateConvertor{id:dateConvertor}
    property date modelData

    property var alternativeDate:{
        if(!AppStyle.ltr)
        {
            dateConvertor.toJalali(modelData.getFullYear(),modelData.getMonth()+1,modelData.getDate())

        }
        else ""
    }

    width:200*AppStyle.size1W
    text:{
        if(AppStyle.ltr)
            return modelData.getFullYear()
        else {
            Number( dateConvertor.toJalali(modelData.getFullYear(),modelData.getMonth()+1,modelData.getDate())[0] )

        }
    }
    onClicked: {
        internalModel.clear()

        var fromDate = new Date(modelData)
        var toDate = new Date(modelData)
        if(AppStyle.ltr)
        {
            fromDate.setMonth(0)
            fromDate.setDate(1)
            fromDate.setHours(0)
            fromDate.setMinutes(0)
            fromDate.setSeconds(0)

            toDate.setYear(toDate.getFullYear+1)
            toDate.setMonth(0)
            toDate.setDate(1)
            toDate.setHours(00)
            toDate.setMinutes(00)
            toDate.setSeconds(00)
            toDate.setSeconds(toDate.getSeconds()-1)
        }
        else
        {
            /******************* FROM DATE ***********************/
            var convertedFromDate = dateConvertor.toMiladi(
                        Number(alternativeDate[0]),     // JALALI YEAR
                        1,   // JALALI MONTH
                        1                               // JALALI DAY
                        )
            fromDate = new Date(convertedFromDate[0],convertedFromDate[1]-1,convertedFromDate[2])


            /******************************************************/
            /******************* TO DATE **************************/
            var toYear= Number(alternativeDate[0])+1

            var convertedToDate = dateConvertor.toMiladi(
                        toYear,     // JALALI YEAR
                        1,  // JALALI MONTH
                        1           // JALALI DAY
                        )

            toDate = new Date(convertedToDate[0],convertedToDate[1]-1,convertedToDate[2])
            toDate.setSeconds( toDate.getSeconds()- 1)

            /******************************************************/
        }

        internalModel.append(ThingsApi.getThingByDate(fromDate,toDate))
    }
}
