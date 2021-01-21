import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtQuick.Controls.Material.impl 2.14

import "qrc:/Components/" as App
import QtGraphicalEffects 1.1
import MEnum 1.0
import MDate 1.0

Item {
    ThingsApi{id: thingApi}
    FriendsAPI { id: friendsApi  }
    ContextsApi{ id: contextsApi }
    property string pageTitle: ""
    property int listId: -1
    property int categoryId: -1
    Component.onCompleted: {
        thingApi.getThings(listId === Memorito.NextAction?
                               nextActionModel :listId === Memorito.Someday?
                                   somedayModel :listId === Memorito.Project?
                                       projectModel :listId === Memorito.Refrence?
                                           refrenceModel : listId === Memorito.Waiting?
                                               waitingModel : listId === Memorito.Calendar?
                                                   calendarModel : listId === Memorito.Trash?
                                                       trashModel : listId === Memorito.Done?
                                                           doneModel : thingModel
                           ,listId,categoryId)
        if(listId === Memorito.Waiting)
        {
            friendsApi.getFriends(friendModel)
        }

        contextsApi.getContexts(contextModel)
    }
    Item {
        anchors{
            centerIn: parent
        }
        visible: control.model.count === 0
        width:  600*size1W
        height: width
        Image {
            width:  600*size1W
            height: width*0.781962339
            source: "qrc:/empties/empty-list-"+appStyle.primaryInt+".svg"
            sourceSize.width: width*2
            sourceSize.height: height*2
            anchors{
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: -30*size1H
            }
        }
        Text{
            text: qsTr("چیزی ثبت نشده‌است")
            font{family: appStyle.appFont;pixelSize:  40*size1F;bold:true}
            color: appStyle.textColor
            anchors{
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
        }
    }

    GridView{
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
                addBtn.anchors.bottomMargin = -60*size1H
            else addBtn.anchors.bottomMargin = 20*size1H

            lastContentY = contentY
        }
        onContentXChanged: {
            if(contentX<0 || contentWidth < control.width)
                contentX = 0
            else if(contentX > (contentWidth-control.width))
                contentX = (contentWidth-control.width)
        }
        anchors{
            top: parent.top
            topMargin: 15*size1H
            right: parent.right
            rightMargin: 20*size1W
            bottom: parent.bottom
            bottomMargin: 15*size1H
            left: parent.left
            leftMargin: 20*size1W
        }
        width: parent.width
        layoutDirection:Qt.RightToLeft
        cellHeight: listId === Memorito.Process? 240*size1W:400*size1W
        cellWidth: width / (parseInt(width / parseInt(600*size1W))===0?1:(parseInt(width / parseInt(600*size1W))))


        /***********************************************/
        delegate: Rectangle {
            id:rootItem
            radius: 15*size1W
            width: control.cellWidth - 10*size1W
            height:  control.cellHeight - 10*size1H
            color: Material.color(appStyle.primaryInt,Material.Shade50)
            clip: true
            MouseArea{
                id: mouseArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {
                    usefulFunc.mainStackPush("qrc:/ThingsDetail.qml",qsTr("جزئیات"),{prevPageModel:model,modelIndex:model.index,listId:listId})
                }
            }
            Ripple {
                clipRadius: 15*size1W
                z:1
                width: mouseArea.width
                height: mouseArea.height
                pressed: mouseArea.pressed
                anchor: mouseArea
                active: mouseArea.focus
                color: appStyle.rippleColor
                OpacityMask {
                    source: mouseArea
                    maskSource: Rectangle {
                        x: mouseArea.mouseX
                        y: mouseArea.mouseY
                        width: mouseArea.width
                        height: mouseArea.height
                        radius: 10*size1W
                    }
                }
            }
            Rectangle{
                id:topRect
                width: parent.width
                height: 70*size1H
                radius: 15*size1W
                Rectangle{
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 15*size1W
                    color: parent.color
                }
                color: Material.color(appStyle.primaryInt,Material.ShadeA700)
                Image {
                    id: unprocessImg
                    source: "qrc:/todo.svg"
                    width: 40*size1W
                    height: width
                    sourceSize.width: width*2
                    sourceSize.height: height*2
                    anchors{
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: 15*size1W
                    }
                    visible: false
                }
                ColorOverlay{
                    anchors.fill: unprocessImg
                    source: unprocessImg
                    color: appStyle.textOnPrimaryColor
                }

                Text{
                    id: thingText
                    text: model.title
                    font{family: appStyle.appFont;pixelSize:  25*size1F;bold:true}
                    color: appStyle.textOnPrimaryColor
                    anchors{
                        top:  parent.top
                        bottom: parent.bottom
                        right: unprocessImg.left
                        rightMargin: 20*size1W
                        left: parent.left
                        leftMargin: 20*size1W
                    }
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }
            }
            Text{
                id: detailText
                text: qsTr("توضیحات") + ": <b>" + (model.detail? model.detail : qsTr("توضیحاتی ثبت نشده است")) +"</b>"
                font{family: appStyle.appFont;pixelSize:  23*size1F;}
                anchors{
                    top:  topRect.bottom
                    topMargin: 15*size1W
                    right: parent.right
                    rightMargin: 20*size1W
                    left: parent.left
                    leftMargin: 20*size1W
                }
                wrapMode: Text.WordWrap
                maximumLineCount: 3
                height: 115*size1W
                elide: ltr?Text.ElideLeft:Text.ElideRight

            }
            Loader{
                active: listId !== Memorito.Process
                visible: active
                anchors{
                    top: detailText.bottom
                    bottom: moreDetailText.top
                    right: parent.right
                    rightMargin: 20*size1W
                    left: parent.left
                    leftMargin: 20*size1W
                }
                sourceComponent:Flow{
                    id: flow1
                    width: parent.width
                    height: parent.height
                    layoutDirection: "RightToLeft"
                    Item{
                        width: parent.width /2
                        height: 50*size1H
                        Image {
                            id: priorityImg
                            source: model.priority_id?usefulFunc.findInModel(model.priority_id,"Id",priorityModel).value.iconSource:"qrc:/priorities/none.svg"
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
                            text: qsTr("اولویت") +":    <b> " + (model.priority_id?usefulFunc.findInModel(model.priority_id,"Id",priorityModel).value.Text:qsTr("ثبت نشده است")) + "</b>"
                            elide: ltr?Text.ElideLeft:Text.ElideRight
                            font{family: appStyle.appFont;pixelSize:  23*size1F;bold:false}
                        }
                    }
                    Item{
                        width: parent.width /2
                        height: 50*size1H
                        Image {
                            id: energyImg
                            source: model.energy_id?usefulFunc.findInModel(model.energy_id,"Id",energyModel).value.iconSource:"qrc:/energies/none.svg"
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
                            text: qsTr("سطح انرژی") +":<b> " + (model.energy_id?usefulFunc.findInModel(model.energy_id,"Id",energyModel).value.Text:qsTr("ثبت نشده است")) + "</b>"
                            elide: ltr?Text.ElideLeft:Text.ElideRight
                            font{family: appStyle.appFont;pixelSize:  23*size1F;bold:false}
                        }
                    }
                    Item{
                        width: parent.width /2
                        height: 50*size1H
                        Image {
                            id: contextImg
                            source: model.context_id?"qrc:/map.svg":"qrc:/map-unknown.svg"
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
                            text: qsTr("محل انجام") +":<b> " + (model.context_id?contextModel.count>0?usefulFunc.findInModel(model.context_id,"id",contextModel).value.context_name:"":qsTr("ثبت نشده است")) + "</b>"
                            font{family: appStyle.appFont;pixelSize:  23*size1F;bold:false}
                            elide: ltr?Text.ElideLeft:Text.ElideRight
                        }
                    }
                    Item{
                        width: parent.width /2
                        height: 50*size1H
                        Image {
                            id: estimateImg
                            source: model.estimate_time?"qrc:/clock-colorful.svg":"qrc:/clock-unknown.svg"
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
                            text: qsTr("تخمین زمانی") +":<b> " + (model.estimate_time?model.estimate_time+ " " + qsTr("دقیقه"):qsTr("ثبت نشده است")) + "</b> "
                            font{family: appStyle.appFont;pixelSize:  23*size1F;bold:false}
                            elide: ltr?Text.ElideLeft:Text.ElideRight
                        }
                    }
                    Loader{
                        active: listId === Memorito.Waiting
                        width: parent.width /2
                        visible: active
                        height: 50*size1H
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
                                text:qsTr("فرد انجام دهنده") +":<b> " + (model.friend_id?friendModel.count>0?usefulFunc.findInModel(model.friend_id,"id",friendModel).value.friend_name
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
                        height: 50*size1H
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
                                DateConvertor{id:dateConverter}
                                property date dueDate: model.due_date
                                text:qsTr("زمان مشخص شده") +":<b> "
                                     +(dueDate?String(dateConverter.toJalali(dueDate.getFullYear(),dueDate.getMonth(),dueDate.getDate())).replace(/,/ig,"/").split("/").slice(0,3)
                                              :qsTr("ثبت نشده است"))
                                     + "</b>"
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
            }
            Text{
                id: moreDetailText
                text: "<u>"+qsTr("توضیحات بیشتر") + "</u>"
                font{family: appStyle.appFont;pixelSize:  20*size1F;bold:false}
                wrapMode: Text.WordWrap
                elide: ltr?Text.ElideLeft:Text.ElideRight
                anchors{
                    bottom: parent.bottom
                    bottomMargin: 10*size1W
                    left: parent.left
                    leftMargin: 20*size1W
                }
            }
            Text{
                text: qsTr("فایل دارد")
                visible: model.has_files
                font{family: appStyle.appFont;pixelSize:  20*size1F;bold:false}
                wrapMode: Text.WordWrap
                anchors{
                    bottom: parent.bottom
                    bottomMargin: 10*size1W
                    right: parent.right
                    rightMargin: 20*size1W
                }
            }
        }

        /***********************************************/
        model: listId === Memorito.NextAction?
                   nextActionModel :listId === Memorito.Someday?
                       somedayModel :listId === Memorito.Project?
                           projectModel :listId === Memorito.Refrence?
                               refrenceModel : listId === Memorito.Waiting?
                                   waitingModel : listId === Memorito.Calendar?
                                       calendarModel : listId === Memorito.Trash?
                                           trashModel : listId === Memorito.Done?
                                               doneModel : thingModel
    }

    App.Button{
        id: addBtn
        text: qsTr("افزودن چیز به") +" "+ (pageTitle)
        anchors{
            left: parent.left
            leftMargin: 20*size1W
            bottom: parent.bottom
            bottomMargin: 20*size1W
        }
        Behavior on anchors.bottomMargin { NumberAnimation{ duration: 200 } }
        radius: 20*size1W
        leftPadding: 35*size1W
        rightPadding: 35*size1W
        onClicked: {
            usefulFunc.mainStackPush("qrc:/AddEditThing.qml",qsTr("افزودن به")+" "+pageTitle,{listId:listId,categoryId:categoryId})

        }
        icon.width: 30*size1W
        icon.source:"qrc:/plus.svg"
    }
}
