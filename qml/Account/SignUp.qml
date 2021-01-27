import QtQuick 2.14 // require for Item and ...
import QtQuick.Controls.Material 2.14 // require for Material.foreground
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.14
import Components 1.0// Require for AppButton and ...
import Global 1.0

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

        else signUpBtn.clicked(Qt.RightButton)
    }

    AppButton{
        id:languageBtn
        flat: true
        anchors{
            top: parent.top
            topMargin: 20*AppStyle.size1H
        }
        width: parent.width
        text: qsTr("English Version")
        radius: 20*AppStyle.size1W
        onClicked: {
            if(!AppStyle.ltr)
                translator.updateLanguage(31) // For Farsi
            else translator.updateLanguage(89) // For English
        }
    }

    Item{
        anchors{topMargin: 50*AppStyle.size1H
            rightMargin: 100*AppStyle.size1W
            bottomMargin: 30*AppStyle.size1H
            leftMargin: 100*AppStyle.size1W
            bottom: accountItem.top
            top: languageBtn.bottom
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
                    validator: RegExpValidator{
                        regExp: /[A-Za-z0-9_.]{50}/
                    }
                    width: parent.width
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    onFocusChanged: {
                        if(focus && text.length === 0)
                        {
                            ToolTip.show(qsTr("فقط از حروف a تا z و A تا Z و 0 تا 9 و _ و . استفاده کنید"),5000)
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
                    Image{
                        id:visiblePasswordIcon
                        LayoutMirroring.enabled: false
                        width: 30*AppStyle.size1W
                        height: width
                        source: "qrc:/view.svg"
                        sourceSize.width: width*2
                        sourceSize.height: height*2
                        anchors.verticalCenter: parent.verticalCenter
                        visible: false
                        anchors.right: parent.right
                    }
                    ColorOverlay{
                        id: visiblePasswordColor
                        anchors.fill: visiblePasswordIcon
                        source: visiblePasswordIcon
                        color: AppStyle.textColor
                        transform:rotation
                        antialiasing: true
                        visible: passwordInput.focus && passwordInput.text!=""
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                if(passwordInput.echoMode === AppTextField.Normal)
                                {
                                    visiblePasswordIcon.source = "qrc:/view.svg"
                                    passwordInput.echoMode= AppTextField.Password
                                }
                                else{
                                    visiblePasswordIcon.source = "qrc:/hide.svg"
                                    passwordInput.echoMode = AppTextField.Normal
                                }
                            }
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

                    Image{
                        id:visiblePasswordConfirmIcon
                        LayoutMirroring.enabled: false
                        width: 30*AppStyle.size1W
                        height: width
                        source: "qrc:/view.svg"
                        sourceSize.width: width*2
                        sourceSize.height: height*2
                        anchors.verticalCenter: parent.verticalCenter
                        visible: false
                        anchors.right: parent.right
                    }

                    ColorOverlay{
                        id: visiblePasswordConfirmColor
                        anchors.fill: visiblePasswordConfirmIcon
                        source: visiblePasswordConfirmIcon
                        color: AppStyle.textColor
                        transform:rotation
                        antialiasing: true
                        visible: passwordConfirmInput.focus && passwordConfirmInput.text!=""
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                if(passwordConfirmInput.echoMode === AppTextField.Normal)
                                {
                                    visiblePasswordConfirmIcon.source = "qrc:/view.svg"
                                    passwordConfirmInput.echoMode= AppTextField.Password
                                }
                                else{
                                    visiblePasswordConfirmIcon.source = "qrc:/hide.svg"
                                    passwordConfirmInput.echoMode = AppTextField.Normal
                                }
                            }
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
                        UsefulFunc.showLog(qsTr("نام کاربری باید بیشتراز ۴ حرف باشد"),true,authLoader.width)
                        return
                    }
                    if(UsefulFunc.emailValidation(emailInput.text) === false)
                    {
                        emailMoveAnimation.start()
                        emailInput.forceActiveFocus()
                        UsefulFunc.showLog(qsTr("لطفا ایمیل خود را به صورت صحیح وارد نمایید"),true,authLoader.width)
                        return
                    }
                    if(passwordInput.text === "" )
                    {
                        passwordMoveAnimation.start()
                        passwordInput.forceActiveFocus()
                        UsefulFunc.showLog(qsTr("لطفا رمزعبور خود را به صورت صحیح وارد نمایید"),true,authLoader.width)
                        return
                    }
                    if ( passwordConfirmInput.text === "" || passwordConfirmInput.text !== passwordInput.text)
                    {
                        passwordConfirmMoveAnimation.start()
                        passwordConfirmInput.forceActiveFocus()
                        UsefulFunc.showLog(qsTr("تکرار رمز عبور با رمزعبور برابر نمی‌باشند."),true,authLoader.width)
                        return
                    }

                    // Let's send to server
                    api.signUp(usernameInput.text,emailInput.text,passwordInput.text)
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
}
