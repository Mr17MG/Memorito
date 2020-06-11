import QtQuick 2.14 // Rquire For Item
import "qrc:/Components" as App // Require for App.Button and ...
import QtQuick.Controls.Material 2.14 // Require for Material.foreground
Item{
    property alias emailInput: emailInput
    Item{
        anchors.topMargin: 50*size1H
        anchors.rightMargin: 100*size1W
        anchors.bottomMargin: 30*size1H
        anchors.leftMargin: 100*size1W
        anchors.fill: parent
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
            App.TextField{
                id:emailInput
                width: parent.width
                height: 100*size1H
                placeholder.text: qsTr("ایمیل یا نام کاربری")
            }
            App.TextField{
                id:passwordInput
                width: parent.width
                height: 100*size1H
                placeholder.text: qsTr("رمز عبور")
                inputMethodHints: Qt.ImhHiddenText
                echoMode: App.TextField.Password
            }
            Item{width: parent.width;height: 30*size1H}
            App.Button{
                width: parent.width
                text: qsTr("وارد شو")
            }
            Item{
                width: parent.width
                height: 70*size1H
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
        App.Button{
            flat: true
            anchors.bottom: parent.bottom
            width: parent.width
            text: qsTr("English Version")
            onClicked: {
                if(!ltr)
                    translator.updateLanguage(31)
                else translator.updateLanguage(89)
            }
        }

    }
}
