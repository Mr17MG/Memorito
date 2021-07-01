import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtGraphicalEffects 1.15
import Components 1.0 
import Global 1.0

Item {
    property int listId : -1
    ListModel{ id:internalModel }
    Component.onCompleted: {
        if(listId === Memorito.Project)
        {
            internalModel.clear()
            CategoriesApi.getCategories(internalModel,Memorito.Project)
        }
        else if(listId === Memorito.Refrence)
        {
            internalModel.clear()
            CategoriesApi.getCategories(internalModel,Memorito.Refrence)
        }
        else if(listId === Memorito.Someday)
        {
            internalModel.clear()
            CategoriesApi.getCategories(internalModel,Memorito.Someday)
        }
    }
    Item {
        anchors{ centerIn: parent }
        visible: internalModel.count === 0
        width:  600*AppStyle.size1W
        height: 650*AppStyle.size1W
        Image {
            id:nodataImg
            width:  580*AppStyle.size1W
            height: width*0.976816074
            source: "qrc:/nodata/no-data-"+AppStyle.primaryInt+".svg"
            sourceSize.width: width*2
            sourceSize.height: height*2
            anchors{
                horizontalCenter: parent.horizontalCenter
                top: parent.top
            }
        }
        Text{
            text: qsTr("هنوز دسته بندی‌ای ایجاد نکردی.")
            font{family: AppStyle.appFont;pixelSize:  40*AppStyle.size1F;bold:true}
            color: AppStyle.textColor
            anchors{
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                horizontalCenterOffset: 35*AppStyle.size1W
            }
        }
    }

    Loader{
        active: internalModel.count > 0
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
        sourceComponent: GridView{
            id: gridView
            property real lastContentY: 0
            onContentYChanged: {
                if(contentY<0 || contentHeight < gridView.height)
                    contentY = 0
                else if(contentY > (contentHeight - gridView.height))
                {
                    contentY = (contentHeight - gridView.height)
                    lastContentY = contentY-1
                }
                /************* Move Add Button to Down or Up *******************/
                if(contentY > lastContentY)
                    addBtn.anchors.bottomMargin = -60*AppStyle.size1H
                else addBtn.anchors.bottomMargin = 20*AppStyle.size1H

                lastContentY = contentY
            }
            onContentXChanged: {
                if(contentX<0 || contentWidth < gridView.width)
                    contentX = 0
                else if(contentX > (contentWidth-gridView.width))
                    contentX = (contentWidth-gridView.width)

            }
            layoutDirection:Qt.RightToLeft
            cellHeight: 200*AppStyle.size1W
            cellWidth: width / (parseInt(width / parseInt(500*AppStyle.size1W))===0?1:(parseInt(width / parseInt(500*AppStyle.size1W))))

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
                        UsefulFunc.mainStackPush("qrc:/Things/ThingList.qml",(listId === Memorito.Project?qsTr("پروژه"):listId === Memorito.Someday?qsTr("شاید یک‌روزی"):listId === Memorito.Refrence?qsTr("مرجع"):"") +": "+
                                                 model.category_name,{listId:listId,categoryId:model.id,pageTitle:model.category_name})
                    }
                }

                Text{
                    id: categoryText
                    text: category_name
                    font{family: AppStyle.appFont;pixelSize:  25*AppStyle.size1F;bold:true}
                    anchors{
                        top:  parent.top
                        topMargin: 30*AppStyle.size1W
                        right: parent.right
                        rightMargin: 20*AppStyle.size1W
                        left: menuImg.right
                    }
                    wrapMode: Text.WordWrap
                }
                Text{
                    text: (listId ===Memorito.Project?qsTr("هدف پروژه"):qsTr("توضیحات"))  + ": " +((model.category_detail??(listId ===Memorito.Project?qsTr("هدفی"):qsTr("توضیحاتی")) +" "+ qsTr("ثبت نشده است."))) +""
                    font{family: AppStyle.appFont;pixelSize:  23*AppStyle.size1F;}
                    anchors{
                        top:  categoryText.bottom
                        topMargin: 10*AppStyle.size1W
                        right: parent.right
                        rightMargin: 20*AppStyle.size1W
                        left: menuImg.right
                    }
                    wrapMode: Text.WordWrap
                    maximumLineCount: 3
                    elide: AppStyle.ltr?Text.ElideLeft:Text.ElideRight
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
                                menuLoader.active = false
                                dialogLoader.active = true
                                dialogLoader.item.categoryId = id
                                dialogLoader.item.isAdd = false
                                dialogLoader.item.modelIndex = model.index
                                dialogLoader.item.categoryName.text = category_name
                                dialogLoader.item.categoryDetailArea.text =  category_detail
                                dialogLoader.item.open()
                            }
                        }
                        AppMenuItem{
                            text: qsTr("حذف")
                            onTriggered: {
                                menuLoader.active = false
                                deleteLoader.active = true
                                deleteLoader.item.categoryName = category_name
                                deleteLoader.item.categoryId = id
                                deleteLoader.item.modelIndex = model.index
                                deleteLoader.item.open()
                            }
                        }
                    }
                }
            }

            /***********************************************/
            model: internalModel
        }
    }

    AppButton{
        id:addBtn
        text: listId === Memorito.Project?qsTr("اضافه کردن پروژه"):qsTr("اضافه کردن دسته‌بندی")
        anchors{
            left: parent.left
            leftMargin: 20*AppStyle.size1W
            bottom: parent.bottom
            bottomMargin: 20*AppStyle.size1W
        }
        Behavior on anchors.bottomMargin { NumberAnimation{ duration: 200 } }

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
            property alias categoryName: categoryName
            property alias categoryDetailArea: flickTextArea
            property int categoryId : -1
            property int modelIndex: -1
            parent: UsefulFunc.mainPage
            width: 600*AppStyle.size1W
            height: 570*AppStyle.size1H
            onClosed: {
                dialogLoader.active = false
            }
            hasButton: true
            hasCloseIcon: true
            hasTitle: true
            buttonTitle: isAdd?qsTr("اضافه کن"):qsTr("تغییرش بده")
            dialogButton.onClicked:{
                if(categoryName.text.trim() !== "")
                {
                    if(isAdd){
                        CategoriesApi.addCategory(categoryName.text.trim(),categoryDetailArea.text.trim(),listId,internalModel)
                    } else {
                        CategoriesApi.editCategory(categoryId,categoryName.text.trim(),categoryDetailArea.text.trim(),listId,internalModel,modelIndex)
                    }
                    addDialog.close()
                }
                else {
                    UsefulFunc.showLog(qsTr("نام پروژه رو مشخص نکردی."),true)
                }
            }
            AppTextInput{
                id: categoryName
                placeholderText: (listId ===Memorito.Project?qsTr("نام پروژه"):qsTr("نام دسته‌بندی"))
                anchors{
                    right: parent.right
                    rightMargin: 25*AppStyle.size1W
                    left: parent.left
                    leftMargin: 25*AppStyle.size1W
                    top: parent.top
                    topMargin: 30*AppStyle.size1W
                }
                EnterKey.type: Qt.EnterKeyGo
                Keys.onReturnPressed: categoryDetailArea.focus = true
                Keys.onEnterPressed: categoryDetailArea.focus = true
                height: 100*AppStyle.size1H
                filedInDialog: true
                maximumLength: 50
            }
            AppFlickTextArea{
                id:flickTextArea
                anchors{
                    top: categoryName.bottom
                    topMargin: 25*AppStyle.size1H
                    right: parent.right
                    rightMargin: 25*AppStyle.size1W
                    left: parent.left
                    leftMargin: 25*AppStyle.size1W
                }
                height: 250*AppStyle.size1W
                placeholderText: (listId ===Memorito.Project?qsTr("هدف پروژه"):qsTr("توضیحات دسته‌بندی")) + " ("+qsTr("اختیاری")+")"
                areaInDialog : true
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
            property string categoryName: ""
            property int categoryId: -1
            property int modelIndex: -1
            dialogTitle: qsTr("حذف")
            dialogText: qsTr("مایلی که") + " '" + categoryName + "' " + qsTr("رو حذف کنی؟")
            accepted: function() {
                CategoriesApi.deleteCategory(categoryId,internalModel,modelIndex)
            }
        }
    }
}
