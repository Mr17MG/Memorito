import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import "qrc:/Components/" as App
import QtGraphicalEffects 1.1

Item {
    ContextsApi{id:api}
    Component.onCompleted: {
        api.getContexts(contextModel)
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
        cellHeight: 150*size1W
        cellWidth: width / (parseInt(width / parseInt(450*size1W))===0?1:(parseInt(width / parseInt(450*size1W))))

        /***********************************************/
        delegate: Rectangle {
            radius: 15*size1W
            width: gridView.cellWidth - 10*size1W
            height:  gridView.cellHeight - 10*size1H
            color: Material.color(appStyle.primaryInt,Material.Shade50)
                Image {
                    id: contextImage
                    source: "qrc:/context.svg"
                    width: height
                    height: 100*size1H
                    sourceSize.width: width*2
                    sourceSize.height: height*2
                    anchors{
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: 10*size1W
                    }
            }

            Text{
                text: context_name
                font{family: appStyle.appFont;pixelSize:  25*size1F;bold:false}
                anchors{
                    right: contextImage.left
                    rightMargin: 20*size1W
                    verticalCenter: parent.verticalCenter
                    left: menuImg.right
                }
                wrapMode: Text.WordWrap
            }
            Image {
                id: menuImg
                source: "qrc:/dots.svg"
                width: 40*size1W
                height: width
                sourceSize.width: width*2
                sourceSize.height: height*2
                anchors{
                    left: parent.left
                    leftMargin: 5*size1W
                    top: parent.top
                    topMargin: 20*size1W
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
                x: menuImg.x + (menuImg.width - 15*size1W)
                y: menuImg.y + (menuImg.height/2)
                sourceComponent: App.Menu{
                    id:menu
                    App.MenuItem{
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
                    App.MenuItem{
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

    App.Button{
        text: qsTr("افزودن زمینه")
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
            dialogLoader.active = true
            dialogLoader.item.isAdd = true
            dialogLoader.item.open()
        }

        icon.width: 30*size1W
        icon.source:"qrc:/plus.svg"
    }
    Loader{
        id: dialogLoader
        active:false
        sourceComponent: App.Dialog{
            id: addDialog
            property bool isAdd: true
            property alias contextName: contextName
            property int contextId : -1
            property int modelIndex: -1
            parent: mainPage
            width: 600*size1W
            height: 300*size1H
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
                        api.addContext(contextName.text.trim(),contextModel)
                    } else {
                        api.editContext(contextId,contextName.text.trim(),contextModel,modelIndex)
                    }
                    addDialog.close()
                }
                else {
                    usefulFunc.showLog(qsTr("لطفا نام زمینه موردنظر خود را وارد نمایید"),true,400*size1W)
                }
            }
            App.TextField{
                id: contextName
                placeholderText: qsTr("نام زمینه")
                anchors{
                    right: parent.right
                    rightMargin: 40*size1W
                    left: parent.left
                    leftMargin: 40*size1W
                    top: parent.top
                    topMargin: 30*size1W
                }
                EnterKey.type: Qt.EnterKeyGo
                Keys.onReturnPressed: dialogButton.clicked(Qt.RightButton)
                Keys.onEnterPressed: dialogButton.clicked(Qt.RightButton)
                height: 100*size1H
            }

        }
    }

    Loader{
        id: deleteLoader
        active: false
        sourceComponent: App.ConfirmDialog{
            parent: mainPage
            onClosed: {
                deleteLoader.active = false
            }
            property string contextName: ""
            property int contextId: -1
            property int modelIndex: -1
            dialogTitle: qsTr("حذف")
            dialogText: qsTr("آیا مایلید که") + " " + contextName + " " + qsTr("را حذف کنید؟")
            accepted: function() {
                api.deleteContext(contextId,contextModel,modelIndex)
            }
        }
    }
}
