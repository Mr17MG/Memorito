import QtQuick
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import Memorito.Global
import Memorito.Components

AppButton {
    id:rootItem
    radius: 15*AppStyle.size1W
    Material.background: Material.color(AppStyle.primaryInt,Material.Shade50)
    clip: true

    onClicked: {
        if(model.type_id === 2)
            UsefulFunc.mainStackPush("qrc:/Things/ThingsList.qml",qsTr("دسته‌بندی")+": "+model.title,{"parentId":model.local_id, "listId": listId,pageTitle:model.title})
        else
            UsefulFunc.mainStackPush("qrc:/Things/ThingsDetail.qml",qsTr("جزئیات")+": "+model.title,{"thingLocalId":model.local_id, "listId": listId})
    }

    Rectangle{
        id:topRect

        width: parent.width
        height: 70*AppStyle.size1H
        radius: 15*AppStyle.size1W

        Rectangle{
            color: parent.color
            width: parent.width
            height: 15*AppStyle.size1W
            anchors.bottom: parent.bottom
        }

        color: Material.color(AppStyle.primaryInt,Material.ShadeA700)

        Image {
            id: iconImg
            source: "qrc:/ThingsListIcon/" +(
                        listId === Memorito.Process?"process-item":
                                                     listId === Memorito.Refrence?"reference-item":
                                                                                   listId === Memorito.Coop?"coop-item":
                                                                                                                listId === Memorito.Calendar?"calendar-item":
                                                                                                                                              listId === Memorito.Trash?"trash-item":
                                                                                                                                                                         listId === Memorito.Done?"done-item":
                                                                                                                                                                                                   listId === Memorito.Someday?"someday-item":
                                                                                                                                                                                                                                listId === Memorito.Project?"project-item":
                                                                                                                                                                                                                                                             listId === Memorito.Contexts?"context-item":
                                                                                                                                                                                                                                                                                           listId === Memorito.Friends?"friends-item":"nextaction-item")+".svg"
            width: 40*AppStyle.size1W
            height: width
            visible: false
            sourceSize: Qt.size(width,height)
            anchors{
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 15*AppStyle.size1W
            }
        }

        ColorOverlay {
            anchors.fill: iconImg
            source: iconImg
            color: AppStyle.textOnPrimaryColor
        }

        Text{
            id: thingText

            elide: Qt.ElideRight
            text: model?.title??"";
            color: AppStyle.textOnPrimaryColor
            verticalAlignment: Text.AlignVCenter

            font {
                family: AppStyle.appFont;
                pixelSize:  25*AppStyle.size1F;
                bold:true
            }

            anchors{
                top:  parent.top
                bottom: parent.bottom
                right: iconImg.left
                rightMargin: 20*AppStyle.size1W
                left: isDoneColor.visible?isDoneImg.right:parent.left
                leftMargin: 20*AppStyle.size1W
            }
        }

        Image {
            id: isDoneImg

            height: width
            visible: false
            asynchronous: true
            width: 40*AppStyle.size1W
            source: "qrc:/check-circle.svg"
            sourceSize: Qt.size(width,height)

            anchors{
                verticalCenter: topRect.verticalCenter
                left: parent.left
                leftMargin: 20*AppStyle.size1W
            }
        }

        ColorOverlay{
            id:isDoneColor

            visible: model.status === 3
            color: AppStyle.textOnPrimaryColor
            source: isDoneImg
            anchors.fill: isDoneImg
        }
    }

    Text{
        id: detailText

        text: qsTr("توضیحات") + ": " + (model?.detail??qsTr("توضیحاتی ثبت نشده"))
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        maximumLineCount: 3
        height: 115*AppStyle.size1W
        elide: AppStyle.ltr?Text.ElideLeft:Text.ElideRight

        font {
            family: AppStyle.appFont;
            pixelSize:  23*AppStyle.size1F;
        }

        anchors{
            top:  topRect.bottom
            topMargin: 15*AppStyle.size1W
            right: parent.right
            rightMargin: 20*AppStyle.size1W
            left: parent.left
            leftMargin: 20*AppStyle.size1W
        }

    }

    Loader{
        visible: active
        active: listId !== Memorito.Process

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
            layoutDirection: Qt.RightToLeft

            Item{
                width: parent.width /2
                height: 50*AppStyle.size1H

                Image {
                    id: priorityImg

                    source: model.priority_id ? UsefulFunc.findInModel(model.priority_id,"Id",Constants.priorityListModel).value.iconSource
                                              : "qrc:/priorities/none.svg"
                    width: 40*AppStyle.size1W
                    height: width
                    sourceSize: Qt.size(width,height)

                    anchors{
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                    }
                }

                Text {
                    id: priorityText

                    elide: AppStyle.ltr?Text.ElideLeft:Text.ElideRight
                    text: qsTr("اولویت") +": " + ( model.priority_id ? UsefulFunc.findInModel(model.priority_id,"Id",Constants.priorityListModel).value.Text
                                                                     : qsTr("ثبت نشده") )

                    font{
                        family: AppStyle.appFont;
                        pixelSize: 23*AppStyle.size1F;
                    }

                    anchors{
                        verticalCenter: priorityImg.verticalCenter
                        right: priorityImg.left
                        rightMargin: 10*AppStyle.size1W
                        left: parent.left
                    }

                }
            }

            Item{
                width: parent.width /2
                height: 50*AppStyle.size1H

                Image {
                    id: energyImg
                    source: model.energy_id ? UsefulFunc.findInModel(model.energy_id,"Id",Constants.energyListModel).value.iconSource
                                            : "qrc:/energies/none.svg"
                    width: 40*AppStyle.size1W
                    height: width
                    sourceSize: Qt.size(width,height)

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
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
                    text: qsTr("سطح انرژی") +": " + (model.energy_id ? UsefulFunc.findInModel(model.energy_id,"Id",Constants.energyListModel).value.Text
                                                                     : qsTr("ثبت نشده"))
                    elide: AppStyle.ltr?Text.ElideLeft:Text.ElideRight
                    font{
                        family: AppStyle.appFont;
                        pixelSize:  23*AppStyle.size1F;
                    }
                }
            }

            Item{
                width: parent.width /2
                height: 50*AppStyle.size1H

                Image {
                    id: contextImg

                    height: width
                    width: 40*AppStyle.size1W
                    sourceSize: Qt.size(width,height)
                    source: model.context_id ? "qrc:/map.svg"
                                             : "qrc:/map-unknown.svg"

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
                    elide: AppStyle.ltr?Text.ElideLeft:Text.ElideRight
                    font {
                        family: AppStyle.appFont;
                        pixelSize:  23*AppStyle.size1F;
                    }
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
                    sourceSize: Qt.size(width,height)
                    anchors{
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                    }
                }
                Text {
                    id: estimateText

                    text: qsTr("تخمین زمانی") +": " + (model.estimate_time ? model.estimate_time+ " " + qsTr("دقیقه")
                                                                           : qsTr("ثبت نشده"))
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
                        pixelSize:  23*AppStyle.size1F;
                    }
                }
            }

            Loader{
                visible: active
                width: parent.width /2
                height: 50*AppStyle.size1H
                active: model.list_id === Memorito.Coop

                sourceComponent: Item{

                    anchors.fill: parent

                    Image {
                        id: friendImg
                        height: width
                        width: 40*AppStyle.size1W
                        source:"qrc:/friends-colorful.svg"
                        sourceSize: Qt.size(width,height)

                        anchors{
                            verticalCenter: parent.verticalCenter
                            right: parent.right
                        }
                    }

                    Text {
                        text:qsTr("فرد انجام دهنده") +": " + (model.friend_id?friendModel.count>0 ? UsefulFunc.findInModel(model.friend_id,"id",friendModel).value.friend_name
                                                                                                  : ""
                                                              :qsTr("ثبت نشده"))
                        elide: AppStyle.ltr?Text.ElideLeft:Text.ElideRight

                        font{
                            family: AppStyle.appFont;
                            pixelSize:  23*AppStyle.size1F;
                        }

                        anchors{
                            verticalCenter: friendImg.verticalCenter
                            right: friendImg.left
                            rightMargin: 10*AppStyle.size1W
                            left: parent.left
                        }
                    }
                }
            }

            Loader{
                visible: active
                width: parent.width
                height: 50*AppStyle.size1H
                active: model.list_id === Memorito.Calendar || model.due_date !==""

                sourceComponent: Item{
                    anchors.fill: parent

                    Image {
                        id: dateImg
                        height: width
                        width: 40*AppStyle.size1W
                        sourceSize: Qt.size(width,height)
                        source:"qrc:/calendar-colorful.svg"

                        anchors{
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                    }

                    Text {
                        property date dueDate:new Date(model.due_date)
                        text:qsTr("زمان مشخص شده") +": "
                             +( model.due_date ?AppStyle.ltr? dueDate.getFullYear()+"/"+(dueDate.getMonth()+1)+"/"+dueDate.getDate()
                                                            :(dateConverter.toJalali(dueDate.getFullYear(),dueDate.getMonth()+1,dueDate.getDate())).slice(0,3).join("/")
                               : qsTr("ثبت نشده"))

                        elide: AppStyle.ltr ? Text.ElideLeft
                                            : Text.ElideRight
                        anchors {
                            verticalCenter: dateImg.verticalCenter
                            right: dateImg.left
                            rightMargin: 10*AppStyle.size1W
                            left: parent.left
                        }
                        font {
                            family: AppStyle.appFont;
                            pixelSize:  23*AppStyle.size1F;
                        }
                    }
                }
            }
        }
    }
    Text{
        id: moreDetailText
        text: "<u>"+qsTr("توضیحات بیشتر") + "</u>"
        wrapMode: Text.WordWrap
        elide: AppStyle.ltr ? Text.ElideLeft
                            : Text.ElideRight

        font {
            family: AppStyle.appFont;
            pixelSize:  20*AppStyle.size1F;
        }
        anchors{
            bottom: parent.bottom
            bottomMargin: 10*AppStyle.size1W
            left: parent.left
            leftMargin: 20*AppStyle.size1W
        }
    }

    Text{
        text: qsTr("فایل داره")
        visible: model?.has_files ?? "";
        wrapMode: Text.WordWrap
        font {
            family: AppStyle.appFont;
            pixelSize:  20*AppStyle.size1F
        }
        anchors{
            bottom: parent.bottom
            bottomMargin: 10*AppStyle.size1W
            right: parent.right
            rightMargin: 20*AppStyle.size1W
        }
    }
}

