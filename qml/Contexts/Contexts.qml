import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtGraphicalEffects 1.1
import Components 1.0
import Global 1.0

Item {
    Component.onCompleted: {
        ContextsApi.getContexts(contextModel)
    }

    Item {
        anchors{ centerIn: parent }
        visible: contextModel.count === 0
        width:  600*AppStyle.size1W
        height: width
        Image {
            width:  600*AppStyle.size1W
            height: width*0.781962339
            source: "qrc:/noplace/noplace-"+AppStyle.primaryInt+".svg"
            sourceSize.width: width*2
            sourceSize.height: height*2
            anchors{
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: -30*AppStyle.size1H
            }
        }
        Text{
            text: qsTr("محلی برای انجام کارت نداری")
            font{family: AppStyle.appFont;pixelSize:  40*AppStyle.size1F;bold:true}
            color: AppStyle.textColor
            anchors{
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
        }
    }

    GridView{
        id: gridView

        onContentYChanged: {
            if(contentY<0 || contentHeight < gridView.height)
                contentY = 0
            else if(contentY > (contentHeight - gridView.height))
                contentY = (contentHeight - gridView.height)
        }
        onContentXChanged: {
            if(contentX<0 || contentWidth < gridView.width)
                contentX = 0
            else if(contentX > (contentWidth-gridView.width))
                contentX = (contentWidth-gridView.width)
        }

        anchors{
            top: parent.top
            topMargin: 15*AppStyle.size1H
            right: parent.right
            rightMargin: 20*AppStyle.size1W
            bottom: parent.bottom
            bottomMargin: 15*AppStyle.size1H
            left: parent.left
            leftMargin: 20*AppStyle.size1W
        }
        width: parent.width
        layoutDirection:Qt.RightToLeft
        cellHeight: 150*AppStyle.size1W
        cellWidth: width / (parseInt(width / parseInt(450*AppStyle.size1W))===0?1:(parseInt(width / parseInt(450*AppStyle.size1W))))

        /***********************************************/
        delegate: Rectangle {
            radius: 15*AppStyle.size1W
            width: gridView.cellWidth - 10*AppStyle.size1W
            height:  gridView.cellHeight - 10*AppStyle.size1H
            color: Material.color(AppStyle.primaryInt,Material.Shade50)
            MouseArea{
                anchors.fill: parent
                cursorShape: Qt.OpenHandCursor
                onClicked: {
                    UsefulFunc.mainStackPush("qrc:/Things/ThingList.qml",qsTr("محل انجام")+": "+model.context_name,{listId:Memorito.Contexts,categoryId:model.id,pageTitle:model.context_name})
                }
            }
                Image {
                    id: contextImage
                    source: "qrc:/context.svg"
                    width: height
                    height: 100*AppStyle.size1H
                    sourceSize.width: width*2
                    sourceSize.height: height*2
                    anchors{
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: 10*AppStyle.size1W
                    }
            }

            Text{
                text: context_name
                font{family: AppStyle.appFont;pixelSize:  25*AppStyle.size1F;bold:false}
                anchors{
                    right: contextImage.left
                    rightMargin: 20*AppStyle.size1W
                    verticalCenter: parent.verticalCenter
                    left: menuImg.right
                }
                wrapMode: Text.WordWrap
            }
            Image {
                id: menuImg
                source: "qrc:/dots.svg"
                width: 40*AppStyle.size1W
                height: width
                sourceSize.width: width*2
                sourceSize.height: height*2
                anchors{
                    left: parent.left
                    leftMargin: 5*AppStyle.size1W
                    top: parent.top
                    topMargin: 20*AppStyle.size1W
                }
                MouseArea{
                    anchors.fill: parent
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
                            menuLoader.active = false
                            dialogLoader.active = true
                            dialogLoader.item.contextId = id
                            dialogLoader.item.isAdd = false
                            dialogLoader.item.modelIndex = model.index
                            dialogLoader.item.contextName.text = context_name
                            dialogLoader.item.open()
                        }
                    }
                    AppMenuItem{
                        text: qsTr("حذف")
                        onTriggered: {
                            menuLoader.active = false
                            deleteLoader.active = true
                            deleteLoader.item.contextName = context_name
                            deleteLoader.item.contextId = id
                            deleteLoader.item.modelIndex = model.index
                            deleteLoader.item.open()
                        }
                    }
                }
            }
        }

        /***********************************************/
        model: contextModel
    }

    AppButton{
        text: qsTr("افزودن محل")
        anchors{
            left: parent.left
            leftMargin: 20*AppStyle.size1W
            bottom: parent.bottom
            bottomMargin: 20*AppStyle.size1W
        }
        radius: 20*AppStyle.size1W
        leftPadding: 35*AppStyle.size1W
        rightPadding: 35*AppStyle.size1W
        onClicked: {
            dialogLoader.active = true
            dialogLoader.item.isAdd = true
            dialogLoader.item.open()
        }

        icon.width: 30*AppStyle.size1W
        icon.source:"qrc:/plus.svg"
    }
    Loader{
        id: dialogLoader
        active:false
        sourceComponent: AppDialog{
            id: addDialog
            property bool isAdd: true
            property alias contextName: contextName
            property int contextId : -1
            property int modelIndex: -1
            parent: UsefulFunc.mainPage
            width: 600*AppStyle.size1W
            height: 300*AppStyle.size1H
            onClosed: {
                dialogLoader.active = false
            }
            hasButton: true
            hasCloseIcon: true
            hasTitle: true
            buttonTitle: isAdd?qsTr("اضافه کن"):qsTr("تغییرش بده")
            dialogButton.onClicked:{
                if(contextName.text.trim() !== "")
                {
                    if(isAdd){
                        ContextsApi.addContext(contextName.text.trim(),contextModel)
                    } else {
                        ContextsApi.editContext(contextId,contextName.text.trim(),contextModel,modelIndex)
                    }
                    addDialog.close()
                }
                else {
                    UsefulFunc.showLog(qsTr("لطفا نام محل موردنظر خود را وارد نمایید"),true)
                }
            }
            AppTextField{
                id: contextName
                placeholderText: qsTr("نام محل")
                anchors{
                    right: parent.right
                    rightMargin: 40*AppStyle.size1W
                    left: parent.left
                    leftMargin: 40*AppStyle.size1W
                    top: parent.top
                    topMargin: 30*AppStyle.size1W
                }
                EnterKey.type: Qt.EnterKeyGo
                Keys.onReturnPressed: dialogButton.clicked(Qt.RightButton)
                Keys.onEnterPressed: dialogButton.clicked(Qt.RightButton)
                height: 100*AppStyle.size1H
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
            property string contextName: ""
            property int contextId: -1
            property int modelIndex: -1
            dialogTitle: qsTr("حذف")
            dialogText: qsTr("آیا مایلید که") + " " + contextName + " " + qsTr("را حذف کنید؟")
            accepted: function() {
                ContextsApi.deleteContext(contextId,contextModel,modelIndex)
            }
        }
    }
}
