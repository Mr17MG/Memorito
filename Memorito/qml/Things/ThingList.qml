import QtQml 2.15 as D
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Material.impl 2.15
import QtGraphicalEffects 1.15
import QtQuick.Layouts 1.15
import QDateConvertor 1.0
import Components 1.0
import Global 1.0
import Qt.labs.calendar 1.0

Item {
    property int listId: -1
    property int categoryId: -1
    ListModel{ id:internalModel }
    QDateConvertor{id:dateConverter}
    property bool searched : false
    property var queryList:{
        "context_id" : [],
        "priority_id" : [],
        "energy_id" : [],
        "has_files" : 2,
        "estimate_type":"<", // timeCompbo.model.get(timeCompbo.currentIndex).query
        "estimate_time" : "", //Number(timeInput.text.trim()),
        "list_id": listId,
        "category_id": categoryId,
        "due_date" : {
            "fromDate": "",
            "toDate" : ""
        },
        "searchText" : "",
        "orderBy":"title",
        "orderType":"ASC"
    }

    function makeQuery()
    {
        let query= []

        if (queryList.context_id.length)
            query.push("context_id IN("+(queryList.context_id)+")")

        if (queryList.priority_id.length)
            query.push("priority_id IN("+(queryList.priority_id)+")")

        if (queryList.energy_id.length)
            query.push("energy_id IN("+(queryList.energy_id)+")")

        if (queryList.has_files !== 2)
            query.push("has_files"+"="+queryList.has_files)

        if (queryList.estimate_time !== "")
            query.push("estimate_time"+queryList.estimate_type + queryList.estimate_time)

        if( listId !== -1)
            query.push("list_id"+"="+listId)

        if( categoryId !== -1)
            query.push("category_id"+"="+categoryId)


        if(listId===Memorito.Calendar)
        {
            query.push("datetime(due_date) BETWEEN datetime('" + queryList.due_date.fromDate + "') AND datetime('" + queryList.due_date.toDate + "')")
        }

        if( queryList.searchText !=="" )
        {
            query.push("(lower(title) LIKE '%"+ queryList.searchText.toLowerCase() +"%' OR "+"lower(detail) LIKE '%"+ queryList.searchText.toLowerCase() +"%')")
        }

        var conditions = query.length?"WHERE "+query.join(" AND "):""
        var order = ("ORDER BY lower(" + queryList.orderBy + ") " + queryList.orderType)
        searched=true
        return conditions + " " + order
    }

    function cameInToPage(object)
    {
        ContextsApi.getContexts(contextModel)

        if(listId === Memorito.Friends)
            internalModel.append(ThingsApi.getThingByFriendId(categoryId))
        else if(listId === Memorito.Contexts)
            internalModel.append(ThingsApi.getThingByContextId(categoryId))
        else if(listId === Memorito.Calendar)
        {
            ThingsApi.getThings(["__"],listId,categoryId)
        }

        else
            ThingsApi.getThings(internalModel,listId,categoryId)

        addBtn.text = qsTr("اضافه کردن چیز جدید به") +" "+ (object.pageTitle??"")

        if(listId === Memorito.Waiting ||listId === Memorito.Done)
            FriendsApi.getFriends(friendModel)
    }

    function cameBackToPage(object)
    {
        if(object)
        {
            let index = 0

            let thing = []
            if(object.thingId)
            {
                index = UsefulFunc.findInModel(object.thingId,"id",internalModel).index
                thing = ThingsApi.getThingById(object.thingId)
            }
            else {
                index = UsefulFunc.findInModel(object.thingLocalId,"local_id",internalModel).index
                thing = ThingsApi.getThingByLocalId(object.thingLocalId)
            }

            if(object.changeType === Memorito.Delete)
            {
                internalModel.remove(index)
                return
            }

            if(object.changeType === Memorito.Update)
            {
                internalModel.set(index,thing)
                return
            }
            else if(object.changeType === Memorito.Insert)
            {
                internalModel.append(thing)
                return
            }

            internalModel.clear()
            ThingsApi.getThings(internalModel,listId,categoryId)
        }
    }


    Item {
        anchors{ centerIn: parent }
        visible: internalModel.count === 0
        width:  600*AppStyle.size1W
        height: width
        Image {
            width:  600*AppStyle.size1W
            height: width*0.781962339
            source: "qrc:/empties/empty-list-"+AppStyle.primaryInt+".svg"
            sourceSize.width: width*2
            sourceSize.height: height*2
            anchors{
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: -30*AppStyle.size1H
            }
        }
        Text{
            text: qsTr("تو این لیست که چیزی نیست")
            font{family: AppStyle.appFont;pixelSize:  40*AppStyle.size1F;bold:true}
            color: AppStyle.textColor
            anchors{
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
        }
    }

    Loader{
        id: calendarTab
        width: parent.width
        active: listId === Memorito.Calendar
        anchors{
            top: parent.top
            topMargin: active?15*AppStyle.size1H:0
            right: parent.right
            rightMargin: 20*AppStyle.size1W
            left: parent.left
            leftMargin: 20*AppStyle.size1W
        }

        sourceComponent: Component{
            TabBar{
                id:topTab
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
                        height: parent.radius
                    }
                    layer.enabled: topTab.Material.elevation > 0
                    layer.effect: ElevationEffect {
                        elevation: topTab.Material.elevation
                        fullWidth: true
                    }
                }

                TabButton{
                    id:dayBtn
                    text: qsTr("روز")
                    Material.foreground: AppStyle.textOnPrimaryColor
                    font{family: AppStyle.appFont;pixelSize:  30*AppStyle.size1F;bold:true}
                }

                TabButton{
                    id:monthBtn
                    text: qsTr("ماه")
                    Material.foreground: AppStyle.textOnPrimaryColor
                    font{family: AppStyle.appFont;pixelSize:  30*AppStyle.size1F;bold:true}
                }

                TabButton{
                    id:yearBtn
                    text: qsTr("سال")
                    Material.foreground: AppStyle.textOnPrimaryColor
                    font{family: AppStyle.appFont;pixelSize:  30*AppStyle.size1F;bold:true}
                }

                TabButton{
                    id:optionBtn
                    text: qsTr("دلخواه")
                    Material.foreground: AppStyle.textOnPrimaryColor
                    font{family: AppStyle.appFont;pixelSize:  30*AppStyle.size1F;bold:true}
                }
            }
        }
    }

    Loader{
        id: calendarRangeTab
        active: listId === Memorito.Calendar
        anchors{
            top: calendarTab.bottom
            topMargin: active?15*AppStyle.size1H:0
            right: parent.right
            rightMargin: 20*AppStyle.size1W
            left: parent.left
            leftMargin: 20*AppStyle.size1W
        }
        width: parent.width
        clip: true

        sourceComponent:Item{
            width: parent.width
            height: 100*AppStyle.size1H
            Loader{
                id:dayLoader
                active: calendarTab.item.currentIndex === 0
                visible: active
                anchors.fill: parent
                sourceComponent: TabBar{
                    id:dayTab
                    currentIndex: 1
                    Component.onCompleted: {
                        sevenDaysLater.clicked()
                    }
                    LayoutMirroring.enabled: !AppStyle.ltr
                    LayoutMirroring.childrenInherit: true
                    TabButton{
                        id: sevenDaysAgo
                        text: qsTr("۷ روز قبلی")
                        icon{
                            source: AppStyle.ltr?"qrc:/previous.svg":"qrc:/next.svg"
                            color: !enabled ? Material.hintTextColor :
                                              sevenDaysAgo.pressed ? Material.accentColor
                                                                   : Material.foreground
                            width: 30*AppStyle.size1W
                            height:30*AppStyle.size1W
                        }
                        LayoutMirroring.enabled: !AppStyle.ltr
                        font{family: AppStyle.appFont;pixelSize:  25*AppStyle.size1F;bold:true}
                        width: 200*AppStyle.size1W
                        property int deletedDays : -1
                        enabled: dayTab.count < 21
                        onClicked: {
                            for(let i=0; i <7 ; i++)
                            {
                                var today = new Date()
                                var component = Qt.createComponent('DayButton.qml',parent);
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
                        text: qsTr("۷ روز بعدی")
                        width: 200*AppStyle.size1W
                        property int addedDays: 0
                        enabled: dayTab.count < 21
                        icon{
                            source: !AppStyle.ltr?"qrc:/previous.svg":"qrc:/next.svg"
                            color: !enabled ? Material.hintTextColor :
                                              sevenDaysLater.pressed ? Material.accentColor
                                                                     : Material.foreground
                            width: 30*AppStyle.size1W
                            height:30*AppStyle.size1W
                        }
                        LayoutMirroring.enabled: AppStyle.ltr
                        font{family: AppStyle.appFont;pixelSize:  25*AppStyle.size1F;bold:true}

                        onClicked: {
                            for(let i=0; i<7; i++)
                            {
                                var today = new Date()
                                var component = Qt.createComponent('DayButton.qml',parent);
                                if (component.status === Component.Ready){
                                    var d = component.createObject(parent, {modelData: new Date(today.setDate( today.getDate()+(addedDays+i)))});
                                    dayTab.insertItem(dayTab.count-2,d)
                                }
                                else console.log(component.errorString())
                            }

                            addedDays+=7
                            dayTab.setCurrentIndex(dayTab.count-8)
                            dayTab.currentItem.clicked(Qt.RightButton)
                        }
                    }
                }
            }

            Loader{
                id:monthLoader
                active: calendarTab.item.currentIndex === 1
                visible: active
                anchors.fill: parent
                sourceComponent: TabBar{
                    id: monthTab
                    LayoutMirroring.enabled: !AppStyle.ltr
                    LayoutMirroring.childrenInherit: true
                    currentIndex: AppStyle.ltr?new Date().getMonth()
                                              :dateConverter.toJalali(new Date().getFullYear(),new Date().getMonth(),new Date().getDate())[1]
                    Component.onCompleted: {
                        fourMonthLater.clicked()
                    }
                    TabButton{
                        id: fourMonthAgo
                        text: qsTr("۴ ماه قبلی")
                        icon{
                            source: AppStyle.ltr?"qrc:/previous.svg":"qrc:/next.svg"
                            color: !enabled ? Material.hintTextColor :
                                              fourMonthAgo.pressed ? Material.accentColor
                                                                   : Material.foreground
                            width: 30*AppStyle.size1W
                            height:30*AppStyle.size1W
                        }
                        LayoutMirroring.enabled: !AppStyle.ltr
                        font{family: AppStyle.appFont;pixelSize:  25*AppStyle.size1F;bold:true}
                        width: 200*AppStyle.size1W
                        property int deletedMonth : -1
                        enabled: monthTab.count < 12
                        onClicked: {
                            for(let i=0; i < 4 ; i++)
                            {
                                var today = new Date()
                                var component = Qt.createComponent('MonthButton.qml',parent);
                                if (component.status === Component.Ready){
                                    var d = component.createObject(parent, {modelData: new Date(today.setMonth( today.getMonth()+(deletedMonth-i)))});
                                    monthTab.insertItem(1,d)
                                }
                                else console.log(component.errorString())
                            }

                            deletedMonth -= 4
                            monthTab.setCurrentIndex(1)
                            monthTab.currentItem.clicked(Qt.RightButton)
                        }
                    }
                    TabButton{
                        id: fourMonthLater
                        text: qsTr("۴ ماه بعدی")
                        width: 200*AppStyle.size1W
                        property int addedMonth: 0
                        enabled: monthTab.count < 12
                        icon{
                            source: !AppStyle.ltr?"qrc:/previous.svg":"qrc:/next.svg"
                            color: !enabled ? Material.hintTextColor :
                                              fourMonthLater.pressed ? Material.accentColor
                                                                     : Material.foreground
                            width: 30*AppStyle.size1W
                            height:30*AppStyle.size1W
                        }
                        LayoutMirroring.enabled: AppStyle.ltr
                        font{family: AppStyle.appFont;pixelSize:  25*AppStyle.size1F;bold:true}

                        onClicked: {
                            for(let i=0; i<4; i++)
                            {
                                var today = new Date()
                                var component = Qt.createComponent('MonthButton.qml',parent);
                                if (component.status === Component.Ready){
                                    var d = component.createObject(parent, {modelData: new Date(today.setMonth( today.getMonth()+(addedMonth+i)))});
                                    monthTab.insertItem(monthTab.count-2,d)
                                }
                                else console.log(component.errorString())
                            }

                            addedMonth += 4
                            monthTab.setCurrentIndex(monthTab.count-5)
                            monthTab.currentItem.clicked(Qt.RightButton)
                        }
                    }
                }
            }

            Loader{
                id:yearLoader
                active: calendarTab.item.currentIndex === 2
                visible: active
                anchors.fill: parent
                sourceComponent: TabBar{
                    id:yearTab
                    LayoutMirroring.enabled: !AppStyle.ltr
                    LayoutMirroring.childrenInherit: true
                    Component.onCompleted: {
                        twoYearLater.clicked()
                    }

                    TabButton{
                        id: twoYearhAgo
                        text: qsTr("۲ سال قبلی")
                        icon{
                            source: AppStyle.ltr?"qrc:/previous.svg":"qrc:/next.svg"
                            color: !enabled ? Material.hintTextColor :
                                              twoYearhAgo.pressed ? Material.accentColor
                                                                  : Material.foreground
                            width: 30*AppStyle.size1W
                            height:30*AppStyle.size1W
                        }
                        LayoutMirroring.enabled: !AppStyle.ltr
                        font{family: AppStyle.appFont;pixelSize:  25*AppStyle.size1F;bold:true}
                        width: 300*AppStyle.size1W
                        property int deletedYear : -1
                        enabled: yearTab.count < 10
                        onClicked: {
                            for(let i=0; i < 2 ; i++)
                            {
                                var today = new Date()
                                var component = Qt.createComponent('YearButton.qml',parent);
                                if (component.status === Component.Ready){
                                    var d = component.createObject(parent, {modelData: new Date(today.setYear(today.getFullYear()+(deletedYear-i)))});
                                    yearTab.insertItem(1,d)
                                }
                                else console.log(component.errorString())
                            }

                            deletedYear -= 2
                            yearTab.setCurrentIndex(1)
                            yearTab.currentItem.clicked(Qt.RightButton)
                        }
                    }
                    TabButton{
                        id: twoYearLater
                        text: qsTr("۲ سال بعدی")
                        width: 300*AppStyle.size1W
                        enabled: yearTab.count < 10
                        icon{
                            source: !AppStyle.ltr?"qrc:/previous.svg":"qrc:/next.svg"
                            color: !enabled ? Material.hintTextColor :
                                              twoYearLater.pressed ? Material.accentColor
                                                                   : Material.foreground
                            width: 30*AppStyle.size1W
                            height:30*AppStyle.size1W
                        }
                        LayoutMirroring.enabled: AppStyle.ltr
                        font{family: AppStyle.appFont;pixelSize:  25*AppStyle.size1F;bold:true}

                        property int addedYear: 0
                        onClicked: {
                            for(let i=0; i<2; i++)
                            {
                                var today = new Date()
                                var component = Qt.createComponent('YearButton.qml',parent);
                                if (component.status === Component.Ready){
                                    var d = component.createObject(parent, {modelData: new Date(today.setYear( today.getFullYear()+(addedYear+i)))});
                                    yearTab.insertItem(yearTab.count-2,d)
                                }
                                else console.log(component.errorString())
                            }

                            addedYear += 2
                            yearTab.setCurrentIndex(yearTab.count-3)
                            yearTab.currentItem.clicked(Qt.RightButton)
                        }
                    }
                }
            }
            Loader{
                id: customLoader
                active: calendarTab.item.currentIndex === 3
                visible: active
                width: parent.width
                height: visible?parent.height:0

                sourceComponent: Flow{
                    width: parent.width
                    height:parent.height - 20*AppStyle.size1H
                    anchors{
                        top: parent.top
                        topMargin:  20*AppStyle.size1H
                    }
                    Component.onCompleted: internalModel.clear()

                    spacing: 20*AppStyle.size1W
                    AppDateInput{
                        id:toDate
                        placeholderText: qsTr("تا")+":"
                        width: parent.width / 2 - 10*AppStyle.size1W
                        height:parent.height- 20*AppStyle.size1H
                        minSelectedDate: fromDate.selectedDate
                        okButton.onClicked: {
                            var localFromDate = fromDate.selectedDate.toString()==="Invalid Date"?0
                                                                                                 :fromDate.selectedDate
                            var localToDate = toDate.selectedDate.toString() === "Invalid Date"?0
                                                                                               :toDate.selectedDate
                            if(localFromDate === 0 && localToDate ===0)
                                return valuesThings

                            else if (localFromDate !== 0 && localToDate === 0)
                                localToDate = new Date('3000')

                            else if (localFromDate === 0 && localToDate !== 0)
                                localFromDate = new Date(0)

                            internalModel.clear()
                            internalModel.append(ThingsApi.getThingByDate(localFromDate,localToDate))

                            queryList.due_date.fromDate = localFromDate.toISOString()
                            queryList.due_date.toDate = localToDate.toISOString()
                        }
                        cancelButton.onClicked: okButton.clicked()
                    }
                    AppDateInput{
                        id:fromDate
                        maxSelectedDate: toDate.selectedDate
                        placeholderText: qsTr("از")+":"
                        width: parent.width / 2 - 10*AppStyle.size1W
                        height:parent.height - 20*AppStyle.size1H
                        okButton.onClicked:  {
                            var localFromDate = fromDate.selectedDate.toString()==="Invalid Date"?0
                                                                                                 :fromDate.selectedDate
                            var localToDate = toDate.selectedDate.toString() === "Invalid Date"?0
                                                                                               :toDate.selectedDate
                            if(localFromDate === 0 && localToDate ===0)
                                return valuesThings

                            else if (localFromDate !== 0 && localToDate === 0)
                                localToDate = new Date('3000')

                            else if (localFromDate === 0 && localToDate !== 0)
                                localFromDate = new Date(0)

                            internalModel.clear()
                            internalModel.append(ThingsApi.getThingByDate(localFromDate,localToDate))

                            queryList.due_date.fromDate = localFromDate.toISOString()
                            queryList.due_date.toDate = localToDate.toISOString()
                        }
                        cancelButton.onClicked: okButton.clicked()
                    }
                }
            }
        }
    }
    Loader{
        id: sortLoader
        width: parent.width
        height: 100*AppStyle.size1H
        anchors{
            top: calendarRangeTab.bottom
            topMargin: listId === Memorito.Calendar ?0:15*AppStyle.size1H
            right: parent.right
            rightMargin: 30*AppStyle.size1W
            left: parent.left
            leftMargin: 30*AppStyle.size1W
        }
        active: internalModel.count>0 || searched
        sourceComponent: RowLayout{
            id:sortFlow
            layoutDirection: Qt.RightToLeft
            spacing: 10*AppStyle.size1W

            AppTextInput{
                id: searchInput
                Layout.fillWidth: true
                Layout.fillHeight: true
                placeholderText: qsTr("جست و جو")
                hasCounter: false
                leftPadding: AppStyle.ltr?20*AppStyle.size1W:parent.height
                rightPadding: AppStyle.ltr?parent.height:20*AppStyle.size1W
                text: queryList.searchText
                onTextEdited: {
                    queryList.searchText = text.trim()
                }

                AppButton{
                    height: parent.height - 20*AppStyle.size1H
                    width: height
                    radius: 20*AppStyle.size1W
                    icon{
                        source: "qrc:/search.svg"
                        color: AppStyle.textOnPrimaryColor
                        width: Qt.size(50*AppStyle.size1W,50*AppStyle.size1W).width
                        height: Qt.size(50*AppStyle.size1W,50*AppStyle.size1W).height
                    }

                    anchors{
                        left: parent.left
                        leftMargin: 10*AppStyle.size1W
                        verticalCenter: parent.verticalCenter
                    }

                    onClicked: {
                        internalModel.clear()
                        internalModel.append(ThingsApi.getThingsByQuery(makeQuery()))
                    }
                }
            }
            AppButton{
                id: advanceSearchBtn
                Layout.fillHeight: true
                text: qsTr("تنظیمات پیشرفته")
                radius: 30*AppStyle.size1W
                flat: true
                borderColor: AppStyle.borderColor
                onClicked: {
                    dialogLoader.active = true
                    dialogLoader.item.open()
                }
                visible: listId !== Memorito.Process
            }

            Loader{
                id: dialogLoader
                active: false
                visible: active
                sourceComponent: Popup{
                    id:advanceSearchDialog
                    x:AppStyle.ltr? advanceSearchBtn.x-advanceSearchDialog.width+advanceSearchBtn.width
                                  : advanceSearchBtn.x
                    y:advanceSearchBtn.height + advanceSearchBtn.y
                    modal:true
                    visible: true

                    width:  (UsefulFunc.rootWindow.width - 100*AppStyle.size1W)  < 800*AppStyle.size1W ?(UsefulFunc.rootWindow.width - 100*AppStyle.size1W)
                                                                                                       : 800*AppStyle.size1W
                    height: (UsefulFunc.rootWindow.height - 500*AppStyle.size1H) < 800*AppStyle.size1H ? UsefulFunc.rootWindow.height - 500*AppStyle.size1H
                                                                                                       : 800*AppStyle.size1H
                    onClosed: {
                        dialogLoader.active = false
                    }

                    Overlay.modal: Rectangle {
                        color: AppStyle.appTheme?"#aa606060":"#80000000"
                    }

                    background: Rectangle{
                        color: AppStyle.dialogBackgroundColor
                        radius: 60*AppStyle.size1W
                    }

                    Flickable{
                        id: mainFlick
                        height: parent.height
                        width:  parent.width
                        clip:true
                        contentHeight: item1.height
                        anchors{
                            right: parent.right
                            top: parent.top
                        }
                        flickableDirection: Flickable.VerticalFlick
                        onContentYChanged: {
                            if(contentY<0 || contentHeight < mainFlick.height)
                                contentY = 0
                            else if(contentY > (contentHeight-mainFlick.height))
                                contentY = contentHeight-mainFlick.height
                        }
                        onContentXChanged: {
                            if(contentX<0 || contentWidth < mainFlick.width)
                                contentX = 0
                            else if(contentX > (contentWidth-mainFlick.width))
                                contentX = (contentWidth-mainFlick.width)
                        }
                        ScrollBar.vertical: ScrollBar {
                            hoverEnabled: true
                            active: hovered || pressed || parent.flickingVertically
                            visible: active
                            orientation: Qt.Vertical
                            anchors.right: mainFlick.right
                            height: parent.height
                            width: hovered || pressed?18*AppStyle.size1W:8*AppStyle.size1W
                            contentItem: Rectangle {
                                visible: parent.active
                                radius: parent.pressed || parent.hovered ?20*AppStyle.size1W:8*AppStyle.size1W
                                color: parent.pressed ?Material.color(AppStyle.primaryInt,Material.Shade900):Material.color(AppStyle.primaryInt,Material.Shade600)
                            }
                        }
                        Flow{
                            id:item1
                            anchors{
                                right: parent.right
                                rightMargin: 10*AppStyle.size1W
                                left: parent.left
                                leftMargin:  10*AppStyle.size1W
                            }


                            Item{
                                width: parent.width
                                height: 100*AppStyle.size1H
                                Image{
                                    id: sortImg
                                    source: "qrc:/sort.svg"
                                    width: 40*AppStyle.size1W
                                    height: width
                                    sourceSize: Qt.size(width*2,height*2)
                                    anchors{
                                        right: parent.right
                                        verticalCenter: parent.verticalCenter
                                    }
                                    visible: false
                                }
                                ColorOverlay{
                                    anchors.fill: sortImg
                                    source: sortImg
                                    color: AppStyle.textColor
                                }
                                Text{
                                    id: sortText
                                    text: qsTr("مرتب‌سازی براساس")+": "

                                    anchors{
                                        right: sortImg.left
                                        rightMargin: 15*AppStyle.size1W
                                        bottom: parent.bottom
                                        bottomMargin: 25*AppStyle.size1H
                                    }
                                    color:AppStyle.textColor
                                    font{family: AppStyle.appFont;pixelSize:  25*AppStyle.size1F;bold:true}
                                }
                                AppComboBox{
                                    id: sortCompbo
                                    anchors{
                                        right: sortText.left
                                        rightMargin: 10*AppStyle.size1W
                                        left: sortTypeBtn.right
                                        leftMargin: 5*AppStyle.size1W
                                        verticalCenter: parent.verticalCenter
                                    }
                                    textAlign: Qt.AlignHCenter
                                    textRole: "text"
                                    currentIndex: UsefulFunc.findInModel(queryList.orderBy,"query",sortCompbo.model).index
                                    iconSize: AppStyle.size1W*50
                                    hasClear: false
                                    model: ListModel{
                                        ListElement{
                                            text: qsTr("الفبا")
                                            query: "title"
                                        }
                                        ListElement{
                                            text: qsTr("تاریخ ثبت")
                                            query: "register_date"
                                        }
                                        ListElement{
                                            text: qsTr("تاریخ آخرین ویرایش")
                                            query: "modified_date"
                                        }
                                        ListElement{
                                            text: qsTr("اولویت")
                                            query: "priority_id"
                                        }
                                        ListElement{
                                            text: qsTr("انرژی")
                                            query: "energy_id"
                                        }
                                        ListElement{
                                            text: qsTr("زمان موردنیاز")
                                            query: "estimate_time"
                                        }
                                    }
                                }
                                AppButton{
                                    id:sortTypeBtn
                                    height: 90*AppStyle.size1H
                                    width: height
                                    checkable: true
                                    Material.accent: "transparent"
                                    Material.primary: "transparent"
                                    Material.background: "transparent"
                                    checked: queryList.orderType === "ASC"? true
                                                                          :false
                                    icon{
                                        source: checked?"qrc:/sort-asc.svg":"qrc:/sort-desc.svg"
                                        color: AppStyle.textColor
                                        width: Qt.size(40*AppStyle.size1W,40*AppStyle.size1W).width
                                        height: Qt.size(40*AppStyle.size1W,40*AppStyle.size1W).height
                                    }
                                    anchors{
                                        bottom: parent.bottom
                                        left: parent.left
                                    }
                                    hoverEnabled: true
                                    property ToolTip toolTip : ToolTip{
                                        text: sortTypeBtn.checked?qsTr("صعودی")
                                                                 :qsTr("نزولی")
                                        font{family: AppStyle.appFont;pixelSize:  25*AppStyle.size1F;bold:true}
                                    }
                                    onHoveredChanged: {

                                        if(hovered)
                                            toolTip.open()
                                        else toolTip.hide()
                                    }
                                    onClicked: {

                                    }
                                }
                            }

                            Item{
                                width: parent.width
                                height: 100*AppStyle.size1H
                                Image{
                                    id: filterImg
                                    source: "qrc:/filter.svg"
                                    width: 40*AppStyle.size1W
                                    height: width
                                    sourceSize: Qt.size(width*2,height*2)
                                    anchors{
                                        right: parent.right
                                        verticalCenter: parent.verticalCenter
                                    }
                                    visible: false
                                }
                                ColorOverlay{
                                    anchors.fill: filterImg
                                    source: filterImg
                                    color: AppStyle.textColor
                                }

                                Text{
                                    id: filterText
                                    text: qsTr("محدود کردن نتایج جست و جو")
                                    anchors{
                                        right: filterImg.left
                                        rightMargin: 15*AppStyle.size1W
                                        verticalCenter: parent.verticalCenter
                                    }
                                    color:AppStyle.textColor
                                    font{family: AppStyle.appFont;pixelSize:  25*AppStyle.size1F;bold:true}
                                }
                            }
                            Text{
                                text: qsTr("محل‌های انجام")+": "
                                width: parent.width
                                font{family: AppStyle.appFont;pixelSize:  25*AppStyle.size1F;bold:true}
                                color:AppStyle.textColor
                                rightPadding: 15*AppStyle.size1W
                                Component.onCompleted: {

                                    if (listId === Memorito.Contexts)
                                    {
                                        visible = false
                                        height = 0
                                    }
                                }
                            }
                            Grid{
                                width: parent.width
                                layoutDirection: Qt.RightToLeft
                                visible: (listId !== Memorito.Contexts)
                                onHeightChanged: {
                                    if(!visible)
                                        height = 0
                                }
                                ButtonGroup{ id:contextGroup;exclusive: false}
                                Repeater{
                                    model: contextModel
                                    delegate: AppCheckBox{
                                        text: model.context_name
                                        ButtonGroup.group: contextGroup
                                        width: parent.width/2
                                        checked: queryList.context_id.indexOf(model.id) !== -1
                                    }
                                }
                            }

                            Text{
                                id: filesText
                                text: qsTr("فایل")+": "
                                width: parent.width
                                font{family: AppStyle.appFont;pixelSize:  25*AppStyle.size1F;bold:true}
                                color:AppStyle.textColor
                                height: 75*AppStyle.size1H
                                verticalAlignment: Text.AlignBottom
                                rightPadding: 15*AppStyle.size1W
                            }
                            Grid{
                                width: parent.width
                                layoutDirection: Qt.RightToLeft
                                ButtonGroup{ id:filesGroup}
                                Repeater{
                                    model: [qsTr("نداشته باشه"),qsTr("داشته باشه"),qsTr("مهم نیست")]
                                    delegate: AppRadioButton{
                                        property int id: index
                                        text: modelData
                                        ButtonGroup.group: filesGroup
                                        checked: queryList.has_files === index
                                        width: parent.width/3
                                    }
                                }
                            }

                            Text{
                                id: prioritiesText
                                text: qsTr("الویت‌ها")+": "
                                width: parent.width
                                font{family: AppStyle.appFont;pixelSize:  25*AppStyle.size1F;bold:true}
                                color:AppStyle.textColor
                                rightPadding: 15*AppStyle.size1W
                                height: 75*AppStyle.size1H
                                verticalAlignment: Text.AlignBottom
                            }
                            Grid{
                                width: parent.width
                                layoutDirection: Qt.RightToLeft
                                rows: 2
                                columns: 2
                                ButtonGroup{ id:prioritiesGroup;exclusive: false}
                                Repeater{
                                    model: priorityModel
                                    delegate: AppCheckBox{
                                        text: "      "+model.Text
                                        ButtonGroup.group: prioritiesGroup
                                        checked: queryList.priority_id.indexOf(model.Id) !== -1
                                        width: prioritiesText.width/2
                                        Image {
                                            source: model.iconSource
                                            width: 40*AppStyle.size1W
                                            height: width
                                            sourceSize.width:width*2
                                            sourceSize.height:height*2
                                            anchors{
                                                verticalCenter: parent.verticalCenter
                                                right: parent.right
                                                rightMargin: 50*AppStyle.size1W
                                            }
                                        }
                                    }
                                }
                            }

                            Text{
                                id: energiesText
                                text: qsTr("انرژی‌ها")+": "
                                width: parent.width
                                font{family: AppStyle.appFont;pixelSize:  25*AppStyle.size1F;bold:true}
                                color:AppStyle.textColor
                                rightPadding: 15*AppStyle.size1W
                                height: 75*AppStyle.size1H
                                verticalAlignment: Text.AlignBottom
                            }
                            Grid{
                                width: parent.width
                                layoutDirection: Qt.RightToLeft
                                rows: 2
                                columns: 2
                                ButtonGroup{ id:energiesGroup;exclusive: false}
                                Repeater{
                                    model: energyModel
                                    delegate: AppCheckBox{
                                        text: "      "+model.Text
                                        ButtonGroup.group: energiesGroup
                                        width: energiesText.width/2
                                        checked: queryList.energy_id.indexOf(model.Id) !== -1
                                        Image {
                                            source: model.iconSource
                                            width: 40*AppStyle.size1W
                                            height: width
                                            sourceSize.width:width*2
                                            sourceSize.height:height*2
                                            anchors{
                                                verticalCenter: parent.verticalCenter
                                                right: parent.right
                                                rightMargin: 50*AppStyle.size1W
                                            }
                                        }
                                    }
                                }
                            }

                            Text{
                                id: timeText
                                text: qsTr("زمان موردنیاز")+": "
                                width: parent.width
                                font{family: AppStyle.appFont;pixelSize:  25*AppStyle.size1F;bold:true}
                                color:AppStyle.textColor
                                rightPadding: 15*AppStyle.size1W
                                height: 75*AppStyle.size1H
                                verticalAlignment: Text.AlignBottom
                            }
                            Item{
                                width: parent.width
                                height: 120*AppStyle.size1H
                                AppComboBox{
                                    id: timeCompbo
                                    anchors{
                                        right: parent.right
                                        rightMargin: 10*AppStyle.size1W
                                        verticalCenter: parent.verticalCenter
                                    }
                                    width: parent.width/2 - 10*AppStyle.size1W
                                    textAlign: Qt.AlignHCenter
                                    textRole: "text"
                                    iconSize: AppStyle.size1W*50
                                    hasClear: false
                                    currentIndex: UsefulFunc.findInModel(queryList.estimate_type,"query",timeCompbo.model).index
                                    model: ListModel{
                                        ListElement{
                                            text:qsTr("کمتر از")
                                            query:"<"
                                        }
                                        ListElement{
                                            text:qsTr("برابر با")
                                            query:"="
                                        }
                                        ListElement{
                                            text:qsTr("بیشتر از")
                                            query:">"
                                        }
                                    }
                                }
                                AppTextField{
                                    id:timeInput
                                    anchors{
                                        right: timeCompbo.left
                                        rightMargin: 10*AppStyle.size1W
                                        left: parent.left
                                        leftMargin: 10*AppStyle.size1W
                                        bottom: parent.bottom
                                        bottomMargin: 2*AppStyle.size1H
                                    }
                                    text: queryList.estimate_time
                                    font.bold: false
                                    placeholder.visible: false
                                    placeholderTextColor: AppStyle.textColor
                                    height: AppStyle.size1H*100
                                    horizontalAlignment: Text.AlignHCenter
                                    placeholderText: qsTr("زمان تخمینی به دقیقه")
                                    maximumLength: 3
                                    validator: RegExpValidator {
                                        regExp: /[0123456789۰۱۲۳۴۵۶۷۸۹]{3}/ig
                                    }
                                    onTextChanged: {
                                        if (text.match(/[۰۱۲۳۴۵۶۷۸۹]/ig))
                                            text = UsefulFunc.faToEnNumber(text)
                                    }
                                    Text{
                                        anchors{
                                            left: parent.left
                                            verticalCenter: parent.verticalCenter
                                        }
                                        text: qsTr("دقیقه")
                                        font: parent.font
                                        visible: parent.text.trim()!==""
                                    }
                                }
                            }

                            Item{
                                width: parent.width
                                height: 150*AppStyle.size1H
                                AppButton{
                                    id: applayFilter
                                    anchors.centerIn: parent
                                    text: qsTr("اعمال")
                                    radius: 30*AppStyle.size1W
                                    width: parent.width/2
                                    icon{
                                        source: "qrc:/check-circle.svg"
                                        width: 40*AppStyle.size1W
                                        height:  40*AppStyle.size1W
                                        color: AppStyle.textOnPrimaryColor
                                    }
                                    onClicked: {
                                        let i =0
                                        let contextsSelected = []
                                        for(i=0; i < contextModel.count; i++)
                                            if(contextGroup.buttons[i].checked)
                                                contextsSelected.push(contextModel.get(i).id)

                                        let prioritiesSelected = []
                                        for(i=0; i<priorityModel.count;i++)
                                            if(prioritiesGroup.buttons[i].checked)
                                                prioritiesSelected.push(priorityModel.get(i).Id)


                                        let energiesSelected = []
                                        for(i=0; i<energyModel.count;i++)
                                            if(energiesGroup.buttons[i].checked)
                                                energiesSelected.push(energyModel.get(i).Id)

                                        if (contextsSelected.length)
                                            queryList["context_id"] = (contextsSelected.join(","))

                                        if (prioritiesSelected.length)
                                            queryList["priority_id"] = (prioritiesSelected.join(","))

                                        if (energiesSelected.length)
                                            queryList["energy_id"] = (energiesSelected.join(","))

                                        queryList["has_files"] = (filesGroup.checkedButton.id)

                                        if (timeInput.text.trim())
                                        {
                                            queryList["estimate_time"] = Number(timeInput.text.trim())
                                            queryList["estimate_type"] = timeCompbo.model.get(timeCompbo.currentIndex).query
                                        }

                                        queryList.orderBy   = sortCompbo.model.get(sortCompbo.currentIndex).query
                                        queryList.orderType = sortTypeBtn.checked?"ASC":"DESC"

                                        internalModel.clear()
                                        internalModel.append(ThingsApi.getThingsByQuery(makeQuery()))

                                        advanceSearchDialog.close()


                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

    }
    Loader{
        id: thingsLoader
        active: internalModel.count > 0
        width: parent.width
        clip: true
        anchors{
            top: sortLoader.bottom
            topMargin: 15*AppStyle.size1H
            right: parent.right
            rightMargin: 30*AppStyle.size1W
            bottom: parent.bottom
            bottomMargin: 15*AppStyle.size1H
            left: parent.left
            leftMargin: 30*AppStyle.size1W
        }
        sourceComponent: GridView{
            id: control
            property real lastContentY: 0
            onContentYChanged: {
                if(contentY<0 || contentHeight < control.height)
                    contentY = 0

                else if(contentY > (contentHeight - control.height))
                {
                    contentY = (contentHeight - control.height)
                    lastContentY = contentY-1
                }

                /************* Move Add Button to Down or Up *******************/
                if(contentY > lastContentY)
                    addBtn.anchors.bottomMargin = -60*AppStyle.size1H
                else addBtn.anchors.bottomMargin = 20*AppStyle.size1H

                lastContentY = contentY
            }
            onContentXChanged: {
                if(contentX<0 || contentWidth < control.width)
                    contentX = 0
                else if(contentX > (contentWidth-control.width))
                    contentX = (contentWidth-control.width)
            }

            layoutDirection:Qt.RightToLeft
            cellHeight: listId === Memorito.Process? 240*AppStyle.size1W:400*AppStyle.size1W
            cellWidth: width / (parseInt(width / parseInt(600*AppStyle.size1W))===0?1:(parseInt(width / parseInt(600*AppStyle.size1W))))


            /***********************************************/
            delegate: AppButton {
                id:rootItem
                radius: 15*AppStyle.size1W
                width: control.cellWidth - 20*AppStyle.size1W
                height:  control.cellHeight - 10*AppStyle.size1H
                Material.background: Material.color(AppStyle.primaryInt,Material.Shade50)
                clip: true


                onClicked: {
                    console.time("Start")
                    UsefulFunc.mainStackPush("qrc:/Things/ThingsDetail.qml",qsTr("جزئیات")+": "+model.title,{"thingLocalId":model.local_id, "listId": listId})
                }

                Rectangle{
                    id:topRect
                    width: parent.width
                    height: 70*AppStyle.size1H
                    radius: 15*AppStyle.size1W
                    Rectangle{
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 15*AppStyle.size1W
                        color: parent.color
                    }
                    color: Material.color(AppStyle.primaryInt,Material.ShadeA700)
                    Image {
                        id: unprocessImg
                        source: "qrc:/ThingsListIcon/" +(
                                    listId === Memorito.Process?"process-item":
                                                                 listId === Memorito.Refrence?"reference-item":
                                                                                               listId === Memorito.Waiting?"waiting-item":
                                                                                                                            listId === Memorito.Calendar?"calendar-item":
                                                                                                                                                          listId === Memorito.Trash?"trash-item":
                                                                                                                                                                                     listId === Memorito.Done?"done-item":
                                                                                                                                                                                                               listId === Memorito.Someday?"someday-item":
                                                                                                                                                                                                                                            listId === Memorito.Project?"project-item":
                                                                                                                                                                                                                                                                         listId === Memorito.Contexts?"context-item":
                                                                                                                                                                                                                                                                                                       listId === Memorito.Friends?"friends-item":"nextaction-item")+".svg"
                        width: 40*AppStyle.size1W
                        height: width
                        sourceSize.width: width*2
                        sourceSize.height: height*2
                        anchors{
                            verticalCenter: parent.verticalCenter
                            right: parent.right
                            rightMargin: 15*AppStyle.size1W
                        }
                        visible: false
                    }
                    ColorOverlay{
                        anchors.fill: unprocessImg
                        source: unprocessImg
                        color: AppStyle.textOnPrimaryColor
                    }

                    Text{
                        id: thingText
                        text: model.title
                        font{family: AppStyle.appFont;pixelSize:  25*AppStyle.size1F;bold:true}
                        color: AppStyle.textOnPrimaryColor
                        anchors{
                            top:  parent.top
                            bottom: parent.bottom
                            right: unprocessImg.left
                            rightMargin: 20*AppStyle.size1W
                            left: isDoneColor.visible?isDoneImg.right:parent.left
                            leftMargin: 20*AppStyle.size1W
                        }
                        verticalAlignment: Text.AlignVCenter
                        elide: Qt.ElideRight
                    }
                    Image {
                        id: isDoneImg
                        source: "qrc:/check-circle.svg"
                        width: 40*AppStyle.size1W
                        height: width
                        sourceSize.width:width*2
                        sourceSize.height:height*2
                        anchors{
                            verticalCenter: topRect.verticalCenter
                            left: parent.left
                            leftMargin: 20*AppStyle.size1W
                        }
                        visible: false
                        asynchronous: true
                    }
                    ColorOverlay{
                        id:isDoneColor
                        visible: model.is_done === 1
                        color: AppStyle.textOnPrimaryColor
                        source: isDoneImg
                        anchors.fill: isDoneImg
                    }
                }
                Text{
                    id: detailText
                    text: qsTr("توضیحات") + ": " + (model.detail? model.detail : qsTr("توضیحاتی ثبت نشده"))
                    font{family: AppStyle.appFont;pixelSize:  23*AppStyle.size1F;}
                    anchors{
                        top:  topRect.bottom
                        topMargin: 15*AppStyle.size1W
                        right: parent.right
                        rightMargin: 20*AppStyle.size1W
                        left: parent.left
                        leftMargin: 20*AppStyle.size1W
                    }
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    maximumLineCount: 3
                    height: 115*AppStyle.size1W
                    elide: AppStyle.ltr?Text.ElideLeft:Text.ElideRight

                }
                Loader{
                    active: listId !== Memorito.Process
                    visible: active
                    anchors{
                        top: detailText.bottom
                        bottom: moreDetailText.top
                        right: parent.right
                        rightMargin: 20*AppStyle.size1W
                        left: parent.left
                        leftMargin: 20*AppStyle.size1W
                    }
                    sourceComponent: Flow{
                        id: flow1
                        width: parent.width
                        height: parent.height
                        layoutDirection: "RightToLeft"
                        Item{
                            width: parent.width /2
                            height: 50*AppStyle.size1H
                            Image {
                                id: priorityImg
                                source: model.priority_id?UsefulFunc.findInModel(model.priority_id,"Id",priorityModel).value.iconSource:"qrc:/priorities/none.svg"
                                width: 40*AppStyle.size1W
                                height: width
                                sourceSize.width:width*2
                                sourceSize.height:height*2
                                anchors{
                                    verticalCenter: parent.verticalCenter
                                    right: parent.right
                                }
                            }
                            Text {
                                id: priorityText
                                anchors{
                                    verticalCenter: priorityImg.verticalCenter
                                    right: priorityImg.left
                                    rightMargin: 10*AppStyle.size1W
                                    left: parent.left
                                }
                                text: qsTr("اولویت") +": " + (model.priority_id?UsefulFunc.findInModel(model.priority_id,"Id",priorityModel).value.Text:qsTr("ثبت نشده"))
                                elide: AppStyle.ltr?Text.ElideLeft:Text.ElideRight
                                font{family: AppStyle.appFont;pixelSize:  23*AppStyle.size1F;bold:false}
                            }
                        }
                        Item{
                            width: parent.width /2
                            height: 50*AppStyle.size1H
                            Image {
                                id: energyImg
                                source: model.energy_id?UsefulFunc.findInModel(model.energy_id,"Id",energyModel).value.iconSource:"qrc:/energies/none.svg"
                                width: 40*AppStyle.size1W
                                height: width
                                sourceSize.width:width*2
                                sourceSize.height:height*2
                                anchors{
                                    verticalCenter: parent.verticalCenter
                                    right: parent.right
                                }
                            }
                            Text {
                                id: energyText
                                anchors{
                                    verticalCenter: energyImg.verticalCenter
                                    right: energyImg.left
                                    rightMargin: 10*AppStyle.size1W
                                    left: parent.left
                                }
                                text: qsTr("سطح انرژی") +": " + (model.energy_id?UsefulFunc.findInModel(model.energy_id,"Id",energyModel).value.Text:qsTr("ثبت نشده"))
                                elide: AppStyle.ltr?Text.ElideLeft:Text.ElideRight
                                font{family: AppStyle.appFont;pixelSize:  23*AppStyle.size1F;bold:false}
                            }
                        }
                        Item{
                            width: parent.width /2
                            height: 50*AppStyle.size1H
                            Image {
                                id: contextImg
                                source: model.context_id?"qrc:/map.svg":"qrc:/map-unknown.svg"
                                width: 40*AppStyle.size1W
                                height: width
                                sourceSize.width:width*2
                                sourceSize.height:height*2
                                anchors{
                                    verticalCenter: parent.verticalCenter
                                    right: parent.right
                                }
                            }
                            Text {
                                id: contextText
                                anchors{
                                    verticalCenter: contextImg.verticalCenter
                                    right: contextImg.left
                                    rightMargin: 10*AppStyle.size1W
                                    left: parent.left
                                }
                                text: qsTr("محل انجام") +": " + (model.context_id?contextModel.count>0?UsefulFunc.findInModel(model.context_id,"id",contextModel).value.context_name:"":qsTr("ثبت نشده"))
                                font{family: AppStyle.appFont;pixelSize:  23*AppStyle.size1F;bold:false}
                                elide: AppStyle.ltr?Text.ElideLeft:Text.ElideRight
                            }
                        }
                        Item{
                            width: parent.width /2
                            height: 50*AppStyle.size1H
                            Image {
                                id: estimateImg
                                source: model.estimate_time?"qrc:/clock-colorful.svg":"qrc:/clock-unknown.svg"
                                width: 40*AppStyle.size1W
                                height: width
                                sourceSize.width:width*2
                                sourceSize.height:height*2
                                anchors{
                                    verticalCenter: parent.verticalCenter
                                    right: parent.right
                                }
                            }
                            Text {
                                id: estimateText
                                anchors{
                                    verticalCenter: estimateImg.verticalCenter
                                    right: estimateImg.left
                                    rightMargin: 10*AppStyle.size1W
                                    left: parent.left
                                }
                                text: qsTr("تخمین زمانی") +": " + (model.estimate_time?model.estimate_time+ " " + qsTr("دقیقه"):qsTr("ثبت نشده"))
                                font{family: AppStyle.appFont;pixelSize:  23*AppStyle.size1F;bold:false}
                                elide: AppStyle.ltr?Text.ElideLeft:Text.ElideRight
                            }
                        }
                        Loader{
                            active: model.list_id === Memorito.Waiting || model.friend_id
                            width: parent.width /2
                            visible: active
                            height: 50*AppStyle.size1H
                            sourceComponent: Item{
                                anchors.fill: parent
                                Image {
                                    id: friendImg
                                    source:"qrc:/friends-colorful.svg"
                                    width: 40*AppStyle.size1W
                                    height: width
                                    sourceSize.width:width*2
                                    sourceSize.height:height*2
                                    anchors{
                                        verticalCenter: parent.verticalCenter
                                        right: parent.right
                                    }
                                }
                                Text {
                                    text:qsTr("فرد انجام دهنده") +": " + (model.friend_id?friendModel.count>0?UsefulFunc.findInModel(model.friend_id,"id",friendModel).value.friend_name
                                                                                                             :""
                                                                          :qsTr("ثبت نشده"))
                                    anchors{
                                        verticalCenter: friendImg.verticalCenter
                                        right: friendImg.left
                                        rightMargin: 10*AppStyle.size1W
                                        left: parent.left
                                    }
                                    font{family: AppStyle.appFont;pixelSize:  23*AppStyle.size1F;bold:false}
                                    elide: AppStyle.ltr?Text.ElideLeft:Text.ElideRight
                                }
                            }
                        }
                        Loader{
                            active: model.list_id === Memorito.Calendar || model.due_date !==""
                            width: parent.width
                            height: 50*AppStyle.size1H
                            visible: active
                            sourceComponent: Item{
                                anchors.fill: parent
                                Image {
                                    id: dateImg
                                    source:"qrc:/calendar-colorful.svg"
                                    width: 40*AppStyle.size1W
                                    height: width
                                    sourceSize.width:width*2
                                    sourceSize.height:height*2
                                    anchors{
                                        verticalCenter: parent.verticalCenter
                                        right: parent.right
                                    }
                                }
                                Text {
                                    property date dueDate: new Date(model.due_date)
                                    text:qsTr("زمان مشخص شده") +": "
                                         +( dueDate ?AppStyle.ltr? dueDate.getFullYear()+"/"+(dueDate.getMonth()+1)+"/"+dueDate.getDate()
                                                                 :(dateConverter.toJalali(dueDate.getFullYear(),dueDate.getMonth()+1,dueDate.getDate())).slice(0,3).join("/")
                                           : qsTr("ثبت نشده"))

                                    anchors{
                                        verticalCenter: dateImg.verticalCenter
                                        right: dateImg.left
                                        rightMargin: 10*AppStyle.size1W
                                        left: parent.left
                                    }
                                    font{family: AppStyle.appFont;pixelSize:  23*AppStyle.size1F;bold:false}
                                    elide: AppStyle.ltr?Text.ElideLeft:Text.ElideRight
                                }
                            }
                        }
                    }
                }
                Text{
                    id: moreDetailText
                    text: "<u>"+qsTr("توضیحات بیشتر") + "</u>"
                    font{family: AppStyle.appFont;pixelSize:  20*AppStyle.size1F;bold:false}
                    wrapMode: Text.WordWrap
                    elide: AppStyle.ltr?Text.ElideLeft:Text.ElideRight
                    anchors{
                        bottom: parent.bottom
                        bottomMargin: 10*AppStyle.size1W
                        left: parent.left
                        leftMargin: 20*AppStyle.size1W
                    }
                }
                Text{
                    text: qsTr("فایل داره")
                    visible: model.has_files
                    font{family: AppStyle.appFont;pixelSize:  20*AppStyle.size1F;bold:false}
                    wrapMode: Text.WordWrap
                    anchors{
                        bottom: parent.bottom
                        bottomMargin: 10*AppStyle.size1W
                        right: parent.right
                        rightMargin: 20*AppStyle.size1W
                    }
                }
            }

            /***********************************************/
            model: internalModel
        }

    }
    AppButton{
        id: addBtn
        anchors{
            left: parent.left
            leftMargin: 20*AppStyle.size1W
            bottom: parent.bottom
            bottomMargin: 20*AppStyle.size1W
        }
        Behavior on anchors.bottomMargin { NumberAnimation{ duration: 200 } }
        radius: 20*AppStyle.size1W
        leftPadding: 35*AppStyle.size1W
        rightPadding: 35*AppStyle.size1W
        onClicked: {
            if(listId === Memorito.Friends)
                UsefulFunc.mainStackPush("qrc:/Things/AddEditThing.qml",text,{listId:Memorito.Waiting,categoryId:categoryId})
            else if(listId === Memorito.Contexts)

                UsefulFunc.mainStackPush("qrc:/Things/AddEditThing.qml",text,{listId:Memorito.NextAction,categoryId:categoryId})

            else
                UsefulFunc.mainStackPush("qrc:/Things/AddEditThing.qml",text,{listId:listId,categoryId:categoryId})

        }
        icon.width: 30*AppStyle.size1W
        icon.source:"qrc:/plus.svg"
    }
}
