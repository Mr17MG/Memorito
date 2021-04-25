import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Material.impl 2.15

import Global 1.0
import QDateConvertor 1.0

TabButton{
    property var monthArray: AppStyle.ltr?["January","February","March","April","May","June","July","August","September","October","November","December"]
                                         :dateConverter.get_month()
    QDateConvertor{id:dateConvertor}

    property date modelData
    property var alternativeDate:{
        if(!AppStyle.ltr)
        {
            dateConvertor.toJalali(modelData.getFullYear(),modelData.getMonth()+1,modelData.getDate())

        }
        else ""
    }

    text: {

        if(AppStyle.ltr)
            monthArray[modelData.getMonth()]+" "+modelData.getFullYear()
        else{
            return monthArray[alternativeDate[1]-1]+ " "+ alternativeDate[0]
        }
    }

    width: monthLoader.width/12<300*AppStyle.size1W?300*AppStyle.size1W:monthLoader.width/12

    onClicked: {
        internalModel.clear()

        var fromDate = new Date(modelData)
        var toDate = new Date(modelData)
        if(AppStyle.ltr)
        {
            fromDate.setDate(1)
            fromDate.setHours(0)
            fromDate.setMinutes(0)
            fromDate.setSeconds(0)

            toDate.setMonth((toDate.getMonth()+1)%12)
            toDate.setDate(1)
            toDate.setHours(00)
            toDate.setMinutes(00)
            toDate.setSeconds(00)
        }
        else
        {
            /******************* FROM DATE ***********************/
            var convertedFromDate = dateConvertor.toMiladi(
                        Number(alternativeDate[0]),     // JALALI YEAR
                        Number(alternativeDate[1])-1,   // JALALI MONTH
                        1                               // JALALI DAY
                        )
            fromDate = new Date(convertedFromDate[0],convertedFromDate[1],convertedFromDate[2])

            /******************************************************/
            /******************* TO DATE **************************/
            var toYear= Number(alternativeDate[0])
            var toMonth = Number(alternativeDate[1])+1

            if( (Number(alternativeDate[1])+1) > 12 ){
                toYear++
                toMonth = toMonth-12
            }

            var convertedToDate = dateConvertor.toMiladi(
                        toYear,     // JALALI YEAR
                        toMonth-1,  // JALALI MONTH
                        1           // JALALI DAY
                        )

            toDate = new Date(convertedToDate[0],convertedToDate[1],convertedToDate[2])
            toDate.setSeconds(toDate.getSeconds()-1)

            /******************************************************/
        }

        internalModel.append(ThingsApi.getThingByDate(fromDate,toDate))
    }
}
