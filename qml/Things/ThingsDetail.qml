import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtGraphicalEffects 1.14
import QDateConvertor 1.0
import MTools 1.0
import Components 1.0
import Global 1.0

Item {
    id:root

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
                prevPageModel = ThingsApi.getThingByLocalId(object.thingLocalId)
            console.timeEnd("Start")
            if(prevPageModel.has_files)
                FilesApi.getFiles(filesModel,prevPageModel.id)
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

            if(object.thingId)
            {
                prevPageModel = ThingsApi.getThingById(object.thingId)[0]
            }
            else {
                prevPageModel = ThingsApi.getThingById(object.thingLocalId)[0]
            }
            if(prevPageModel.list_id !== listId){
                dataForPop = {"thingId":object.thingId, "changeType":Memorito.Delete}
                listId = prevPageModel.list_id
            }
            else
                dataForPop = object

            if(prevPageModel.has_files)
            {
                filesModel.clear()
                FilesApi.getFiles(filesModel,prevPageModel.id)
            }
        }
    }

    function sendToPreviousPage()
    {
        if( dataForPop )
        {
            return dataForPop
        }
    }

    QDateConvertor{id:dateConverter}
    MTools{id:myTools}

    Rectangle{
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
        clip: true
        color: Material.color(AppStyle.primaryInt,Material.Shade50)
        radius: 20*AppStyle.size1W
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
                active: hovered || pressed || parent.flicking
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
            Item{
                id:item1
                width: parent.width
                height: titleText.height+detailText.height+dateFlow.height+conentFlow.height+filesFlow.height+buttonFlow.height+200*AppStyle.size1W
                Text {
                    id: titleText
                    anchors{
                        top: parent.top
                        topMargin: 20*AppStyle.size1W
                        right: parent.right
                        rightMargin: 20*AppStyle.size1W
                        left: parent.left
                        leftMargin: 20*AppStyle.size1W
                    }
                    text: !prevPageModel?"":prevPageModel.title??""
                                                                  font{family: AppStyle.appFont;pixelSize:  35*AppStyle.size1F;bold:true}
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }
                Column{
                    width: parent.width
                    spacing: detailText.lineHeight -2*AppStyle.size1W
                    anchors{
                        top: titleText.bottom
                        topMargin: 40*AppStyle.size1W
                        right: parent.right
                        rightMargin: 30*AppStyle.size1W
                        left: parent.left
                        leftMargin: 30*AppStyle.size1W
                    }
                    clip:true
                    Repeater{
                        model:detailText.lineCount
                        delegate: Row{
                            spacing: 10*AppStyle.size1W
                            width: parent.width
                            Repeater {
                                clip: true
                                model: root.width/3 // or any number of dots you want
                                Rectangle {width: 5*AppStyle.size1W; height: 2*AppStyle.size1W; color: "#A5A5A5"}
                            }
                        }
                    }
                }
                Text {
                    id: detailText
                    anchors{
                        top: titleText.bottom
                        topMargin: 20*AppStyle.size1W
                        right: parent.right
                        rightMargin: 30*AppStyle.size1W
                        left: parent.left
                        leftMargin: 30*AppStyle.size1W
                    }
                    text: !prevPageModel?"":prevPageModel.detail ?? ""
                                                                    font{family: AppStyle.appFont;pixelSize:  25*AppStyle.size1F;}
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignJustify
                    lineHeightMode: Text.FixedHeight
                    lineHeight: 50*AppStyle.size1H
                }
                Flow{
                    id:dateFlow
                    anchors{
                        top: detailText.bottom
                        topMargin: 20*AppStyle.size1W
                        right: parent.right
                        rightMargin: 30*AppStyle.size1W
                        left: parent.left
                        leftMargin: 30*AppStyle.size1W
                    }
                    layoutDirection: "RightToLeft"
                    spacing: 20*AppStyle.size1W
                    Text {
                        width: parent.width/2 > 350*AppStyle.size1W?parent.width/2-20*AppStyle.size1W:350*AppStyle.size1W
                        property date registerDate: !prevPageModel?"":prevPageModel.register_date?new Date(prevPageModel.register_date):""
                        text: !prevPageModel?"":prevPageModel.register_date?qsTr("ثبت شده در")+": <b> "
                                                                             +
                                                                             registerDate.getHours()+":"+registerDate.getMinutes()+":"+registerDate.getSeconds()
                                                                             +"  "+
                                                                             String(dateConverter.toJalali(registerDate.getFullYear(),registerDate.getMonth(),registerDate.getDate())).replace(/,/ig,"/").split("/").slice(0,3)
                                                                             +"</b>"
                                                                           :""
                        font{family: AppStyle.appFont;pixelSize:  23*AppStyle.size1F;bold:false}
                    }
                    Text {
                        width: parent.width/2 > 350*AppStyle.size1W?parent.width/2:350*AppStyle.size1W
                        property date modifiedDate: !prevPageModel?"":prevPageModel.modified_date?new Date(prevPageModel.modified_date):""
                        text:!prevPageModel?"":prevPageModel.modified_date?qsTr("ویرایش شده در")+": <b> "
                                                                            +
                                                                            modifiedDate.getHours()+":"+modifiedDate.getMinutes()+":"+modifiedDate.getSeconds()
                                                                            +"  "+
                                                                            String(dateConverter.toJalali(modifiedDate.getFullYear(),modifiedDate.getMonth(),modifiedDate.getDate())).replace(/,/ig,"/").split("/").slice(0,3)
                                                                            +"</b>"
                                                                          :""
                        font{family: AppStyle.appFont;pixelSize:  23*AppStyle.size1F;bold:false}
                    }
                }
                Flow{
                    id: conentFlow
                    anchors{
                        top: dateFlow.bottom
                        topMargin: 20*AppStyle.size1W
                        right: parent.right
                        rightMargin: 30*AppStyle.size1W
                        left: parent.left
                        leftMargin: 30*AppStyle.size1W
                    }
                    width: parent.width
                    layoutDirection: "RightToLeft"
                    Item{
                        width: parent.width/2 > 350*AppStyle.size1W?parent.width/2:350*AppStyle.size1W
                        height: 70*AppStyle.size1H
                        Image {
                            id: priorityImg
                            source: !prevPageModel?"":prevPageModel.priority_id?UsefulFunc.findInModel(prevPageModel.priority_id,"Id",priorityModel).value.iconSource:"qrc:/priorities/none.svg"
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
                            text: !prevPageModel?"":qsTr("اولویت") +":    <b> " + (prevPageModel.priority_id?UsefulFunc.findInModel(prevPageModel.priority_id,"Id",priorityModel).value.Text:qsTr("ثبت نشده است")) + "</b>"
                            elide: AppStyle.ltr?Text.ElideLeft:Text.ElideRight
                            font{family: AppStyle.appFont;pixelSize:  23*AppStyle.size1F;bold:false}
                        }
                    }
                    Item{
                        width: parent.width/2 > 350*AppStyle.size1W?parent.width/2:350*AppStyle.size1W
                        height: 70*AppStyle.size1H
                        Image {
                            id: energyImg
                            source: !prevPageModel?"":prevPageModel.energy_id?UsefulFunc.findInModel(prevPageModel.energy_id,"Id",energyModel).value.iconSource:"qrc:/energies/none.svg"
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
                            text: !prevPageModel?"":qsTr("سطح انرژی") +":<b> " + (prevPageModel.energy_id?UsefulFunc.findInModel(prevPageModel.energy_id,"Id",energyModel).value.Text:qsTr("ثبت نشده است")) + "</b>"
                            elide: AppStyle.ltr?Text.ElideLeft:Text.ElideRight
                            font{family: AppStyle.appFont;pixelSize:  23*AppStyle.size1F;bold:false}
                        }
                    }
                    Item{
                        width: parent.width/2 > 350*AppStyle.size1W?parent.width/2:350*AppStyle.size1W
                        height: 70*AppStyle.size1H
                        Image {
                            id: contextImg
                            source: !prevPageModel?"":prevPageModel.context_id?"qrc:/map.svg":"qrc:/map-unknown.svg"
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
                            text: !prevPageModel?"":qsTr("محل انجام") +":<b> " + (prevPageModel.context_id?contextModel.count>0?UsefulFunc.findInModel(prevPageModel.context_id,"id",contextModel).value.context_name:"":qsTr("ثبت نشده است")) + "</b>"
                            font{family: AppStyle.appFont;pixelSize:  23*AppStyle.size1F;bold:false}
                            elide: AppStyle.ltr?Text.ElideLeft:Text.ElideRight
                        }
                    }
                    Item{
                        width: parent.width/2 > 350*AppStyle.size1W?parent.width/2:350*AppStyle.size1W
                        height: 70*AppStyle.size1H
                        Image {
                            id: estimateImg
                            source: !prevPageModel?"":prevPageModel.estimate_time?"qrc:/clock-colorful.svg":"qrc:/clock-unknown.svg"
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
                            text: !prevPageModel?"":qsTr("تخمین زمانی") +":<b> " + (prevPageModel.estimate_time?prevPageModel.estimate_time+ " " + qsTr("دقیقه"):qsTr("ثبت نشده است")) + "</b> "
                            font{family: AppStyle.appFont;pixelSize:  23*AppStyle.size1F;bold:false}
                            elide: AppStyle.ltr?Text.ElideLeft:Text.ElideRight
                        }
                    }
                    Loader{
                        active: listId === Memorito.Waiting
                        width: parent.width
                        visible: active
                        height: 70*AppStyle.size1H
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
                                text:!prevPageModel?"":qsTr("فرد انجام دهنده") +":<b> " + (prevPageModel.friend_id?friendModel.count>0?UsefulFunc.findInModel(prevPageModel.friend_id,"id",friendModel).value.friend_name
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
                        active: listId === Memorito.Calendar
                        width: parent.width
                        height: 70*AppStyle.size1H
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
                                property date dueDate:  !prevPageModel?"":prevPageModel.due_date?new Date(prevPageModel.due_date):""
                                text: !prevPageModel?"":qsTr("زمان مشخص شده") +":<b> "
                                                      + (
                                                          (
                                                              dueDate.getHours()===17 && dueDate.getMinutes() === 17 && dueDate.getSeconds() === 17
                                                              ?"":dueDate.getHours()+":"+dueDate.getMinutes()+":"+dueDate.getSeconds()+"  ")
                                                          +
                                                          (
                                                              dueDate?String(dateConverter.toJalali(dueDate.getFullYear(),dueDate.getMonth(),dueDate.getDate())).replace(/,/ig,"/").split("/").slice(0,3)
                                                                     :qsTr("ثبت نشده است"))
                                                          )
                                                      +"</b>"

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
                Flow{
                    id: filesFlow
                    width: parent.width
                    layoutDirection: Qt.RightToLeft
                    property real cellWidth: width / (parseInt(width / parseInt(500*AppStyle.size1W))===0?1:(parseInt(width / parseInt(500*AppStyle.size1W))))
                    anchors{
                        top: conentFlow.bottom
                        topMargin: 40*AppStyle.size1H
                        horizontalCenter: parent.horizontalCenter
                    }
                    Repeater{
                        model: ListModel{id:filesModel}

                        delegate: Item {
                            width: filesFlow.cellWidth
                            height: 175*AppStyle.size1W
                            AppButton{
                                radius: 15*AppStyle.size1W
                                Material.background: Material.color(AppStyle.primaryInt,Material.Shade400)
                                width: parent.width - 20*AppStyle.size1W
                                height: parent.height - 20*AppStyle.size1H
                                anchors{
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
                                        width: parent.width -15*AppStyle.size1W
                                        height: width
                                        source: model.file_extension.toLowerCase().match(/svg|png|jpg|gif|jpeg/g)?
                                                    "file://"+myTools.saveBase64asFile(model.file_name,model.file_extension,model.file):
                                                    icon.parent.extensions.indexOf(model.file_extension.toLowerCase())!== -1?
                                                        "qrc:/pack/"+(model.file_extension.toLowerCase())+".svg"
                                                      :"qrc:/pack/unknown.svg"
                                        anchors.centerIn: parent
                                        asynchronous: true
                                        sourceSize: Qt.size(width,height)
                                        fillMode:Image.PreserveAspectCrop
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
                                    font{family: AppStyle.appFont;pixelSize:  25*AppStyle.size1F;bold:true}
                                    anchors{
                                        left:  icon.right
                                        leftMargin: 10*AppStyle.size1W
                                        right: parent.right
                                        rightMargin: 10*AppStyle.size1W
                                        verticalCenter: parent.verticalCenter
                                    }
                                    width: parent.width
                                    verticalAlignment: Text.AlignVCenter
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    maximumLineCount: 2
                                    elide: Qt.ElideRight
                                }
                            }
                        }
                    }
                }
                Flow{
                    id: buttonFlow
                    property var doneableArray: [Memorito.NextAction,Memorito.Someday,Memorito.Waiting,Memorito.Calendar,Memorito.Project]
                    width: doneableArray.indexOf(listId) !== -1?640*AppStyle.size1W:420*AppStyle.size1W
                    spacing:  20*AppStyle.size1W
                    anchors{
                        top: filesFlow.bottom
                        topMargin: 40*AppStyle.size1H
                        horizontalCenter: parent.horizontalCenter
                    }

                    AppButton{
                        id:deleteBtn
                        width: 200*AppStyle.size1W
                        text: qsTr("حذف")
                        Material.background: Material.Red
                        onClicked: {
                            deleteLoader.active = true
                            deleteLoader.item.thingName = prevPageModel.title
                            deleteLoader.item.thingId = prevPageModel.id
                            deleteLoader.item.modelIndex = modelIndex
                            deleteLoader.item.open()
                        }

                    }
                    AppButton{
                        id:openBtn
                        width: 200*AppStyle.size1W
                        text: qsTr("ویرایش کردن")
                        Material.background: Material.LightBlue
                        onClicked: {
                            UsefulFunc.mainStackPush("qrc:/Things/AddEditThing.qml",qsTr("پردازش"),{"thingLocalId":prevPageModel.local_id,listId:listId})
                        }
                    }
                    AppButton{
                        id: doneBtn
                        visible: parent.doneableArray.indexOf(listId) !== -1
                        width: 200*AppStyle.size1W
                        text: qsTr("انجام شد")
                        Material.background: Material.Green
                        onClicked: {

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
            onClosed: {
                deleteLoader.active = false
            }
            property string thingName: ""
            property int thingId: -1
            property int modelIndex: -1
            dialogTitle: qsTr("حذف")
            dialogText: qsTr("آیا مایلید که") + " '" + thingName + "' " + qsTr("را حذف کنید؟")
            accepted: function() {
                ThingsApi.deleteThing(thingId,null,null)
            }
        }
    }

}
