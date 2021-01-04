import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import "qrc:/Components/" as App
import QtGraphicalEffects 1.14
import MEnum 1.0

Item {
    CategoryApi{id: categoryApi}
    property int listId : -1
    Component.onCompleted: {
        if(listId === Memorito.Project)
        {
            projectModel.clear()
            categoryApi.getCategories(projectCategoryModel,Memorito.Project)
        }
        else if(listId === Memorito.Refrence)
        {
            refrenceModel.clear()
            categoryApi.getCategories(refrenceCategoryModel,Memorito.Refrence)
        }
        else if(listId === Memorito.Someday)
        {
            somedayModel.clear()
            categoryApi.getCategories(somedayCategoryModel,Memorito.Someday)
        }
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
        cellHeight: 200*size1W
        cellWidth: width / (parseInt(width / parseInt(500*size1W))===0?1:(parseInt(width / parseInt(500*size1W))))

        /***********************************************/
        delegate: Rectangle {
            radius: 15*size1W
            width: control.cellWidth - 10*size1W
            height:  control.cellHeight - 10*size1H
            color: Material.color(appStyle.primaryInt,Material.Shade50)
            MouseArea{
                anchors.fill: parent
                cursorShape: Qt.OpenHandCursor
                onClicked: {
                    usefulFunc.mainStackPush("qrc:/Flow/NextAction.qml",(listId === Memorito.Project?qsTr("پروژه"):listId === Memorito.Someday?qsTr("شاید یک‌روزی"):listId === Memorito.Refrence?qsTr("مرجع"):"") +": "+
                                             model.category_name,{listId:listId,categoryId:model.id,pageTitle:model.category_name})
                }
            }

            Text{
                id: categoryText
                text: category_name
                font{family: appStyle.appFont;pixelSize:  25*size1F;bold:true}
                anchors{
                    top:  parent.top
                    topMargin: 30*size1W
                    right: parent.right
                    rightMargin: 20*size1W
                    left: menuImg.right
                }
                wrapMode: Text.WordWrap
            }
            Text{
                text: (listId ===Memorito.Project?qsTr("هدف پروژه"):qsTr("توضیحات"))  + ": <b>" +(listId ===Memorito.Project?qsTr("هدفی"):qsTr("توضیحاتی")) +" "+ (model.category_detail?? qsTr("ثبت نشده است")) +"</b>"
                font{family: appStyle.appFont;pixelSize:  23*size1F;}
                anchors{
                    top:  categoryText.bottom
                    topMargin: 10*size1W
                    right: parent.right
                    rightMargin: 20*size1W
                    left: menuImg.right
                }
                wrapMode: Text.WordWrap
                maximumLineCount: 3
                elide: ltr?Text.ElideLeft:Text.ElideRight
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
                    anchors{
                        fill: parent
                        topMargin: -10*size1H
                        bottomMargin: -10*size1H
                        rightMargin: -10*size1W
                        leftMargin: -10*size1W
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
                x: menuImg.x + (menuImg.width - 15*size1W)
                y: menuImg.y + (menuImg.height/2)
                sourceComponent: App.Menu{
                    id:menu
                    App.MenuItem{
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
                    App.MenuItem{
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
        model: listId === Memorito.Project?projectCategoryModel:listId === Memorito.Someday?somedayCategoryModel:listId === Memorito.Refrence?refrenceCategoryModel:[]
    }

    App.Button{
        text: listId === Memorito.Project?qsTr("افزودن پروژه"):qsTr("افزودن دسته‌بندی")
        anchors{
            left: parent.left
            leftMargin: 20*size1W
            bottom: parent.bottom
            bottomMargin: 20*size1W
        }
        radius: 20*size1W
        width: 275*size1W
        leftPadding: 35*size1W
        onClicked: {
            dialogLoader.active = true
            dialogLoader.item.isAdd = true
            dialogLoader.item.open()
        }

        Image {
            id:submitIcon
            width: 30*size1W
            height: width
            source: "qrc:/plus.svg"
            anchors{
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: 30*size1W
            }
            sourceSize.width:width*2
            sourceSize.height:height*2
            visible: false
        }
        ColorOverlay{
            anchors.fill: submitIcon
            source: submitIcon
            color: "white"
        }
    }
    Loader{
        id: dialogLoader
        active:false
        sourceComponent: App.Dialog{
            id: addDialog
            property bool isAdd: true
            property alias categoryName: categoryName
            property alias categoryDetailArea: flickTextArea
            property int categoryId : -1
            property int modelIndex: -1
            parent: mainColumn
            width: 600*size1W
            height: 570*size1H
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
                        categoryApi.addCategory(categoryName.text.trim(),categoryDetailArea.text.trim(),listId,projectCategoryModel)
                    } else {
                        categoryApi.editCategory(categoryId,categoryName.text.trim(),categoryDetailArea.text.trim(),listId,projectCategoryModel,modelIndex)
                    }
                    addDialog.close()
                }
                else {
                    usefulFunc.showLog(qsTr("لطفا نام پروژه خود را وارد نمایید"),true,null,400*size1W, ltr)
                }
            }
            App.TextInput{
                id: categoryName
                placeholderText: (listId ===Memorito.Project?qsTr("نام پروژه"):qsTr("نام دسته‌بندی"))
                anchors{
                    right: parent.right
                    rightMargin: 25*size1W
                    left: parent.left
                    leftMargin: 25*size1W
                    top: parent.top
                    topMargin: 30*size1W
                }
                EnterKey.type: Qt.EnterKeyGo
                Keys.onReturnPressed: categoryDetailArea.focus = true
                Keys.onEnterPressed: categoryDetailArea.focus = true
                height: 100*size1H
                filedInDialog: true
                maximumLength: 50
            }
            App.FlickTextArea{
                id:flickTextArea
                anchors{
                    top: categoryName.bottom
                    topMargin: 25*size1H
                    right: parent.right
                    rightMargin: 25*size1W
                    left: parent.left
                    leftMargin: 25*size1W
                }
                placeholderText: (listId ===Memorito.Project?qsTr("هدف پروژه"):qsTr("توضیحات دسته‌بندی")) + " ("+qsTr("اختیاری")+")"
                areaInDialog : true
            }
        }
    }

    Loader{
        id: deleteLoader
        active: false
        sourceComponent: App.ConfirmDialog{
            parent: mainColumn
            onClosed: {
                deleteLoader.active = false
            }
            property string categoryName: ""
            property int categoryId: -1
            property int modelIndex: -1
            dialogTitle: qsTr("حذف")
            dialogText: qsTr("آیا مایلید که") + " '" + categoryName + "' " + qsTr("را حذف کنید؟")
            accepted: function() {
                categoryApi.deleteCategory(categoryId,projectCategoryModel,modelIndex)
            }
        }
    }
}
