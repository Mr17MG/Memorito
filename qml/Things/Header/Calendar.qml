import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import Memorito.Global
import Memorito.Components

ColumnLayout {

    TabBar{
        id:calendarTab

        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: 100*AppStyle.size1H

        LayoutMirroring.enabled: !AppStyle.ltr
        LayoutMirroring.childrenInherit: true

        Material.accent: AppStyle.textOnPrimaryColor
        background: Rectangle {
            color: Material.color(AppStyle.primaryInt,Material.ShadeA700)
            radius: 50*AppStyle.size1W
            Rectangle {
                width: parent.width
                color: parent.color
                anchors{
                    bottom: parent.bottom
                }
                height: 40*AppStyle.size1W
            }
            //layer.enabled: topTab.Material.elevation > 0
            //layer.effect: ElevationEffect {
            //    elevation: topTab.Material.elevation
            //    fullWidth: true
            //}
        }

        TabButton{
            id:dayBtn

            text: qsTr("روز")
            Material.foreground: AppStyle.textOnPrimaryColor

            font{
                family: AppStyle.appFont;
                pixelSize:  30*AppStyle.size1F;
                bold:true;
            }
        }

        TabButton{
            id:monthBtn

            text: qsTr("ماه")
            Material.foreground: AppStyle.textOnPrimaryColor

            font{
                family: AppStyle.appFont;
                pixelSize:  30*AppStyle.size1F
                ;bold:true
            }
        }

        TabButton{
            id:yearBtn

            text: qsTr("سال")
            Material.foreground: AppStyle.textOnPrimaryColor

            font{
                family: AppStyle.appFont;
                pixelSize:  30*AppStyle.size1F;
                bold:true;
            }
        }

        TabButton{
            id:optionBtn

            text: qsTr("دلخواه")
            Material.foreground: AppStyle.textOnPrimaryColor

            font{
                family: AppStyle.appFont;
                pixelSize:  30*AppStyle.size1F;
                bold:true;
            }
        }
    }

    Loader{
        id: calendarRangeTab

        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: 100*AppStyle.size1H

        sourceComponent: Item {
            width: parent.width
            height: 100*AppStyle.size1H

            Loader{
                id:dayLoader

                visible: active
                anchors.fill: parent
                active: calendarTab.currentIndex === 0

                sourceComponent: TabBar {
                    id:dayTab

                    currentIndex: 1

                    Component.onCompleted: {
                        sevenDaysLater.clicked()
                    }

                    LayoutMirroring.enabled: !AppStyle.ltr
                    LayoutMirroring.childrenInherit: true

                    TabButton{
                        id: sevenDaysAgo

                        property int deletedDays : -1
                        enabled: dayTab.count < 21

                        text: qsTr("۷ روز قبلی")
                        width: 200*AppStyle.size1W
                        LayoutMirroring.enabled: !AppStyle.ltr

                        icon {
                            source: AppStyle.ltr?"qrc:/previous.svg":"qrc:/next.svg"
                            color: !enabled ? Material.hintTextColor
                                            : sevenDaysAgo.pressed ? Material.accentColor
                                                                   : Material.foreground
                            width: 30*AppStyle.size1W
                            height:30*AppStyle.size1W
                        }

                        font {
                            family: AppStyle.appFont;
                            pixelSize:  25*AppStyle.size1F;
                            bold:true
                        }

                        onClicked: {
                            for(let i=0; i <7 ; i++)
                            {
                                var today = new Date()
                                var component = Qt.createComponent('qrc:/Things/Header/CalendarButtons/Day.qml',parent);
                                if (component.status === Component.Ready){
                                    var d = component.createObject(parent, {modelData: new Date(today.setDate( today.getDate()+(deletedDays-i)))});
                                    dayTab.insertItem(1,d)
                                }
                                else console.log(component.errorString())
                            }

                            deletedDays -= 7
                            dayTab.setCurrentIndex(1)
                            dayTab.currentItem.clicked(Qt.RightButton)
                        }
                    }

                    TabButton{
                        id: sevenDaysLater

                        property int addedDays: 0
                        enabled: dayTab.count < 21

                        text: qsTr("۷ روز بعدی")
                        width: 200*AppStyle.size1W
                        LayoutMirroring.enabled: AppStyle.ltr

                        icon {
                            source: !AppStyle.ltr?"qrc:/previous.svg":"qrc:/next.svg"
                            color: !enabled ? Material.hintTextColor
                                            : sevenDaysLater.pressed ? Material.accentColor
                                                                     : Material.foreground
                            width: 30*AppStyle.size1W
                            height:30*AppStyle.size1W
                        }
                        font {
                            family: AppStyle.appFont;
                            pixelSize:  25*AppStyle.size1F;
                            bold:true
                        }

                        onClicked: {
                            for(let i=0; i<7; i++)
                            {
                                var today = new Date()
                                var component = Qt.createComponent('qrc:/Things/Header/CalendarButtons/Day.qml',parent);
                                if (component.status === Component.Ready){
                                    var d = component.createObject(parent, {modelData: new Date(today.setDate( today.getDate()+(addedDays+i)))});
                                    dayTab.insertItem(dayTab.count-2,d)
                                }
                                else console.log(component.errorString())
                            }

                            addedDays+=7
                            dayTab.setCurrentIndex(dayTab.count-8)
                            dayTab.currentItem.clicked()
                        }
                    }
                }
            }

            Loader{
                id:monthLoader
                visible: active
                anchors.fill: parent
                active: calendarTab.currentIndex === 1

                sourceComponent: TabBar{
                    id: monthTab

                    LayoutMirroring.enabled: !AppStyle.ltr
                    LayoutMirroring.childrenInherit: true

                    Component.onCompleted: {
                        fourMonthLater.clicked()
                    }

                    TabButton{
                        id: fourMonthAgo

                        property int deletedMonth : -1

                        text: qsTr("۴ ماه قبلی")
                        width: 200*AppStyle.size1W
                        enabled: monthTab.count < 12
                        LayoutMirroring.enabled: !AppStyle.ltr

                        icon{
                            source: AppStyle.ltr?"qrc:/previous.svg":"qrc:/next.svg"
                            color: !enabled ? Material.hintTextColor
                                            : fourMonthAgo.pressed ? Material.accentColor
                                                                   : Material.foreground
                            width: 30*AppStyle.size1W
                            height:30*AppStyle.size1W
                        }

                        font{
                            family: AppStyle.appFont;
                            pixelSize:  25*AppStyle.size1F;
                            bold:true
                        }

                        onClicked: {
                            for(let i=0; i < 4 ; i++)
                            {
                                var today = new Date()
                                var component = Qt.createComponent('qrc:/Things/Header/CalendarButtons/Month.qml',parent);
                                if (component.status === Component.Ready){
                                    var d = component.createObject(parent, {modelData: new Date(today.setMonth( today.getMonth()+(deletedMonth-i)))});
                                    monthTab.insertItem(1,d)
                                }
                                else console.log(component.errorString())
                            }

                            deletedMonth -= 4
                            monthTab.setCurrentIndex(1)
                            monthTab.currentItem.clicked()
                        }
                    }

                    TabButton{
                        id: fourMonthLater

                        property int addedMonth: 0

                        text: qsTr("۴ ماه بعدی")
                        width: 200*AppStyle.size1W
                        enabled: monthTab.count < 12
                        LayoutMirroring.enabled: AppStyle.ltr

                        icon {
                            source: !AppStyle.ltr?"qrc:/previous.svg":"qrc:/next.svg"
                            color: !enabled ? Material.hintTextColor
                                            : fourMonthLater.pressed ? Material.accentColor
                                                                     : Material.foreground
                            width: 30*AppStyle.size1W
                            height:30*AppStyle.size1W
                        }

                        font {
                            family: AppStyle.appFont;
                            pixelSize:  25*AppStyle.size1F;
                            bold:true
                        }

                        onClicked: {
                            for(let i=0; i<4; i++)
                            {
                                var today = new Date()
                                var component = Qt.createComponent('qrc:/Things/Header/CalendarButtons/Month.qml',parent);
                                if (component.status === Component.Ready){
                                    var d = component.createObject(parent, {modelData: new Date(today.setMonth( today.getMonth()+(addedMonth+i)))});
                                    monthTab.insertItem(monthTab.count-2,d)
                                }
                                else console.log(component.errorString())
                            }

                            addedMonth += 4
                            monthTab.setCurrentIndex(monthTab.count-5)
                            monthTab.currentItem.clicked()
                        }
                    }
                }
            }

            Loader{
                id:yearLoader

                visible: active
                anchors.fill: parent
                active: calendarTab.currentIndex === 2

                sourceComponent: TabBar{
                    id:yearTab

                    LayoutMirroring.enabled: !AppStyle.ltr
                    LayoutMirroring.childrenInherit: true

                    Component.onCompleted: {
                        twoYearLater.clicked()
                    }

                    TabButton{
                        id: twoYearhAgo
                        property int deletedYear : -1

                        text: qsTr("۲ سال قبلی")
                        width: 300*AppStyle.size1W
                        enabled: yearTab.count < 10
                        LayoutMirroring.enabled: !AppStyle.ltr

                        icon{
                            source: AppStyle.ltr?"qrc:/previous.svg":"qrc:/next.svg"
                            color: !enabled ? Material.hintTextColor
                                            : twoYearhAgo.pressed ? Material.accentColor
                                                                  : Material.foreground
                            width: 30*AppStyle.size1W
                            height:30*AppStyle.size1W
                        }

                        font {
                            family: AppStyle.appFont;
                            pixelSize:  25*AppStyle.size1F;
                            bold:true
                        }
                        onClicked: {
                            for(let i=0; i < 2 ; i++)
                            {
                                var today = new Date()
                                var component = Qt.createComponent('qrc:/Things/Header/CalendarButtons/Year.qml',parent);
                                if (component.status === Component.Ready){
                                    var d = component.createObject(parent, {modelData: new Date(today.setYear(today.getFullYear()+(deletedYear-i)))});
                                    yearTab.insertItem(1,d)
                                }
                                else console.log(component.errorString())
                            }

                            deletedYear -= 2
                            yearTab.setCurrentIndex(1)
                            yearTab.currentItem.clicked()
                        }
                    }

                    TabButton{
                        id: twoYearLater

                        property int addedYear: 0

                        text: qsTr("۲ سال بعدی")
                        width: 300*AppStyle.size1W
                        enabled: yearTab.count < 10
                        LayoutMirroring.enabled: AppStyle.ltr

                        icon{
                            source: !AppStyle.ltr?"qrc:/previous.svg":"qrc:/next.svg"
                            color: !enabled ? Material.hintTextColor
                                            : twoYearLater.pressed ? Material.accentColor
                                                                   : Material.foreground
                            width: 30*AppStyle.size1W
                            height:30*AppStyle.size1W
                        }

                        font {
                            family: AppStyle.appFont;
                            pixelSize:  25*AppStyle.size1F;
                            bold:true
                        }

                        onClicked: {
                            for(let i=0; i<2; i++)
                            {
                                var today = new Date()
                                var component = Qt.createComponent('qrc:/Things/Header/CalendarButtons/Year.qml',parent);
                                if (component.status === Component.Ready){
                                    var d = component.createObject(parent, {modelData: new Date(today.setYear( today.getFullYear()+(addedYear+i)))});
                                    yearTab.insertItem(yearTab.count-2,d)
                                }
                                else console.log(component.errorString())
                            }

                            addedYear += 2
                            yearTab.setCurrentIndex(yearTab.count-3)
                            yearTab.currentItem.clicked()
                        }
                    }
                }
            }

            Loader{
                id: customLoader
                visible: active
                width: parent.width
                height: visible?parent.height:0
                active: calendarTab.currentIndex === 3

                sourceComponent: Flow {
                    width: parent.width
                    spacing: 20*AppStyle.size1W
                    height:parent.height - 20*AppStyle.size1H

                    anchors{
                        top: parent.top
                        topMargin:  20*AppStyle.size1H
                    }

                    AppDatePicker{
                        id:toDate

                        placeholderText: qsTr("تا")+":"
                        width: parent.width / 2 - 10*AppStyle.size1W
                        height:parent.height- 20*AppStyle.size1H
                        minDate: fromDate.selectedDate

//                        okButton.onClicked: {
//                            var localFromDate = fromDate.selectedDate.toString()==="Invalid Date"?0
//                                                                                                 :fromDate.selectedDate
//                            var localToDate = toDate.selectedDate.toString() === "Invalid Date"?0
//                                                                                               :toDate.selectedDate
//                            if(localFromDate === 0 && localToDate ===0);
////                                return valuesThings

//                            else if (localFromDate !== 0 && localToDate === 0)
//                                localToDate = new Date('3000')

//                            else if (localFromDate === 0 && localToDate !== 0)
//                                localFromDate = new Date(0)

////                            internalModel.clear()
////                            internalModel.append(ThingsApi.getThingByDate(localFromDate,localToDate))

//                            queryList.due_date.fromDate = localFromDate.toISOString()
//                            queryList.due_date.toDate = localToDate.toISOString()
//                        }

//                        cancelButton.onClicked: {
//                            okButton.clicked()
//                        }
                    }
                    AppDatePicker{
                        id:fromDate

                        maxDate: toDate.selectedDate
                        placeholderText: qsTr("از")+":"
                        width: parent.width / 2 - 10*AppStyle.size1W
                        height:parent.height - 20*AppStyle.size1H

//                        okButton.onClicked:  {
//                            var localFromDate = fromDate.selectedDate.toString()==="Invalid Date"?0
//                                                                                                 :fromDate.selectedDate
//                            var localToDate = toDate.selectedDate.toString() === "Invalid Date"?0
//                                                                                               :toDate.selectedDate
//                            if(localFromDate === 0 && localToDate ===0);
////                                return valuesThings

//                            else if (localFromDate !== 0 && localToDate === 0)
//                                localToDate = new Date('3000')

//                            else if (localFromDate === 0 && localToDate !== 0)
//                                localFromDate = new Date(0)

////                            internalModel.clear()
////                            internalModel.append(ThingsApi.getThingByDate(localFromDate,localToDate))

//                            queryList.due_date.fromDate = localFromDate.toISOString()
//                            queryList.due_date.toDate = localToDate.toISOString()
//                        }

//                        cancelButton.onClicked: {
//                            okButton.clicked()
//                        }
                    }

                }
            }
        }
    }
}
