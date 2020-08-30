import QtQuick 2.14 // Rquire For Item
import "qrc:/Components" as App // Require for App.Button and ...
import QtQuick.Controls.Material 2.14 // Require for Material.foreground

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
            width: parent.width
            height: 100*size1H
            active: isReset
            visible: active
            sourceComponent: Item{
                anchors.fill: parent
                App.TextField{
                    id:passInput
                    width: parent.width/2
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    placeholder.text: qsTr("رمز عبور جدید")
                    validator: RegExpValidator{
                        regExp: /[0-9۰-۹]{6}/
                    }
                }
            }
        }
        Loader{
            width: parent.width
            height: 100*size1H
            active: isReset
            visible: active
            sourceComponent: Item{
                anchors.fill: parent
                App.TextField{
                    id:confitrmPassInput
                    width: parent.width/2
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    placeholder.text: qsTr("تکرار رمز عبور جدید")
                    validator: RegExpValidator{
                        regExp: /[0-9۰-۹]{6}/
                    }
                }
            }
        }
        Item{
            id:btnItem
            width: parent.width
            height: 100*size1H
            App.Button{
                width: parent.width/2
                text: qsTr("تائید")
                enabled: (otpInput.text.length === 6 && (!isReset || (isReset && passInput.text.length > 4 && confitrmPassInput.text.length > 4)))
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                radius: 20*size1W
                onClicked: {
                    if(!isReset)
                        api.validateOTP(email,otpInput.text)
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
                        confitrmInput.clear()
                        waiterTime.start()
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
