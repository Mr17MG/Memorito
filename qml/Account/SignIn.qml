import QtQuick  // Rquire For Item
import QtQuick.Controls
import QtQuick.Controls.Material  // Require for Material.foreground
import Qt5Compat.GraphicalEffects

import Memorito.Components// Require for AppButton and ...
import Memorito.Global

Item{
    id:root

    function getKeyType()
    {
        if( usernameInput.text.length > 0  && passwordInput.text.length > 0)
            return Qt.EnterKeyGo

        else
            return Qt.EnterKeyNext
    }
    function getNextFocus()
    {
        if( usernameInput.text.length === 0 )
            usernameInput.forceActiveFocus()

        else if( passwordInput.text.length === 0 )
            passwordInput.forceActiveFocus()

        else signinBtn.clicked()
    }

    Item{
        anchors{
            top: parent.top
            topMargin: 30*AppStyle.size1H
            right: parent.right
            rightMargin: 100*AppStyle.size1W
            left: parent.left
            leftMargin: 100*AppStyle.size1W
            bottom: accountItem.top
            bottomMargin: 30*AppStyle.size1H
        }
        Flow{
            width: parent.width
            anchors.centerIn: parent
            spacing: 10*AppStyle.size1W
            Text{
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                font{family: AppStyle.appFont;pixelSize: 50*AppStyle.size1F;}
                text: qsTr("ورود به حساب")
                color: AppStyle.textColor
                height: 100*AppStyle.size1H
            }
            Item{
                width: parent.width
                height: 110*AppStyle.size1H
                AppTextField{
                    id:usernameInput
                    placeholder.text: qsTr("ایمیل یا نام کاربری")
                    width: parent.width
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    inputMethodHints: Qt.ImhPreferLowercase
                    EnterKey.type: getKeyType()
                    Keys.onReturnPressed:  getNextFocus()
                    Keys.onEnterPressed:  getNextFocus()

                    SequentialAnimation {
                        id:usernameMoveAnimation
                        running: false
                        loops: 3
                        NumberAnimation { target: usernameInput; property: "anchors.horizontalCenterOffset"; to: -10; duration: 50}
                        NumberAnimation { target: usernameInput; property: "anchors.horizontalCenterOffset"; to: 10; duration: 100}
                        NumberAnimation { target: usernameInput; property: "anchors.horizontalCenterOffset"; to: 0; duration: 50}
                    }
                }
            }

            Item{
                width: parent.width
                height: 110*AppStyle.size1H
                AppTextField{
                    id:passwordInput
                    placeholder.text: qsTr("رمز عبور")
                    inputMethodHints: Qt.ImhHiddenText
                    echoMode: AppTextField.Password
                    passwordMaskDelay: 200
                    width: parent.width
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    EnterKey.type: getKeyType()
                    Keys.onReturnPressed:  getNextFocus()
                    Keys.onEnterPressed:  getNextFocus()
                    rightPadding: visiblePasswordIcon.width
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
                        flat: true
                        width: visible?65*AppStyle.size1W:0
                        height: width
                        visible: passwordInput.text != "" && ( passwordInput.focus || visiblePasswordIcon.focus )

                        icon{
                            color: AppStyle.textColor
                            source: passwordInput.echoMode === AppTextField.Password ? "qrc:/view.svg" : "qrc:/hide.svg"
                        }

                        anchors{
                            right: AppStyle.ltr?undefined:parent.right
                            left: AppStyle.ltr?parent.left:undefined
                            verticalCenter: parent.verticalCenter
                        }

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

            Item{width: parent.width;height: 20*AppStyle.size1H}

            AppButton{
                id: signinBtn
                width: parent.width
                text: qsTr("وارد شو")
                radius: 20*AppStyle.size1W
                onClicked: {
                    if(usernameInput.text.length < 4)
                    {
                        usernameMoveAnimation.start()
                        usernameInput.forceActiveFocus()
                        UsefulFunc.showLog(qsTr("نام کاربری باید بیشتراز ۴ حرف باشه."),true)
                        return
                    }
                    if(passwordInput.text === "" )
                    {
                        passwordMoveAnimation.start()
                        passwordInput.forceActiveFocus()
                        UsefulFunc.showLog(qsTr("لطفا رمزعبورتو وارد کن."),true)
                        return
                    }
                    userController.signIn(usernameInput.text.trim(),passwordInput.text)
                }
            }
            Item{
                width: parent.width
                height: 70*AppStyle.size1H
                Flow{
                    anchors.centerIn: parent
                    layoutDirection: Qt.RightToLeft
                    Text{
                        id: forgetText
                        font{family: AppStyle.appFont;pixelSize: 25*AppStyle.size1F;}
                        text: qsTr("رمزتو فراموش کردی؟")
                        color: AppStyle.textColor
                        height: resetBtn.height
                        verticalAlignment: Text.AlignVCenter

                    }
                    AppButton{
                        id: resetBtn
                        flat: true
                        text: "<u>" + qsTr("بازنشانی کن") +"<u/>"
                        Material.foreground: AppStyle.primaryInt
                        onClicked: {
                            if(usernameInput.text.length < 4)
                            {
                                usernameMoveAnimation.start()
                                usernameInput.forceActiveFocus()
                                UsefulFunc.showLog(qsTr("نام کاربری باید بیشتراز ۴ حرف باشه."),true)
                                return
                            }
                            userController.forgetPass(usernameInput.text)
                        }
                    }
                }
            }
        }
    }

    Item{
        id: accountItem
        width: parent.width
        height: 70*AppStyle.size1H
        anchors{
            bottom: parent.bottom
            bottomMargin: 20*AppStyle.size1H
        }
        Flow{
            anchors.centerIn: parent
            layoutDirection: Qt.RightToLeft
            Text{
                id: accountText
                font{family: AppStyle.appFont;pixelSize: 25*AppStyle.size1F;}
                text: qsTr("حساب نداری؟")
                color: AppStyle.textColor
                height: signText.height
                verticalAlignment: Text.AlignVCenter
            }
            AppButton{
                id:signText
                flat: true
                text: "<u>" + qsTr("یکی بساز") +"<u/>"
                Material.foreground: AppStyle.primaryInt
                onClicked: {
                    isSignIn = false
                }
            }
        }
    }

    Connections{
        target: userController
        function onWrongUsername()
        {
            usernameMoveAnimation.start()
            usernameInput.forceActiveFocus()
        }

        function onWrongPassword()
        {
            passwordMoveAnimation.start()
            passwordInput.forceActiveFocus()
        }
    }
}
