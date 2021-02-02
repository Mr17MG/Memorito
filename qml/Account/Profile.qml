import QtQuick 2.14
import QtQml 2.15
import QtGraphicalEffects 1.14
import QtQuick.Controls.Material 2.14
import QtQuick.Controls 2.14
import QtQuick.Dialogs 1.3
import Components 1.0
import Global 1.0
import MTools 1.0

Item {
    property bool isEditable: false
    property bool modified: false
    MTools{id:myTools}
    Loader{
        id:fileLoader
        active: false
        sourceComponent: FileDialog{
            id:fileDialog
            selectMultiple: false
            title: qsTr("لطفا فایل‌های خود را انتخاب نمایید")
            nameFilters: [ "All Images (*.png *.jpeg *jpg)" ]
            folder: shortcuts.pictures
            sidebarVisible: false
            onAccepted: {
                let file = fileDialog.fileUrl;
                UsefulFunc.mainStackPush("qrc:/Components/ImageEditor.qml",qsTr("ویرایش‌گر تصویر"),{imageSource:file})
                fileLoader.active = false
            }
            onRejected: {
                fileLoader.active = false
            }
        }
    }
    function cameBackToPage(object)
    {
        if(object)
        {
            let json = JSON.stringify(
                    {
                        avatar : object.base64,
                        two_step : User.twoStep,
                    }, null, 1);

            UserApi.editUser(User.id,json)
        }
    }

    Rectangle{
        id: root
        width: 250*AppStyle.size1W
        height: width
        radius: width
        anchors{
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 15*AppStyle.size1H
        }
        border.color: Material.color(AppStyle.primaryInt)
        border.width: 5*AppStyle.size1W
        Binding{
            target: profileImage
            property: "source"
            value: User.profile
            when: User.isSet
            restoreMode: Binding.RestoreBindingOrValue
        }
        Image {
            id: profileImage
            anchors{
                fill: parent
                margins: root.border.width
            }
            cache: false
            asynchronous: true
            sourceSize.width: parent.width*4
            sourceSize.height: parent.height*4
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    x: root.x
                    y: root.y
                    width: root.width
                    height: root.height
                    radius: root.radius
                }
            }
            onSourceChanged: {
                if(modified===false && isEditable)
                    modified=true
            }
        }
        MouseArea{
            anchors.fill: parent
            enabled: isEditable
            cursorShape:Qt.PointingHandCursor
            onClicked: {
                fileLoader.active = true
                fileLoader.item.open()
            }
        }
    }

    Item{
        id:usernameItem
        width: parent.width/3*2
        height: 100*AppStyle.size1H
        anchors{
            top: root.bottom
            topMargin: 20*AppStyle.size1H
            horizontalCenter: parent.horizontalCenter
        }

        SequentialAnimation {
            id:usernameMoveAnimation
            running: false
            loops: 3
            NumberAnimation { target: usernameItem; property: "anchors.horizontalCenterOffset"; to: -10; duration: 50}
            NumberAnimation { target: usernameItem; property: "anchors.horizontalCenterOffset"; to: 10; duration: 100}
            NumberAnimation { target: usernameItem; property: "anchors.horizontalCenterOffset"; to: 0; duration: 50}
        }

        AppTextField{
            id:usernameInput
            width: parent.width
            height: 100*AppStyle.size1H
            enabled: isEditable
            anchors.bottom: parent.bottom
            inputMethodHints: Qt.ImhPreferLowercase
            placeholderText: qsTr("نام کاربری")
            text: User.username
            validator: RegExpValidator{regExp: /[A-Za-z0-9_.]{50}/}
            EnterKey.type: Qt.EnterKeyNext
            Keys.onEnterPressed:  emailInput.forceActiveFocus()
            Keys.onReturnPressed:  emailInput.forceActiveFocus()
            onEditingFinished: {
                if(modified===false && text.trim()!==User.username)
                    modified=true
            }
        }
    }
    Item{
        id:emailItem
        width: parent.width/3*2
        height: 100*AppStyle.size1H
        anchors{
            top: usernameItem.bottom
            horizontalCenter: parent.horizontalCenter
        }
        SequentialAnimation {
            id:emailMoveAnimation
            running: false
            loops: 3
            NumberAnimation { target: emailItem; property: "anchors.horizontalCenterOffset"; to: -10; duration: 50}
            NumberAnimation { target: emailItem; property: "anchors.horizontalCenterOffset"; to: 10; duration: 100}
            NumberAnimation { target: emailItem; property: "anchors.horizontalCenterOffset"; to: 0; duration: 50}
        }
        AppTextField{
            id:emailInput
            width: parent.width
            height: 100*AppStyle.size1H
            enabled: isEditable
            anchors.bottom: parent.bottom
            inputMethodHints: Qt.ImhEmailCharactersOnly
            placeholderText: qsTr("ایمیل")
            text: User.email
            validator: RegExpValidator{regExp: /[A-Za-z0-9_]*/}
            EnterKey.type: Qt.EnterKeyGo
            Keys.onEnterPressed:  edit.forceActiveFocus()
            Keys.onReturnPressed:  edit.forceActiveFocus()
            onEditingFinished: {
                if(modified===false && text.trim()!==User.email)
                    modified=true
            }
        }
    }
    AppButton{
        id: edit
        height: AppStyle.size1H*75
        width: usernameItem.width
        anchors{
            top: emailItem.bottom
            topMargin: AppStyle.size1H*20
            horizontalCenter: parent.horizontalCenter
        }
        flat: true
        Material.background: isEditable? AppStyle.primaryInt:"transparent"
        radius: AppStyle.size1W*20
        text: isEditable?qsTr("بروزرسانی اطلاعات"):qsTr("ویرایش اطلاعات")
        font { family: AppStyle.appFont; pixelSize: AppStyle.size1F*30;bold:true}
        Material.foreground: isEditable? AppStyle.textOnPrimaryColor:AppStyle.textColor
        onClicked: {
            usernameInput.focus = false
            if(!modified)
            {
                isEditable = !isEditable;
                return
            }

            if(usernameInput.text.trim()==="" || emailInput.text.trim()==="")
            {
                UsefulFunc.showLog(qsTr("اطلاعات وارد شده صحیح نمی‌باشد."),true)
                if(usernameInput.text.trim()==="")
                    usernameMoveAnimation.start()
                if(emailInput.text.trim()==="")
                    emailMoveAnimation.start()
                return
            }
            isEditable = !isEditable;
            if(!isEditable){
                modified=false
            }
        }
    }
    AppButton{
        id: logoutBtn
        height: AppStyle.size1H*75
        width: 300*AppStyle.size1W
        anchors{
            bottom: parent.bottom
            bottomMargin: 20*AppStyle.size1H
            right: parent.right
            rightMargin: 30*AppStyle.size1W
        }
        flat: !isEditable
        enabled: isEditable
        radius: AppStyle.size1W*20
        text: qsTr("خروج از حساب")
        font { family: AppStyle.appFont; pixelSize: AppStyle.size1F*30;bold:true}
        onClicked: {
            UsefulFunc.showConfirm(
                        qsTr("خروج از حساب"),
                        qsTr("آیا مطمئن هستید که می‌خواهید از حساب خود خارج شوید؟"),
                        function()
                        {
                            myTools.deleteSaveDir();
                            UsefulFunc.mainLoader.source = "qrc:/Account/AccountMain.qml"
                            SettingDriver.setValue("last_date","")
                            User.clear()
                        }
                        )
        }
    }

}
