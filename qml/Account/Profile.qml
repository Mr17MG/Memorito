import QtQuick 2.14
import QtQml 2.15
import QtGraphicalEffects 1.14
import QtQuick.Controls.Material 2.14
import QtQuick.Controls 2.14
import QtQuick.Dialogs 1.3
import Components 1.0
import Global 1.0
import MTools 1.0

Pane {
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


    Flickable{
        anchors{
            top: parent.top
            bottom: parent.bottom
            topMargin: 70*AppStyle.size1H
            bottomMargin: 70*AppStyle.size1H
            horizontalCenter: parent.horizontalCenter
        }
        width: parent.width/3*2 > 800*AppStyle.size1W?800*AppStyle.size1W:parent.width/3*2
        contentHeight: flow1.height
        Rectangle{
            color: Material.color(AppStyle.primaryInt,Material.Shade50)
            opacity: AppStyle.appTheme?0.2:0.5
            anchors.fill: parent
            border{
                color: Material.color(AppStyle.primaryInt,Material.Shade100)
                width: 4*AppStyle.size1W
            }
            radius: 100*AppStyle.size1W
        }
        Flow{
            id:flow1
            width: parent.width
            spacing: 30*AppStyle.size1H
            Item{
                width: parent.width
                height: 600*AppStyle.size1W
                Rectangle{
                    id: root
                    width: 500*AppStyle.size1W
                    height: width
                    radius: width
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
                    validator: RegExpValidator{regExp: /[A-Za-z][A-Za-z0-9_.]{50}/}
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
                    validator: RegExpValidator{regExp: /[A-Za-z0-9_]*/}
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
                onCheckedChanged: {
                    checkModify()
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
                font { family: AppStyle.appFont; pixelSize: AppStyle.size1F*30;bold:true}
                icon{
                    source: "qrc:/previous.svg"
                    color: AppStyle.textColor
                    width: AppStyle.size1W*20
                    height: AppStyle.size1W*20
                }

                onClicked: {
                    UsefulFunc.showConfirm(
                                qsTr("تغییر رمز ورود"),
                                qsTr("آیا مطمئن هستید که می‌خواهید رمز ورود به حساب خود را تغییر دهید؟"),
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
                icon{
                    source: "qrc:/previous.svg"
                    color: AppStyle.textColor
                    width: AppStyle.size1W*20
                    height: AppStyle.size1W*20
                }
                horizontalAlignment: Qt.AlignRight
                flat: true
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
                                    UsefulFunc.stackPages.clear()
                                }
                                )
                }
            }


            Item{
                width: parent.width
                height: 200*AppStyle.size1H
                AppButton{
                    id: edit
                    enabled: modified
                    height: 100*AppStyle.size1H
                    anchors.centerIn: parent
                    width: usernameInput.width
                    radius: AppStyle.size1W*50
                    text: qsTr("بروزرسانی اطلاعات")
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
                            UsefulFunc.showLog(qsTr("اطلاعات وارد شده صحیح نمی‌باشد."),true)
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
                            UsefulFunc.showLog(qsTr("لطفا ایمیل خود را به صورت صحیح وارد نمایید"),true)
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


        }
    }
}
