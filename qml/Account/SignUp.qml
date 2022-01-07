import QtQuick  // require for Item and ...
import QtQuick.Controls 
import QtQuick.Controls.Material  // require for Material.foreground
import Qt5Compat.GraphicalEffects

import Memorito.Components// Require for AppButton and ...
import Memorito.Global

Item {
    function getKeyType()
    {
        if( usernameInput.text.length>0 && emailInput.text.length > 0 && passwordConfirmInput.text.length > 0 && passwordInput.text.length > 0)
            return Qt.EnterKeyGo

        else
            return Qt.EnterKeyNext
    }
    function getNextFocus()
    {
        if( usernameInput.text.length === 0 )
            usernameInput.forceActiveFocus()

        else if( emailInput.text.length === 0 )
            emailInput.forceActiveFocus()

        else if( passwordInput.text.length === 0 )
            passwordInput.forceActiveFocus()

        else if( passwordConfirmInput.text.length === 0 )
            passwordConfirmInput.forceActiveFocus()

        else signUpBtn.clicked()
    }

    Item{
        anchors{
            topMargin: 150*AppStyle.size1H
            rightMargin: 100*AppStyle.size1W
            bottomMargin: 30*AppStyle.size1H
            leftMargin: 100*AppStyle.size1W
            bottom: accountItem.top
            top: parent.top
            left: parent.left
            right: parent.right
        }

        Flow{
            width: parent.width
            anchors.centerIn: parent
            Text{
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                font{family: AppStyle.appFont;pixelSize: 50*AppStyle.size1F;}
                text: qsTr("ساخت حساب")
                color: AppStyle.textColor
                height: 100*AppStyle.size1H
            }

            Item{
                width: parent.width
                height: 100*AppStyle.size1H
                AppTextField{
                    id:usernameInput
                    placeholder.text: qsTr("نام کاربری")
                    validator: RegularExpressionValidator{
                        regularExpression: /[A-Za-z][A-Za-z0-9_.]{50}/
                    }
                    width: parent.width
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    onFocusChanged: {
                        if(focus && text.length === 0)
                        {
                            ToolTip.show(qsTr("فقط از حروف a تا z و A تا Z و 0 تا 9 و _ و . استفاده کن."),5000)
                        }
                    }
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
                height: 100*AppStyle.size1H
                AppTextField{
                    id:emailInput
                    placeholder.text: qsTr("ایمیل")
                    width: parent.width
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    inputMethodHints: Qt.ImhEmailCharactersOnly
                    EnterKey.type: getKeyType()
                    Keys.onReturnPressed:  getNextFocus()
                    Keys.onEnterPressed:  getNextFocus()
                    SequentialAnimation {
                        id:emailMoveAnimation
                        running: false
                        loops: 3
                        NumberAnimation { target: emailInput; property: "anchors.horizontalCenterOffset"; to: -10; duration: 50}
                        NumberAnimation { target: emailInput; property: "anchors.horizontalCenterOffset"; to: 10; duration: 100}
                        NumberAnimation { target: emailInput; property: "anchors.horizontalCenterOffset"; to: 0; duration: 50}
                    }
                }
            }

            Item{
                width: parent.width
                height: 100*AppStyle.size1H
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
                        visible: passwordInput.text != "" && ( passwordInput.activeFocus || visiblePasswordIcon.activeFocus )
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

            Item{
                width: parent.width
                height: 100*AppStyle.size1H
                AppTextField{
                    id:passwordConfirmInput
                    placeholder.text: qsTr("تکرار رمز عبور")
                    inputMethodHints: Qt.ImhHiddenText
                    echoMode: AppTextField.Password
                    passwordMaskDelay: 200
                    width: parent.width
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    EnterKey.type: getKeyType()
                    Keys.onReturnPressed:  getNextFocus()
                    Keys.onEnterPressed:  getNextFocus()
                    rightPadding: visiblePasswordConfirmIcon.width
                    SequentialAnimation {
                        id:passwordConfirmMoveAnimation
                        running: false
                        loops: 3
                        NumberAnimation { target: passwordConfirmInput; property: "anchors.horizontalCenterOffset"; to: -10; duration: 50}
                        NumberAnimation { target: passwordConfirmInput; property: "anchors.horizontalCenterOffset"; to: 10; duration: 100}
                        NumberAnimation { target: passwordConfirmInput; property: "anchors.horizontalCenterOffset"; to: 0; duration: 50}
                    }

                    AppButton{
                        id:visiblePasswordConfirmIcon
                        width: 65*AppStyle.size1W
                        height: width
                        flat: true
                        icon{
                            source: passwordConfirmInput.echoMode === AppTextField.Password?"qrc:/view.svg":"qrc:/hide.svg"
                            color: AppStyle.textColor
                        }
                        anchors{
                            right: AppStyle.ltr?undefined:parent.right
                            left: AppStyle.ltr?parent.left:undefined
                            verticalCenter: parent.verticalCenter
                        }
                        visible: passwordConfirmInput.text != "" && ( passwordConfirmInput.activeFocus || visiblePasswordConfirmIcon.activeFocus )
                        onClicked: {
                            if(passwordConfirmInput.echoMode === AppTextField.Normal)
                            {
                                passwordConfirmInput.echoMode= AppTextField.Password
                            }
                            else{
                                passwordConfirmInput.echoMode = AppTextField.Normal
                            }
                        }
                        onVisibleChanged: {
                            if(!visible)
                                passwordConfirmInput.echoMode= AppTextField.Password

                        }
                    }
                }
            }

            Item{width: parent.width;height: 20*AppStyle.size1H}

            AppButton{
                id:signUpBtn
                width: parent.width
                radius: 20*AppStyle.size1W
                text: qsTr("بساز")
                Keys.onEnterPressed:  clicked(Qt.RightButton)
                Keys.onReturnPressed:  clicked(Qt.RightButton)
                onClicked: {
                    if(usernameInput.text.length < 4)
                    {
                        usernameMoveAnimation.start()
                        usernameInput.forceActiveFocus()
                        UsefulFunc.showLog(qsTr("نام کاربری باید بیشتراز ۴ حرف باشه."),true)
                        return
                    }
                    if(UsefulFunc.emailValidation(emailInput.text) === false)
                    {
                        emailMoveAnimation.start()
                        emailInput.forceActiveFocus()
                        UsefulFunc.showLog(qsTr("لطفا ایمیلتو به صورت صحیح وارد کن."),true)
                        return
                    }
                    if(passwordInput.text === "" )
                    {
                        passwordMoveAnimation.start()
                        passwordInput.forceActiveFocus()
                        UsefulFunc.showLog(qsTr("لطفا رمزعبورتو به صورت صحیح وارد کن."),true)
                        return
                    }
                    if ( passwordConfirmInput.text === "" || passwordConfirmInput.text !== passwordInput.text)
                    {
                        passwordConfirmMoveAnimation.start()
                        passwordConfirmInput.forceActiveFocus()
                        UsefulFunc.showLog(qsTr("تکرار رمز عبور با رمزعبور یکی نیست."),true)
                        return
                    }

                    // Let's send to server
                    userController.signUp(usernameInput.text,emailInput.text,passwordInput.text)
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

        Text{
            id: accountText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: AppStyle.ltr?50*AppStyle.size1W:width/2
            font{family: AppStyle.appFont;pixelSize: 25*AppStyle.size1F;}
            text: qsTr("حساب داری؟")
            color: AppStyle.textColor
            anchors.verticalCenter: parent.verticalCenter
        }
        AppButton{
            flat: true
            anchors.right: accountText.left
            anchors.verticalCenter: parent.verticalCenter
            width: AppStyle.size1W*125
            text: "<u>" + qsTr("وارد شو") +"<u/>"
            Material.foreground: AppStyle.primaryInt
            onClicked: {
                isSignIn = true
            }
        }
    }

    Connections{
        target: userController
        function onWrongEmail()
        {
            emailMoveAnimation.start()
            emailInput.forceActiveFocus()
        }
        function onWrongUsername()
        {
            usernameMoveAnimation.start()
            usernameInput.forceActiveFocus()
        }
    }
}
