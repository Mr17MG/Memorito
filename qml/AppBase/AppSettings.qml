import QtQuick 2.14 // Require For Item and Flow and ...
import QtQuick.Controls 2.14 // Require for ItemDelegate
import QtQuick.Controls.Material 2.14 // Require for
import QtGraphicalEffects 1.14 // Require for  ColorOverlay
import Components 1.0  // // Require for  Switch and
import Global 1.0

Item {
    Flow{
        width: parent.width
        anchors.top: parent.top
        anchors.topMargin: 20*AppStyle.size1W
        anchors.right: parent.right
        spacing: 10*AppStyle.size1W
        Flow{
            id:themeFlow
            width: parent.width
            layoutDirection: Qt.RightToLeft
            Text{
                text: qsTr("طرح زمینه") + " :"
                font{family: AppStyle.appFont;pixelSize: 35*AppStyle.size1F;bold:false}
                verticalAlignment: Text.AlignVCenter
                color: AppStyle.textColor
                height: themeSwitch.height
            }
            Text{
                text: qsTr("روشن")
                font{family: AppStyle.appFont;pixelSize: 35*AppStyle.size1F}
                verticalAlignment: Text.AlignVCenter
                color: AppStyle.textColor
                height: themeSwitch.height
            }
            AppSwitch{
                id: themeSwitch
                Material.accent: AppStyle.primaryColor
                Material.theme: Material.Light
                checked: AppStyle.appTheme?false:true
                onCheckedChanged: {
                    AppStyle.setAppTheme(checked?0:1)
                }
            }
            Text{
                text: qsTr("تیره")
                font{family: AppStyle.appFont;pixelSize: 35*AppStyle.size1F}
                verticalAlignment: Text.AlignVCenter
                color: AppStyle.textColor
                height: themeSwitch.height
            }
        }

        Item {
            id: colorItem
            width: parent.width
            height: 90*AppStyle.size1H
            Text{
                id:colorText
                text: qsTr("رنگ اصلی") + " :"
                font{family: AppStyle.appFont;pixelSize: 35*AppStyle.size1F;bold:false}
                verticalAlignment: Text.AlignBottom
                color: AppStyle.textColor
                height: primaryCombo.height
                anchors.right: parent.right
                anchors.leftMargin: 10*AppStyle.size1W
                anchors.bottom: primaryCombo.bottom
            }
            AppComboBox{
                id:primaryCombo
                hasClear: false
                width: 260*AppStyle.size1W
                height: 70*AppStyle.size1H
                anchors.right: colorText.left
                anchors.rightMargin: 20*AppStyle.size1W
                placeholderText: qsTr("رنگ‌ها")
                currentIndex : AppStyle.primaryInt
                popup.height : 350*AppStyle.size1H
                popup.y:height
                font{family: AppStyle.appFont;pixelSize: 35*AppStyle.size1F}
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
                        font{family: AppStyle.appFont;pixelSize: 35*AppStyle.size1F}
                        anchors.centerIn: parent
                    }

                    width: primaryCombo.popup.width
                    height: 70*AppStyle.size1H
                    Rectangle {
                        z: -1
                        anchors.fill: parent
                        parent: colorDelegate.background
                        color: Material.color(index)
                    }
                }
                onCurrentIndexChanged: {
                    if(currentIndex!==-1 && !AppStyle.languageChanged) // Need For Do Not change Color When Language Changed
                    {
                        AppStyle.primaryInt = currentIndex
                    }
                }
            }
        }

        Item {
            id: textColorItem
            width: parent.width
            height: 90*AppStyle.size1H
            Text{
                id: textColorText
                text: qsTr("رنگ نوشته در رنگ اصلی") + " :"
                font{family: AppStyle.appFont;pixelSize: 35*AppStyle.size1F;bold:false}
                verticalAlignment: Text.AlignBottom
                color: AppStyle.textColor
                height: primaryCombo.height
                anchors.right: parent.right
                anchors.leftMargin: 10*AppStyle.size1W
                anchors.bottom: textColorCombo.bottom
            }
            AppComboBox{
                id:textColorCombo
                hasClear: false
                width: 260*AppStyle.size1W
                height: 70*AppStyle.size1H
                anchors.right: textColorText.left
                anchors.rightMargin: 20*AppStyle.size1W
                placeholderText: qsTr("رنگ‌ها")
                currentIndex : AppStyle.textOnPrimaryInt
                font{family: AppStyle.appFont;pixelSize: 35*AppStyle.size1F}
                model: [
                    qsTr("سفید"),
                    qsTr("مشکی")
                ]
                onCurrentIndexChanged: {
                    if(currentIndex!==-1 && !AppStyle.languageChanged) // Need For Do Not change Color When Language Changed
                    {
                        AppStyle.textOnPrimaryInt = currentIndex
                    }
                }
            }
        }


        Item{
            width: parent.width
            height: 90*AppStyle.size1H
            Text{
                id:languageText
                text: qsTr("زبان") + " :"
                font{family: AppStyle.appFont;pixelSize: 35*AppStyle.size1F;bold:false}
                verticalAlignment: Text.AlignBottom
                color: AppStyle.textColor
                anchors.right: parent.right
                anchors.leftMargin: 10*AppStyle.size1W
            }
            AppComboBox{
                id:languageCombo
                width: 260*AppStyle.size1W
                height: 70*AppStyle.size1H
                hasClear: false
                anchors.right: languageText.left
                anchors.rightMargin: 20*AppStyle.size1W
                placeholderText: qsTr("زبان‌ها")
                popup.y:height
                currentIndex: translator?UsefulFunc.findInModel(translator?translator.getCurrentLanguage():"","code",langList).index:-1
                textRole: "name"
                font{family: AppStyle.appFont;pixelSize: 35*AppStyle.size1F;}
                onCurrentIndexChanged: {
                    if(currentIndex !== -1 && translator.getCurrentLanguage()!== model.get(currentIndex).code)
                    {
                        AppStyle.languageChanged = true
                        AppStyle.ltr = model.get(currentIndex).code === translator.getLanguages().ENG
                        translator.updateLanguage(model.get(currentIndex).code);
                        SettingDriver.setValue("AppLanguage",model.get(currentIndex).code)
                        AppStyle.languageChanged = false
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
        SpinBox {
            value: 100
            from: 1
            to: 200
            editable: true
            onValueChanged: {
                setSizes(value/100)
            }
        }
    }
}
