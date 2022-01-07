import QtQuick 
import QtQml 
import Qt5Compat.GraphicalEffects

import QtQuick.Controls.Material 
import QtQuick.Controls 
import QtQuick.Dialogs
import Memorito.Components
import Memorito.Global
import Memorito.Tools

Item {
    MTools{id:myTools}
    property bool modified: false

    function checkModify()
    {
        if(usernameInput.text.trim() === User.username && emailInput.text.trim() === User.email &&  Number(twoStepCheckbox.checked) === User.twoStep)
        {
            return modified = false;

        }
        return modified = true;
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

    Loader{
        id:fileLoader
        active: false
        sourceComponent: AppFilePicker{
            id:fileDialog
            selectMultiple: false
            width:UsefulFunc.rootWindow.width
            height: UsefulFunc.rootWindow.height
            parent: UsefulFunc.mainLoader
            x:0
            y:0
            title: qsTr("عکستو انتخاب کن")
            nameFilters: [ "*.png","*.jpeg","*.jpg" ]
            onAccepted: {
                let file = fileDialog.fileUrls[0];
                UsefulFunc.mainStackPush("qrc:/Memorito/Components/ImageEditor.qml",qsTr("ویرایش‌گر تصویر"),{imageSource:file})
                fileLoader.active = false
            }
            onRejected: {
                fileLoader.active = false
            }
        }
    }


    Flickable{
        clip: true
        contentHeight: flow1.height + 150*AppStyle.size1H
        anchors.fill: parent
        Rectangle{
            anchors{
                top: flow1.top
                bottom: flow1.bottom
                bottomMargin: -50*AppStyle.size1H
                left: flow1.left
                right: flow1.right
            }
            color: Material.color(AppStyle.primaryInt,Material.Shade50)
            opacity: AppStyle.appTheme?0.2:0.5
            border{
                color: Material.color(AppStyle.primaryInt,Material.Shade100)
                width: 4*AppStyle.size1W
            }
            radius: 100*AppStyle.size1W
        }
        Flow{
            id:flow1
            spacing: 30*AppStyle.size1H
            width: Math.min(parent.width - 50 * AppStyle.size1H, 800*AppStyle.size1W)
            anchors{
                top: parent.top
                topMargin: 50*AppStyle.size1H
                horizontalCenter: parent.horizontalCenter
            }
            Item{
                width: parent.width
                height: 600*AppStyle.size1W
                Rectangle{
                    id: root
                    width: 500*AppStyle.size1W>parent.width-100*AppStyle.size1W?parent.width-100*AppStyle.size1W:500*AppStyle.size1W
                    height: width
                    radius: height
                    anchors.centerIn: parent
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
                        sourceSize: Qt.size(width*4.,height*4)
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
                    }
                    MouseArea{
                        anchors.fill: parent
                        cursorShape:Qt.PointingHandCursor
                        onClicked: {
                            fileLoader.active = true
                            fileLoader.item.open()
                        }
                    }
                }
            }

            Item{
                id:usernameItem
                width: parent.width
                height: 100*AppStyle.size1H
                SequentialAnimation {
                    id:usernameMoveAnimation
                    running: false
                    loops: 3
                    NumberAnimation { target: usernameInput; property: "anchors.horizontalCenterOffset"; to: -10; duration: 50}
                    NumberAnimation { target: usernameInput; property: "anchors.horizontalCenterOffset"; to: 10; duration: 100}
                    NumberAnimation { target: usernameInput; property: "anchors.horizontalCenterOffset"; to: 0; duration: 50}
                }

                AppTextField{
                    id:usernameInput
                    width: parent.width- 100*AppStyle.size1W
                    height: 100*AppStyle.size1H
                    anchors{
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                    inputMethodHints: Qt.ImhPreferLowercase
                    placeholderText: qsTr("نام کاربری")
                    text: User.username
                    validator: RegularExpressionValidator{regularExpression: /[A-Za-z][A-Za-z0-9_.]{50}/}
                    EnterKey.type: Qt.EnterKeyNext
                    Keys.onEnterPressed:  emailInput.forceActiveFocus()
                    Keys.onReturnPressed:  emailInput.forceActiveFocus()
                    onTextEdited: {
                        checkModify()
                    }
                }
            }


            Item{
                id:emailItem
                width: parent.width
                height: 100*AppStyle.size1H
                SequentialAnimation {
                    id:emailMoveAnimation
                    running: false
                    loops: 3
                    NumberAnimation { target: emailInput; property: "anchors.horizontalCenterOffset"; to: -10; duration: 50}
                    NumberAnimation { target: emailInput; property: "anchors.horizontalCenterOffset"; to: 10; duration: 100}
                    NumberAnimation { target: emailInput; property: "anchors.horizontalCenterOffset"; to: 0; duration: 50}
                }
                AppTextField{
                    id:emailInput
                    width: parent.width- 100*AppStyle.size1W
                    height: 100*AppStyle.size1H
                    anchors{
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                    inputMethodHints: Qt.ImhEmailCharactersOnly
                    placeholderText: qsTr("ایمیل")
                    text: User.email
                    validator: RegularExpressionValidator{regularExpression: /[A-Za-z0-9_]*/}
                    EnterKey.type: Qt.EnterKeyGo
                    Keys.onEnterPressed:  edit.forceActiveFocus()
                    Keys.onReturnPressed:  edit.forceActiveFocus()
                    onTextEdited: {
                        checkModify()
                    }
                }
            }

            AppCheckBox{
                width: parent.width
                id: twoStepCheckbox
                height: 100*AppStyle.size1H
                checked: User.twoStep
                text: qsTr("تائید دو مرحله‌ای")
                spacing: 20*AppStyle.size1W
                font { family: AppStyle.appFont; pixelSize: AppStyle.size1F*30;bold:true}
                rightPadding: 50*AppStyle.size1W
                leftPadding: 50*AppStyle.size1W
                onCheckedChanged: {
                    checkModify()
                }
            }

            Item{
                width: parent.width
                height: 120*AppStyle.size1H
                AppButton{
                    id: edit
                    enabled: modified
                    height: 100*AppStyle.size1H
                    width: usernameInput.width
                    radius: AppStyle.size1W*50
                    text: qsTr("بروزرسانی اطلاعات")
                    anchors.centerIn: parent
                    contentMirorred: !AppStyle.ltr
                    font { family: AppStyle.appFont; pixelSize: AppStyle.size1F*30;bold:true}
                    icon{
                        source: "qrc:/check-circle.svg"
                        width: AppStyle.size1W*50
                        height: AppStyle.size1W*50
                    }
                    onClicked: {
                        if(!modified)
                            return

                        if(usernameInput.text.trim()==="" || emailInput.text.trim()==="")
                        {
                            UsefulFunc.showLog(qsTr("نام کاربری یا ایمیل نباید خالی باشه."),true)
                            if(usernameInput.text.trim()==="")
                                usernameMoveAnimation.start()
                            if(emailInput.text.trim()==="")
                                emailMoveAnimation.start()
                            return
                        }

                        if(UsefulFunc.emailValidation(emailInput.text) === false)
                        {
                            emailMoveAnimation.start()
                            emailInput.forceActiveFocus()
                            UsefulFunc.showLog(qsTr("ایمیلی که نوشتی درست نیست."),true)
                            return
                        }

                        let json = JSON.stringify(
                                {
                                    two_step : Number(twoStepCheckbox.checked),
                                    username : usernameInput.text.trim(),
                                    email : emailInput.text.trim()
                                }, null, 1);

                        UserApi.editUser(User.id,json)
                    }
                }
            }
            AppButton{
                id: password
                width: parent.width
                height: 100*AppStyle.size1H
                radius: AppStyle.size1W*50
                text: qsTr("تغییر رمز ورود")
                rightPadding: 50*AppStyle.size1W
                horizontalAlignment: Qt.AlignRight
                flat: true
                leftPadding: 50*AppStyle.size1W
                contentMirorred: AppStyle.ltr
                font { family: AppStyle.appFont; pixelSize: AppStyle.size1F*30;bold:true}
                icon{
                    source: contentMirorred?"qrc:/next.svg":"qrc:/previous.svg"
                    color: AppStyle.textColor
                    width: AppStyle.size1W*20
                    height: AppStyle.size1W*20
                }
                onClicked: {
                    UsefulFunc.showConfirm(
                                qsTr("تغییر رمز ورود"),
                                qsTr("مطمئنی که میخوای رمز وردتو تغییر بدی؟"),
                                function()
                                {
                                    UserApi.forgetPass(User.username,true)

                                }
                                )
                }
            }


            AppButton{
                id: logoutBtn
                height: AppStyle.size1H*75
                width: parent.width
                radius: AppStyle.size1W*50
                text: qsTr("خروج از حساب")
                rightPadding: 50*AppStyle.size1W
                leftPadding: 50*AppStyle.size1W
                contentMirorred: AppStyle.ltr
                horizontalAlignment: Qt.AlignRight
                flat: true
                font { family: AppStyle.appFont; pixelSize: AppStyle.size1F*30;bold:true}
                icon{
                    source: contentMirorred?"qrc:/next.svg":"qrc:/previous.svg"
                    color: AppStyle.textColor
                    width: AppStyle.size1W*20
                    height: AppStyle.size1W*20
                }
                onClicked: {
                    UsefulFunc.showConfirm(
                                qsTr("خروج از حساب"),
                                qsTr("مطمئنی که میخوای از حسابت بری بیرون؟"),
                                function()
                                {
                                    myTools.deleteSaveDir();
                                    UsefulFunc.mainLoader.source = "qrc:/Account/AccountMain.qml"
                                    SettingDriver.setValue("last_date","")
                                    User.clear()
                                    UsefulFunc.stackPages.clear()
                                }
                                )
                }
            }
            AppButton{
                id: deleteBtn
                height: AppStyle.size1H*75
                width: parent.width
                radius: AppStyle.size1W*50
                text: qsTr("حذف حساب کاربری")
                rightPadding: 50*AppStyle.size1W
                leftPadding: 50*AppStyle.size1W
                contentMirorred: AppStyle.ltr
                horizontalAlignment: Qt.AlignRight
                flat: true
                font { family: AppStyle.appFont; pixelSize: AppStyle.size1F*30;bold:true}
                icon{
                    source: contentMirorred?"qrc:/next.svg":"qrc:/previous.svg"
                    color: AppStyle.textColor
                    width: AppStyle.size1W*20
                    height: AppStyle.size1W*20
                }
                onClicked: {
                    deleteAccountDialog.open()

                }
            }

            AppDialog{
                id: deleteAccountDialog
                hasButton: true
                buttonTitle: qsTr("حذف کن")
                hasCloseIcon: true
                height: AppStyle.size1H*550
                width: 600*AppStyle.size1W
                parent: UsefulFunc.mainLoader
                dialogButton.onClicked: {
                    if(passwordInput.text.trim())
                        UserApi.deleteAccount(passwordInput.text.trim())
                }

                Text{
                    id: titleText
                    color: AppStyle.textColor
                    text: qsTr("واقعا میخوای حسابتو حذف کنی؟!")
                    font { family: AppStyle.appFont; pixelSize: AppStyle.size1F*30;bold:true}
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                    anchors{
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 40*AppStyle.size1W
                    }
                }
                Item{
                    id: passwordItem
                    height: 100*AppStyle.size1H
                    anchors{
                        left: parent.left
                        right: parent.right
                        top: titleText.bottom
                        margins: 25*AppStyle.size1W
                        topMargin: 35*AppStyle.size1W
                    }
                    AppTextInput{
                        id: passwordInput
                        placeholderText: qsTr("رمز عبور")
                        inputMethodHints: Qt.ImhHiddenText
                        echoMode: AppTextField.Password
                        horizontalAlignment: Qt.AlignLeft
                        passwordMaskDelay: 200
                        width: parent.width
                        height: parent.height
                        maximumLength: 50
                        anchors.horizontalCenter: parent.horizontalCenter
                        EnterKey.type: Qt.EnterKeyGo
                        Keys.onReturnPressed:  deleteAccountDialog.dialogButton.clicked(Qt.RightButton)
                        Keys.onEnterPressed: deleteAccountDialog.dialogButton.clicked(Qt.RightButton)
                        rightPadding: visiblePasswordIcon.width
                        fieldInDialog: true
                        SequentialAnimation {
                            id:passwordMoveAnimation
                            running: false
                            loops: 3
                            NumberAnimation { target: passwordInput; property: "anchors.horizontalCenterOffset"; to: -10; duration: 50}
                            NumberAnimation { target: passwordInput; property: "anchors.horizontalCenterOffset"; to: 10; duration: 100}
                            NumberAnimation { target: passwordInput; property: "anchors.horizontalCenterOffset"; to: 0; duration: 50}
                        }
                        AppButton{
                            id:visiblePasswordIcon
                            width: 65*AppStyle.size1W
                            height: width
                            flat: true
                            icon{
                                source: passwordInput.echoMode === AppTextField.Password?"qrc:/view.svg":"qrc:/hide.svg"
                                color: AppStyle.textColor
                            }
                            anchors{
                                right: AppStyle.ltr?undefined:parent.right
                                left: AppStyle.ltr?parent.left:undefined
                                verticalCenter: parent.verticalCenter
                            }
                            visible: (passwordInput.text !== "") && ( passwordInput.activeFocus || visiblePasswordIcon.activeFocus )
                            onClicked: {
                                if(passwordInput.echoMode === AppTextField.Normal)
                                {
                                    passwordInput.echoMode= AppTextField.Password
                                }
                                else{
                                    passwordInput.echoMode = AppTextField.Normal
                                }
                            }
                            onVisibleChanged: {
                                if(!visible)
                                    passwordInput.echoMode= AppTextField.Password

                            }
                        }
                    }
                }
                Text{
                    id: warningText
                    color: Material.color(AppStyle.appTheme?Material.Yellow:Material.Oranges)
                    text: qsTr("با حذف شدن حساب اطلاعات قابل بازگشت نیست.")
                    font { family: AppStyle.appFont; pixelSize: AppStyle.size1F*25;bold: true}
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                    anchors{
                        left: parent.left
                        right: parent.right
                        top: passwordItem.bottom
                        margins: 35*AppStyle.size1W
                    }
                }
            }
        }
    }
}
