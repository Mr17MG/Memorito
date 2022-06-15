import QtQuick 
import QtQuick.Controls 
import QtQuick.Controls.Material 
import Qt5Compat.GraphicalEffects

import QtQuick.Layouts 1.15

import Memorito.Tools
import Memorito.Things
import Memorito.Logs
import Memorito.Files

import Memorito.Components
import Memorito.Global

Item {
    id:root

    property int thingLocalId: -1
    property var prevPageModel
    property int listId: -1
    property int modelIndex: -1
    property var dataForPop

    function cameInToPage(object)
    {
        if(object)
        {
            listId = object.listId ?? -1;

            if(object.thingLocalId)
                prevPageModel = thingsModel.getThingByLocalId(object.thingLocalId)

            console.timeEnd("Start")

            filesListModel.clear()
            filesListModel.append(filesModel.getAllFilesByThingLocalId(object.thingLocalId))

            logsListModel.clear()
            logsListModel.append(logsModel.getAllLogsByThingLocalId(thingLocalId))
        }
    }

    function cameBackToPage(object)
    {
        if(object)
        {
            if(object.changeType === Memorito.Delete )
            {
                UsefulFunc.mainStackPop(object)
                return
            }

            prevPageModel = thingsModel.getThingByLocalId(object.thingLocalId)

//            if(prevPageModel.list_id !== listId){
//                dataForPop = {"thingId":object.thingId, "changeType":Memorito.Delete}
//            }
//            else
//                dataForPop = object

            filesListModel.clear()
            filesListModel.append(filesModel.getAllFilesByThingLocalId(object.thingLocalId))
        }
    }

    function sendToPreviousPage()
    {
        if( dataForPop )
        {
            return dataForPop
        }
    }

    ThingsController { id: thingsController }
    ThingsModel { id: thingsModel }

    LogsController { id: logsController }
    LogsModel { id: logsModel }

    FilesController { id: filesController }
    FilesModel { id: filesModel }

    MTools{id:myTools}

    Connections {
        target: thingsController

        function onThingUpdated(serverId)
        {
            prevPageModel = thingsModel.getThingByServerId(serverId)
            dataForPop = UsefulFunc.mainStackPop({"thingLocalId":thingLocalId,"chnageType":Memorito.Update})
        }
    }

    Connections {
        target: logsController

        function onNewLogAdded(rowId)
        {
            logsListModel.append(logsModel.getLogByLocalId(rowId))
        }

        function onLogUpdated(serverId)
        {
            var res = UsefulFunc.findInModel(serverId,"server_id",logsListModel)
            if( res.index>=0 )
                logsListModel.set(res.index,logsModel.getLogByServerId(serverId))
        }

        function onLogDeleted(serverId)
        {
            var res = UsefulFunc.findInModel(serverId,"server_id",logsListModel)
            if( res.index>=0 )
                logsListModel.remove(res.index)
        }

    }
    Rectangle {
        anchors{
            top: parent.top
            topMargin: 40*AppStyle.size1H
            right: parent.right
            rightMargin: 30*AppStyle.size1W
            left: parent.left
            leftMargin: 30*AppStyle.size1W
            bottom: parent.bottom
            bottomMargin: 40*AppStyle.size1H
        }

        color: Material.color(AppStyle.primaryInt,Material.Shade50)
        radius: 20*AppStyle.size1W

        Flickable{
            id: mainFlick

            clip:true
            contentHeight: item1.height
            flickableDirection: Flickable.VerticalFlick

            anchors {
                fill: parent
            }

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
                height: parent.height
                orientation: Qt.Vertical
                anchors.right: mainFlick.right
                active: hovered || pressed || parent.flicking
                width: hovered || pressed?18*AppStyle.size1W:8*AppStyle.size1W

                contentItem: Rectangle {
                    visible: parent.active
                    radius: parent.pressed || parent.hovered ?20*AppStyle.size1W:8*AppStyle.size1W
                    color: parent.pressed ?Material.color(AppStyle.primaryInt,Material.Shade900):Material.color(AppStyle.primaryInt,Material.Shade600)
                }
            }

            Item{
                id:item1

                width: parent.width
                height: titleText.height+detailText.height+dateFlow.height+contentFlow.height+filesFlow.height+
                        logItem.height+ buttonFlow.height+200*AppStyle.size1W
                Text {
                    id: titleText

                    height: 80*AppStyle.size1H
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: prevPageModel?.title??"";

                    anchors {
                        top: parent.top
                        topMargin: 20*AppStyle.size1W
                        right: parent.right
                        rightMargin: 20*AppStyle.size1W
                        left: parent.left
                        leftMargin: 20*AppStyle.size1W
                    }

                    font{
                        family: AppStyle.appFont;
                        pixelSize:  35*AppStyle.size1F;
                        bold:true
                    }

                    Rectangle{
                        width: parent.width - 100*AppStyle.size1W
                        height: 2*AppStyle.size1H
                        color: "#0F110F"
                        anchors{
                            bottom: parent.bottom
                            bottomMargin: 10*AppStyle.size1H
                            horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                Column{
                    width: parent.width
                    spacing: detailText.lineHeight -2*AppStyle.size1W

                    anchors {
                        top: titleText.bottom
                        topMargin: 40*AppStyle.size1W
                        right: parent.right
                        rightMargin: 35*AppStyle.size1W
                        left: parent.left
                        leftMargin: 35*AppStyle.size1W
                    }

                    Repeater{
                        model:detailText.lineCount
                        delegate: Row{
                            spacing: 10*AppStyle.size1W
                            width: parent.width
                            Repeater {
                                clip: true
                                model: root.width/3 // or any number of dots you want
                                Rectangle{width: 5*AppStyle.size1W;
                                    height: 2*AppStyle.size1W;
                                    opacity: 0.5;
                                    color: "#A5A5A5"
                                }
                            }
                        }
                    }
                }

                Text {
                    id: detailText

                    lineHeight: 50*AppStyle.size1H
                    lineHeightMode: Text.FixedHeight
                    text: prevPageModel?.detail ?? "";
                    horizontalAlignment: Text.AlignJustify
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                    anchors{
                        top: titleText.bottom
                        topMargin: 20*AppStyle.size1W
                        right: parent.right
                        rightMargin: 35*AppStyle.size1W
                        left: parent.left
                        leftMargin: 35*AppStyle.size1W
                    }

                    font{
                        family: AppStyle.appFont;
                        pixelSize:  25*AppStyle.size1F;
                    }
                }

                Flow {
                    id:dateFlow

                    spacing: 20*AppStyle.size1W
                    layoutDirection: "RightToLeft"

                    anchors{
                        top: detailText.bottom
                        topMargin: 20*AppStyle.size1W
                        right: parent.right
                        rightMargin: 35*AppStyle.size1W
                        left: parent.left
                        leftMargin: 35*AppStyle.size1W
                    }


                    Text {
                        horizontalAlignment: Text.AlignHCenter
                        width: Math.max(parent.width/2-20*AppStyle.size1W , 350*AppStyle.size1W)
                        text: qsTr("ثبت شده در: %1").arg(UsefulFunc.convertDateTimeToLocaleText(prevPageModel?.register_date??""))
                        font {
                            family: AppStyle.appFont;
                            pixelSize:  23*AppStyle.size1F;
                        }
                    }
                    Text {
                        horizontalAlignment: Text.AlignHCenter
                        width: Math.max(parent.width/2-20*AppStyle.size1W , 350*AppStyle.size1W)
                        text: prevPageModel?.modified_date? qsTr("ویرایش شده در: %1").arg(UsefulFunc.convertDateTimeToLocaleText(prevPageModel?.modified_date??""))
                                                          :""
                        font {
                            family: AppStyle.appFont;
                            pixelSize:  23*AppStyle.size1F;
                        }
                    }
                }

                Flow{
                    id: contentFlow

                    width: parent.width
                    layoutDirection: "RightToLeft"

                    anchors{
                        top: dateFlow.bottom
                        topMargin: 20*AppStyle.size1W
                        right: parent.right
                        rightMargin: 30*AppStyle.size1W
                        left: parent.left
                        leftMargin: 30*AppStyle.size1W
                    }

                    Item{
                        width: Math.min(parent.width/2 , 350*AppStyle.size1W)
                        height: 70*AppStyle.size1H

                        Image {
                            id: priorityImg

                            source: prevPageModel?.priority_id ? UsefulFunc.findInModel(prevPageModel.priority_id,"Id",Constants.priorityListModel).value.iconSource
                                                               : "qrc:/priorities/none.svg"
                                                                 ?? "";
                            width: 40*AppStyle.size1W
                            height: width
                            sourceSize:Qt.size(width*2,height*2)

                            anchors{
                                verticalCenter: parent.verticalCenter
                                right: parent.right
                            }
                        }

                        Text {
                            id: priorityText

                            text: qsTr("اولویت") +": " + (prevPageModel?.priority_id? UsefulFunc.findInModel(prevPageModel.priority_id,"Id",Constants.priorityListModel).value.Text
                                                                                    : qsTr("ثبت نشده"))
                            elide: AppStyle.ltr ? Text.ElideLeft
                                                : Text.ElideRight

                            anchors{
                                verticalCenter: priorityImg.verticalCenter
                                right: priorityImg.left
                                rightMargin: 10*AppStyle.size1W
                                left: parent.left
                            }

                            font {
                                family: AppStyle.appFont;
                                pixelSize:  23*AppStyle.size1F;
                            }
                        }
                    }

                    Item{
                        height: 70*AppStyle.size1H
                        width: Math.min(parent.width/2 , 350*AppStyle.size1W)

                        Image {
                            id: energyImg

                            source: prevPageModel?.energy_id? UsefulFunc.findInModel(prevPageModel.energy_id,"Id",Constants.energyListModel).value.iconSource
                                                            : "qrc:/energies/none.svg"
                                                              ?? "";
                            width: 40*AppStyle.size1W
                            height: width
                            sourceSize:Qt.size(width*2,height*2)

                            anchors{
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                            }
                        }

                        Text {
                            id: energyText

                            text: qsTr("سطح انرژی") +": " + (prevPageModel?.energy_id? UsefulFunc.findInModel(prevPageModel.energy_id,"Id",Constants.energyListModel).value.Text
                                                                                     :qsTr("ثبت نشده"))
                            elide: AppStyle.ltr ? Text.ElideLeft
                                                : Text.ElideRight

                            anchors{
                                verticalCenter: energyImg.verticalCenter
                                right: energyImg.left
                                rightMargin: 10*AppStyle.size1W
                                left: parent.left
                            }

                            font {
                                family: AppStyle.appFont;
                                pixelSize:  23*AppStyle.size1F
                            }
                        }
                    }

                    Item{
                        height: 70*AppStyle.size1H
                        width: Math.min(parent.width/2 , 350*AppStyle.size1W)

                        Image {
                            id: contextImg

                            source: prevPageModel?.context_id ? "qrc:/map.svg"
                                                              : "qrc:/map-unknown.svg"
                            width: 40*AppStyle.size1W
                            height: width
                            sourceSize:Qt.size(width*2,height*2)

                            anchors{
                                verticalCenter: parent.verticalCenter
                                right: parent.right
                            }
                        }
                        Text {
                            id: contextText


                            text: qsTr("محل انجام") +": " + (prevPageModel?.context_id_local? UsefulFunc.findInModel(prevPageModel.context_id_local,"local_id",Constants.contextsListModel).value?.context_name??qsTr("ثبت نشده")
                                                                                      : qsTr("ثبت نشده"))
                            elide: AppStyle.ltr ? Text.ElideLeft
                                                : Text.ElideRight
                            anchors {
                                verticalCenter: contextImg.verticalCenter
                                right: contextImg.left
                                rightMargin: 10*AppStyle.size1W
                                left: parent.left
                            }

                            font{
                                family: AppStyle.appFont;
                                pixelSize:  23*AppStyle.size1F
                            }
                        }
                    }

                    Item{
                        height: 70*AppStyle.size1H
                        width: Math.min(parent.width/2 , 350*AppStyle.size1W)

                        Image {
                            id: estimateImg

                            source: prevPageModel?.estimated_time ? "qrc:/clock-colorful.svg"
                                                                 : "qrc:/clock-unknown.svg"
                            height: width
                            width: 40*AppStyle.size1W
                            sourceSize:Qt.size(width*2,height*2)

                            anchors{
                                verticalCenter: parent.verticalCenter
                                right: parent.right
                            }
                        }

                        Text {
                            id: estimateText

                            text: !prevPageModel?"":qsTr("تخمین زمانی") +": " + (prevPageModel.estimated_time?prevPageModel.estimated_time+ " " + qsTr("دقیقه"):qsTr("ثبت نشده"))
                            elide: AppStyle.ltr ? Text.ElideLeft
                                                : Text.ElideRight

                            anchors {
                                verticalCenter: estimateImg.verticalCenter
                                right: estimateImg.left
                                rightMargin: 10*AppStyle.size1W
                                left: parent.left
                            }

                            font {
                                family: AppStyle.appFont;
                                pixelSize:  23*AppStyle.size1F
                            }
                        }
                    }

                    Loader{

                        active: true
                        height: 70*AppStyle.size1H
                        width: Math.min(parent.width/2 , 350*AppStyle.size1W)

                        sourceComponent: Item{
                            anchors.fill: parent

                            Image {
                                id: listImg

                                height: width
                                width: 40*AppStyle.size1W
                                source:"qrc:/list-colorful.svg"
                                sourceSize:Qt.size(width*2,height*2)

                                anchors{
                                    verticalCenter: parent.verticalCenter
                                    right: parent.right
                                }
                            }

                            Text {
                                property var listName:  [
                                    {id:Memorito.Collect    ,name:qsTr("جمع آوری")},
                                    {id:Memorito.Process    ,name:qsTr("پردازش نشده‌‌ها")},
                                    {id:Memorito.NextAction ,name:qsTr("عملیات بعدی")},
                                    {id:Memorito.Refrence   ,name:qsTr("مرجع")},
                                    {id:Memorito.Coop       ,name:qsTr("لیست انتظار")},
                                    {id:Memorito.Calendar   ,name:qsTr("تقویم")},
                                    {id:Memorito.Trash      ,name:qsTr("سطل آشغال")},
                                    {id:Memorito.Done       ,name:qsTr("انجام شده‌ها")},
                                    {id:Memorito.Someday    ,name:qsTr("شاید یک‌روزی")},
                                    {id:Memorito.Project    ,name:qsTr("پروژه‌ها")}
                                ]

                                text: qsTr("در لیست")+": "+ listName.find(list => list.id === (prevPageModel?.list_id??listId)).name
                                elide: AppStyle.ltr ? Text.ElideLeft
                                                    : Text.ElideRight

                                anchors{
                                    verticalCenter: listImg.verticalCenter
                                    right: listImg.left
                                    rightMargin: 10*AppStyle.size1W
                                    left: parent.left
                                }

                                font{
                                    family: AppStyle.appFont;
                                    pixelSize:  23*AppStyle.size1F
                                }
                            }
                        }
                    }

                    Loader{
                        visible: active
                        height: 70*AppStyle.size1H
                        active: prevPageModel?.parent_id?true:false??false
                        width: Math.min(parent.width/2 , 350*AppStyle.size1W)

                        sourceComponent: Item{
                            anchors.fill: parent

                            Image {
                                id: categorymg

                                source: prevPageModel? (prevPageModel.list_id === Memorito.Project ? "qrc:/project-colorful.svg"
                                                                                                   : "qrc:/category-colorful.svg")
                                                     : ""
                                height: width
                                width: 40*AppStyle.size1W
                                sourceSize:Qt.size(width*2,height*2)

                                anchors{
                                    verticalCenter: parent.verticalCenter
                                    right: parent.right
                                }
                            }

                            Text {
                                text: prevPageModel ? (prevPageModel.list_id === Memorito.Project ? qsTr("در پروژه")
                                                                                                  :qsTr("در دسته بندی"))+": "+ CategoriesApi.getCategoryById(prevPageModel.category_id).category_name
                                                    : ""

                                anchors{
                                    verticalCenter: categorymg.verticalCenter
                                    right: categorymg.left
                                    rightMargin: 10*AppStyle.size1W
                                    left: parent.left
                                }
                                font{family: AppStyle.appFont;pixelSize:  23*AppStyle.size1F;bold:false}
                                elide: AppStyle.ltr?Text.ElideLeft:Text.ElideRight
                            }
                        }
                    }

                    Loader{
                        visible: active
                        height: 70*AppStyle.size1H
                        width: Math.min(parent.width/2 , 350*AppStyle.size1W)
                        active: listId === Memorito.Coop || (prevPageModel?.friend_id?true:false??false)

                        sourceComponent: Item{
                            anchors.fill: parent
                            Image {
                                id: friendImg

                                source:"qrc:/friends-colorful.svg"
                                height: width
                                width: 40*AppStyle.size1W
                                sourceSize:Qt.size(width*2,height*2)

                                anchors{
                                    verticalCenter: parent.verticalCenter
                                    right: parent.right
                                }
                            }

                            Text {
                                text: qsTr("فرد انجام دهنده") +": " + (prevPageModel?.friend_id? UsefulFunc.findInModel(prevPageModel.friend_id,"id",friendModel).value.friend_name
                                                                                               : qsTr("ثبت نشده"))
                                elide: AppStyle.ltr ? Text.ElideLeft
                                                    : Text.ElideRight

                                anchors{
                                    verticalCenter: friendImg.verticalCenter
                                    right: friendImg.left
                                    rightMargin: 10*AppStyle.size1W
                                    left: parent.left
                                }

                                font {
                                    family: AppStyle.appFont;
                                    pixelSize:  23*AppStyle.size1F
                                }
                            }
                        }
                    }

                    Loader{
                        visible: active
                        width: parent.width
                        height: 70*AppStyle.size1H
                        active: listId === Memorito.Calendar || (prevPageModel?.due_date?true :false ?? false)

                        sourceComponent: Item{
                            anchors.fill: parent
                            Image {
                                id: dateImg

                                source:"qrc:/calendar-colorful.svg"
                                height: width
                                width: 40*AppStyle.size1W
                                sourceSize:Qt.size(width*2,height*2)

                                anchors{
                                    verticalCenter: parent.verticalCenter
                                    right: parent.right
                                }
                            }

                            Text {
                                text: qsTr("زمان مشخص شده: %1").arg(UsefulFunc.convertDateTimeToLocaleText(prevPageModel?.due_date??""))
                                elide: AppStyle.ltr ? Text.ElideLeft
                                                    : Text.ElideRight
                                anchors{
                                    verticalCenter: dateImg.verticalCenter
                                    right: dateImg.left
                                    rightMargin: 10*AppStyle.size1W
                                    left: parent.left
                                }

                                font {
                                    family: AppStyle.appFont;pixelSize:  23*AppStyle.size1F
                                }
                            }
                        }
                    }
                }

                Flow{
                    id: buttonFlow

                    property var doneableArray: [Memorito.NextAction,Memorito.Someday,Memorito.Coop,Memorito.Calendar,Memorito.Project]

                    spacing:  15*AppStyle.size1W
                    width: Math.min( parent.width-30*AppStyle.size1W ,doneableArray.indexOf(listId) !== -1 ? 630*AppStyle.size1W
                                                                                                           : 415*AppStyle.size1W)

                    anchors{
                        top: contentFlow.bottom
                        topMargin: 40*AppStyle.size1H
                        horizontalCenter: parent.horizontalCenter
                    }

                    AppButton{
                        id:deleteBtn

                        text: qsTr("حذف")
                        width: 200*AppStyle.size1W
                        radius: 20*AppStyle.size1W
                        spacing: 10*AppStyle.size1W
                        Material.foreground: "White"
                        Material.background: Material.color(Material.Red,Material.Shade900)

                        icon{
                            source: "qrc:/close.svg"
                            color:  "White"
                            width: 30*AppStyle.size1W
                            height: 30*AppStyle.size1W
                        }

                        onClicked: {
                            deleteLoader.active = true
                            deleteLoader.item.open()
                        }

                    }
                    AppButton{
                        id:openBtn

                        text: qsTr("ویرایش کردن")
                        width: 200*AppStyle.size1W
                        radius: 20*AppStyle.size1W
                        spacing: 10*AppStyle.size1W
                        Material.foreground: "White"
                        Material.background: Material.color(Material.LightBlue,Material.Shade900)

                        icon{
                            source: "qrc:/edit.svg"
                            color:  "White"
                            width: 30*AppStyle.size1W
                            height: 30*AppStyle.size1W
                        }
                        onClicked: {
                            UsefulFunc.mainStackPush("qrc:/Things/AddEditThing.qml",qsTr("پردازش"),{"thingLocalId":prevPageModel.local_id,listId:listId})
                        }
                    }

                    AppButton{
                        id: doneBtn

                        text: qsTr("انجام شد")
                        width: 200*AppStyle.size1W
                        radius: 20*AppStyle.size1W
                        spacing: 10*AppStyle.size1W
                        Material.foreground: "White"
                        visible: parent.doneableArray.indexOf(listId) !== -1 && ((prevPageModel?.status ?? 0) !==3)
                        Material.background: Material.color(Material.Green,Material.Shade900)

                        icon{
                            source: "qrc:/check.svg"
                            color:  "White"
                            width: 30*AppStyle.size1W
                            height: 30*AppStyle.size1W
                        }

                        onClicked: {
                            let json = JSON.stringify(
                                    {
                                        title         : prevPageModel?.title ?? ""           ,
                                        detail        : prevPageModel?.detail ?? ""          ,
                                        type_id       : prevPageModel?.type_id ?? 1          ,
                                        status        : 3                                    ,
                                        display_type  : prevPageModel?.display_type ?? 1     ,
                                        energy_id     : prevPageModel?.energy_id       ? prevPageModel.energy_id      :null ?? null ,
                                        context_id    : prevPageModel?.context_id      ? prevPageModel.context_id     :null ?? null ,
                                        priority_id   : prevPageModel?.priority_id     ? prevPageModel.priority_id    :null ?? null ,
                                        estimated_time : prevPageModel?.estimated_time ? prevPageModel.estimated_time :null ?? null ,
                                    }, null, 1);

                            if (prevPageModel)
                                thingsController.updateThing(prevPageModel.server_id,json)
                        }
                    }
                }

                Flow{
                    id: filesFlow

                    width: parent.width
                    layoutDirection: Qt.RightToLeft
                    property real cellWidth: width / (parseInt(width / parseInt(500*AppStyle.size1W))===0?1:(parseInt(width / parseInt(500*AppStyle.size1W))))

                    anchors{
                        top: buttonFlow.bottom
                        topMargin: 40*AppStyle.size1H
                        horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: qsTr("فایل‌ها")
                        width: parent.width
                        height: 80*AppStyle.size1H
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        font{
                            family: AppStyle.appFont;
                            pixelSize:  35*AppStyle.size1F;
                            bold:true
                        }

                        Rectangle{
                            width: parent.width - 100*AppStyle.size1W
                            height:2*AppStyle.size1H
                            color: "#0F110F"
                            anchors{
                                bottom: parent.bottom
                                bottomMargin: 10*AppStyle.size1H
                                horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    Repeater{
                        model: ListModel{id: filesListModel}

                        delegate: Item {
                            width: filesFlow.cellWidth
                            height: 175*AppStyle.size1W

                            AppButton {
                                radius: 15*AppStyle.size1W
                                width: parent.width - 20*AppStyle.size1W
                                height: parent.height - 20*AppStyle.size1H
                                Material.background: Material.color(AppStyle.primaryInt,Material.Shade400)

                                anchors {
                                    centerIn: parent
                                }

                                onClicked: {
                                    if(!model.file_source)
                                        model.file_source = "file://"+myTools.saveBase64asFile(model.file_name,model.file_extension,model.file)
                                    Qt.openUrlExternally(model.file_source)
                                }

                                property var extensions: ["aac","ace","ai","aut","avi","bin","bmp","cad","cdr","css","db","dmg","doc","docx","dwf","dwg","eps",
                                    "exe","flac","gif","hlp","htm","html","ini","iso","java","jpg","js","mkv","mov","mp3","mp4","mpg","pdf","php","png","ppt",
                                    "ps","psd","rar","rss","rtf","svg","swf","sys","tiff","txt","xls","xlsx","zip",
                                ]

                                Rectangle{
                                    id: icon

                                    width: 125*AppStyle.size1W
                                    height: width
                                    radius: 10*AppStyle.size1W
                                    color: "transparent"

                                    border{
                                        width: 2*AppStyle.size1W
                                        color:Material.color(AppStyle.primaryInt,Material.ShadeA700)
                                    }

                                    anchors{
                                        left: parent.left
                                        leftMargin: 10*AppStyle.size1W
                                        verticalCenter: parent.verticalCenter
                                    }

                                    Image {
                                        height: width
                                        asynchronous: true
                                        sourceSize: Qt.size(width,height)
                                        fillMode:Image.PreserveAspectCrop
                                        width: parent.width -15*AppStyle.size1W

                                        source: model.file_extension.toLowerCase().match(/svg|png|jpg|gif|jpeg/g)?
                                                    "file://"+myTools.saveBase64asFile(model.file_name,model.file_extension,model.file):
                                                    icon.parent.extensions.indexOf(model.file_extension.toLowerCase())!== -1?
                                                        "qrc:/pack/"+(model.file_extension.toLowerCase())+".svg"
                                                      :"qrc:/pack/unknown.svg"


                                        anchors{
                                            centerIn: parent
                                        }

                                        layer.enabled: true
                                        layer.effect: OpacityMask {
                                            maskSource: Rectangle {
                                                x: icon.x
                                                y: icon.y
                                                width: icon.width-10*AppStyle.size1W
                                                height: icon.height-10*AppStyle.size1W
                                                radius: icon.radius
                                            }
                                        }
                                    }
                                }

                                Text{
                                    id: thingText

                                    color: AppStyle.textOnPrimaryColor
                                    text: model.file_name + "."+ model.file_extension
                                    width: parent.width
                                    verticalAlignment: Text.AlignVCenter
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    maximumLineCount: 2
                                    elide: Qt.ElideRight

                                    font{
                                        family: AppStyle.appFont;
                                        pixelSize:  25*AppStyle.size1F;
                                        bold:true
                                    }

                                    anchors{
                                        left:  icon.right
                                        leftMargin: 10*AppStyle.size1W
                                        right: parent.right
                                        rightMargin: 10*AppStyle.size1W
                                        verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }
                }

                Flow {
                    id: logItem

                    width: parent.width
                    spacing: 15*AppStyle.size1H
                    layoutDirection: Flow.TopToBottom

                    anchors{
                        top: filesFlow.bottom
                        topMargin: 20*AppStyle.size1H
                        horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        id:logTitle

                        text: qsTr("روند کار")
                        width: parent.width
                        height: 80*AppStyle.size1H
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        font{
                            family: AppStyle.appFont;
                            pixelSize:  35*AppStyle.size1F;
                            bold:true
                        }

                        Rectangle{
                            width: parent.width - 100*AppStyle.size1W
                            height: 2*AppStyle.size1H
                            color: "#0F110F"
                            anchors{
                                bottom: parent.bottom
                                bottomMargin: 10*AppStyle.size1H
                                horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    Repeater{
                        model: ListModel { id: logsListModel }
                        delegate:
                            Item{

                            id: rect1
                            width: parent.width
                            height: 120*AppStyle.size1H + logText.height

                            RectangularGlow {
                                id: effect

                                spread: 0.2
                                glowRadius: 10*AppStyle.size1W
                                cornerRadius: backgroundId.radius + glowRadius
                                color: Material.color(AppStyle.primaryInt,Material.Shade100)

                                anchors {
                                    fill: backgroundId
                                }
                            }

                            Rectangle{
                                id: backgroundId

                                radius: 20*AppStyle.size1W
                                color: Material.color(AppStyle.primaryInt,Material.Shade50)

                                border{
                                    color: Material.color(AppStyle.primaryInt,Material.Shade100)
                                    width: 2*AppStyle.size1W
                                }

                                anchors{
                                    fill: parent
                                    leftMargin: 35*AppStyle.size1W
                                    rightMargin: 35*AppStyle.size1W
                                }
                            }

                            Text{
                                id:logText

                                color: "black"
                                text: model.log_text
                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                                anchors{
                                    right: parent.right
                                    rightMargin: 60*AppStyle.size1W
                                    left: parent.left
                                    leftMargin: 60*AppStyle.size1W
                                    top: menuImg.bottom
                                    topMargin: 15*AppStyle.size1H
                                }

                                font{
                                    family: AppStyle.appFont
                                    pixelSize:  25*AppStyle.size1F
                                }
                            }

                            Text{
                                id:registerDateText

                                text: qsTr("ثبت شده در: %1").arg(UsefulFunc.convertDateTimeToLocaleText(prevPageModel?.register_date??""))

                                color: "black"
                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                                anchors{
                                    right: parent.right
                                    rightMargin: 50*AppStyle.size1W
                                    top: parent.top
                                    topMargin: 15*AppStyle.size1H
                                }

                                font{
                                    family: AppStyle.appFont
                                    pixelSize:  18*AppStyle.size1F
                                }
                            }

                            Text {
                                id: modifiedDateText
                                visible: prevPageModel?.modified_date?true:false ?? false;
                                text: prevPageModel?.modified_date? qsTr("ویرایش شده در: %1").arg(UsefulFunc.convertDateTimeToLocaleText(prevPageModel?.modified_date??""))
                                                                  :""
                                color: "black"
                                verticalAlignment: Text.AlignVCenter
                                anchors{
                                    left: parent.left
                                    leftMargin: 50*AppStyle.size1W
                                    bottom: parent.bottom
                                    bottomMargin: 15*AppStyle.size1H
                                }
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font{
                                    family: AppStyle.appFont
                                    pixelSize:  18*AppStyle.size1F
                                }
                            }

                            Image {
                                id: menuImg

                                height: width
                                source: "qrc:/dots.svg"
                                width: 30*AppStyle.size1W
                                sourceSize:Qt.size(width*2,height*2)

                                anchors{
                                    left: parent.left
                                    leftMargin: 50*AppStyle.size1W
                                    top: parent.top
                                    topMargin: 15*AppStyle.size1W
                                }
                                MouseArea{
                                    anchors{
                                        fill: parent
                                        topMargin: -10*AppStyle.size1H
                                        bottomMargin: -10*AppStyle.size1H
                                        rightMargin: -10*AppStyle.size1W
                                        leftMargin: -10*AppStyle.size1W
                                    }

                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        menuLoader.active = true
                                        menuLoader.item.open()
                                    }
                                }
                            }

                            Loader{
                                id: menuLoader

                                active: false
                                x: menuImg.x + (menuImg.width - 15*AppStyle.size1W)
                                y: menuImg.y + (menuImg.height/2)

                                sourceComponent: AppMenu{
                                    id:menu
                                    AppMenuItem{
                                        text: qsTr("ویرایش")
                                        onTriggered: {
                                            editLogLoader.active = true
                                            editLogLoader.item.modelIndex = index
                                            editLogLoader.item.logId = model.server_id
                                            editLogLoader.item.logText = model.log_text
                                            editLogLoader.item.open()
                                        }
                                    }
                                    AppMenuItem{
                                        text: qsTr("حذف")
                                        onTriggered: {
                                            deleteLogLoader.active = true
                                            deleteLogLoader.item.modelIndex = index
                                            deleteLogLoader.item.logId = model.server_id
                                            deleteLogLoader.item.logText = model.log_text
                                            deleteLogLoader.item.open()
                                        }
                                    }
                                }
                            }
                        }


                    }

                    Item{
                        height: 120*AppStyle.size1H
                        width: parent.width

                        AppTextInput {
                            id:commentInput

                            color: "#0F110F"
                            maximumLength: 300
                            fieldInPrimary: true
                            height: parent.height
                            controlPlaceHolder.color: "black"
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            placeholderText: qsTr("روند کار یا نظرات‌ِتو بنویس")

                            bgUnderItem: Material.color(AppStyle.primaryInt,Material.Shade50)
                            rightPadding: AppStyle.ltr?25*AppStyle.size1W+submitBtn.width:10*AppStyle.size1W
                            leftPadding: AppStyle.ltr?10*AppStyle.size1W:25*AppStyle.size1W + submitBtn.width

                            Keys.onEnterPressed: submitBtn.clicked()
                            Keys.onReturnPressed:  submitBtn.clicked()

                            anchors{
                                right: parent.right
                                rightMargin: 35*AppStyle.size1W
                                left: parent.left
                                leftMargin: 35*AppStyle.size1W
                            }

                            AppButton {
                                id: submitBtn

                                radius: 20*AppStyle.size1W

                                anchors{
                                    left: parent.left
                                    leftMargin: 20*AppStyle.size1W
                                    verticalCenter: parent.verticalCenter
                                }

                                icon{
                                    source: "qrc:/check.svg"
                                    color: AppStyle.textOnPrimaryColor
                                    width: 25*AppStyle.size1W
                                }

                                onClicked: {
                                    if(commentInput.text.trim() === "" )
                                    {
                                        UsefulFunc.showLog(qsTr("نظرتو وارد نکردی."),true)
                                    }
                                    else{
                                        let json = JSON.stringify(
                                                {
                                                    "log_text" : commentInput.text.trim(),
                                                    "thing_id": prevPageModel?.server_id
                                                }, null, 1);
                                        logsController.addNewLog(json)
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
        id: deleteLoader

        active: false

        sourceComponent: AppConfirmDialog{
            parent: UsefulFunc.mainPage

            dialogTitle: qsTr("حذف")
            dialogText: qsTr("میخوای که") + " '" + prevPageModel.title  + "' " + (prevPageModel.list_id === Memorito.Trash?qsTr("برای همیشه حذف بشه؟"):qsTr("بره تو سطل آشغال؟"))

            onClosed: {
                deleteLoader.active = false
            }
            accepted: function() {


                if (prevPageModel.list_id === Memorito.Trash)
                {
                    logsController.deleteThing(prevPageModel.server_id)
                }
                else
                {

                    let json = JSON.stringify(
                            {
                                title         : prevPageModel?.title ?? ""  ,
                                detail        : prevPageModel?.detail ?? "" ,
                                type_id       : prevPageModel?.type_id ?? 1 ,
                                status        : prevPageModel?.status ?? 1 ,
                                display_type  : 3     ,
                                energy_id      : prevPageModel?.energy_id      ? prevPageModel.energy_id      :null ?? null ,
                                context_id     : prevPageModel?.context_id     ? prevPageModel.context_id     :null ?? null ,
                                priority_id    : prevPageModel?.priority_id    ? prevPageModel.priority_id    :null ?? null ,
                                estimated_time : prevPageModel?.estimated_time ? prevPageModel.estimated_time :null ?? null ,
                            }, null, 1);

                    if (prevPageModel)
                        thingsController.updateThing(prevPageModel.server_id,json)
                    thingsController.updateThing(prevPageModel.server_id,json)
                }
            }
        }
    }


    Loader{
        id: editLogLoader
        active: false

        sourceComponent: AppDialog {
            property int logId: -1
            property string logText: ""
            property int modelIndex: -1

            parent: UsefulFunc.mainPage
            height: 480*AppStyle.size1H
            width: 600*AppStyle.size1W
            hasButton: true
            hasCloseIcon: true
            hasTitle: true
            buttonTitle: qsTr("بروزرسانی")

            dialogButton.onClicked: {
                if( editLogArea.text.trim() )
                {

                    let json = JSON.stringify(
                            {
                                "log_text" : editLogArea.text.trim(),
                                "thing_id": prevPageModel?.server_id
                            }, null, 1);
                    logsController.updateLog(logId,json)
                    close()
                }
                else
                    UsefulFunc.showLog(qsTr("نظرتو وارد نکردی."),true)

            }
            onClosed: {
                editLogLoader.active = false
            }

            AppFlickTextArea{
                id:editLogArea

                text: logText
                areaInDialog: true
                height: 250*AppStyle.size1H
                placeholderText: qsTr("روند کار یا نظرات‌ِتو بنویس")

                anchors{
                    right: parent.right
                    rightMargin: 35*AppStyle.size1W
                    left: parent.left
                    leftMargin: 35*AppStyle.size1W
                    top: parent.top
                    topMargin: 40*AppStyle.size1H
                }
            }
        }
    }

    Loader{
        id: deleteLogLoader

        active: false
        sourceComponent: AppConfirmDialog{
            property int logId: -1
            property string logText: ""
            property int modelIndex: -1

            parent: UsefulFunc.mainPage
            dialogTitle: qsTr("حذف")
            dialogText: qsTr("میخوای که") + " '" + logText  + "' " +qsTr("برای همیشه حذف بشه؟")

            onClosed: {
                deleteLogLoader.active = false
            }
            accepted: function() {
                logsController.deleteLog(logId)
            }
        }
    }
}
