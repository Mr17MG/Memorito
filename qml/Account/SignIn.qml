import QtQuick 2.14 // Rquire For Item
import "qrc:/Components" as App // Require for App.Button and ...
import QtQuick.Controls.Material 2.14 // Require for Material.foreground
import QtGraphicalEffects 1.14
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
    App.Button{
        id:languageBtn
        flat: true
        anchors{
            top: parent.top
            topMargin: 20*size1H
        }
        width: parent.width
        text: qsTr("English Version")
        radius: 20*size1W
        onClicked: {
            if(!ltr)
                translator.updateLanguage(31)
            else translator.updateLanguage(89)
        }
    }
    Item{
        anchors{
            topMargin: 50*size1H
            rightMargin: 100*size1W
            bottomMargin: 30*size1H
            leftMargin: 100*size1W
            bottom: accountItem.top
            top: languageBtn.bottom
            left: parent.left
            right: parent.right
        }
        Flow{
            width: parent.width
            anchors.centerIn: parent
            spacing: 10*size1W
            Text{
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                font{family: appStyle.appFont;pixelSize: 50*size1F;}
                text: qsTr("ورود به حساب")
                color: appStyle.textColor
                height: 100*size1H
            }
            Item{
                width: parent.width
                height: 100*size1H
                App.TextField{
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
                height: 100*size1H
                App.TextField{
                    id:passwordInput
                    placeholder.text: qsTr("رمز عبور")
                    inputMethodHints: Qt.ImhHiddenText
                    echoMode: App.TextField.Password
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
                        width: 30*size1W
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
                        color: appStyle.textColor
                        transform:rotation
                        antialiasing: true
                        visible: passwordInput.focus && passwordInput.text!=""
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                if(passwordInput.echoMode === App.TextField.Normal)
                                {
                                    visiblePasswordIcon.source = "qrc:/view.svg"
                                    passwordInput.echoMode= App.TextField.Password
                                }
                                else{
                                    visiblePasswordIcon.source = "qrc:/hide.svg"
                                    passwordInput.echoMode = App.TextField.Normal
                                }
                            }
                        }
                    }
                }
            }
            Item{width: parent.width;height: 20*size1H}
            App.Button{
                id: signinBtn
                width: parent.width
                text: qsTr("وارد شو")
                radius: 20*size1W
                onClicked: {
                    if(usernameInput.text.length < 4)
                    {
                        usernameMoveAnimation.start()
                        usernameInput.forceActiveFocus()
                        usefulFunc.showLog(qsTr("نام کاربری باید بیشتراز ۴ حرف باشد"),true,authLoader,authLoader.width,false)
                        return
                    }
                    if(passwordInput.text === "" )
                    {
                        passwordMoveAnimation.start()
                        passwordInput.forceActiveFocus()
                        usefulFunc.showLog(qsTr("لطفا رمزعبور خود را وارد نمایید"),true,authLoader,authLoader.width,false)
                        return
                    }
                    userApi.signIn(usernameInput.text,passwordInput.text)
                }
            }
            Item{
                width: parent.width
                height: 70*size1H
                Text{
                    id: forgetText
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: ltr?50*size1W:width/2-25*size1W
                    font{family: appStyle.appFont;pixelSize: 25*size1F;}
                    text: qsTr("رمزتو فراموش کردی؟")
                    color: appStyle.textColor
                    anchors.verticalCenter: parent.verticalCenter

                }
                App.Button{
                    flat: true
                    anchors.right: forgetText.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "<u>" + qsTr("بازنشانی کن") +"<u/>"
                    Material.foreground: appStyle.primaryInt
                    onClicked: {
                        if(usernameInput.text.length < 4)
                        {
                            usernameMoveAnimation.start()
                            usernameInput.forceActiveFocus()
                            usefulFunc.showLog(qsTr("نام کاربری باید بیشتراز ۴ حرف باشد"),true,authLoader,authLoader.width,false)
                            return
                        }
                        userApi.forgetPass(usernameInput.text)
                    }
                }
            }
        }
    }
    Item{
        id: accountItem
        width: parent.width
        height: 70*size1H
        anchors{
            bottom: parent.bottom
            bottomMargin: 20*size1H
        }
        Text{
            id: accountText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: ltr?50*size1W:width/2
            font{family: appStyle.appFont;pixelSize: 25*size1F;}
            text: qsTr("حساب نداری؟")
            color: appStyle.textColor
            anchors.verticalCenter: parent.verticalCenter

        }
        App.Button{
            id:signText
            flat: true
            anchors.right: accountText.left
            anchors.verticalCenter: parent.verticalCenter
            text: "<u>" + qsTr("ثبت نام کن") +"<u/>"
            Material.foreground: appStyle.primaryInt
            onClicked: {
                isSignIn = false
            }
        }
    }
}
