import QtQuick 
import QtQuick.Controls 
import QtQuick.Controls.Material 
import Qt5Compat.GraphicalEffects

import Memorito.Components
import Memorito.Global

import Memorito.Friends

Item {
    function cameInToPage(object) {
        friendListModel.clear()
        friendListModel.append(friendsModel.getAllFriends())
    }

    FriendsController {
        id: friendsController
    }

    FriendsModel {
        id: friendsModel
    }

    Connections{
        target: friendsController
        function onNewFriendAdded(id)
        {
            friendListModel.append(friendsModel.getFriendById(id))
        }
        function onFriendDeleted(serverId)
        {
            var res = UsefulFunc.findInModel(serverId,"server_id",friendListModel)
            if( res.index>=0 )
                friendListModel.remove(res.index)
        }

        function onFriendUpdated(serverId,friendDetail)
        {
            var res = UsefulFunc.findInModel(serverId,"server_id",friendListModel)
            if( res.index>=0 )
                friendListModel.set(res.index,friendDetail)
        }

        function onFriendSerched(list)
        {
            searchedFriend.clear()
            searchedFriend.append(list)
        }
    }

    ListModel{
        id: searchedFriend
    }

    Item {
        anchors{ centerIn: parent }
        visible: friendListModel.count === 0
        width:  600*AppStyle.size1W
        height: width
        Image {
            width:  600*AppStyle.size1W
            height: width*0.781962339
            source: "qrc:/alone/alone-"+AppStyle.primaryInt+".svg"
            sourceSize.width: width*2
            sourceSize.height: height*2
            anchors{
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: -30*AppStyle.size1H
            }
        }
        Text{
            text: qsTr("هیچ دوستی که اینجا نداری")
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
                UsefulFunc.mainStackPush("qrc:/Things/ThingList.qml",qsTr("دوست")+": "+model.friend_name,{listId:Memorito.Friends,categoryId:model.id,pageTitle:model.friend_name})
            }

            Rectangle{
                id: friendRect

                width: height
                radius: width
                height: 100*AppStyle.size1H
                color: Material.color(AppStyle.primaryInt,Material.Shade50)

                border{
                    color: Material.color(AppStyle.primaryInt,Material.Shade800)
                    width: 3*AppStyle.size1W
                }

                anchors{
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 10*AppStyle.size1W
                }
                Image {
                    id: friendImage
                    source: "qrc:/user.svg"
                    anchors.fill: parent
                    sourceSize.width: width*2
                    sourceSize.height: height*2
                    anchors.margins: friendRect.border.width
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            x: friendRect.x
                            y: friendRect.y
                            width: friendRect.width
                            height: friendRect.height
                            radius: friendRect.radius
                        }
                    }
                }
            }


            Text{
                id: friendNameText
                text: User.id === model.friend1?model.friend2_nickname:model.friend1_nickname
                wrapMode: Text.WordWrap

                font{
                    family: AppStyle.appFont;
                    pixelSize:  25*AppStyle.size1F;
                    bold: true
                }

                anchors{
                    top: friendRect.top
                    topMargin: 10*AppStyle.size1H
                    right: friendRect.left
                    rightMargin: 20*AppStyle.size1W
                    left: menuImg.right
                }
            }
            Text{
                text: {
                    if(model.friend2 > 0){
                        switch(model.friendship_state){
                        case 1:
                            return User.id === model.friend1 ? qsTr("درخواست داده شده")
                                                             : qsTr("درخواست جدید")
                        case 2:
                            return qsTr("دوست ممورتویی")
                        case 3:
                            return qsTr("درخواست رد شد")
                        case 4:
                            return qsTr("بلاک شده")
                        }
                    }
                    else return qsTr("دوست غیرمموریتویی")
                }
                wrapMode: Text.WordWrap

                font{
                    family: AppStyle.appFont;
                    pixelSize:  20*AppStyle.size1F;
                }
                anchors{
                    top: friendNameText.bottom
                    topMargin: 5*AppStyle.size1H
                    right: friendRect.left
                    rightMargin: 20*AppStyle.size1W
                    left: menuImg.right
                }
            }

            Image {
                id: menuImg

                source: "qrc:/dots.svg"
                width: 40*AppStyle.size1W
                height: width
                sourceSize: Qt.size(width,height)

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
                y: menuImg.y + (menuImg.height/2)
                x: menuImg.x + (menuImg.width - 15*AppStyle.size1W)
                sourceComponent: AppMenu{
                    id:menu

                    AppMenu{
                        title: qsTr("درخواست")
                        enabled: model.friend2? true : false;
                        AppMenuItem{
                            text: qsTr("درخواست مجدد")
                            enabled: (model.friendship_state >= 3 ) && User.id === model.friend1
                            onTriggered: {
                                menuLoader.active = false
                                actionLoader.active = true
                                actionLoader.item.actionType = 1
                                actionLoader.item.friendName = (User.id === model.friend1?model.friend2_nickname:model.friend1_nickname)
                                actionLoader.item.friendId = Number(server_id)
                                actionLoader.item.open()
                            }
                        }
                        AppMenuItem{
                            text: qsTr("قبول کردن")
                            enabled: model.friendship_state === 1 && User.id !== model.friend1
                            onTriggered: {
                                menuLoader.active = false
                                actionLoader.active = true
                                actionLoader.item.actionType = 2
                                actionLoader.item.friendName = (User.id === model.friend1?model.friend2_nickname:model.friend1_nickname)
                                actionLoader.item.friendId = Number(server_id)
                                actionLoader.item.open()
                            }
                        }

                        AppMenuItem{
                            text: User.id === model.friend1 ? qsTr("لغو کردن")
                                                            : qsTr("رد کردن")
                            enabled: model.friendship_state === 1
                            onTriggered: {
                                menuLoader.active = false
                                actionLoader.active = true
                                actionLoader.item.actionType = 3
                                actionLoader.item.friendName = (User.id === model.friend1?model.friend2_nickname:model.friend1_nickname)
                                actionLoader.item.friendId = Number(server_id)
                                actionLoader.item.open()
                            }
                        }
//                        AppMenuItem{
//                            text: qsTr("بلاک کردن")
//                            enabled: model.friendship_state !== 4
//                            onTriggered: {
//                                menuLoader.active = false
//                                actionLoader.active = true
//                                actionLoader.item.actionType = 4
//                                actionLoader.item.friendName = (User.id === model.friend1?model.friend2_nickname:model.friend1_nickname)
//                                actionLoader.item.friendId = Number(server_id)
//                                actionLoader.item.open()
//                            }
//                        }
                    }

                    AppMenuItem{
                        text: qsTr("ویرایش")
                        onTriggered: {
                            menuLoader.active = false
                            dialogLoader.active = true
                            dialogLoader.item.friendId = Number(server_id)
                            dialogLoader.item.isAdd = false
                            dialogLoader.item.friendName.text = (User.id === model.friend1?model.friend2_nickname:model.friend1_nickname)
                            dialogLoader.item.open()
                        }
                    }
                    AppMenuItem{
                        text: qsTr("حذف")
                        onTriggered: {
                            menuLoader.active = false
                            actionLoader.active = true
                            actionLoader.item.actionType = 5
                            actionLoader.item.friendName = (User.id === model.friend1?model.friend2_nickname:model.friend1_nickname)
                            actionLoader.item.friendId = Number(server_id)
                            actionLoader.item.open()
                        }
                    }
                }
            }
        }

        /***********************************************/
        model: ListModel{
            id: friendListModel
            dynamicRoles: true
        }
    }

    AppButton{
        text: qsTr("اضافه کردن دوست")
        radius: 20*AppStyle.size1W
        leftPadding: 35*AppStyle.size1W
        rightPadding: 35*AppStyle.size1W

        icon{
            source:"qrc:/plus.svg"
            width: 30*AppStyle.size1W
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
            property alias friendName: friendName
            property int friendId : -1

            parent: UsefulFunc.mainPage
            width: 600*AppStyle.size1W
            height: onlineCheckbox.checked ? 710*AppStyle.size1H
                                           : 410*AppStyle.size1H
            hasButton: true
            hasCloseIcon: true
            hasTitle: true
            buttonTitle: isAdd?qsTr("اضافه کن"):qsTr("تغییرش بده")

            onClosed: {
                dialogLoader.active = false
            }

            dialogButton.onClicked:{
                if(onlineCheckbox.checked)
                {
                    if(searchCombo.currentIndex < 0)
                    {
                        UsefulFunc.showLog(qsTr("دوستتو انتخاب نکردی"),true)
                        return;
                    }
                }
                if(friendName.text.trim() !== "")
                {
                    if(isAdd){
                        friendsController.addNewFriend(User.id,User.username,onlineCheckbox.checked?searchedFriend.get(searchCombo.currentIndex).id:-1,friendName.text.trim())
                    } else {
                        friendsController.editFriend(friendId,friendName.text.trim())
                    }
                    addDialog.close()
                }
                else {
                    UsefulFunc.showLog(qsTr("اسم دوستتو وارد نکردی"),true)
                }
            }
            AppSwitch{
                id: onlineCheckbox
                visible: isAdd
                text: qsTr("دوستم در مموریتو حساب دارد.")
                width: friendName.width
                checked: false
                anchors{
                    top: parent.top
                    topMargin: 25*AppStyle.size1W
                    horizontalCenter: parent.horizontalCenter
                }
            }
            Frame{
                id: frame
                height: visible?300*AppStyle.size1H:0
                visible: onlineCheckbox.checked
                anchors{
                    right: parent.right
                    rightMargin: 40*AppStyle.size1W
                    left: parent.left
                    leftMargin: 40*AppStyle.size1W
                    top: onlineCheckbox.bottom
                    topMargin: 25*AppStyle.size1W
                }

                AppTextInput{
                    id: searchBox
                    placeholderText: qsTr("ایمیل یا نام کاربری دوستت (کامل)")
                    maximumLength: 254
                    fieldInDialog: true
                    height: 100*AppStyle.size1H

                    EnterKey.type: Qt.EnterKeyGo
                    Keys.onEnterPressed:{
                        searchedFriend.clear()
                        friendsController.searchFriend(searchBox.text.trim())
                    }
                    Keys.onReturnPressed: {
                        searchedFriend.clear()
                        friendsController.searchFriend(searchBox.text.trim())
                    }

                    anchors{
                        right: parent.right
                        rightMargin: 40*AppStyle.size1W
                        left: parent.left
                        leftMargin: 40*AppStyle.size1W
                        top: parent.top
                        topMargin: 10*AppStyle.size1H
                    }
                }

                AppComboBox{
                    id: searchCombo
                    placeholderText: searchedFriend.count >0? qsTr("انتخاب کن"):qsTr("جستجو کن")
                    model: searchedFriend
                    currentIndex: searchedFriend.count >0 ? 0:-1
                    onCurrentIndexChanged: {
                        if(currentIndex > -1)
                            friendName.text = searchedFriend.get(currentIndex).username
                        else friendName.clear()
                    }

                    textRole: "username"
                    anchors{
                        right: parent.right
                        rightMargin: 40*AppStyle.size1W
                        left: parent.left
                        leftMargin: 40*AppStyle.size1W
                        top: searchBox.bottom
                        topMargin: 10*AppStyle.size1H
                    }
                }
            }

            AppTextInput{
                id: friendName
                placeholderText: qsTr("نام دوستت")
                fieldInDialog: true
                EnterKey.type: Qt.EnterKeyGo
                height: 120*AppStyle.size1H
                maximumLength: 50
                anchors{
                    right: parent.right
                    rightMargin: 40*AppStyle.size1W
                    left: parent.left
                    leftMargin: 40*AppStyle.size1W
                    top: onlineCheckbox.checked?frame.bottom:onlineCheckbox.bottom
                    topMargin: 15*AppStyle.size1W
                }

                Keys.onReturnPressed: dialogButton.clicked()
                Keys.onEnterPressed: dialogButton.clicked()
            }
        }
    }

    Loader{
        id: actionLoader
        active: false
        sourceComponent: AppConfirmDialog{
            parent: UsefulFunc.mainPage
            onClosed: {
                actionLoader.active = false
            }
            property int actionType
            property int friendId: -1
            property string friendName: ""

            dialogTitle: {
                switch(actionType){
                case 1:
                    return qsTr("درخواست مجدد")
                case 2:
                    return qsTr("قبول کردن")
                case 3:
                    return qsTr("رد کردن")
//                case 4:
//                    return qsTr("بلاک کردن")
                case 5:
                    return qsTr("حذف")
                default:
                    return ""
                }
            }

            dialogText: {
                switch(actionType){
                case 1:
                    return qsTr("مطمئنی می‌خوای به %1 دوباره درخواست بدی؟").arg(friendName)
                case 2:
                    return qsTr("مطمئنی می‌خوای درخواست %1 رو قبول کنی؟").arg(friendName)
                case 3:
                    return qsTr("مطمئنی می‌خوای درخواست %1 رو رد کنی؟").arg(friendName)
//                case 4:
//                    return qsTr("مطمئنی می‌خوای %1 رو بلاک کنی؟").arg(friendName)
                case 5:
                    return qsTr("مطمئنی می‌خوای %1 رو حذف کنی؟").arg(friendName)
                default:
                    return ""
                }
            }

            accepted: function() {
                switch(actionType){
                case 1:
                case 2:
                case 3:
                case 4:
                    friendsController.updateFriendshipState(friendId,actionType)
                    break;
                case 5:
                    friendsController.deleteFriend(friendId)
                    break;
                }
            }
        }
    }
}
