import QtQuick 2.14 // Rquire For Item
import QtQuick.Controls.Material 2.14 // Require for Material.foreground
import Components 1.0// Require for AppButton and ...
import Global 1.0

Item {
    property string email: ""
    property int waitingSecond: defaultWaintingTime
    property int defaultWaintingTime: 180
    property bool isReset: false
    function secondToMMSS(second)
    {
        var MM = 0
        while(second>=60)
        {
            MM++;
            second-=60;
        }
        MM = MM < 10?"0"+MM:MM;
        second = second<10?"0"+second:second;
        return MM+":"+second;
    }

    function getKeyType()
    {
        if (otpInput.text.length >0 && (!isReset || (isReset && passLoader.item.passInput.text.length > 0 && confirmPassLoader.item.confirmPassInput.text.length > 0)))
            return Qt.EnterKeyGo
        else
            return Qt.EnterKeyNext
    }
    function getNextFocus()
    {
        if( otpInput.text.length < 6 )
            otpInput.forceActiveFocus()
        else if(passLoader.item.passInput.text.length === 0 )
            passLoader.item.passInput.forceActiveFocus()
        else if( confirmPassLoader.item.confirmPassInput.text.length === 0 )
            confirmPassLoader.item.confirmPassInput.forceActiveFocus()
        else confirmBtn.clicked(Qt.RightButton)
    }

    Flow{
        width: parent.width
        anchors.centerIn: parent
        spacing: 10*AppStyle.size1W
        Text{
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            font{family: AppStyle.appFont;pixelSize: 50*AppStyle.size1F;}
            text: qsTr("اعتبارسنجی")
            color: AppStyle.textColor
            height: 100*AppStyle.size1H
        }
        Text{
            width: parent.width
            rightPadding: 40*AppStyle.size1W
            leftPadding: 40*AppStyle.size1W
            horizontalAlignment: Text.AlignHCenter
            font{family: AppStyle.appFont;pixelSize: 25*AppStyle.size1F;}
            text: qsTr("کد تایید حساب شما به ایمیل") + ": "
                  + email + " \n"
                  +qsTr("ارسال شد لطفا آن را در قسمت زیر وارد نمایید.")
            color: AppStyle.textColor
            height: 100*AppStyle.size1H
            wrapMode: Text.WordWrap
        }
        Item{
            width: parent.width
            height: 100*AppStyle.size1H
            AppTextField{
                id: otpInput
                width: parent.width/2
                height: parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                placeholder.text: qsTr("کد تائید")
                validator: RegExpValidator{
                    regExp: /[0-9۰-۹]{6}/
                }
            }
        }
        Loader{
            id: passLoader
            width: parent.width
            height: 100*AppStyle.size1H
            active: isReset
            visible: active
            sourceComponent: Item{
                anchors.fill: parent
                property alias passInput: passInput
                property alias passwordMoveAnimation: passwordMoveAnimation
                AppTextField{
                    id:passInput
                    width: parent.width/2
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    placeholder.text: qsTr("رمز عبور جدید")
                    inputMethodHints: Qt.ImhHiddenText
                    echoMode: AppTextField.Password
                    EnterKey.type: getKeyType()
                    Keys.onReturnPressed:  getNextFocus()
                    Keys.onEnterPressed:  getNextFocus()
                }
                SequentialAnimation {
                    id:passwordMoveAnimation
                    running: false
                    loops: 3
                    NumberAnimation { target: passInput; property: "anchors.horizontalCenterOffset"; to: -10; duration: 50}
                    NumberAnimation { target: passInput; property: "anchors.horizontalCenterOffset"; to: 10; duration: 100}
                    NumberAnimation { target: passInput; property: "anchors.horizontalCenterOffset"; to: 0; duration: 50}
                }
            }
        }
        Loader{
            id: confirmPassLoader
            width: parent.width
            height: 100*AppStyle.size1H
            active: isReset
            visible: active
            sourceComponent: Item{
                anchors.fill: parent
                property alias confirmPassInput: confirmPassInput
                property alias passwordConfirmMoveAnimation: passwordConfirmMoveAnimation
                AppTextField{
                    id:confirmPassInput
                    width: parent.width/2
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    placeholder.text: qsTr("تکرار رمز عبور جدید")
                    inputMethodHints: Qt.ImhHiddenText
                    echoMode: AppTextField.Password
                    EnterKey.type: getKeyType()
                    Keys.onReturnPressed:  getNextFocus()
                    Keys.onEnterPressed:  getNextFocus()
                }
                SequentialAnimation {
                    id:passwordConfirmMoveAnimation
                    running: false
                    loops: 3
                    NumberAnimation { target: confirmPassInput; property: "anchors.horizontalCenterOffset"; to: -10; duration: 50}
                    NumberAnimation { target: confirmPassInput; property: "anchors.horizontalCenterOffset"; to: 10; duration: 100}
                    NumberAnimation { target: confirmPassInput; property: "anchors.horizontalCenterOffset"; to: 0; duration: 50}
                }
            }
        }
        Item{
            id:btnItem
            width: parent.width
            height: 100*AppStyle.size1H
            AppButton{
                id:confirmBtn
                width: parent.width/2
                text: qsTr("تائید")
                enabled: (otpInput.text.length === 6 && (!isReset || (isReset && passLoader.item.passInput.text.length > 4 && confirmPassLoader.item.confirmPassInput.text.length > 4)))
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                radius: 20*AppStyle.size1W
                onClicked: {
                    if(!isReset)
                        UserApi.validateOTP(email,otpInput.text)
                    else {
                        if(passLoader.item.passInput.text === "" )
                        {
                            passLoader.item.passwordMoveAnimation.start()
                            passLoader.item.passInput.forceActiveFocus()
                            UsefulFunc.showLog(qsTr("لطفا رمزعبور خود را به صورت صحیح وارد نمایید"),true,authLoader.width)
                            return
                        }
                        if ( confirmPassLoader.item.confirmPassInput.text === "" || confirmPassLoader.item.confirmPassInput.text !== passLoader.item.passInput.text)
                        {
                            confirmPassLoader.item.passwordConfirmMoveAnimation.start()
                            confirmPassLoader.item.confirmPassInput.forceActiveFocus()
                            UsefulFunc.showLog(qsTr("تکرار رمز عبور با رمزعبور برابر نمی‌باشند."),true,authLoader.width)
                            return
                        }
                        UserApi.resetPass(email, otpInput.text, passLoader.item.passInput.text)
                    }
                }
            }
        }
        Item {
            id: name
            width: btnItem.width
            height: 70*AppStyle.size1H
            clip: true
            Flow{
                anchors.horizontalCenter: parent.horizontalCenter
                layoutDirection: Flow.RightToLeft
                height: parent.height
                Text{
                    id: accountText
                    height: parent.height
                    font{family: AppStyle.appFont;pixelSize: 25*AppStyle.size1F;}
                    text: qsTr("کد رو دریافت نکردی؟")
                    color: AppStyle.textColor
                    verticalAlignment: Text.AlignVCenter
                }
                AppButton{
                    id:resendButton
                    flat: true
                    height: parent.height
                    text: waitingSecond === defaultWaintingTime? "<u>" + qsTr("ارسال مجدد کد تایید") +"<u/>"
                                                               : (secondToMMSS( waitingSecond ) +" " + qsTr("صبر کن"))
                    Material.foreground: AppStyle.primaryInt
                    onClicked: {
                        if(waitingSecond === defaultWaintingTime){
                            otpInput.clear()
                            waiterTime.start()
                            UserApi.resendOTP(email)
                        }

                    }
                }
            }
        }
    }

    Timer{
        id:waiterTime
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if(waitingSecond <=0)
            {
                waitingSecond = defaultWaintingTime
                waiterTime.stop()
            }
            else{
                waitingSecond--;
            }
        }
    }
}
