import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import Memorito.Global
import Memorito.Components

RowLayout {
    id:sortFlow
    spacing: 10*AppStyle.size1W
    layoutDirection: Qt.RightToLeft

    AppTextInput{
        id: searchInput

        hasCounter: false
        text: queryList.searchText
        placeholderText: qsTr("جست و جو")

        Layout.fillWidth: true
        Layout.fillHeight: true

        leftPadding : AppStyle.ltr ? 20*AppStyle.size1W
                                   : parent.height
        rightPadding: AppStyle.ltr ? parent.height
                                   : 20*AppStyle.size1W

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
                width : Qt.size(50*AppStyle.size1W,50*AppStyle.size1W).width
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
    AppButton {
        id: advanceSearchBtn

        flat: true
        radius: 30*AppStyle.size1W
        text: qsTr("تنظیمات پیشرفته")
        borderColor: AppStyle.borderColor
        visible: listId !== Memorito.Process

        Layout.fillHeight: true

        onClicked: {
            dialogLoader.active = true
            dialogLoader.item.open()
        }
    }

    Loader{
        id: dialogLoader

        active: false
        visible: active

        sourceComponent: Popup{
            id:advanceSearchDialog

            modal:true
            visible: true

            x: AppStyle.ltr? advanceSearchBtn.x-advanceSearchDialog.width+advanceSearchBtn.width
                           : advanceSearchBtn.x
            y: advanceSearchBtn.height + advanceSearchBtn.y

            width:  Math.min((UsefulFunc.rootWindow.width - 100*AppStyle.size1W), 800*AppStyle.size1W)
            height: Math.min((UsefulFunc.rootWindow.height - 500*AppStyle.size1H), 800*AppStyle.size1H)

            Overlay.modal: Rectangle {
                color: AppStyle.appTheme?"#aa606060":"#80000000"
            }

            background: Rectangle{
                color: AppStyle.dialogBackgroundColor
                radius: 60*AppStyle.size1W
            }

            onClosed: {
                dialogLoader.active = false
            }


            Flickable{
                id: mainFlick

                height: parent.height
                width:  parent.width

                clip:true
                contentHeight: item1.height
                flickableDirection: Flickable.VerticalFlick

                anchors{
                    right: parent.right
                    top: parent.top
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

                            visible: false
                            height: width
                            source: "qrc:/sort.svg"
                            width: 40*AppStyle.size1W
                            sourceSize: Qt.size(width,height)

                            anchors{
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                            }
                        }

                        ColorOverlay{
                            anchors.fill: sortImg
                            source: sortImg
                            color: AppStyle.textColor
                        }

                        Text{
                            id: sortText
                            color:AppStyle.textColor
                            text: qsTr("مرتب‌سازی براساس")+": "

                            anchors{
                                right: sortImg.left
                                rightMargin: 15*AppStyle.size1W
                                bottom: parent.bottom
                                bottomMargin: 25*AppStyle.size1H
                            }

                            font {
                                family: AppStyle.appFont;
                                pixelSize: 25*AppStyle.size1F;
                                bold:true
                            }
                        }
                        AppComboBox{
                            id: sortCompbo

                            hasClear: false
                            textRole: "text"
                            textAlign: Qt.AlignHCenter
                            iconSize: AppStyle.size1W*50
                            currentIndex: UsefulFunc.findInModel(queryList.orderBy,"query",sortCompbo.model).index

                            anchors{
                                right: sortText.left
                                rightMargin: 10*AppStyle.size1W
                                left: sortTypeBtn.right
                                leftMargin: 5*AppStyle.size1W
                                verticalCenter: parent.verticalCenter
                            }

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

                            width: height
                            checkable: true
                            hoverEnabled: true
                            height: 90*AppStyle.size1H
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

                            anchors {
                                left: parent.left
                                bottom: parent.bottom
                            }

                            property ToolTip toolTip : ToolTip{
                                text: sortTypeBtn.checked ? qsTr("صعودی")
                                                          : qsTr("نزولی")
                                font{
                                    family: AppStyle.appFont;
                                    pixelSize:  25*AppStyle.size1F;
                                    bold:true
                                }
                            }

                            onHoveredChanged: {
                                if(hovered)
                                    toolTip.open()
                                else toolTip.hide()
                            }
                        }
                    }

                    Item{
                        width: parent.width
                        height: 100*AppStyle.size1H

                        Image{
                            id: filterImg

                            height: width
                            visible: false
                            source: "qrc:/filter.svg"
                            width: 40*AppStyle.size1W
                            sourceSize: Qt.size(width,height)

                            anchors{
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                            }
                        }

                        ColorOverlay{
                            anchors.fill: filterImg
                            source: filterImg
                            color: AppStyle.textColor
                        }

                        Text{
                            id: filterText

                            color:AppStyle.textColor
                            text: qsTr("محدود کردن نتایج جست و جو")

                            anchors {
                                right: filterImg.left
                                rightMargin: 15*AppStyle.size1W
                                verticalCenter: parent.verticalCenter
                            }
                            font {
                                family: AppStyle.appFont;
                                pixelSize:  25*AppStyle.size1F;
                                bold:true
                            }
                        }
                    }
                    Text{
                        width: parent.width
                        color:AppStyle.textColor
                        text: qsTr("محل‌های انجام")+": "
                        rightPadding: 15*AppStyle.size1W
                        font {
                            family: AppStyle.appFont;
                            pixelSize:  25*AppStyle.size1F;
                            bold:true
                        }
                        Component.onCompleted: {

                            if (listId === Memorito.Contexts)
                            {
                                visible = false
                                height = 0
                            }
                        }
                    }

                    Grid {
                        columns: 2
                        width: parent.width
                        layoutDirection: Qt.RightToLeft
                        visible: (listId !== Memorito.Contexts)
                        horizontalItemAlignment: Qt.AlignRight

                        ButtonGroup {
                            id:contextGroup;
                            exclusive: false
                        }

                        Repeater{
                            model: Constants.contextsListModel
                            delegate: AppCheckBox{
                                text: model.context_name
                                ButtonGroup.group: contextGroup
                                width: (parent.width/2)-15*AppStyle.size1W
                                checked: queryList.context_id.indexOf(model.id) !== -1
                            }
                        }
                    }

                    Text{
                        id: filesText
                        text: qsTr("فایل")+": "
                        width: parent.width
                        color:AppStyle.textColor
                        height: 75*AppStyle.size1H
                        verticalAlignment: Text.AlignBottom
                        rightPadding: 15*AppStyle.size1W
                        font {
                            family: AppStyle.appFont;
                            pixelSize:  25*AppStyle.size1F;
                            bold:true
                        }
                    }

                    Grid{
                        width: parent.width
                        layoutDirection: Qt.RightToLeft

                        ButtonGroup {
                            id:filesGroup
                        }
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
                        color:AppStyle.textColor
                        height: 75*AppStyle.size1H
                        rightPadding: 15*AppStyle.size1W
                        verticalAlignment: Text.AlignBottom
                        font {
                            family: AppStyle.appFont;
                            pixelSize: 25*AppStyle.size1F;
                            bold:true
                        }
                    }

                    Grid{
                        rows: 2
                        columns: 2
                        width: parent.width
                        layoutDirection: Qt.RightToLeft

                        ButtonGroup{
                            id:prioritiesGroup;
                            exclusive: false
                        }
                        Repeater{
                            model: Constants.priorityListModel
                            delegate: AppCheckBox{
                                text: "      "+model.Text
                                ButtonGroup.group: prioritiesGroup
                                checked: queryList.priority_id.indexOf(model.Id) !== -1
                                width: prioritiesText.width/2
                                Image {
                                    source: model.iconSource
                                    width: 40*AppStyle.size1W
                                    height: width
                                    sourceSize: Qt.size(width,height)
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
                        color:AppStyle.textColor
                        height: 75*AppStyle.size1H
                        rightPadding: 15*AppStyle.size1W
                        verticalAlignment: Text.AlignBottom
                        font {
                            family: AppStyle.appFont;
                            pixelSize: 25*AppStyle.size1F;
                            bold:true
                        }
                    }

                    Grid{
                        rows: 2
                        columns: 2
                        width: parent.width
                        layoutDirection: Qt.RightToLeft

                        ButtonGroup {
                            id:energiesGroup;
                            exclusive: false
                        }

                        Repeater{
                            model: Constants.energyListModel
                            delegate: AppCheckBox{
                                text: "      "+model.Text
                                width: energiesText.width/2
                                ButtonGroup.group: energiesGroup
                                checked: queryList.energy_id.indexOf(model.Id) !== -1
                                Image {
                                    source: model.iconSource
                                    width: 40*AppStyle.size1W
                                    height: width
                                    sourceSize: Qt.size(width,height)
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
                        color:AppStyle.textColor
                        height: 75*AppStyle.size1H
                        rightPadding: 15*AppStyle.size1W
                        verticalAlignment: Text.AlignBottom

                        font {
                            family: AppStyle.appFont;
                            pixelSize:  25*AppStyle.size1F;
                            bold:true
                        }
                    }
                    Item{
                        width: parent.width
                        height: 120*AppStyle.size1H

                        AppComboBox{
                            id: timeCompbo

                            width: parent.width/2 - 10*AppStyle.size1W
                            textAlign: Qt.AlignHCenter
                            textRole: "text"
                            iconSize: AppStyle.size1W*50
                            hasClear: false
                            currentIndex: UsefulFunc.findInModel(queryList.estimate_type,"query",timeCompbo.model).index

                            anchors{
                                right: parent.right
                                rightMargin: 10*AppStyle.size1W
                                verticalCenter: parent.verticalCenter
                            }

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

                            text: queryList.estimate_time
                            font.bold: false
                            placeholder.visible: false
                            placeholderTextColor: AppStyle.textColor
                            height: AppStyle.size1H*100
                            horizontalAlignment: Text.AlignHCenter
                            placeholderText: qsTr("زمان تخمینی به دقیقه")
                            maximumLength: 3

                            anchors {
                                right: timeCompbo.left
                                rightMargin: 10*AppStyle.size1W
                                left: parent.left
                                leftMargin: 10*AppStyle.size1W
                                bottom: parent.bottom
                                bottomMargin: 2*AppStyle.size1H
                            }

                            validator: RegularExpressionValidator {
                                regularExpression: /[0123456789۰۱۲۳۴۵۶۷۸۹]{3}/ig
                            }

                            onTextChanged: {
                                if (text.match(/[۰۱۲۳۴۵۶۷۸۹]/ig))
                                    text = UsefulFunc.faToEnNumber(text)
                            }

                            Text{
                                text: qsTr("دقیقه")
                                font: parent.font
                                visible: parent.text.trim()!==""

                                anchors{
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }

                    Item{
                        width: parent.width
                        height: 150*AppStyle.size1H

                        AppButton{
                            id: applayFilter

                            text: qsTr("اعمال")
                            width: parent.width/2
                            anchors.centerIn: parent
                            radius: 30*AppStyle.size1W

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
                                for(i=0; i<Constants.priorityListModel.count;i++)
                                    if(prioritiesGroup.buttons[i].checked)
                                        prioritiesSelected.push(Constants.priorityListModel.get(i).Id)


                                let energiesSelected = []
                                for(i=0; i<Constants.energyListModel.count;i++)
                                    if(energiesGroup.buttons[i].checked)
                                        energiesSelected.push(Constants.energyListModel.get(i).Id)

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

