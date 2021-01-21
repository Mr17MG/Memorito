import QtQuick 2.14 // Rquire For Item
import "qrc:/Components" as App // Require for App.Button and ...
import QtQuick.Controls.Material 2.14 // Require for Material.foreground
import "../"
Item {
    property string email: ""
    property int waitingSecond: defaultWaintingTime
    property int defaultWaintingTime: 180
    property bool isReset: false
    UserAPI{ id:userApi }
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
        spacing: 10*size1W
        Text{
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            font{family: appStyle.appFont;pixelSize: 50*size1F;}
            text: qsTr("اعتبارسنجی")
            color: appStyle.textColor
            height: 100*size1H
        }
        Text{
            width: parent.width
            rightPadding: 40*size1W
            leftPadding: 40*size1W
            horizontalAlignment: Text.AlignHCenter
            font{family: appStyle.appFont;pixelSize: 25*size1F;}
            text: qsTr("کد تایید حساب شما به ایمیل") + ": "
                  + email + " \n"
                  +qsTr("ارسال شد لطفا آن را در قسمت زیر وارد نمایید.")
            color: appStyle.textColor
            height: 100*size1H
            wrapMode: Text.WordWrap
        }
        Item{
            width: parent.width
            height: 100*size1H
            App.TextField{
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
            height: 100*size1H
            active: isReset
            visible: active
            sourceComponent: Item{
                anchors.fill: parent
                property alias passInput: passInput
                property alias passwordMoveAnimation: passwordMoveAnimation
                App.TextField{
                    id:passInput
                    width: parent.width/2
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    placeholder.text: qsTr("رمز عبور جدید")
                    inputMethodHints: Qt.ImhHiddenText
                    echoMode: App.TextField.Password
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
            height: 100*size1H
            active: isReset
            visible: active
            sourceComponent: Item{
                anchors.fill: parent
                property alias confirmPassInput: confirmPassInput
                property alias passwordConfirmMoveAnimation: passwordConfirmMoveAnimation
                App.TextField{
                    id:confirmPassInput
                    width: parent.width/2
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    placeholder.text: qsTr("تکرار رمز عبور جدید")
                    inputMethodHints: Qt.ImhHiddenText
                    echoMode: App.TextField.Password
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
            height: 100*size1H
            App.Button{
                id:confirmBtn
                width: parent.width/2
                text: qsTr("تائید")
                enabled: (otpInput.text.length === 6 && (!isReset || (isReset && passLoader.item.passInput.text.length > 4 && confirmPassLoader.item.confirmPassInput.text.length > 4)))
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                radius: 20*size1W
                onClicked: {
                    if(!isReset)
                        userApi.validateOTP(email,otpInput.text)
                    else {
                        if(passLoader.item.passInput.text === "" )
                        {
                            passLoader.item.passwordMoveAnimation.start()
                            passLoader.item.passInput.forceActiveFocus()
                            usefulFunc.showLog(qsTr("لطفا رمزعبور خود را به صورت صحیح وارد نمایید"),true,authLoader,authLoader.width,true)
                            return
                        }
                        if ( confirmPassLoader.item.confirmPassInput.text === "" || confirmPassLoader.item.confirmPassInput.text !== passLoader.item.passInput.text)
                        {
                            confirmPassLoader.item.passwordConfirmMoveAnimation.start()
                            confirmPassLoader.item.confirmPassInput.forceActiveFocus()
                            usefulFunc.showLog(qsTr("تکرار رمز عبور با رمزعبور برابر نمی‌باشند."),true,authLoader,authLoader.width,true)
                            return
                        }
                        userApi.resetPass(email, otpInput.text, passLoader.item.passInput.text)
                    }
                }
            }
        }
        Item {
            id: name
            width: btnItem.width
            height: 70*size1H
            clip: true
            Flow{
                anchors.horizontalCenter: parent.horizontalCenter
                layoutDirection: Flow.RightToLeft
                height: parent.height
                Text{
                    id: accountText
                    height: parent.height
                    font{family: appStyle.appFont;pixelSize: 25*size1F;}
                    text: qsTr("کد رو دریافت نکردی؟")
                    color: appStyle.textColor
                    verticalAlignment: Text.AlignVCenter
                }
                App.Button{
                    id:resendButton
                    flat: true
                    height: parent.height
                    text: waitingSecond === defaultWaintingTime? "<u>" + qsTr("ارسال مجدد کد تایید") +"<u/>"
                                                               : (secondToMMSS( waitingSecond ) +" " + qsTr("صبر کن"))
                    Material.foreground: appStyle.primaryInt
                    onClicked: {
                        if(waitingSecond === defaultWaintingTime){
                            otpInput.clear()
                            waiterTime.start()
                            userApi.resendOTP(email)
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
