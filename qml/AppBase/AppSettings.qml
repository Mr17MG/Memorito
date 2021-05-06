import QtQuick 2.14 // Require For Item and Flow and ...
import QtQuick.Controls 2.14 // Require for ItemDelegate
import QtQuick.Controls.Material 2.14 // Require for
import QtGraphicalEffects 1.14 // Require for  ColorOverlay
import Components 1.0  // // Require for  Switch and
import Global 1.0
import QtQuick.Layouts 1.15

Item {
    Rectangle{
        color: "transparent"
        anchors{
            top: parent.top
            topMargin: 20*AppStyle.size1H
            right: parent.right
            rightMargin: 20*AppStyle.size1W
            left: parent.left
            leftMargin: 20*AppStyle.size1W
            bottom: parent.bottom
            bottomMargin: 20*AppStyle.size1H
        }
        border{
            color: Material.color(AppStyle.primaryInt,Material.Shade100)
            width: 4*AppStyle.size1W
        }
        radius: 30*AppStyle.size1W
    }
    Flickable{
        anchors{
            top: parent.top
            topMargin: 60*AppStyle.size1H
            right: parent.right
            rightMargin: 50*AppStyle.size1W
            left: parent.left
            leftMargin: 50*AppStyle.size1W
            bottom: parent.bottom
            bottomMargin: 60*AppStyle.size1H
        }
        contentHeight: flow1.height

        ColumnLayout{
            id:flow1
            width: parent.width
            layoutDirection: Qt.RightToLeft
            RowLayout {
                layoutDirection: Qt.RightToLeft
                Layout.alignment: Qt.AlignHCenter
                Text{
                    id: themeText
                    color: AppStyle.textColor
                    text: qsTr("طرح زمینه") + " :"

                    Layout.alignment: Text.AlignVCenter
                    font{family: AppStyle.appFont;pixelSize: 30*AppStyle.size1F;bold:false}
                }
                AppComboBox{
                    id:themeCombo
                    hasClear: false
                    Layout.preferredHeight: 90*AppStyle.size1H
                    font{family: AppStyle.appFont;pixelSize: 30*AppStyle.size1F}
                    model: [ qsTr("روشن"), qsTr("تیره") ]
                    currentIndex: AppStyle.appTheme
                    onCurrentIndexChanged: {
                        if(currentIndex !==- 1 && !AppStyle.languageChanged) // Need For Do Not change Color When Language Changed
                        {
                            AppStyle.setAppTheme(currentIndex)
                        }
                    }
                }
            }

            RowLayout {
                layoutDirection: Qt.RightToLeft
                Layout.alignment: Text.AlignHCenter
                Text{
                    id:colorText
                    text: qsTr("رنگ اصلی") + " :"
                    font{family: AppStyle.appFont;pixelSize: 30*AppStyle.size1F;bold:false}
                    Layout.alignment: Text.AlignVCenter
                    color: AppStyle.textColor

                }
                AppComboBox{
                    id:primaryCombo
                    hasClear: false
                    placeholderText: qsTr("رنگ‌ها")
                    currentIndex : AppStyle.primaryInt
                    Layout.preferredHeight: 90*AppStyle.size1H
                    font{family: AppStyle.appFont;pixelSize: 30*AppStyle.size1F}
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
                        width: primaryCombo.popupWidth
                        height: 150*AppStyle.size1H
                        Text{
                            text: modelData
                            color: AppStyle.textOnPrimaryColor
                            anchors.centerIn: parent
                            font{family: AppStyle.appFont;pixelSize: 30*AppStyle.size1F}
                        }
                        background: Rectangle { color: Material.color(index) }
                    }
                    onCurrentIndexChanged: {
                        if(currentIndex!==-1 && !AppStyle.languageChanged) // Need For Do Not change Color When Language Changed
                        {
                            AppStyle.primaryInt = currentIndex
                        }
                    }
                }
            }

            RowLayout {
                layoutDirection: Qt.RightToLeft
                Layout.alignment: Text.AlignHCenter
                Text{
                    id: textColorText
                    text: qsTr("رنگ نوشته در رنگ اصلی") + " :"
                    font{family: AppStyle.appFont;pixelSize: 30*AppStyle.size1F;bold:false}
                    Layout.alignment: Qt.AlignRight
                    color: AppStyle.textColor
                    height: primaryCombo.height
                    wrapMode: Text.WordWrap

                }
                AppComboBox{
                    id:textColorCombo
                    hasClear: false
                    placeholderText: qsTr("رنگ‌ها")
                    currentIndex : AppStyle.textOnPrimaryInt
                    Layout.preferredHeight: 90*AppStyle.size1H
                    font{family: AppStyle.appFont;pixelSize: 30*AppStyle.size1F}
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


            RowLayout {
                layoutDirection: Qt.RightToLeft
                Layout.alignment: Text.AlignHCenter
                Text{
                    id:languageText
                    text: qsTr("زبان") + " :"
                    font{family: AppStyle.appFont;pixelSize: 30*AppStyle.size1F;bold:false}
                    Layout.alignment: Text.AlignVCenter
                    color: AppStyle.textColor

                }

                AppComboBox{
                    id:languageCombo
                    hasClear: false
                    placeholderText: qsTr("زبان‌ها")
                    popup.y:height
                    Layout.preferredHeight: 90*AppStyle.size1H
                    currentIndex: translator?UsefulFunc.findInModel(translator?translator.getCurrentLanguage():"","code",langList).index:-1
                    textRole: "name"

                    font{family: AppStyle.appFont;pixelSize: 30*AppStyle.size1F;}
                    onCurrentIndexChanged: {
                        if(currentIndex !== -1 && translator.getCurrentLanguage()!== model.get(currentIndex).code)
                        {
                            AppStyle.languageChanged = true
                            translator.updateLanguage(model.get(currentIndex).code);
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
            RowLayout {
                layoutDirection: Qt.RightToLeft
                Layout.alignment: Text.AlignHCenter
                Text{
                    text: qsTr("اندازه‌ی نوشته") + " :"
                    font{family: AppStyle.appFont;pixelSize: 30*AppStyle.size1F;bold:false}
                    Layout.alignment: Text.AlignVCenter
                    color: AppStyle.textColor

                }
                Slider {
                    id: fontSlider
                    value: 10
                    from: 0
                    to: 40
                    stepSize: 1
                    onValueChanged: {
                        AppStyle.setFontSizes((90+value)/100)
                    }
                }
                AppButton{
                    enabled: fontSlider.value !=10
                    radius: width
                    icon{
                        source: "qrc:/rotate-left.svg"
                        width: 40*AppStyle.size1H
                        height:  40*AppStyle.size1H
                    }
                    onClicked: fontSlider.value = 10
                }
            }
            RowLayout {
                layoutDirection: Qt.RightToLeft
                Layout.alignment: Text.AlignHCenter
                Text{
                    text: qsTr("اندازه‌ی عرض") + " :"
                    font{family: AppStyle.appFont;pixelSize: 30*AppStyle.size1F;bold:false}
                    Layout.alignment: Text.AlignVCenter
                    color: AppStyle.textColor

                }
                Slider {
                    id: widthSlider
                    value: 10
                    from: 0
                    to: 40
                    stepSize: 1
                    onValueChanged: {
                        AppStyle.setWidthSizes((90+value)/100)
                    }
                }
                AppButton{
                    enabled: widthSlider.value !=10
                    radius: width
                    icon{
                        source: "qrc:/rotate-left.svg"
                        width: 40*AppStyle.size1H
                        height:  40*AppStyle.size1H
                    }
                    onClicked: widthSlider.value = 10
                }
            }
            RowLayout {
                layoutDirection: Qt.RightToLeft
                Layout.alignment: Text.AlignHCenter
                Text{
                    text: qsTr("اندازه‌ی ارتفاع") + " :"
                    font{family: AppStyle.appFont;pixelSize: 30*AppStyle.size1F;bold:false}
                    Layout.alignment: Text.AlignVCenter
                    color: AppStyle.textColor

                }
                Slider {
                    id: heightSlider
                    value: 10
                    from: 0
                    to: 40
                    stepSize: 1
                    onValueChanged: {
                        AppStyle.setHeightSizes((90+value)/100)
                    }
                }
                AppButton{
                    enabled: heightSlider.value !=10
                    radius: width
                    icon{
                        source: "qrc:/rotate-left.svg"
                        width: 40*AppStyle.size1W
                        height:  40*AppStyle.size1H
                    }
                    onClicked: heightSlider.value = 10
                }
            }
        }
    }
}


