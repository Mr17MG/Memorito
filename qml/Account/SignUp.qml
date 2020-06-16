import QtQuick 2.14 // require for Item and ...
import "qrc:/Components" as App // rquire for App.Button
import QtQuick.Controls.Material 2.14 // require for Material.foreground

Item {
    Item{
        anchors{topMargin: 50*size1H
            rightMargin: 100*size1W
            bottomMargin: 30*size1H
            leftMargin: 100*size1W
            top: parent.top
            bottom: languageBtn.top
            left: parent.left
            right: parent.right
        }
        Flow{
            width: parent.width
            anchors.centerIn: parent
            Text{
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                font{family: appStyle.appFont;pixelSize: 50*size1F;}
                text: qsTr("ساخت حساب")
                color: appStyle.textColor
                height: 100*size1H
            }
            App.TextField{
                id:usernameInput
                width: parent.width
                height: 100*size1H
                placeholder.text: qsTr("نام کاربری")
            }
            App.TextField{
                id:emailInput
                width: parent.width
                height: 100*size1H
                placeholder.text: qsTr("ایمیل")
            }
            App.TextField{
                id:passwordInput
                width: parent.width
                height: 100*size1H
                placeholder.text: qsTr("رمز عبور")
                inputMethodHints: Qt.ImhHiddenText
                echoMode: App.TextField.Password
            }
            App.TextField{
                id:passwordConfirmInput
                width: parent.width
                height: 100*size1H
                placeholder.text: qsTr("تکرار رمز عبور")
                inputMethodHints: Qt.ImhHiddenText
                echoMode: App.TextField.Password
            }
            Item{width: parent.width;height: 30*size1H}
            App.Button{
                width: parent.width
                radius: 20*size1W
                text: qsTr("بساز")
            }
            Item{
                width: parent.width
                height: 70*size1H
                Text{
                    id: accountText
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: ltr?50*size1W:width/2
                    font{family: appStyle.appFont;pixelSize: 25*size1F;}
                    text: qsTr("حساب داری؟")
                    color: appStyle.textColor
                    anchors.verticalCenter: parent.verticalCenter

                }
                App.Button{
                    flat: true
                    anchors.right: accountText.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: size1W*125
                    text: "<u>" + qsTr("وارد شو") +"<u/>"
                    Material.foreground: appStyle.primaryInt
                    onClicked: {
                        isSignIn = true
                    }
                }
            }
        }
    }
    App.Button{
        id:languageBtn
        flat: true
        anchors{
            bottom: parent.bottom
            bottomMargin: 30*size1H
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

}
