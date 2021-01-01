import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtQuick.Controls.Material.impl 2.14

import "qrc:/Components/" as App
import QtGraphicalEffects 1.1
import "qrc:/Managment/" as Managment
import MEnum 1.0
import MDate 1.0

Item {
    ThingsApi{id: thingApi}
    Managment.API{ id: managmentApi }
    property int listId: -1
    property string title: ""
    Component.onCompleted: {
        thingApi.getThings(listId === Memorito.NextAction?
                               nextActionModel :listId === Memorito.Someday?
                                   somedayModel :listId === Memorito.Refrence?
                                       refrenceModel : listId === Memorito.Waiting?
                                           waitingModel : listId === Memorito.Calendar?
                                               calendarModel : listId === Memorito.Trash?
                                                   trashModel : listId === Memorito.Done?
                                                       doneModel : thingModel
                           ,listId)
        if(listId === Memorito.Waiting)
        {
            managmentApi.getFriends(friendModel)
        }

        managmentApi.getContexts(contextModel)
    }

    GridView{
        id: control
        onContentYChanged: {
            if(contentY<0 || contentHeight < control.height)
                contentY = 0
            else if(contentY > (contentHeight - control.height))
                contentY = (contentHeight - control.height)
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
        cellHeight: listId === Memorito.Process? 240*size1W:370*size1W
        cellWidth: width / (parseInt(width / parseInt(500*size1W))===0?1:(parseInt(width / parseInt(500*size1W))))

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
                    usefulFunc.mainStackPush("qrc:/Flow/Collect.qml",qsTr("پردازش"),{prevPageModel:model,modelIndex:model.index,listId:listId})
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
                    color: "white"
                }

                Text{
                    id: thingText
                    text: title
                    font{family: appStyle.appFont;pixelSize:  25*size1F;bold:true}
                    color: "white"
                    anchors{
                        top:  parent.top
                        bottom: parent.bottom
                        right: unprocessImg.left
                        rightMargin: 20*size1W
                        left: parent.left
                        leftMargin: 20*size1W
                    }
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                }
            }
            Text{
                id: detailText
                text: qsTr("توضیحات") + ": " + (detail?detail:qsTr("توضیحاتی ثبت نشده است"))
                font{family: appStyle.appFont;pixelSize:  23*size1F;bold:false;italic: true}
                anchors{
                    top:  topRect.bottom
                    topMargin: 20*size1W
                    right: parent.right
                    rightMargin: 20*size1W
                    left: parent.left
                }
                wrapMode: Text.WordWrap
                maximumLineCount: 3
                elide: ltr?Text.ElideLeft:Text.ElideRight
            }
            Loader{
                active: listId !== Memorito.Process
                visible: active
                anchors{
                    top: detailText.bottom
                    topMargin: 20*size1W
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
                    Text {
                        id: priorityText
                        text: qsTr("اولویت") +":<b> " + (model.priority_id?usefulFunc.findInModel(model.priority_id,"Id",priorityModel).value.Text:qsTr("ثبت نشده است")) + "</b>"
                        width: parent.width /2
                        elide: ltr?Text.ElideLeft:Text.ElideRight
                        font{family: appStyle.appFont;pixelSize:  20*size1F;bold:false}
                    }
                    Text {
                        id: energyText
                        text: qsTr("سطح انرژی") +":<b> " + (model.energy_id?usefulFunc.findInModel(model.energy_id,"Id",energyModel).value.Text:qsTr("ثبت نشده است")) + "</b>"
                        width: parent.width /2
                        elide: ltr?Text.ElideLeft:Text.ElideRight
                        font{family: appStyle.appFont;pixelSize:  20*size1F;bold:false}
                    }
                    Text {
                        id: contextText
                        text: qsTr("محل انجام") +":<b> " + (model.context_id?contextModel.count>0?usefulFunc.findInModel(model.context_id,"id",contextModel).value.context_name:"":qsTr("ثبت نشده است")) + "</b>"
                        width: parent.width /2
                        elide: ltr?Text.ElideLeft:Text.ElideRight
                    }
                    Text {
                        id: estimateText
                        text: qsTr("تخمین زمانی") +":<b> " + (model.estimate_time?model.estimate_time+ " " + qsTr("دقیقه"):qsTr("ثبت نشده است")) + "</b> "
                        width: parent.width /2
                        font{family: appStyle.appFont;pixelSize:  20*size1F;bold:false}
                        elide: ltr?Text.ElideLeft:Text.ElideRight
                    }
                    Loader{
                        active: listId === Memorito.Waiting
                        width: parent.width /2
                        visible: active
                        height: 30*size1H
                        sourceComponent: Text {
                            text:qsTr("فرد انجام دهنده") +":<b> " + (model.friend_id?friendModel.count>0?usefulFunc.findInModel(model.friend_id,"id",friendModel).value.friend_name
                                                                                                        :""
                                                                     :qsTr("ثبت نشده است")) + "</b>"
                            anchors.fill: parent
                            font{family: appStyle.appFont;pixelSize:  20*size1F;bold:false}
                            elide: ltr?Text.ElideLeft:Text.ElideRight
                        }
                    }
                    Loader{
                        active: listId === Memorito.Calendar
                        width: parent.width
                        height: 30*size1H
                        visible: active
                        sourceComponent: Text {
                            DateConvertor{id:dateConverter}
                            property date dueDate: model.due_date
                            text:qsTr("زمان مشخص شده") +":<b> " + (dueDate?dateConverter.toJalali(dueDate.getFullYear(),dueDate.getMonth(),dueDate.getDate())
                                                                          :qsTr("ثبت نشده است")) + "</b>"
                            anchors.fill: parent
                            font{family: appStyle.appFont;pixelSize:  20*size1F;bold:false}
                            elide: ltr?Text.ElideLeft:Text.ElideRight
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
                       somedayModel :listId === Memorito.Refrence?
                           refrenceModel : listId === Memorito.Waiting?
                               waitingModel : listId === Memorito.Calendar?
                                   calendarModel : listId === Memorito.Trash?
                                       trashModel : listId === Memorito.Done?
                                           doneModel : thingModel
    }

    App.Button{
        text: qsTr("افزودن چیز به") +" "+ (title)
        anchors{
            left: parent.left
            leftMargin: 20*size1W
            bottom: parent.bottom
            bottomMargin: 20*size1W
        }
        radius: 20*size1W
        leftPadding: 35*size1W
        rightPadding: 35*size1W
        onClicked: {
            usefulFunc.mainStackPush("qrc:/Flow/Collect.qml",qsTr("پردازش"),{listId:listId})

        }
        icon.width: 30*size1W
        icon.source:"qrc:/plus.svg"
        icon.color: "white"
    }
}
