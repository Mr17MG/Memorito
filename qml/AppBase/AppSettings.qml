import QtQuick  // Require For Item and Flow and ...
import QtQuick.Controls  // Require for ItemDelegate
import QtQuick.Controls.Material  // Require for
import Qt5Compat.GraphicalEffects // Require for  ColorOverlay
import Memorito.Components  // // Require for  Switch and
import Memorito.Global
import QtQuick.Layouts 1.15

Item {

    Rectangle{
        color: "transparent"
        radius: 30*AppStyle.size1W

        border {
            color: Material.color(AppStyle.primaryInt,Material.Shade100)
            width: 4*AppStyle.size1W
        }

        anchors {
            top: parent.top
            topMargin: 20*AppStyle.size1H
            right: parent.right
            rightMargin: 20*AppStyle.size1W
            left: parent.left
            leftMargin: 20*AppStyle.size1W
            bottom: parent.bottom
            bottomMargin: 20*AppStyle.size1H
        }
    }

    Flickable {
        id:flick

        clip: true
        contentWidth: flow1.width
        contentHeight: flow1.height

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

        ColumnLayout {
            id:flow1

            spacing: 20*AppStyle.size1H
            layoutDirection: Qt.RightToLeft
            width: Math.max(flick.width,600*AppStyle.size1W)

            RowLayout {
                layoutDirection: Qt.RightToLeft
                Layout.fillWidth: true

                Text {
                    text: qsTr("تغییر زبان")
                    color: AppStyle.textColor
                    font {
                        family: AppStyle.appFont;
                        pixelSize: 30*AppStyle.size1F;
                    }
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
                Layout.fillWidth: true
                layoutDirection: Qt.RightToLeft

                Text{
                    id:languageText
                    ToolTip{ id:langTooltip }

                    HoverHandler{
                        acceptedDevices: PointerDevice.Mouse
                        onHoveredChanged: {
                            if(hovered)
                                langTooltip.show("Alt + L")
                            else langTooltip.hide()
                        }
                    }

                    text: qsTr("زبان") + " :"
                    Layout.fillHeight: true
                    color: AppStyle.textColor
                    verticalAlignment: Text.AlignVCenter
                    Layout.minimumWidth: textColorText.width
                    font {
                        family: AppStyle.appFont;
                        pixelSize: 25*AppStyle.size1F;
                    }
                }

                AppRadioButton{
                    text: "فارسی"
                    checked:{
                        try {
                            return translator.getCurrentLanguage() === translator.getLanguages().FA && !AppStyle.languageChanged
                        }
                        catch(e){
                            return false
                        }
                    }

                    onCheckedChanged: {
                        try{
                            if(translator.getCurrentLanguage() !== translator.getLanguages().FA)
                            {
                                AppStyle.languageChanged = true
                                translator.updateLanguage(translator.getLanguages().FA)
                                AppStyle.languageChanged = false
                            }
                        }
                        catch(e){
                        }
                    }
                }
                AppRadioButton{
                    text: "English"
                    checked:{
                        try{
                            return translator.getCurrentLanguage() === translator.getLanguages().ENG && !AppStyle.languageChanged
                        }
                        catch(e){
                            return false
                        }
                    }

                    onCheckedChanged: {
                        try{
                            if(translator.getCurrentLanguage() !== translator.getLanguages().ENG)
                            {
                                AppStyle.languageChanged = true
                                translator.updateLanguage(translator.getLanguages().ENG)
                                AppStyle.languageChanged = false
                            }
                        }
                        catch(e){
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                layoutDirection: Qt.RightToLeft

                Text{
                    text: qsTr("شخصی‌سازی")
                    Layout.fillHeight: true
                    color: AppStyle.textColor
                    verticalAlignment: Text.AlignVCenter
                    font {
                        family: AppStyle.appFont;
                        pixelSize: 30*AppStyle.size1F;
                    }
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
                Layout.fillWidth: true
                spacing: 20*AppStyle.size1W
                layoutDirection: Qt.RightToLeft

                Text{
                    id:pageText

                    Layout.fillHeight: true
                    color: AppStyle.textColor
                    text: qsTr("صفحه ابتدایی") + " :"
                    verticalAlignment: Text.AlignVCenter
                    Layout.minimumWidth: textColorText.width

                    font {
                        family: AppStyle.appFont;
                        pixelSize: 25*AppStyle.size1F;
                    }
                }

                AppComboBox{
                    id: pageCombo

                    hasClear: false
                    textRole: "title"
                    iconRole: "iconSrc"
                    iconSize: AppStyle.size1W*40
                    iconColor: AppStyle.textColor
                    placeholderText: qsTr("صفحات")
                    Layout.preferredHeight: 90*AppStyle.size1H
                    Layout.preferredWidth: 270*AppStyle.size1W
                    currentIndex: UsefulFunc.findInModel(Number(SettingDriver.value("firstPage",0)),"listId",model).index

                    font {
                        family: AppStyle.appFont;
                        pixelSize: 25*AppStyle.size1F
                    }

                    model: ListModel {
                        ListElement {
                            listId: 0
                            pageSource :""
                            title:qsTr("خانه")
                            iconSrc: "qrc:/home.svg"
                        }
                        ListElement {
                            title: qsTr("جمع‌آوری")
                            listId: Memorito.Collect
                            iconSrc: "qrc:/collect.svg"
                            pageSource :"qrc:/Things/AddEditThing.qml"
                        }
                        ListElement {
                            listId: Memorito.Process
                            title:qsTr("پردازش نشده‌ها")
                            iconSrc: "qrc:/process.svg"
                            pageSource: "qrc:/Things/ThingList.qml"
                        }
                        ListElement {
                            title:qsTr("عملیات بعدی")
                            listId: Memorito.NextAction
                            iconSrc: "qrc:/nextAction.svg"
                            pageSource: "qrc:/Things/ThingList.qml"
                        }
                        ListElement {
                            title:qsTr("تقویم")
                            listId: Memorito.Calendar
                            iconSrc: "qrc:/calendar.svg"
                            pageSource: "qrc:/Things/ThingList.qml"
                        }
                        ListElement{
                            title:qsTr("پروژه‌ها")
                            listId: Memorito.Project
                            iconSrc: "qrc:/project.svg"
                            pageSource: "qrc:/Categories/CategoriesList.qml"
                        }
                    }
                    onCurrentIndexChanged: {
                        if(currentIndex !== -1 && !AppStyle.languageChanged) // Need For Do Not change Color When Language Changed
                        {
                            SettingDriver.setValue("firstPage",model.get(currentIndex).listId)
                        }
                    }
                }

                Item{ Layout.fillWidth: true }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 20*AppStyle.size1W
                layoutDirection: Qt.RightToLeft

                Text{
                    id:colorText

                    ToolTip{ id: textTooltip }
                    HoverHandler{
                        acceptedDevices: PointerDevice.Mouse
                        onHoveredChanged: {
                            if(hovered)
                                textTooltip.show(qsTr("قبلی")+": Alt + [\n"+qsTr("بعدی")+": Alt + ]")
                            else textTooltip.hide()
                        }
                    }

                    text: qsTr("رنگ اصلی") + " :"
                    color: AppStyle.textColor
                    Layout.fillHeight: true
                    Layout.minimumWidth: textColorText.width
                    verticalAlignment: Text.AlignVCenter
                    font{
                        family: AppStyle.appFont;
                        pixelSize: 25*AppStyle.size1F;
                    }
                }

                AppComboBox{
                    id:primaryCombo
                    hasClear: false
                    iconSize: AppStyle.size1W*45
                    iconColor: AppStyle.textColor
                    placeholderText: qsTr("رنگ‌ها")
                    placeholderIcon: "qrc:/paint.svg"
                    currentIndex : AppStyle.primaryInt
                    Layout.preferredHeight: 90*AppStyle.size1H
                    Layout.preferredWidth: 270*AppStyle.size1W

                    font{
                        family: AppStyle.appFont;
                        pixelSize: 25*AppStyle.size1F
                    }

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

                        // background: Rectangle { color: Material.color(index) }
                        Text{
                            text: modelData
                            color:Material.color(index)
                            anchors.centerIn: parent
                            font{family: AppStyle.appFont;pixelSize: 30*AppStyle.size1F;bold:true}
                        }

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
                        if(currentIndex !== -1 && !AppStyle.languageChanged) // Need For Do Not change Color When Language Changed
                        {
                            AppStyle.primaryInt = currentIndex
                        }
                    }
                }

                Item{ Layout.fillWidth: true }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 20*AppStyle.size1W
                layoutDirection: Qt.RightToLeft

                Text{
                    id: themeText

                    ToolTip{ id: themeTooltip}
                    HoverHandler{
                        acceptedDevices: PointerDevice.Mouse
                        onHoveredChanged: {
                            if(hovered)
                                themeTooltip.show("Alt + T")
                            else themeTooltip.hide()
                        }
                    }

                    color: AppStyle.textColor
                    text: qsTr("طرح زمینه") + " :"
                    Layout.fillHeight: true
                    verticalAlignment: Text.AlignVCenter
                    Layout.minimumWidth: textColorText.width

                    font{
                        family: AppStyle.appFont;
                        pixelSize: 25*AppStyle.size1F;
                    }
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
                spacing: 20*AppStyle.size1W
                Layout.fillWidth: true
                layoutDirection: Qt.RightToLeft
                Text{
                    id: textColorText

                    ToolTip{ id: pTextTooltip}
                    HoverHandler{
                        acceptedDevices: PointerDevice.Mouse
                        onHoveredChanged: {
                            if(hovered)
                                pTextTooltip.show("Alt + Y")
                            else pTextTooltip.hide()
                        }
                    }

                    wrapMode: Text.WordWrap
                    color: AppStyle.textColor
                    Layout.alignment: Qt.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    text: qsTr("رنگ نوشته در رنگ اصلی") + " :"

                    font {
                        family: AppStyle.appFont;
                        pixelSize: 25*AppStyle.size1F
                    }
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
                Layout.fillWidth: true
                layoutDirection: Qt.RightToLeft

                Text{
                    color: AppStyle.textColor
                    text: qsTr("تغییر اندازه‌ها")
                    font {
                        family: AppStyle.appFont;
                        pixelSize: 30*AppStyle.size1F
                    }
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
                Layout.fillWidth: true
                layoutDirection: Qt.RightToLeft

                Text{
                    text: qsTr("اندازه‌ی نوشته") + " :"
                    color: AppStyle.textColor
                    font {
                        family: AppStyle.appFont;
                        pixelSize: 25*AppStyle.size1F
                    }
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
                    enabled: fontSlider.value !==10
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
                Layout.fillWidth: true
                layoutDirection: Qt.RightToLeft

                Text{
                    text: qsTr("اندازه‌ی عرض") + " :"
                    color: AppStyle.textColor
                    Layout.preferredWidth: 150*AppStyle.size1H

                    font {
                        family: AppStyle.appFont;
                        pixelSize: 25*AppStyle.size1F
                    }
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
                    enabled: widthSlider.value !==10
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
                    enabled: heightSlider.value !==10
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


