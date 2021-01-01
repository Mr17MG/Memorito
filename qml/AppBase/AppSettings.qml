import QtQuick 2.14 // Require For Item and Flow and ...
import QtQuick.Controls 2.14 // Require for ItemDelegate
import QtQuick.Controls.Material 2.14 // Require for
import QtGraphicalEffects 1.14 // Require for  ColorOverlay
import "qrc:/Components/" as App // // Require for  Switch and

Item {
    Flow{
        width: parent.width
        anchors.top: parent.top
        anchors.topMargin: 20*size1W
        anchors.right: parent.right
        spacing: 10*size1W
        Flow{
            id:themeFlow
            width: parent.width
            layoutDirection: Qt.RightToLeft
            Text{
                text: qsTr("طرح زمینه") + " :"
                font{family: appStyle.appFont;pixelSize: 35*size1F;bold:false}
                verticalAlignment: Text.AlignVCenter
                color: appStyle.textColor
                height: themeSwitch.height
            }
            Text{
                text: qsTr("روشن")
                font{family: appStyle.appFont;pixelSize: 35*size1F}
                verticalAlignment: Text.AlignVCenter
                color: appStyle.textColor
                height: themeSwitch.height
            }
            App.Switch{
                id: themeSwitch
                Material.accent: appStyle.primaryColor
                Material.theme: Material.Light
                checked: appStyle.appTheme?false:true
                onCheckedChanged: {
                    setAppTheme(checked?0:1)
                }
            }
            Text{
                text: qsTr("تیره")
                font{family: appStyle.appFont;pixelSize: 35*size1F}
                verticalAlignment: Text.AlignVCenter
                color: appStyle.textColor
                height: themeSwitch.height
            }
        }

        Item {
            id: colorItem
            width: parent.width
            height: 90*size1H
            Text{
                id:colorText
                text: qsTr("رنگ اصلی") + " :"
                font{family: appStyle.appFont;pixelSize: 35*size1F;bold:false}
                verticalAlignment: Text.AlignBottom
                color: appStyle.textColor
                height: primaryCombo.height
                anchors.right: parent.right
                anchors.leftMargin: 10*size1W
                anchors.bottom: primaryCombo.bottom
            }
            App.ComboBox{
                id:primaryCombo
                hasClear: false
                width: 260*size1W
                height: 70*size1H
                anchors.right: colorText.left
                anchors.rightMargin: 20*size1W
                placeholderText: qsTr("رنگ‌ها")
                currentIndex : appStyle.primaryInt
                popup.height : 350*size1H
                popup.y:height
                font{family: appStyle.appFont;pixelSize: 35*size1F}
                model: [
                    qsTr("قرمز"),
                    qsTr("صورتی"),
                    qsTr("بنفش"),
                    qsTr("بنفش تیره"),
                    qsTr("نیلی"),
                    qsTr("آبی"),
                    qsTr("آبی روشن"),
                    qsTr("فیروزه‌ای"),
                    qsTr("سبز تیره"),
                    qsTr("سبز"),
                    qsTr("سبز روشن"),
                    qsTr("لیمویی"),
                    qsTr("زرد"),
                    qsTr("کهربایی"),
                    qsTr("نارنجی"),
                    qsTr("نارنجی تیره"),
                    qsTr("قهوه‌ای"),
                    qsTr("خاکستری"),
                    qsTr("آبی خاکستری")
                ]

                delegate: ItemDelegate {
                    id: colorDelegate
                    Text{
                        text: modelData
                        color: "#FFFFFF"
                        font{family: appStyle.appFont;pixelSize: 35*size1F}
                        anchors.centerIn: parent
                    }

                    width: primaryCombo.popup.width
                    height: 70*size1H
                    Rectangle {
                        z: -1
                        anchors.fill: parent
                        parent: colorDelegate.background
                        color: Material.color(index)
                    }
                }
                onCurrentIndexChanged: {
                    if(currentIndex!==-1 && !appStyle.languageChanged) // Need For Do Not change Color When Language Changed
                    {
                        appStyle.primaryInt = currentIndex
                    }
                }
            }
        }

        Item{
            width: parent.width
            height: 90*size1H
            Text{
                id:languageText
                text: qsTr("زبان") + " :"
                font{family: appStyle.appFont;pixelSize: 35*size1F;bold:false}
                verticalAlignment: Text.AlignBottom
                color: appStyle.textColor
                anchors.right: parent.right
                anchors.leftMargin: 10*size1W
            }
            App.ComboBox{
                id:languageCombo
                width: 260*size1W
                height: 70*size1H
                hasClear: false
                anchors.right: languageText.left
                anchors.rightMargin: 20*size1W
                placeholderText: qsTr("زبان‌ها")
                popup.y:height
                currentIndex: translator?usefulFunc.findInModel(translator?translator.getCurrentLanguage():"","code",langList).index:-1
                textRole: "name"
                font{family: appStyle.appFont;pixelSize: 35*size1F;}
                onCurrentIndexChanged: {
                    if(currentIndex !== -1 && translator.getCurrentLanguage()!== model.get(currentIndex).code)
                    {
                        appStyle.languageChanged = true
                        ltr = model.get(currentIndex).code === translator.getLanguages().ENG
                        translator.updateLanguage(model.get(currentIndex).code);
                        appSetting.setValue("AppLanguage",model.get(currentIndex).code)
                        appStyle.languageChanged = false
                    }
                }

                model:ListModel{
                    id:langList
                    ListElement{
                        name:"English"
                        code: 31
                    }
                    ListElement{
                        name: "فارسی"
                        code: 89
                    }
                }
            }
        }
    }
}
