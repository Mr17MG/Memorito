import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import MDate 1.0
import MEnum 1.0
import "qrc:/Components" as App
Item {
    id:root
    property var prevPageModel
    property int listId: -1
    property int modelIndex: -1
    DateConvertor{id:dateConverter}

    Loader{
        id: deleteLoader
        active: false
        sourceComponent: App.ConfirmDialog{
            parent: mainPage
            onClosed: {
                deleteLoader.active = false
            }
            property string thingName: ""
            property int thingId: -1
            property int modelIndex: -1
            dialogTitle: qsTr("حذف")
            dialogText: qsTr("آیا مایلید که") + " '" + thingName + "' " + qsTr("را حذف کنید؟")
            accepted: function() {
                thingsApi.deleteThing(thingId,null,null)
            }
        }
    }
    Rectangle{
        anchors{
            top: parent.top
            topMargin: 40*size1H
            right: parent.right
            rightMargin: 40*size1W
            left: parent.left
            leftMargin: 40*size1W
            bottom: parent.bottom
            bottomMargin: 40*size1H
        }
        clip: true
        color: Material.color(appStyle.primaryInt,Material.Shade50)
        radius: 20*size1W
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
                active: hovered || pressed
                orientation: Qt.Vertical
                anchors.right: mainFlick.right
                height: parent.height
                width: hovered || pressed?18*size1W:8*size1W
                contentItem: Rectangle {
                    visible: parent.active
                    radius: parent.pressed || parent.hovered ?20*size1W:8*size1W
                    color: parent.pressed ?Material.color(appStyle.primaryInt,Material.Shade900):Material.color(appStyle.primaryInt,Material.Shade600)
                }
            }
            Item{
                id:item1
                width: parent.width
                height: titleText.height+detailText.height+flow1.height+flow2.height+flow3.height+160*size1W
                Text {
                    id: titleText
                    anchors{
                        top: parent.top
                        topMargin: 20*size1W
                        right: parent.right
                        rightMargin: 20*size1W
                        left: parent.left
                        leftMargin: 20*size1W
                    }
                    text: !prevPageModel?"":prevPageModel.title??""
                                                                  font{family: appStyle.appFont;pixelSize:  35*size1F;bold:true}
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }
                Column{
                    width: parent.width
                    spacing: detailText.lineHeight -2*size1W
                    anchors{
                        top: titleText.bottom
                        topMargin: 40*size1W
                        right: parent.right
                        rightMargin: 30*size1W
                        left: parent.left
                        leftMargin: 30*size1W
                    }
                    clip:true
                    Repeater{
                        model:detailText.lineCount
                        delegate: Row{
                            spacing: 10*size1W
                            width: parent.width
                            Repeater {
                                clip: true
                                model: root.width/3 // or any number of dots you want
                                Rectangle {width: 5*size1W; height: 2*size1W; color: "#A5A5A5"}
                            }
                        }
                    }
                }
                Text {
                    id: detailText
                    anchors{
                        top: titleText.bottom
                        topMargin: 20*size1W
                        right: parent.right
                        rightMargin: 30*size1W
                        left: parent.left
                        leftMargin: 30*size1W
                    }
                    text: !prevPageModel?"":prevPageModel.detail ?? ""
                                                                    font{family: appStyle.appFont;pixelSize:  25*size1F;}
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignJustify
                    lineHeightMode: Text.FixedHeight
                    lineHeight: 50*size1H
                }
                Flow{
                    id:flow1
                    anchors{
                        top: detailText.bottom
                        topMargin: 20*size1W
                        right: parent.right
                        rightMargin: 30*size1W
                        left: parent.left
                        leftMargin: 30*size1W
                    }
                    layoutDirection: "RightToLeft"
                    spacing: 20*size1W
                    Text {
                        width: parent.width/2 > 350*size1W?parent.width/2-20*size1W:350*size1W
                        property date registerDate: !prevPageModel?"":prevPageModel.register_date?new Date(prevPageModel.register_date):""
                        text: !prevPageModel?"":prevPageModel.register_date?qsTr("ثبت شده در")+": <b> "
                                                                             +
                                                                             registerDate.getHours()+":"+registerDate.getMinutes()+":"+registerDate.getSeconds()
                                                                             +"  "+
                                                                             String(dateConverter.toJalali(registerDate.getFullYear(),registerDate.getMonth(),registerDate.getDate())).replace(/,/ig,"/").split("/").slice(0,3)
                                                                             +"</b>"
                                                                           :""
                        font{family: appStyle.appFont;pixelSize:  23*size1F;bold:false}
                    }
                    Text {
                        width: parent.width/2 > 350*size1W?parent.width/2:350*size1W
                        property date modifiedDate: !prevPageModel?"":prevPageModel.modified_date?new Date(prevPageModel.modified_date):""
                        text:!prevPageModel?"":prevPageModel.modified_date?qsTr("ویرایش شده در")+": <b> "
                                                                            +
                                                                            modifiedDate.getHours()+":"+modifiedDate.getMinutes()+":"+modifiedDate.getSeconds()
                                                                            +"  "+
                                                                            String(dateConverter.toJalali(modifiedDate.getFullYear(),modifiedDate.getMonth(),modifiedDate.getDate())).replace(/,/ig,"/").split("/").slice(0,3)
                                                                            +"</b>"
                                                                          :""
                        font{family: appStyle.appFont;pixelSize:  23*size1F;bold:false}
                    }
                }
                Flow{
                    id: flow2
                    anchors{
                        top: flow1.bottom
                        topMargin: 20*size1W
                        right: parent.right
                        rightMargin: 30*size1W
                        left: parent.left
                        leftMargin: 30*size1W
                    }
                    width: parent.width
                    layoutDirection: "RightToLeft"
                    Item{
                        width: parent.width/2 > 350*size1W?parent.width/2:350*size1W
                        height: 70*size1H
                        Image {
                            id: priorityImg
                            source: !prevPageModel?"":prevPageModel.priority_id?usefulFunc.findInModel(prevPageModel.priority_id,"Id",priorityModel).value.iconSource:"qrc:/priorities/none.svg"
                            width: 40*size1W
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
                                rightMargin: 10*size1W
                                left: parent.left
                            }
                            text: !prevPageModel?"":qsTr("اولویت") +":    <b> " + (prevPageModel.priority_id?usefulFunc.findInModel(prevPageModel.priority_id,"Id",priorityModel).value.Text:qsTr("ثبت نشده است")) + "</b>"
                            elide: ltr?Text.ElideLeft:Text.ElideRight
                            font{family: appStyle.appFont;pixelSize:  23*size1F;bold:false}
                        }
                    }
                    Item{
                        width: parent.width/2 > 350*size1W?parent.width/2:350*size1W
                        height: 70*size1H
                        Image {
                            id: energyImg
                            source: !prevPageModel?"":prevPageModel.energy_id?usefulFunc.findInModel(prevPageModel.energy_id,"Id",energyModel).value.iconSource:"qrc:/energies/none.svg"
                            width: 40*size1W
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
                                rightMargin: 10*size1W
                                left: parent.left
                            }
                            text: !prevPageModel?"":qsTr("سطح انرژی") +":<b> " + (prevPageModel.energy_id?usefulFunc.findInModel(prevPageModel.energy_id,"Id",energyModel).value.Text:qsTr("ثبت نشده است")) + "</b>"
                            elide: ltr?Text.ElideLeft:Text.ElideRight
                            font{family: appStyle.appFont;pixelSize:  23*size1F;bold:false}
                        }
                    }
                    Item{
                        width: parent.width/2 > 350*size1W?parent.width/2:350*size1W
                        height: 70*size1H
                        Image {
                            id: contextImg
                            source: !prevPageModel?"":prevPageModel.context_id?"qrc:/map.svg":"qrc:/map-unknown.svg"
                            width: 40*size1W
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
                                rightMargin: 10*size1W
                                left: parent.left
                            }
                            text: !prevPageModel?"":qsTr("محل انجام") +":<b> " + (prevPageModel.context_id?contextModel.count>0?usefulFunc.findInModel(prevPageModel.context_id,"id",contextModel).value.context_name:"":qsTr("ثبت نشده است")) + "</b>"
                            font{family: appStyle.appFont;pixelSize:  23*size1F;bold:false}
                            elide: ltr?Text.ElideLeft:Text.ElideRight
                        }
                    }
                    Item{
                        width: parent.width/2 > 350*size1W?parent.width/2:350*size1W
                        height: 70*size1H
                        Image {
                            id: estimateImg
                            source: !prevPageModel?"":prevPageModel.estimate_time?"qrc:/clock-colorful.svg":"qrc:/clock-unknown.svg"
                            width: 40*size1W
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
                                rightMargin: 10*size1W
                                left: parent.left
                            }
                            text: !prevPageModel?"":qsTr("تخمین زمانی") +":<b> " + (prevPageModel.estimate_time?prevPageModel.estimate_time+ " " + qsTr("دقیقه"):qsTr("ثبت نشده است")) + "</b> "
                            font{family: appStyle.appFont;pixelSize:  23*size1F;bold:false}
                            elide: ltr?Text.ElideLeft:Text.ElideRight
                        }
                    }
                    Loader{
                        active: listId === Memorito.Waiting
                        width: parent.width
                        visible: active
                        height: 70*size1H
                        sourceComponent: Item{
                            anchors.fill: parent
                            Image {
                                id: friendImg
                                source:"qrc:/friends-colorful.svg"
                                width: 40*size1W
                                height: width
                                sourceSize.width:width*2
                                sourceSize.height:height*2
                                anchors{
                                    verticalCenter: parent.verticalCenter
                                    right: parent.right
                                }
                            }
                            Text {
                                text:!prevPageModel?"":qsTr("فرد انجام دهنده") +":<b> " + (prevPageModel.friend_id?friendModel.count>0?usefulFunc.findInModel(prevPageModel.friend_id,"id",friendModel).value.friend_name
                                                                                                                                      :""
                                                                                           :qsTr("ثبت نشده است")) + "</b>"
                                anchors{
                                    verticalCenter: friendImg.verticalCenter
                                    right: friendImg.left
                                    rightMargin: 10*size1W
                                    left: parent.left
                                }
                                font{family: appStyle.appFont;pixelSize:  23*size1F;bold:false}
                                elide: ltr?Text.ElideLeft:Text.ElideRight
                            }
                        }
                    }
                    Loader{
                        active: listId === Memorito.Calendar
                        width: parent.width
                        height: 70*size1H
                        visible: active
                        sourceComponent: Item{
                            anchors.fill: parent
                            Image {
                                id: dateImg
                                source:"qrc:/calendar-colorful.svg"
                                width: 40*size1W
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
                                    rightMargin: 10*size1W
                                    left: parent.left
                                }
                                font{family: appStyle.appFont;pixelSize:  23*size1F;bold:false}
                                elide: ltr?Text.ElideLeft:Text.ElideRight
                            }
                        }
                    }
                }
                Flow{
                    id: flow3
                    property var doneableArray: [Memorito.NextAction,Memorito.Someday,Memorito.Waiting,Memorito.Calendar,Memorito.Project]
                    width: doneableArray.indexOf(listId) !== -1?640*size1W:420*size1W
                    spacing:  20*size1W
                    anchors{
                        top: flow2.bottom
                        topMargin: 40*size1H
                        horizontalCenter: parent.horizontalCenter
                    }

                    App.Button{
                        id:deleteBtn
                        width: 200*size1W
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
                    App.Button{
                        id:openBtn
                        width: 200*size1W
                        text: qsTr("ویرایش کردن")
                        Material.background: Material.LightBlue
                        onClicked: {
                            usefulFunc.mainStackPush("qrc:/AddEditThing.qml",qsTr("پردازش"),{prevPageModel:prevPageModel,modelIndex:modelIndex,listId:listId})
                        }
                    }
                    App.Button{
                        id: doneBtn
                        visible: parent.doneableArray.indexOf(listId) !== -1
                        width: 200*size1W
                        text: qsTr("انجام شد")
                        Material.background: Material.Green
                        onClicked: {

                        }
                    }

                }
            }
        }
    }

}
