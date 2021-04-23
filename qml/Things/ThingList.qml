import QtQml 2.15 as D
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Material.impl 2.15
import QtGraphicalEffects 1.15

import QDateConvertor 1.0
import Components 1.0
import Global 1.0
import Qt.labs.calendar 1.0

Item {
    property int listId: -1
    property int categoryId: -1
    ListModel{ id:internalModel }
    QDateConvertor{id:dateConverter}

    function cameInToPage(object)
    {
        ContextsApi.getContexts(contextModel)

        if(listId === Memorito.Friends)
            internalModel.append(ThingsApi.getThingByFriendId(categoryId))
        else if(listId === Memorito.Contexts)
            internalModel.append(ThingsApi.getThingByContextId(categoryId))
        else if(listId === Memorito.Calendar);

        else
            ThingsApi.getThings(internalModel,listId,categoryId)

        addBtn.text = qsTr("افزودن چیز به") +" "+ (object.pageTitle??"")

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
        active: listId === Memorito.Calendar
        anchors{
            top: parent.top
            topMargin: active?15*AppStyle.size1H:0
            right: parent.right
            rightMargin: 20*AppStyle.size1W
            left: parent.left
            leftMargin: 20*AppStyle.size1W
        }
        width: parent.width

        sourceComponent: Component{
            TabBar{
                id:topTab
                LayoutMirroring.enabled: !AppStyle.ltr
                LayoutMirroring.childrenInherit: true

                TabButton{
                    id:dayBtn
                    text: qsTr("روز")
                }

                TabButton{
                    id:monthBtn
                    text: qsTr("ماه")
                }

                TabButton{
                    id:yearBtn
                    text: qsTr("سال")
                }

                TabButton{
                    id:optionBtn
                    text: qsTr("دلخواه")
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

        sourceComponent:Item{
            width: parent.width
            height: 100*AppStyle.size1H
            Loader{
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
                        width: 200*AppStyle.size1W
                        property int deletedDays : 0
                        enabled: dayTab.count < 21
                        onClicked: {
                            for(let i=0; i <7 ; i++)
                            {
                                var today = new Date()
                                var component = Qt.createComponent(DayButton,parent);
                                if (component.status === Component.Ready){
                                    var d = component.createObject(parent, {modelData: new Date(today.setDate( today.getDate()+(deletedDays-i)))});
                                    dayTab.insertItem(1,d)
                                }
                                else console.log(component.errorString())
                            }

                            deletedDays -= 7
                            dayTab.setCurrentIndex(7)
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
                    LayoutMirroring.enabled: !AppStyle.ltr
                    LayoutMirroring.childrenInherit: true
                    currentIndex: AppStyle.ltr?new Date().getMonth()
                                              :dateConverter.toJalali(new Date().getFullYear(),new Date().getMonth(),new Date().getDate())[1]
                    Repeater{
                        model: AppStyle.ltr?["January","February","March","April","May","June","July","August","September","October","November","December"]
                                           :dateConverter.get_month()
                        delegate: TabButton{
                            text: modelData
                            width: monthLoader.width/12<200*AppStyle.size1W?200*AppStyle.size1W:monthLoader.width/12
                        }
                    }
                }
            }
            Loader{
                active: calendarTab.item.currentIndex === 2
                visible: active
                anchors.fill: parent
                sourceComponent: TabBar{
                    id:yearTab
                    LayoutMirroring.enabled: !AppStyle.ltr
                    LayoutMirroring.childrenInherit: true
                    Repeater{
                        model: [-2,-1,0,1,2,3]
                        delegate: TabButton{
                            property date today : new Date()

                            text: AppStyle.ltr?today.getFullYear()+modelData
                                              :parseInt(dateConverter.toJalali(today.getFullYear(),today.getMonth()+1,today.getDate())[0])+modelData
                            width: monthLoader.width/count<200*AppStyle.size1W?200*AppStyle.size1W:monthLoader.width/count
                            Component.onCompleted: {

                                yearTab.currentIndex = today.getFullYear() === today.getFullYear()+modelData?index:yearTab.currentIndex

                            }
                        }
                    }
                }
            }
            Loader{
                id: yearLoader
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

                    spacing: 20*AppStyle.size1W
                    AppDateInput{
                        id:toDate
                        placeholderText: qsTr("تا")+":"
                        width: parent.width / 2 - 10*AppStyle.size1W
                        height:parent.height- 20*AppStyle.size1H
                        minSelectedDate: fromDate.selectedDate
                    }
                    AppDateInput{
                        id:fromDate
                        maxSelectedDate: toDate.selectedDate
                        placeholderText: qsTr("از")+":"
                        width: parent.width / 2 - 10*AppStyle.size1W
                        height:parent.height - 20*AppStyle.size1H
                    }
                }
            }
        }
    }
    Loader{
        active: internalModel.count > 0
        anchors{
            top: calendarRangeTab.bottom
            topMargin: 15*AppStyle.size1H
            right: parent.right
            rightMargin: 20*AppStyle.size1W
            bottom: parent.bottom
            bottomMargin: 15*AppStyle.size1H
            left: parent.left
            leftMargin: 20*AppStyle.size1W
        }
        width: parent.width
        clip: true

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
            delegate: Rectangle {
                id:rootItem
                radius: 15*AppStyle.size1W
                width: control.cellWidth - 20*AppStyle.size1W
                height:  control.cellHeight - 10*AppStyle.size1H
                color: Material.color(AppStyle.primaryInt,Material.Shade50)
                clip: true
                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 10*AppStyle.size1W
                    verticalOffset: 10*AppStyle.size1H
                    radius: 20
                    samples: 41
                    color: AppStyle.shadowColor// Material.color(AppStyle.primaryInt,Material.Shade100)
                }

                MouseArea{
                    id: mouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
                        console.time("Start")
                        UsefulFunc.mainStackPush("qrc:/Things/ThingsDetail.qml",qsTr("جزئیات")+": "+model.title,{"thingLocalId":model.local_id, "listId": listId})
                    }
                }
                Ripple {
                    clipRadius: 15*AppStyle.size1W
                    z:1
                    width: mouseArea.width
                    height: mouseArea.height
                    pressed: mouseArea.pressed
                    anchor: mouseArea
                    active: mouseArea.focus
                    color: AppStyle.rippleColor
                    OpacityMask {
                        source: mouseArea
                        maskSource: Rectangle {
                            x: mouseArea.mouseX
                            y: mouseArea.mouseY
                            width: mouseArea.width
                            height: mouseArea.height
                            radius: 10*AppStyle.size1W
                        }
                    }
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
                        source: "qrc:/todo.svg"
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
                    text: qsTr("توضیحات") + ": <b>" + (model.detail? model.detail : qsTr("توضیحاتی ثبت نشده است")) +"</b>"
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
                    sourceComponent:Flow{
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
                                text: qsTr("اولویت") +":    <b> " + (model.priority_id?UsefulFunc.findInModel(model.priority_id,"Id",priorityModel).value.Text:qsTr("ثبت نشده است")) + "</b>"
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
                                text: qsTr("سطح انرژی") +":<b> " + (model.energy_id?UsefulFunc.findInModel(model.energy_id,"Id",energyModel).value.Text:qsTr("ثبت نشده است")) + "</b>"
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
                                text: qsTr("محل انجام") +":<b> " + (model.context_id?contextModel.count>0?UsefulFunc.findInModel(model.context_id,"id",contextModel).value.context_name:"":qsTr("ثبت نشده است")) + "</b>"
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
                                text: qsTr("تخمین زمانی") +":<b> " + (model.estimate_time?model.estimate_time+ " " + qsTr("دقیقه"):qsTr("ثبت نشده است")) + "</b> "
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
                                    text:qsTr("فرد انجام دهنده") +":<b> " + (model.friend_id?friendModel.count>0?UsefulFunc.findInModel(model.friend_id,"id",friendModel).value.friend_name
                                                                                                                :""
                                                                             :qsTr("ثبت نشده است")) + "</b>"
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
                            active: model.list_id === Memorito.Calendar || model.due_date
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
                                    text:qsTr("زمان مشخص شده") +":<b> "
                                         +( dueDate ?AppStyle.ltr? dueDate.getFullYear()+"/"+(dueDate.getMonth()+1)+"/"+dueDate.getDate()
                                                                 :(dateConverter.toJalali(dueDate.getFullYear(),dueDate.getMonth()+1,dueDate.getDate())).slice(0,3).join("/")
                                                    : qsTr("ثبت نشده است"))
                                         + "</b>"
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
                    text: qsTr("فایل دارد")
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
            UsefulFunc.mainStackPush("qrc:/Things/AddEditThing.qml",text,{listId:listId,categoryId:categoryId})

        }
        icon.width: 30*AppStyle.size1W
        icon.source:"qrc:/plus.svg"
    }
}
