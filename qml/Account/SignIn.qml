import QtQuick 2.14 // Rquire For Item
import QtQuick.Controls.Material 2.14 // Require for Material.foreground
import QtGraphicalEffects 1.14
import Components 1.0// Require for AppButton and ...
import Global 1.0

Item{
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

        else signinBtn.clicked(Qt.RightButton)
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
        anchors{
            topMargin: 50*AppStyle.size1H
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
                height: 100*AppStyle.size1H
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
                        UsefulFunc.showLog(qsTr("نام کاربری باید بیشتراز ۴ حرف باشد"),true,UsefulFunc.authLoader.width)
                        return
                    }
                    if(passwordInput.text === "" )
                    {
                        passwordMoveAnimation.start()
                        passwordInput.forceActiveFocus()
                        UsefulFunc.showLog(qsTr("لطفا رمزعبور خود را وارد نمایید"),true,UsefulFunc.authLoader.width)
                        return
                    }
                    UserApi.signIn(usernameInput.text,passwordInput.text)
                }
            }
            Item{
                width: parent.width
                height: 70*AppStyle.size1H
                Text{
                    id: forgetText
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: AppStyle.ltr?50*AppStyle.size1W:width/2-25*AppStyle.size1W
                    font{family: AppStyle.appFont;pixelSize: 25*AppStyle.size1F;}
                    text: qsTr("رمزتو فراموش کردی؟")
                    color: AppStyle.textColor
                    anchors.verticalCenter: parent.verticalCenter

                }
                AppButton{
                    flat: true
                    anchors.right: forgetText.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "<u>" + qsTr("بازنشانی کن") +"<u/>"
                    Material.foreground: AppStyle.primaryInt
                    onClicked: {
                        if(usernameInput.text.length < 4)
                        {
                            usernameMoveAnimation.start()
                            usernameInput.forceActiveFocus()
                            UsefulFunc.showLog(qsTr("نام کاربری باید بیشتراز ۴ حرف باشد"),true,UsefulFunc.authLoader.width)
                            return
                        }
                        UserApi.forgetPass(usernameInput.text)
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
        Text{
            id: accountText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: AppStyle.ltr?50*AppStyle.size1W:width/2
            font{family: AppStyle.appFont;pixelSize: 25*AppStyle.size1F;}
            text: qsTr("حساب نداری؟")
            color: AppStyle.textColor
            anchors.verticalCenter: parent.verticalCenter

        }
        AppButton{
            id:signText
            flat: true
            anchors.right: accountText.left
            anchors.verticalCenter: parent.verticalCenter
            text: "<u>" + qsTr("ثبت نام کن") +"<u/>"
            Material.foreground: AppStyle.primaryInt
            onClicked: {
                isSignIn = false
            }
        }
    }
}
