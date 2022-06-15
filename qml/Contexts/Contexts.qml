import QtQuick 
import QtQuick.Controls 
import QtQuick.Controls.Material 
import Memorito.Components
import Memorito.Global
import Memorito.Contexts

Item {
    function cameInToPage(object) {
        if(Constants.contextsListModel.count === 0)
            Constants.contextsListModel.append(contextsModel.getAllContexts())
    }

    ContextsModel{
        id: contextsModel
    }
    ContextsController{
        id: contextsController
    }

    Connections{
        target: contextsController
        function onNewContextAdded(id)
        {
            Constants.contextsListModel.append(contextsModel.getContextByLocalId(id))
        }
        function onContextDeleted(serverId)
        {
            var res = UsefulFunc.findInModel(serverId,"server_id",Constants.contextsListModel)
            if( res.index>=0 )
                Constants.contextsListModel.remove(res.index)
        }

        function onContextUpdated(serverId,contextName)
        {
            var res = UsefulFunc.findInModel(serverId,"server_id",Constants.contextsListModel)
            if( res.index>=0 )
                Constants.contextsListModel.setProperty(res.index,"context_name",contextName)
        }
    }

    Item {
        height: width
        width:  600*AppStyle.size1W
        visible: Constants.contextsListModel.count === 0
        anchors {
            centerIn: parent
        }
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

        width: parent.width
        layoutDirection:Qt.RightToLeft
        cellHeight: 150*AppStyle.size1W
        cellWidth: width / (parseInt(width / parseInt(450*AppStyle.size1W))===0?1:(parseInt(width / parseInt(450*AppStyle.size1W))))

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

        displaced: Transition {
            NumberAnimation { properties: "x,y"; duration: 200 }
        }

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

        /***********************************************/
        delegate: AppButton {
            radius: 15*AppStyle.size1W
            width: gridView.cellWidth - 10*AppStyle.size1W
            height:  gridView.cellHeight - 10*AppStyle.size1H
            Material.background: Material.color(AppStyle.primaryInt,Material.Shade50)

            onClicked: {
                UsefulFunc.mainStackPush("qrc:/Things/ThingList.qml",qsTr("محل انجام")+": "+model.context_name,{listId:Memorito.Contexts,categoryId:model.id,pageTitle:model.context_name})
            }

            Image {
                id: contextImage
                source: "qrc:/context.svg"
                width: height
                height: 100*AppStyle.size1H
                sourceSize: Qt.size(width,height)
                anchors{
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 10*AppStyle.size1W
                }
            }

            Text{
                text: model.context_name
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
                            dialogLoader.item.contextId = model.server_id
                            dialogLoader.item.isAdd = false
                            dialogLoader.item.modelIndex = model.index
                            dialogLoader.item.contextName.text = model.context_name
                            dialogLoader.item.open()
                        }
                    }
                    AppMenuItem{
                        text: qsTr("حذف")
                        onTriggered: {
                            menuLoader.active = false
                            deleteLoader.active = true
                            deleteLoader.item.contextName = model.context_name
                            deleteLoader.item.contextId = model.server_id
                            deleteLoader.item.modelIndex = model.index
                            deleteLoader.item.open()
                        }
                    }
                }
            }
        }

        /***********************************************/
        model: Constants.contextsListModel
    }

    AppButton{
        text: qsTr("افزودن محل")
        radius: 20*AppStyle.size1W
        leftPadding: 35*AppStyle.size1W
        rightPadding: 35*AppStyle.size1W

        icon {
            width: 30*AppStyle.size1W
            source:"qrc:/plus.svg"
        }

        anchors{
            left: parent.left
            leftMargin: 20*AppStyle.size1W
            bottom: parent.bottom
            bottomMargin: 20*AppStyle.size1W
        }

        onClicked: {
            dialogLoader.active = true
            dialogLoader.item.isAdd = true
            dialogLoader.item.open()
        }
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
            height: 350*AppStyle.size1H
            hasButton: true
            hasCloseIcon: true
            hasTitle: true
            buttonTitle: isAdd?qsTr("اضافه کن"):qsTr("تغییرش بده")

            onClosed: {
                dialogLoader.active = false
            }

            dialogButton.onClicked:{
                if(contextName.text.trim() !== "")
                {
                    if(isAdd){
                        contextsController.addNewContext(contextName.text.trim())
                    } else {
                        contextsController.editContext(contextId,contextName.text.trim())
                    }
                    addDialog.close()
                }
                else {
                    UsefulFunc.showLog(qsTr("لطفا نام محل موردنظرتو وارد کن"),true)
                }
            }

            AppTextInput{
                id: contextName

                placeholderText: qsTr("نام محل")
                EnterKey.type: Qt.EnterKeyGo
                Keys.onReturnPressed: dialogButton.clicked()
                Keys.onEnterPressed: dialogButton.clicked()
                height: 120*AppStyle.size1H
                maximumLength: 25
                fieldInDialog: true

                anchors{
                    right: parent.right
                    rightMargin: 40*AppStyle.size1W
                    left: parent.left
                    leftMargin: 40*AppStyle.size1W
                    top: parent.top
                    topMargin: 45*AppStyle.size1W
                }
            }

        }
    }

    Loader {
        id: deleteLoader
        active: false
        sourceComponent: AppConfirmDialog{

            property string contextName: ""
            property int contextId: -1
            property int modelIndex: -1

            parent: UsefulFunc.mainPage
            dialogTitle: qsTr("حذف")
            dialogText: qsTr("مایلی که") + " " + contextName + " " + qsTr("رو حذف کنی؟")

            accepted: function() {
                contextsController.deleteContext(contextId)
            }

            onClosed: {
                deleteLoader.active = false
            }
        }
    }
}
