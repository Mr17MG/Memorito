import QtQuick 2.15 // Require For Item and Flow and ...
import QtQuick.Controls 2.15 // Require for ItemDelegate
import QtQuick.Controls.Material 2.15 // Require for
import QtGraphicalEffects 1.15 // Require for  ColorOverlay
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
        id:flick
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
        clip: true
        ColumnLayout{
            id:flow1
            width: flick.width
            spacing: 20*AppStyle.size1H
            layoutDirection: Qt.RightToLeft
            RowLayout {
                layoutDirection: Qt.RightToLeft
                Layout.fillWidth: true
                Text{
                    text: qsTr("تغییر زبان")
                    font{family: AppStyle.appFont;pixelSize: 30*AppStyle.size1F;bold:false}
                    color: AppStyle.textColor
                }
                MenuSeparator{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentItem: Rectangle {
                        radius: width
                        opacity: 0.2
                        color: Material.color(AppStyle.primaryInt,Material.ShadeA100)
                    }
                }
            }

            RowLayout {
                layoutDirection: Qt.RightToLeft
                Layout.fillWidth: true
                Text{
                    ToolTip{ id:langTooltip }
                    HoverHandler{
                        acceptedDevices: PointerDevice.Mouse
                        onHoveredChanged: {
                            if(hovered)
                                langTooltip.show("Alt + L")
                            else langTooltip.hide()
                        }
                    }
                    id:languageText
                    text: qsTr("زبان") + " :"
                    font{family: AppStyle.appFont;pixelSize: 25*AppStyle.size1F;bold:false}
                    verticalAlignment: Text.AlignVCenter
                    Layout.fillHeight: true
                    color: AppStyle.textColor
                    Layout.minimumWidth: textColorText.width
                }

                AppRadioButton{
                    text: "فارسی"
                    checked: try{
                                 return translator.getCurrentLanguage() === translator.getLanguages().FA && !AppStyle.languageChanged
                             }
                             catch(e){return false}
                    onCheckedChanged: {
                        try{
                            if(translator.getCurrentLanguage() !== translator.getLanguages().FA)
                            {
                                AppStyle.languageChanged = true
                                translator.updateLanguage(translator.getLanguages().FA)
                                AppStyle.languageChanged = false
                            }
                        }catch(e){}
                    }
                }
                AppRadioButton{
                    text: "English"
                    checked: try{
                                 return translator.getCurrentLanguage() === translator.getLanguages().ENG && !AppStyle.languageChanged
                             }
                             catch(e){
                                 return false
                             }
                    onCheckedChanged: {
                        try{
                            if(translator.getCurrentLanguage() !== translator.getLanguages().ENG)
                            {
                                AppStyle.languageChanged = true
                                translator.updateLanguage(translator.getLanguages().ENG)
                                AppStyle.languageChanged = false
                            }
                        }catch(e){}
                    }
                }

            }
            RowLayout {
                layoutDirection: Qt.RightToLeft
                Layout.fillWidth: true
                Text{
                    text: qsTr("شخصی‌سازی")
                    font{family: AppStyle.appFont;pixelSize: 30*AppStyle.size1F;bold:false}
                    Layout.fillHeight: true

                    verticalAlignment: Text.AlignVCenter
                    color: AppStyle.textColor
                }
                MenuSeparator{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentItem: Rectangle {
                        radius: width
                        opacity: 0.2
                        color: Material.color(AppStyle.primaryInt,Material.ShadeA100)
                    }
                }
            }
            RowLayout {
                layoutDirection: Qt.RightToLeft
                spacing: 20*AppStyle.size1W
                Layout.fillWidth: true
                Text{
                    id:pageText
                    text: qsTr("صفحه ابتدایی") + " :"
                    font{family: AppStyle.appFont;pixelSize: 25*AppStyle.size1F;bold:false}
                    color: AppStyle.textColor
                    Layout.fillHeight: true
                    Layout.minimumWidth: textColorText.width
                    verticalAlignment: Text.AlignVCenter
                }
                AppComboBox{
                    id: pageCombo
                    hasClear: false
                    placeholderText: qsTr("صفحات")
                    Layout.preferredWidth: 270*AppStyle.size1W
                    Layout.preferredHeight: 90*AppStyle.size1H
                    font{family: AppStyle.appFont;pixelSize: 25*AppStyle.size1F}
                    textRole: "title"
                    iconRole: "iconSrc"
                    iconColor: AppStyle.textColor
                    iconSize: AppStyle.size1W*40
                    currentIndex: UsefulFunc.findInModel(Number(SettingDriver.value("firstPage",0)),"listId",model).index
                    model: ListModel{
                        ListElement{
                            title:qsTr("خانه")
                            pageSource :""
                            iconSrc: "qrc:/home.svg"
                            listId: 0
                        }
                        ListElement{
                            title: qsTr("جمع‌آوری")
                            pageSource :"qrc:/Things/AddEditThing.qml"
                            iconSrc: "qrc:/collect.svg"
                            listId: Memorito.Collect
                        }
                        ListElement{
                            title:qsTr("پردازش نشده‌ها")
                            iconSrc: "qrc:/process.svg"
                            pageSource: "qrc:/Things/ThingList.qml"
                            listId: Memorito.Process
                        }
                        ListElement{
                            title:qsTr("عملیات بعدی")
                            iconSrc: "qrc:/nextAction.svg"
                            pageSource: "qrc:/Things/ThingList.qml"
                            listId: Memorito.NextAction
                        }
                        ListElement{
                            title:qsTr("تقویم")
                            iconSrc: "qrc:/calendar.svg"
                            pageSource: "qrc:/Things/ThingList.qml"
                            listId: Memorito.Calendar
                        }
                        ListElement{
                            title:qsTr("پروژه‌ها")
                            iconSrc: "qrc:/project.svg"
                            pageSource: "qrc:/Categories/CategoriesList.qml"
                            listId: Memorito.Project
                        }
                    }
                    onCurrentIndexChanged: {
                        if(currentIndex!==-1 && !AppStyle.languageChanged) // Need For Do Not change Color When Language Changed
                        {
                            SettingDriver.setValue("firstPage",model.get(currentIndex).listId)
                        }
                    }
                }

                Item{ Layout.fillWidth: true }
            }
            RowLayout {
                layoutDirection: Qt.RightToLeft
                spacing: 20*AppStyle.size1W
                Layout.fillWidth: true
                Text{
                    ToolTip{ id: textTooltip }
                    HoverHandler{
                        acceptedDevices: PointerDevice.Mouse
                        onHoveredChanged: {
                            if(hovered)
                                textTooltip.show(qsTr("قبلی")+": Alt + [\n"+qsTr("بعدی")+": Alt + ]")
                            else textTooltip.hide()
                        }
                    }
                    id:colorText
                    text: qsTr("رنگ اصلی") + " :"
                    font{family: AppStyle.appFont;pixelSize: 25*AppStyle.size1F;bold:false}
                    color: AppStyle.textColor
                    Layout.fillHeight: true
                    Layout.minimumWidth: textColorText.width
                    verticalAlignment: Text.AlignVCenter
                }
                AppComboBox{
                    id:primaryCombo
                    hasClear: false
                    placeholderText: qsTr("رنگ‌ها")
                    Layout.preferredWidth: 270*AppStyle.size1W
                    currentIndex : AppStyle.primaryInt
                    Layout.preferredHeight: 90*AppStyle.size1H
                    font{family: AppStyle.appFont;pixelSize: 25*AppStyle.size1F}
                    placeholderIcon: "qrc:/paint.svg"
                    iconColor: AppStyle.textColor
                    iconSize: AppStyle.size1W*45
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
                        height: 120*AppStyle.size1H
                        Text{
                            text: modelData
                            color:Material.color(index)
                            anchors.centerIn: parent
                            font{family: AppStyle.appFont;pixelSize: 30*AppStyle.size1F;bold:true}
                        }
//                        background: Rectangle { color: Material.color(index) }
                        Image {
                            id: iconImg
                            visible: false
                            anchors{
                                verticalCenter: parent.verticalCenter
                                right: parent.right
                                rightMargin: 10*AppStyle.size1W
                            }
                            source: "qrc:/paint.svg"
                            width: AppStyle.size1W*55
                            height: width
                            sourceSize: Qt.size(width,height)
                        }
                        ColorOverlay{
                            source : iconImg
                            anchors.fill: iconImg
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

                Item{ Layout.fillWidth: true }
            }

            RowLayout {
                layoutDirection: Qt.RightToLeft
                Layout.fillWidth: true
                spacing: 20*AppStyle.size1W
                Text{
                    ToolTip{ id: themeTooltip}
                    HoverHandler{
                        acceptedDevices: PointerDevice.Mouse
                        onHoveredChanged: {
                            if(hovered)
                                themeTooltip.show("Alt + T")
                            else themeTooltip.hide()
                        }
                    }
                    id: themeText
                    color: AppStyle.textColor
                    text: qsTr("طرح زمینه") + " :"
                    font{family: AppStyle.appFont;pixelSize: 25*AppStyle.size1F;bold:false}
                    Layout.fillHeight: true
                    verticalAlignment: Text.AlignVCenter
                    Layout.minimumWidth: textColorText.width
                }

                AppRadioButton{
                    text: qsTr("روشن")
                    checked: AppStyle.appTheme === 0 && !AppStyle.languageChanged
                    onCheckedChanged: {
                        if(checked && !AppStyle.languageChanged) // Need For Do Not change Color When Language Changed
                        {
                            AppStyle.setAppTheme(0)
                        }
                    }
                }
                AppRadioButton{
                    text: qsTr("تیره")
                    checked: AppStyle.appTheme === 1 && !AppStyle.languageChanged
                    onCheckedChanged: {
                        if(checked && !AppStyle.languageChanged) // Need For Do Not change Color When Language Changed
                        {
                            AppStyle.setAppTheme(1)
                        }
                    }
                }
            }

            RowLayout {
                layoutDirection: Qt.RightToLeft
                spacing: 20*AppStyle.size1W
                Layout.fillWidth: true
                ToolTip{ id: pTextTooltip}
                HoverHandler{
                    acceptedDevices: PointerDevice.Mouse
                    onHoveredChanged: {
                        if(hovered)
                            pTextTooltip.show("Alt + Y")
                        else pTextTooltip.hide()
                    }
                }
                Text{
                    id: textColorText
                    text: qsTr("رنگ نوشته در رنگ اصلی") + " :"
                    font{family: AppStyle.appFont;pixelSize: 25*AppStyle.size1F;bold:false}
                    Layout.alignment: Qt.AlignRight
                    color: AppStyle.textColor
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }

                AppRadioButton{
                    text: qsTr("سفید")
                    checked: AppStyle.textOnPrimaryInt === 0 && !AppStyle.languageChanged
                    onCheckedChanged: {
                        if(checked && !AppStyle.languageChanged) // Need For Do Not change Color When Language Changed
                        {
                            AppStyle.textOnPrimaryInt = 0
                        }
                    }
                }
                AppRadioButton{
                    text: qsTr("مشکی")
                    checked: AppStyle.textOnPrimaryInt === 1 && !AppStyle.languageChanged
                    onCheckedChanged: {
                        if(checked && !AppStyle.languageChanged) // Need For Do Not change Color When Language Changed
                        {
                            AppStyle.textOnPrimaryInt = 1
                        }
                    }
                }
                Item{ Layout.fillWidth: true }
            }
            RowLayout {
                layoutDirection: Qt.RightToLeft
                Layout.fillWidth: true
                Text{
                    text: qsTr("تغییر اندازه‌ها")
                    font{family: AppStyle.appFont;pixelSize: 30*AppStyle.size1F;bold:false}
                    color: AppStyle.textColor
                }
                MenuSeparator{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentItem: Rectangle {
                        radius: width
                        opacity: 0.2
                        color: Material.color(AppStyle.primaryInt,Material.ShadeA100)
                    }
                }
            }

            RowLayout {
                layoutDirection: Qt.RightToLeft
                Layout.fillWidth: true
                Text{
                    text: qsTr("اندازه‌ی نوشته") + " :"
                    font{family: AppStyle.appFont;pixelSize: 25*AppStyle.size1F;bold:false}
                    color: AppStyle.textColor
                }
                Slider {
                    id: fontSlider
                    value: AppStyle.scaleF*100 - 90
                    from: 0
                    to: 40
                    stepSize: 1
                    Layout.fillWidth: true
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
                Item{ Layout.fillWidth: true }
            }

            RowLayout {
                layoutDirection: Qt.RightToLeft
                Layout.fillWidth: true
                Text{
                    text: qsTr("اندازه‌ی عرض") + " :"
                    font{family: AppStyle.appFont;pixelSize: 25*AppStyle.size1F;bold:false}
                    color: AppStyle.textColor
                }
                Slider {
                    id: widthSlider
                    value: AppStyle.scaleW*100 - 90
                    from: 0
                    to: 40
                    stepSize: 1
                    Layout.fillWidth: true
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
                Layout.fillWidth: true

                Text{
                    text: qsTr("اندازه‌ی ارتفاع") + " :"
                    font{family: AppStyle.appFont;pixelSize: 25*AppStyle.size1F;bold:false}
                    color: AppStyle.textColor
                }

                Slider {
                    id: heightSlider
                    value: AppStyle.scaleH*100 - 90
                    from: 0
                    to: 40
                    stepSize: 1
                    Layout.fillWidth: true
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
                Item{ Layout.fillWidth: true }
            }
        }
    }
}


