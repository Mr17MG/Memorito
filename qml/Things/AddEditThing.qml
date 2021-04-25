import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtGraphicalEffects 1.14
import QtQuick.Layouts 1.15

import Components 1.0
import Global 1.0
import QDateConvertor 1.0
Item {

    ListModel { id: attachModel }

    property bool isDual: prevPageModel ? true : false
    property var prevPageModel
    property var options: []
    property int listId: -1
    property int categoryId: -1

    function cameInToPage(object)
    {
        if (object)
        {
            if (object.thingLocalId)
            {
                prevPageModel = ThingsApi.getThingByLocalId(object.thingLocalId)

                if (prevPageModel.has_files === 1)
                {
                    FilesApi.getFiles(attachModel, prevPageModel.id)
                }
                if (listId === Memorito.Process)
                    collectLoader.item.submitBtn.isUpdate = true
            }
        }
    }

    function checking()
    {
        if(titleInput.text.trim() === "")
        {
            UsefulFunc.showLog(qsTr("لطفا قسمت 'چی تو دهنته؟' رو پر کن"),true)
            titleMoveAnimation.start()
            return 2
        }
        if (attachModel.count > 0) {
            for (var i = 0; i < attachModel.count; i++)
                if (attachModel.get(i).change_type !== 3)
                {
                    return 1
                }
        }
        return 0
    }

    Flickable {
        id: mainFlick
        height: parent.height
        width: nRow == 3 && (listId === Memorito.Process
                             || listId === Memorito.Collect)
               && isDual ? parent.width / 2 : parent.width
        clip: true
        contentHeight: mainFlow.height + 120*AppStyle.size1W
        anchors {
            right: parent.right
            top: parent.top
        }
        flickableDirection: Flickable.VerticalFlick
        onContentYChanged: {
            if (contentY < 0 || contentHeight < mainFlick.height)
                contentY = 0
            else if (contentY > (contentHeight - mainFlick.height))
                contentY = contentHeight - mainFlick.height
        }
        onContentXChanged: {
            if (contentX < 0 || contentWidth < mainFlick.width)
                contentX = 0
            else if (contentX > (contentWidth - mainFlick.width))
                contentX = (contentWidth - mainFlick.width)
        }
        ScrollBar.vertical: ScrollBar {
            hoverEnabled: true
            active: hovered || pressed
            orientation: Qt.Vertical
            anchors.right: mainFlick.right
            height: parent.height
            width: hovered || pressed ? 18 * AppStyle.size1W : 8 * AppStyle.size1W
        }

        Flow {
            id: mainFlow
            width: parent.width
            spacing: 25 * AppStyle.size1H
            anchors {
                top: parent.top
                topMargin: 15 * AppStyle.size1H
                right: parent.right
                rightMargin: 25 * AppStyle.size1W
                left: parent.left
                leftMargin: 25 * AppStyle.size1W
            }

            Item {
                id: titleItem
                width: parent.width
                height: 100 * AppStyle.size1H
                AppTextInput {
                    id: titleInput
                    placeholderText: qsTr("چی تو ذهنته؟")
                    text: prevPageModel ? prevPageModel.title ?? "" : ""
                    width: parent.width
                    height: parent.height
                    inputMethodHints: Qt.ImhPreferLowercase
                    font.bold: false
                    maximumLength: 50
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                    }
                }
                SequentialAnimation {
                    id: titleMoveAnimation
                    running: false
                    loops: 3
                    NumberAnimation {
                        target: titleInput
                        property: "anchors.horizontalCenterOffset"
                        to: -10
                        duration: 50
                    }
                    NumberAnimation {
                        target: titleInput
                        property: "anchors.horizontalCenterOffset"
                        to: 10
                        duration: 100
                    }
                    NumberAnimation {
                        target: titleInput
                        property: "anchors.horizontalCenterOffset"
                        to: 0
                        duration: 50
                    }
                }
            }
            SplitView {
                width: parent.width
                height: 190 * AppStyle.size1H + Math.max( (mainFlick.height - titleItem.height - 415 * AppStyle.size1H),450 * AppStyle.size1H)

                orientation: Qt.Vertical
                spacing: 100 * AppStyle.size1W
                Item{
                    SplitView.minimumHeight: 100 * AppStyle.size1H
                    SplitView.preferredHeight: 240 * AppStyle.size1H
                    AppFlickTextArea {
                        id: flickTextArea
                        placeholderText: qsTr(
                                             "توضیحاتی از چیزی که تو ذهنته رو بنویس") + " (" + qsTr(
                                             "اختیاری") + ")"
                        text: prevPageModel ? prevPageModel.detail ?? "" : ""
                        width: parent.width
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 10*AppStyle.size1H
                    }
                }
                Item{
                    SplitView.minimumHeight: 275 * AppStyle.size1H
                    SplitView.preferredHeight: 450 * AppStyle.size1W
                    AppFilesSelection {
                        id: fileRect
                        width: parent.width
                        anchors{
                            top: parent.top
                            topMargin: 10*AppStyle.size1H
                            bottom: parent.bottom
                        }
                        model: attachModel
                    }
                }
            }

            Loader {
                id: optionLoader
                width: flickTextArea.width
                active: listId !== Memorito.Collect && listId !== Memorito.Process
                height: active ? 600 * AppStyle.size1H : 0
                sourceComponent: optionsComponent
            }

            Loader {
                id: collectLoader
                width: flickTextArea.width
                height: active ? (
                                     (   listId === Memorito.Project
                                      || listId === Memorito.Someday
                                      || listId === Memorito.Waiting
                                      || listId === Memorito.Calendar
                                      || listId === Memorito.Refrence) ? 220 * AppStyle.size1H
                                                                       : 110 * AppStyle.size1H
                                     )
                               : 0
                sourceComponent: listId === Memorito.NextAction ? nextComponent : listId === Memorito.Someday ? somedayComponent : listId === Memorito.Refrence ? refrenceComponent : listId === Memorito.Waiting ? friendComponent : listId === Memorito.Calendar ? calendarComponent : listId === Memorito.Trash ? trashComponent : listId === Memorito.Done ? doComponent : listId === Memorito.Project ? projectCategoryComponent : collectComponent
            }

            Loader {
                id: processLoader
                width: flickTextArea.width
                height: active ? 1800 * AppStyle.size1W : 0
                active: nRow <= 2
                        && (listId === Memorito.Process
                            || listId === Memorito.Collect) && isDual
                sourceComponent: processComponent
                visible: active
            }
        } // end of Flow
    } //end of Flickable

    Loader {
        active: nRow === 3 && (listId === Memorito.Process
                               || listId === Memorito.Collect) && isDual
        width: parent.width / 2
        height: active ? mainFlick.height : 0
        asynchronous: true
        anchors {
            top: parent.top
            topMargin: 15 * AppStyle.size1H
            left: parent.left
            leftMargin: 25 * AppStyle.size1W
        }
        sourceComponent: Flickable {
            id: secondFlick
            contentHeight: processLoader2.height
            flickableDirection: Flickable.VerticalFlick
            onContentYChanged: {
                if (contentY < 0 || contentHeight < secondFlick.height)
                    contentY = 0
                else if (contentY > (contentHeight - secondFlick.height))
                    contentY = contentHeight - secondFlick.height
            }
            onContentXChanged: {
                if (contentX < 0 || contentWidth < secondFlick.width)
                    contentX = 0
                else if (contentX > (contentWidth - secondFlick.width))
                    contentX = (contentWidth - secondFlick.width)
            }

            ScrollBar.vertical: ScrollBar {
                hoverEnabled: true
                active: hovered || pressed
                orientation: Qt.Vertical
                anchors.right: secondFlick.right
                height: parent.height
                width: hovered || pressed ? 18 * AppStyle.size1W : 8 * AppStyle.size1W
            }

            Loader {
                id: processLoader2
                width: parent.width
                height: 2000 * AppStyle.size1H
                active: true
                asynchronous: true
                sourceComponent: processComponent
            }
        } //end of Flickable
    } //end of Loader

    Component {
        id: processComponent
        Item {
            Flow {
                anchors {
                    top: parent.top
                    right: parent.right
                    rightMargin: 15 * AppStyle.size1W
                    bottom: parent.bottom
                    bottomMargin: 20 * AppStyle.size1H
                    left: parent.left
                    leftMargin: 15 * AppStyle.size1W
                }
                spacing: 10 * AppStyle.size1H

                Loader {
                    id: optionsLoader
                    width: parent.width
                    height: 620 * AppStyle.size1H
                    sourceComponent: optionsComponent
                }
                /*********** انجام نشدنی‌ها*****************/
                Text {
                    id: actionText
                    text: "⏺ " + qsTr("این چیز انجام شدنی نیست") + ":"
                    width: parent.width
                    color: AppStyle.textColor
                    font {
                        family: AppStyle.appFont
                        pixelSize: AppStyle.size1F * 30
                        bold: true
                    }
                }

                AppRadioButton {
                    id: somedayRadio
                    text: qsTr("شاید یک روزی این را انجام دادم")
                    width: parent.width
                    rightPadding: 50 * AppStyle.size1W
                }
                Loader {
                    id: somedayLoader
                    width: parent.width
                    height: somedayRadio.checked ? 240 * AppStyle.size1W : 0
                    active: height !== 0
                    Behavior on height {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                    clip: true
                    sourceComponent: somedayComponent
                }

                /*********************************/
                AppRadioButton {
                    id: refrenceRadio
                    text: qsTr(
                              "اطلاعات مفیدی است میخواهم بعدا به آن مراجعه کنم")
                    width: parent.width
                    rightPadding: 50 * AppStyle.size1W
                }
                Loader {
                    id: refrenceLoader
                    width: parent.width
                    height: refrenceRadio.checked ? 240 * AppStyle.size1W : 0
                    active: height !== 0
                    Behavior on height {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                    clip: true
                    sourceComponent: refrenceComponent
                }

                /*********************************/
                AppRadioButton {
                    id: trashRadio
                    text: qsTr("اطلاعات به درد نخوری است میخواهم به سطل آشغال بیاندازم")
                    width: parent.width
                    rightPadding: 50 * AppStyle.size1W
                }
                Loader {
                    id: trashLoader
                    width: parent.width
                    height: trashRadio.checked ? 120 * AppStyle.size1W : 0
                    active: height !== 0
                    Behavior on height {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                    clip: true
                    sourceComponent: trashComponent
                }
                /*********************************/
                /*********** انجام نشدنی‌ها*****************/

                /*********** انجام شدنی‌ها*****************/
                /*********************************/
                Text {
                    id: action2Text
                    text: "⏺ " + qsTr("این چیز انجام شدنی است") + ":"
                    width: parent.width
                    color: AppStyle.textColor
                    font {
                        family: AppStyle.appFont
                        pixelSize: AppStyle.size1F * 30
                        bold: true
                    }
                }

                /*********************************/
                Text {
                    id: action3Text
                    text: "⏺ " + qsTr(
                              "این چیز با یک انجام یک عمل به پایان نمی‌رسد") + ":"
                    width: parent.width
                    color: AppStyle.textColor
                    height: 50 * AppStyle.size1H
                    verticalAlignment: Text.AlignBottom
                    font {
                        family: AppStyle.appFont
                        pixelSize: AppStyle.size1F * 24
                        bold: true
                    }
                    rightPadding: 50 * AppStyle.size1W
                }
                AppRadioButton {
                    id: projectRadio
                    text: qsTr("می‌خواهم یک پروژه جدید بسازم")
                    width: parent.width
                    rightPadding: 80 * AppStyle.size1W
                }
                Loader {
                    id: projectLoader
                    active: height !== 0
                    width: parent.width
                    height: projectRadio.checked ? 120 * AppStyle.size1W : 0
                    Behavior on height {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                    clip: true
                    sourceComponent: projectComponent
                }

                /*********************************/
                AppRadioButton {
                    id: projectCategoryRadio
                    text: qsTr("می‌خواهم این عمل را به پروژه های قدیمی اضافه کنم")
                    width: parent.width
                    rightPadding: 80 * AppStyle.size1W
                }
                Loader {
                    id: projectCategoryLoader
                    active: height !== 0
                    width: parent.width
                    height: projectCategoryRadio.checked ? 240 * AppStyle.size1W : 0
                    Behavior on height {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                    clip: true
                    sourceComponent: projectCategoryComponent
                }

                /*********************************/
                Text {
                    id: action4Text
                    text: "⏺ " + qsTr(
                              "این عمل بیشتر از ۵ دقیقه زمان نیاز دارد") + ":"
                    width: parent.width
                    color: AppStyle.textColor
                    height: 50 * AppStyle.size1H
                    verticalAlignment: Text.AlignBottom
                    font {
                        family: AppStyle.appFont
                        pixelSize: AppStyle.size1F * 24
                        bold: true
                    }
                    rightPadding: 50 * AppStyle.size1W
                }
                AppRadioButton {
                    id: friendRadio
                    text: qsTr("می‌خواهم این را شخص دیگری انجام دهد")
                    width: parent.width
                    rightPadding: 80 * AppStyle.size1W
                }
                Loader {
                    id: friendLoader
                    active: height !== 0
                    width: parent.width
                    height: friendRadio.checked ? 240 * AppStyle.size1W : 0
                    Behavior on height {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                    clip: true
                    sourceComponent: friendComponent
                }

                /*********************************/
                AppRadioButton {
                    id: calendarRadio
                    text: qsTr("می‌خواهم این عمل را در زمان مشخصی انجام دهم")
                    width: parent.width
                    rightPadding: 80 * AppStyle.size1W
                }
                Loader {
                    id: calendarLoader
                    active: height !== 0
                    width: parent.width
                    height: calendarRadio.checked ? 320 * AppStyle.size1W : 0
                    Behavior on height {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                    clip: true
                    sourceComponent: calendarComponent
                }

                /*********************************/
                AppRadioButton {
                    id: nextRadio
                    text: qsTr("می‌خواهم این عمل را در بعدا انجام دهم")
                    width: parent.width
                    rightPadding: 80 * AppStyle.size1W
                }

                Loader {
                    id: nextLoader
                    active: height !== 0
                    width: parent.width
                    height: nextRadio.checked ? 120 * AppStyle.size1W : 0
                    Behavior on height {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                    clip: true
                    sourceComponent: nextComponent
                }

                /*********************************/
                Text {
                    id: action5Text
                    text: "⏺ " + qsTr(
                              "این عمل کمتر از ۵ دقیقه انجام می‌شود") + ":"
                    width: parent.width
                    color: AppStyle.textColor
                    height: 50 * AppStyle.size1H
                    verticalAlignment: Text.AlignBottom
                    font {
                        family: AppStyle.appFont
                        pixelSize: AppStyle.size1F * 24
                        bold: true
                    }
                    rightPadding: 50 * AppStyle.size1W
                }

                AppRadioButton {
                    id: doRadio
                    text: qsTr("می‌خواهم این عمل را در الان انجام دهم")
                    width: parent.width
                    rightPadding: 80 * AppStyle.size1W
                }
                Loader {
                    id: doLoader
                    active: height !== 0
                    width: parent.width
                    height: doRadio.checked ? 120 * AppStyle.size1W : 0
                    Behavior on height {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                    clip: true
                    sourceComponent: doComponent
                }
                /*********************************/
                /*********** انجام شدنی‌ها*****************/
            }
        }
    }

    Component {
        id: collectComponent
        Rectangle {
            property alias submitBtn: submitBtn
            radius: 15 * AppStyle.size1W
            border.width: 2 * AppStyle.size1W
            border.color: AppStyle.borderColor
            color: "transparent"
            RowLayout {
                anchors.fill: parent
                layoutDirection: RowLayout.RightToLeft
                AppButton {
                    id: submitBtn
                    property bool isUpdate: false
                    text: qsTr("بفرست به پردازش نشده ها")

                    Layout.fillWidth: true
                    Layout.rightMargin: 25 * AppStyle.size1W
                    Layout.leftMargin: 25 * AppStyle.size1W
                    Layout.minimumWidth: processBtn.checked ? 170 * AppStyle.size1W : 370 * AppStyle.size1W
                    Layout.preferredWidth: 390 * AppStyle.size1W
                    Layout.maximumWidth: 400 * AppStyle.size1W
                    Layout.minimumHeight: 70 * AppStyle.size1H
                    Layout.maximumHeight: 70 * AppStyle.size1H

                    radius: 15 * AppStyle.size1W
                    leftPadding: 35 * AppStyle.size1W
                    enabled: !processBtn.checked
                    icon.source: "qrc:/check.svg"
                    icon.width: 20 * AppStyle.size1W
                    onClicked: {
                        let hasFiles = checking()
                        if(hasFiles === 2)
                            return

                        let json = JSON.stringify(
                                {
                                    user_id         : User.id,
                                    list_id         : Memorito.Process,
                                    has_files       : parseInt(hasFiles),
                                    title           : titleInput.text.trim(),
                                    detail          : flickTextArea.text.trim(),

                                    priority_id     : null,
                                    estimate_time   : null,
                                    context_id      : null,
                                    energy_id       : null,
                                    due_date        : null,
                                    friend_id       : null,
                                    category_id     : null
                                }, null, 1);

                        if ((listId === Memorito.Collect || listId === Memorito.Process) && !isUpdate)
                        {
                            ThingsApi.addThing(json,attachModel)
                            flickTextArea.detailInput.clear()
                            titleInput.clear()
                            isDual = false
                        }
                        else
                            ThingsApi.editThing(prevPageModel.id,json,attachModel)
                    }
                } // 2 is proccess list id

                Item {
                    Layout.fillWidth: true
                }

                AppButton {
                    id: processBtn
                    text: qsTr("پردازش")

                    Layout.leftMargin: 25 * AppStyle.size1W
                    Layout.rightMargin: 25 * AppStyle.size1W
                    Layout.fillWidth: true
                    Layout.minimumWidth: 170 * AppStyle.size1W
                    Layout.maximumWidth: 210 * AppStyle.size1W
                    Layout.preferredWidth: 210 * AppStyle.size1W
                    Layout.minimumHeight: 70 * AppStyle.size1H
                    Layout.maximumHeight: 70 * AppStyle.size1H

                    checkable: true
                    Material.accent: "transparent"
                    Material.primary: "transparent"
                    Material.background: checked ? AppStyle.primaryInt : "transparent"
                    Material.foreground: checked ? AppStyle.textOnPrimaryColor : AppStyle.primaryInt

                    checked: isDual
                    onCheckedChanged: {
                        isDual = checked
                    }

                    radius: 10 * AppStyle.size1W
                    leftPadding: AppStyle.ltr ? 0 : 35 * AppStyle.size1W
                    rightPadding: AppStyle.ltr ? 35 * AppStyle.size1W : 0
                    Image {
                        id: processIcon
                        width: 20 * AppStyle.size1W
                        height: width
                        source: "qrc:/arrow.svg"
                        anchors {
                            left: parent.left
                            leftMargin: 30 * AppStyle.size1W
                            verticalCenter: parent.verticalCenter
                        }
                        sourceSize {
                            width: width * 2
                            height: height * 2
                        }
                        visible: false
                    }
                    ColorOverlay {
                        rotation: processBtn.checked ? (nRow
                                                        === 3 ? 90 : 180) : (nRow === 3 ? 270 : 0)
                        anchors.fill: processIcon
                        source: processIcon
                        color: processBtn.checked ? AppStyle.textOnPrimaryColor : AppStyle.primaryColor
                    }
                }
            }
        }
    } //end of collectComponent

    Component {
        id: optionsComponent
        Flow {
            width: parent.width
            property alias energyInput: energyInput
            property alias contextInput: contextInput
            property alias priorityInput: priorityInput
            property alias estimateInput: estimateInput
            spacing: 25 * AppStyle.size1H
            Rectangle {
                width: parent.width
                height: 130 * AppStyle.size1H
                radius: 15 * AppStyle.size1W
                border.width: 2 * AppStyle.size1W
                border.color: AppStyle.borderColor
                color: "transparent"
                Text {
                    id: contextText
                    text: qsTr("محل انجام") + ":"
                    width: 250 * AppStyle.size1W
                    anchors {
                        right: parent.right
                        rightMargin: 15 * AppStyle.size1W
                        verticalCenter: parent.verticalCenter
                    }
                    color: AppStyle.textColor
                    font {
                        family: AppStyle.appFont
                        pixelSize: AppStyle.size1F * 30
                        bold: true
                    }
                }
                AppComboBox {
                    id: contextInput
                    anchors {
                        right: contextText.left
                        rightMargin: 15 * AppStyle.size1W
                        left: parent.left
                        leftMargin: 15 * AppStyle.size1W
                        bottom: contextText.bottom
                        bottomMargin: -20 * AppStyle.size1W
                    }
                    font.pixelSize: AppStyle.size1F * 28
                    textRole: "context_name"
                    placeholderText: qsTr("محل انجام") + " (" + qsTr(
                                         "اختیاری") + ")"
                    currentIndex: prevPageModel ? contextModel.count > 0 ? prevPageModel.context_id ? UsefulFunc.findInModel(prevPageModel.context_id, "id", contextModel).index : -1 : -1 : -1
                    model: contextModel
                    onCurrentIndexChanged: {
                        options["contextId"] = contextInput.currentIndex
                                === -1 ? null : contextModel.get(
                                             contextInput.currentIndex).id
                    }

                    Component.onCompleted: {
                        ContextsApi.getContexts(contextModel)
                    }
                }
            }
            Rectangle {
                width: parent.width
                height: 130 * AppStyle.size1H
                radius: 15 * AppStyle.size1W
                border.width: 2 * AppStyle.size1W
                border.color: AppStyle.borderColor
                color: "transparent"
                Text {
                    id: priorityText
                    text: qsTr("اولویت‌ها") + ":"
                    width: 250 * AppStyle.size1W
                    anchors {
                        right: parent.right
                        rightMargin: 15 * AppStyle.size1W
                        verticalCenter: parent.verticalCenter
                    }
                    color: AppStyle.textColor
                    font {
                        family: AppStyle.appFont
                        pixelSize: AppStyle.size1F * 30
                        bold: true
                    }
                }
                AppComboBox {
                    id: priorityInput
                    anchors {
                        right: priorityText.left
                        rightMargin: 15 * AppStyle.size1W
                        left: parent.left
                        leftMargin: 15 * AppStyle.size1W
                        bottom: priorityText.bottom
                        bottomMargin: -20 * AppStyle.size1W
                    }
                    textRole: "Text"
                    iconRole: "iconSource"
                    font.pixelSize: AppStyle.size1F * 28
                    placeholderText: qsTr("اولویت") + " (" + qsTr(
                                         "اختیاری") + ")"
                    currentIndex: prevPageModel ? prevPageModel.priority_id ? UsefulFunc.findInModel(prevPageModel.priority_id, "Id", priorityModel).index : -1 : -1
                    model: priorityModel
                    onCurrentIndexChanged: {
                        options["priorityId"] = priorityInput.currentIndex
                                === -1 ? null : priorityModel.get(
                                             priorityInput.currentIndex).Id
                    }
                }
            }
            Rectangle {
                width: parent.width
                height: 130 * AppStyle.size1H
                radius: 15 * AppStyle.size1W
                border.width: 2 * AppStyle.size1W
                border.color: AppStyle.borderColor
                color: "transparent"
                Text {
                    id: energyText
                    text: qsTr("سطح انرژی") + ":"
                    width: 250 * AppStyle.size1W
                    anchors {
                        right: parent.right
                        rightMargin: 15 * AppStyle.size1W
                        verticalCenter: parent.verticalCenter
                    }
                    color: AppStyle.textColor
                    font {
                        family: AppStyle.appFont
                        pixelSize: AppStyle.size1F * 30
                        bold: true
                    }
                }
                AppComboBox {
                    id: energyInput
                    anchors {
                        right: energyText.left
                        rightMargin: 15 * AppStyle.size1W
                        left: parent.left
                        leftMargin: 15 * AppStyle.size1W
                        bottom: energyText.bottom
                        bottomMargin: -20 * AppStyle.size1W
                    }
                    textRole: "Text"
                    iconRole: "iconSource"
                    font.pixelSize: AppStyle.size1F * 28
                    placeholderText: qsTr("سطح انرژی") + " (" + qsTr(
                                         "اختیاری") + ")"
                    model: energyModel
                    currentIndex: prevPageModel ? prevPageModel.energy_id ? UsefulFunc.findInModel(prevPageModel.energy_id, "Id", energyModel).index : -1 : -1
                    onCurrentIndexChanged: {
                        options["energyId"] = energyInput.currentIndex
                                === -1 ? null : energyModel.get(
                                             energyInput.currentIndex).Id
                    }
                }
            }
            Rectangle {
                width: parent.width
                height: 130 * AppStyle.size1H
                radius: 15 * AppStyle.size1W
                border.width: 2 * AppStyle.size1W
                border.color: AppStyle.borderColor
                color: "transparent"
                Text {
                    id: estimateText
                    text: qsTr("تخمین زمان انجام") + ":"
                    anchors {
                        right: parent.right
                        rightMargin: 15 * AppStyle.size1W
                        verticalCenter: parent.verticalCenter
                    }
                    width: 250 * AppStyle.size1W
                    color: AppStyle.textColor
                    font {
                        family: AppStyle.appFont
                        pixelSize: AppStyle.size1F * 30
                        bold: true
                    }
                }
                TextField {
                    id: estimateInput
                    text: prevPageModel ? prevPageModel.estimate_time ? prevPageModel.estimate_time : "" : ""
                    font {
                        family: AppStyle.appFont
                        pixelSize: 28 * AppStyle.size1F
                    }
                    selectByMouse: true
                    renderType: Text.NativeRendering
                    placeholderTextColor: AppStyle.textColor
                    verticalAlignment: Text.AlignBottom
                    Material.accent: AppStyle.primaryColor
                    placeholderText: qsTr("تخمین به دقیقه") + " (" + qsTr(
                                         "اختیاری") + ")"
                    horizontalAlignment: Text.AlignHCenter
                    validator: RegExpValidator {
                        regExp: /[0123456789۰۱۲۳۴۵۶۷۸۹]{3}/ig
                    }
                    anchors {
                        right: estimateText.left
                        rightMargin: 15 * AppStyle.size1W
                        left: parent.left
                        bottom: estimateText.bottom
                        leftMargin: 15 * AppStyle.size1W
                        bottomMargin: -20 * AppStyle.size1W
                    }
                    onTextChanged: {
                        if (text.match(/[۰۱۲۳۴۵۶۷۸۹]/ig))
                            text = UsefulFunc.faToEnNumber(text)

                        options["estimateTime"] = estimateInput.text.trim(
                                    ) === "" ? null : parseInt(
                                                   estimateInput.text.trim())
                    }
                }
            }
        }
    } // end of optionsComponent

    Component {
        id: projectComponent
        Rectangle {
            id: projectItem
            anchors {
                fill: parent
            }
            radius: 10 * AppStyle.size1W
            color: "transparent"
            border.width: 3 * AppStyle.size1W
            border.color: Material.hintTextColor

            AppButton {
                id: projectBtn
                width: 410 * AppStyle.size1W
                height: 70 * AppStyle.size1H
                checkable: true
                Material.accent: "transparent"
                Material.primary: "transparent"
                Material.background: AppStyle.primaryInt

                anchors {
                    centerIn: parent
                }
                text: qsTr("ساخت پروژه جدید")
                radius: 10 * AppStyle.size1W
                leftPadding: 35 * AppStyle.size1W
                onClicked: {

                    if (listId === Memorito.Process)
                        CategoriesApi.addCategory(titleInput.text.trim(),
                                                  flickTextArea.text.trim(),
                                                  Memorito.Project,
                                                  projectCategoryModel, 2,
                                                  thingModel, modelIndex)
                    else
                        CategoriesApi.addCategory(titleInput.text.trim(),
                                                  flickTextArea.text.trim(),
                                                  Memorito.Project,
                                                  null, 1)
                }
            }
        }
    }

    Component {
        id: nextComponent
        Rectangle {
            id: nextItem
            anchors {
                fill: parent
            }
            radius: 10 * AppStyle.size1W
            color: "transparent"
            border.width: 3 * AppStyle.size1W
            border.color: Material.hintTextColor
            AppButton {
                id: nextBtn
                width: 410 * AppStyle.size1W
                height: 70 * AppStyle.size1H
                checkable: true
                Material.accent: "transparent"
                Material.primary: "transparent"
                Material.background: AppStyle.primaryInt

                anchors {
                    centerIn: parent
                }
                text: prevPageModel
                      && listId !== Memorito.Process ? qsTr("بروزرسانی") : qsTr(
                                                           "بفرست به عملیات بعدی")
                radius: 10 * AppStyle.size1W
                leftPadding: 35 * AppStyle.size1W
                rightPadding: 35 * AppStyle.size1W
                onClicked: {
                    let hasFiles = checking()
                    if(hasFiles === 2)
                        return

                    let json = JSON.stringify(
                            {
                                title : titleInput.text.trim(),
                                user_id: User.id,
                                detail : flickTextArea.text.trim(),
                                list_id : Memorito.NextAction,
                                has_files: parseInt(hasFiles),
                                priority_id : options["priorityId"]??null,
                                estimate_time : options["estimateTime"]??null,
                                context_id : options["contextId"]??null,
                                energy_id : options["energyId"]??null,
                                due_date : null,
                                friend_id : null,
                                category_id : null
                            }, null, 1);

                    if (prevPageModel)
                        ThingsApi.editThing(prevPageModel.id,json,attachModel)
                    else
                    {
                        ThingsApi.addThing(json,attachModel)
                        flickTextArea.detailInput.clear()
                        titleInput.clear()
                        isDual = false
                    }
                }
            }
        }
    } // 3 is next action list id

    Component {
        id: refrenceComponent
        Rectangle {
            id: refrenceItem
            anchors {
                fill: parent
            }
            radius: 10 * AppStyle.size1W
            color: "transparent"
            border.width: 3 * AppStyle.size1W
            border.color: Material.hintTextColor
            Text {
                id: refrenceCategoryText
                text: qsTr("دسته بندی") + ":"
                anchors {
                    right: parent.right
                    rightMargin: 20 * AppStyle.size1W
                    top: parent.top
                    topMargin: 50 * AppStyle.size1W
                }
                font {
                    family: AppStyle.appFont
                    pixelSize: AppStyle.size1F * 30
                    bold: true
                }
                color: AppStyle.textColor
            }
            AppComboBox {
                id: refrenceCategoryCombo
                textRole: "category_name"
                font.pixelSize: AppStyle.size1F * 28
                placeholderText: qsTr("دسته بندی")
                currentIndex: prevPageModel ? refrenceCategoryModel.count > 0 ? prevPageModel.category_id ? UsefulFunc.findInModel(prevPageModel.category_id, "id", refrenceCategoryModel).index : -1 : -1 : -1
                anchors {
                    top: parent.top
                    topMargin: 10 * AppStyle.size1W
                    right: refrenceCategoryText.left
                    rightMargin: currentIndex === -1 ? 20 * AppStyle.size1W : 50 * AppStyle.size1W
                    left: parent.left
                    leftMargin: 20 * AppStyle.size1W
                }
                model: ListModel{ id:refrenceCategoryModel }
                Component.onCompleted: {
                    CategoriesApi.getCategories(refrenceCategoryModel,
                                                Memorito.Refrence) // 4= مرجع
                }
            }

            AppButton {
                id: refrenceBtn
                width: 410 * AppStyle.size1W
                height: 70 * AppStyle.size1H
                checkable: true
                Material.accent: "transparent"
                Material.primary: "transparent"
                Material.background: AppStyle.primaryInt

                anchors {
                    top: refrenceCategoryCombo ? refrenceCategoryCombo.visible ? refrenceCategoryCombo.bottom : parent.top : undefined
                    topMargin: 25 * AppStyle.size1W
                    horizontalCenter: parent.horizontalCenter
                }
                text: prevPageModel
                      && listId !== Memorito.Process ? qsTr("بروزرسانی") : qsTr(
                                                           "بفرست به مرجع")
                radius: 10 * AppStyle.size1W
                leftPadding: 35 * AppStyle.size1W
                rightPadding: 35 * AppStyle.size1W
                onClicked: {
                    let hasFiles = checking()
                    if(hasFiles === 2)
                        return

                    let categoryId = refrenceCategoryCombo.currentIndex !== -1 ? refrenceCategoryModel.get(refrenceCategoryCombo.currentIndex).id
                                                                               : null

                    let json = JSON.stringify(
                            {
                                title : titleInput.text.trim(),
                                user_id: User.id,
                                detail : flickTextArea.text.trim(),
                                list_id : Memorito.Refrence,
                                has_files: parseInt(hasFiles),
                                priority_id : options["priorityId"]??null,
                                estimate_time : options["estimateTime"]??null,
                                context_id : options["contextId"]??null,
                                energy_id : options["energyId"]??null,
                                due_date : null,
                                friend_id : null,
                                category_id : categoryId
                            }, null, 1);

                    if (prevPageModel)
                        ThingsApi.editThing(prevPageModel.id,json,attachModel)
                    else
                    {
                        ThingsApi.addThing(json,attachModel)
                        flickTextArea.detailInput.clear()
                        titleInput.clear()
                        isDual = false
                    }
                }
            }
        }
    } // 4 is refrence list id

    Component {
        id: friendComponent
        Rectangle {
            id: friendItem
            anchors {
                fill: parent
            }

            radius: 10 * AppStyle.size1W
            color: "transparent"
            border.width: 3 * AppStyle.size1W
            border.color: Material.hintTextColor
            Text {
                id: friendCategoryText
                text: qsTr("انتخاب دوست") + ":"
                visible: friendModel.count !== 0
                anchors {
                    right: parent.right
                    rightMargin: 20 * AppStyle.size1W
                    top: parent.top
                    topMargin: 50 * AppStyle.size1W
                }
                font {
                    family: AppStyle.appFont
                    pixelSize: AppStyle.size1F * 30
                    bold: true
                }
                color: AppStyle.textColor
            }
            AppComboBox {
                id: friendCombo
                textRole: "friend_name"
                font.pixelSize: AppStyle.size1F * 28
                placeholderText: qsTr("دوست موردنظر را انتخاب کنید")
                currentIndex: prevPageModel ? friendModel.count > 0 ? prevPageModel.friend_id ? UsefulFunc.findInModel(prevPageModel.friend_id, "id", friendModel).index : -1 : -1 : -1
                anchors {
                    top: parent.top
                    topMargin: 10 * AppStyle.size1W
                    right: friendCategoryText.left
                    rightMargin: currentIndex === -1 ? 20 * AppStyle.size1W : 50 * AppStyle.size1W
                    left: parent.left
                    leftMargin: 20 * AppStyle.size1W
                }
                model: friendModel
                Component.onCompleted: {
                    FriendsApi.getFriends(friendModel)
                }
            }

            AppButton {
                id: friendBtn
                width: 410 * AppStyle.size1W
                height: 70 * AppStyle.size1H
                checkable: true
                Material.accent: "transparent"
                Material.primary: "transparent"
                Material.background: AppStyle.primaryInt

                anchors {
                    top: friendCombo ? friendCombo.visible ? friendCombo.bottom : parent.top : undefined
                    topMargin: 25 * AppStyle.size1W
                    horizontalCenter: parent.horizontalCenter
                }
                text: prevPageModel
                      && listId !== Memorito.Process ? qsTr("بروزرسانی") : qsTr(
                                                           "بفرست به لیست انتظار")
                radius: 10 * AppStyle.size1W
                leftPadding: 35 * AppStyle.size1W
                rightPadding: 35 * AppStyle.size1W
                onClicked: {

                    if (friendCombo.currentIndex === -1) {
                        if (friendModel.count > 0)
                            UsefulFunc.showLog(
                                        qsTr("لطفا دوست خودتو انتخاب کن"),
                                        true)
                        else
                            UsefulFunc.showLog(
                                        qsTr("لطفااول دوستاتو اضافه کن بعد دوست خودتو انتخاب کن"),
                                        true)
                        return
                    }

                    let hasFiles = checking()
                    if(hasFiles === 2)
                        return

                    let friendId = friendModel.get(friendCombo.currentIndex).id

                    let json = JSON.stringify(
                            {
                                title : titleInput.text.trim(),
                                user_id: User.id,
                                detail : flickTextArea.text.trim(),
                                list_id : Memorito.Waiting,
                                has_files: parseInt(hasFiles),
                                priority_id : options["priorityId"]??null,
                                estimate_time : options["estimateTime"]??null,
                                context_id : options["contextId"]??null,
                                energy_id : options["energyId"]??null,
                                due_date : null,
                                friend_id : friendId,
                                category_id : null
                            }, null, 1);

                    if (prevPageModel)
                        ThingsApi.editThing(prevPageModel.id,json,attachModel)
                    else
                    {
                        ThingsApi.addThing(json,attachModel)
                        flickTextArea.detailInput.clear()
                        titleInput.clear()
                        isDual = false
                    }
                }
            }
        }
    } // 5 is waiting list id

    Component {
        id: calendarComponent
        Rectangle {
            id: calendarItem
            anchors {
                fill: parent
            }
            radius: 10 * AppStyle.size1W
            color: "transparent"
            border.width: 3 * AppStyle.size1W
            border.color: Material.hintTextColor
            Behavior on height {
                NumberAnimation {
                    duration: 200
                }
            }
            clip: true
            TabBar{
                id: suggestionTab
                width: parent.width
                height: 100*AppStyle.size1H
                anchors {
                    top: parent.top
                    topMargin: 20 * AppStyle.size1W
                    right: parent.right
                    rightMargin: 20 * AppStyle.size1W
                    left: parent.left
                    leftMargin: 20 * AppStyle.size1W
                }
                LayoutMirroring.enabled: !AppStyle.ltr
                LayoutMirroring.childrenInherit: true
                currentIndex: 0
                QDateConvertor{id:dateConvertor}
                TabButton{
                    text: qsTr("زمان دلخواه")
                    width: 200 * AppStyle.size1W
                }
                TabButton{
                    text: qsTr("فردا")
                    width: 200 * AppStyle.size1W
                    onCheckedChanged: {
                        if(checked)
                        {
                            var today = new Date()
                            today.setDate(today.getDate()+1)
                            dateInput.selectedDate = today
                        }
                    }
                }
                TabButton{
                    text: qsTr("پس فردا")
                    width: 200 * AppStyle.size1W
                    onCheckedChanged: {
                        if(checked)
                        {
                            var today = new Date()
                            today.setDate(today.getDate()+2)
                            dateInput.selectedDate = today
                        }
                    }
                }
                TabButton{
                    text: qsTr("آخرهفته")
                    width: 200 * AppStyle.size1W
                    onCheckedChanged: {
                        if(checked)
                        {
                            var today = new Date()
                            today.setDate((AppStyle.ltr?6:4)-today.getDay()+today.getDate())
                            dateInput.selectedDate = today
                        }
                    }
                }
                TabButton{
                    text: qsTr("اول هفته‌ی بعد")
                    width: 200 * AppStyle.size1W
                    onCheckedChanged: {
                        if(checked)
                        {
                            var today = new Date()
                            today.setDate((AppStyle.ltr?8:6)-today.getDay()+today.getDate())
                            dateInput.selectedDate = today
                        }
                    }
                }
                TabButton{
                    text: qsTr("آخر ماه")
                    width: 200 * AppStyle.size1W
                    onCheckedChanged: {
                        if(checked)
                        {
                            var today = new Date()
                            if(AppStyle.ltr)
                            {
                                today.setMonth(today.getMonth()+1)
                                today.setDate(1)
                                today.setDate(today.getDate()-2)
                            }
                            else{
                                var todayJalali = dateConvertor.toJalali(today.getFullYear(),today.getMonth()+1,today.getDate())
                                if(Number(todayJalali[1])+1 > 12)
                                {
                                    todayJalali[0] = Number(todayJalali[0])+1
                                    todayJalali[1] = Number(todayJalali[1])-12
                                }
                                else {
                                    todayJalali[1] = Number(todayJalali[1])+1
                                }
                                var miladi = dateConvertor.toMiladi(Number(todayJalali[0]),Number(todayJalali[1]),1)
                                today = new Date(Number(miladi[0]),Number(miladi[1])-1,Number(miladi[2]))
                                today.setDate(today.getDate()-2)
                            }

                            dateInput.selectedDate = today
                        }
                    }
                }
                TabButton{
                    text: qsTr("اول ماه بعد")
                    width: 200 * AppStyle.size1W
                    onCheckedChanged: {
                        if(checked)
                        {
                            var today = new Date()
                            if(AppStyle.ltr)
                            {
                                today.setMonth(today.getMonth()+1)
                                today.setDate(1)
                                today.setDate(today.getDate())
                            }
                            else{
                                var todayJalali = dateConvertor.toJalali(today.getFullYear(),today.getMonth()+1,today.getDate())
                                if(Number(todayJalali[1])+1 > 12)
                                {
                                    todayJalali[0] = Number(todayJalali[0])+1
                                    todayJalali[1] = Number(todayJalali[1])-12
                                }
                                else {
                                    todayJalali[1] = Number(todayJalali[1])+1
                                }
                                var miladi = dateConvertor.toMiladi(Number(todayJalali[0]),Number(todayJalali[1]),1)
                                today = new Date(Number(miladi[0]),Number(miladi[1]-1),Number(miladi[2]))
                            }

                            dateInput.selectedDate = today
                        }
                    }
                }
            }

            property date dueDate: prevPageModel ? prevPageModel.due_date ? new Date(prevPageModel.due_date) : "" : ""
            AppCheckBox {
                id: clockCheck
                visible: suggestionTab.currentIndex === 0
                anchors {
                    left: parent.left
                    leftMargin: 20 * AppStyle.size1W
                    top: suggestionTab.bottom
                    topMargin: 20 * AppStyle.size1W
                }
                text: qsTr("تعیین ساعت")
                checked: prevPageModel ? prevPageModel.due_date ? !(calendarItem.dueDate.getHours() === 5 && calendarItem.dueDate.getMinutes() === 17
                                                                    && calendarItem.dueDate.getSeconds() === 17)
                                                                : false : false
            }
            AppDateInput {
                id: dateInput
                visible: suggestionTab.currentIndex === 0
                placeholderText: qsTr("زمان مورد نظر را انتخاب نمایید")
                hasTime: clockCheck.checked
                minSelectedDate: new Date()
                selectedDate: calendarItem.dueDate
                anchors {
                    top: suggestionTab.bottom
                    right: clockCheck.left
                    rightMargin: 30 * AppStyle.size1W
                    left: parent.left
                    leftMargin: 20 * AppStyle.size1W
                }
            }
            Text{
                anchors {
                    top: suggestionTab.bottom
                    topMargin: 20 * AppStyle.size1W
                    right: parent.right
                    rightMargin: 20 * AppStyle.size1W
                    left: parent.left
                    leftMargin: 20 * AppStyle.size1W
                }
                visible: suggestionTab.currentIndex !== 0
                text: qsTr("زمان انتخاب شده") + ": "+ dateInput.date.text
                color: AppStyle.textColor
                font {
                    family: AppStyle.appFont
                    pixelSize: AppStyle.size1F * 30
                }

            }

            AppButton {
                id: calendarBtn
                width: 410 * AppStyle.size1W
                height: 70 * AppStyle.size1H
                checkable: true
                Material.accent: "transparent"
                Material.primary: "transparent"
                Material.background: AppStyle.primaryInt

                anchors {
                    top: dateInput.bottom
                    topMargin: 20 * AppStyle.size1W
                    horizontalCenter: parent.horizontalCenter
                }
                text: prevPageModel
                      && listId !== Memorito.Process ? qsTr("بروزرسانی") : qsTr(
                                                           "بفرست به تقویم")

                radius: 10 * AppStyle.size1W
                leftPadding: 35 * AppStyle.size1W
                onClicked: {

                    if (dateInput.selectedDate.toString() === "Invalid Date") {
                        UsefulFunc.showLog(
                                    qsTr("لطفا زمانی که میخوای این کار رو بکنی مشخص کن"),
                                    true)
                        return
                    }
                    let hasFiles = checking()
                    if(hasFiles === 2)
                        return

                    if (!clockCheck.checked) {
                        dateInput.selectedDate = new Date(dateInput.selectedDate.setHours(
                                                              5))
                        dateInput.selectedDate = new Date(dateInput.selectedDate.setMinutes(
                                                              17))
                        dateInput.selectedDate = new Date(dateInput.selectedDate.setSeconds(
                                                              17))
                    }
                    let dueDate = encodeURIComponent(UsefulFunc.formatDate( dateInput.selectedDate, false ))
                    let json = JSON.stringify(
                            {
                                title : titleInput.text.trim(),
                                user_id: User.id,
                                detail : flickTextArea.text.trim(),
                                list_id : Memorito.Calendar,
                                has_files: parseInt(hasFiles),
                                priority_id : options["priorityId"]??null,
                                estimate_time : options["estimateTime"]??null,
                                context_id : options["contextId"]??null,
                                energy_id : options["energyId"]??null,
                                due_date : dueDate,
                                friend_id : null,
                                category_id : null
                            }, null, 1);

                    if (prevPageModel)
                        ThingsApi.editThing(prevPageModel.id,json,attachModel)
                    else
                    {
                        ThingsApi.addThing(json,attachModel)
                        flickTextArea.detailInput.clear()
                        titleInput.clear()
                        isDual = false
                    }
                }
            }
        }
    } // 6 is calendar list id

    Component {
        id: trashComponent
        Rectangle {
            id: trashItem
            anchors {
                fill: parent
            }
            radius: 10 * AppStyle.size1W
            color: "transparent"
            border.width: 3 * AppStyle.size1W
            border.color: Material.hintTextColor
            AppButton {
                id: trashBtn
                width: 410 * AppStyle.size1W
                height: 70 * AppStyle.size1H
                checkable: true
                Material.accent: "transparent"
                Material.primary: "transparent"
                Material.background: AppStyle.primaryInt

                anchors {
                    centerIn: parent
                }
                text: prevPageModel
                      && listId !== Memorito.Process ? qsTr("بروزرسانی") : qsTr(
                                                           "بفرست به سطل آشغال")
                radius: 10 * AppStyle.size1W
                leftPadding: 35 * AppStyle.size1W
                rightPadding: 35 * AppStyle.size1W
                onClicked: {
                    let hasFiles = checking()
                    if(hasFiles === 2)
                        return

                    if (prevPageModel)
                        ThingsApi.editThing(prevPageModel.id,json,attachModel)
                    else
                    {
                        ThingsApi.addThing(json,attachModel)
                        flickTextArea.detailInput.clear()
                        titleInput.clear()
                        isDual = false
                    }
                }
            }
        }
    } // 7 is trash list id

    Component {
        id: doComponent
        Rectangle {
            id: doItem
            anchors {
                fill: parent
            }
            radius: 10 * AppStyle.size1W
            color: "transparent"
            border.width: 3 * AppStyle.size1W
            border.color: Material.hintTextColor
            AppButton {
                id: doBtn
                width: 410 * AppStyle.size1W
                height: 70 * AppStyle.size1H
                checkable: true
                Material.accent: "transparent"
                Material.primary: "transparent"
                Material.background: AppStyle.primaryInt

                anchors {
                    centerIn: parent
                }
                text: prevPageModel
                      && listId !== Memorito.Process ? qsTr("بروزرسانی") : qsTr(
                                                           "بفرست به انجام شده ها")
                radius: 10 * AppStyle.size1W
                leftPadding: 35 * AppStyle.size1W
                rightPadding: 35 * AppStyle.size1W
                onClicked: {
                    let hasFiles = checking()
                    if(hasFiles === 2)
                        return
                    let json = JSON.stringify(
                            {
                                title : titleInput.text.trim(),
                                user_id: User.id,
                                detail : flickTextArea.text.trim(),
                                list_id : listId === Memorito.Collect?Memorito.Done:listId,
                                has_files: parseInt(hasFiles),
                                priority_id : options["priorityId"]??null,
                                estimate_time : options["estimateTime"]??null,
                                context_id : options["contextId"]??null,
                                energy_id : options["energyId"]??null,
                                due_date : prevPageModel?prevPageModel.due_date??null:null,
                                friend_id : prevPageModel?prevPageModel.friend??null:null,
                                category_id : categoryId === -1?null:categoryId,
                                is_done: 1
                            }, null, 1);

                    if (prevPageModel)
                        ThingsApi.editThing(prevPageModel.id,json,attachModel)
                    else
                    {
                        ThingsApi.addThing(json,attachModel)
                        flickTextArea.detailInput.clear()
                        titleInput.clear()
                        isDual = false
                    }
                }
            }
        }
    } // 8 is Done list id

    Component {
        id: somedayComponent
        Rectangle {
            id: somedayItem
            anchors {
                fill: parent
            }
            radius: 10 * AppStyle.size1W
            color: "transparent"
            border.width: 3 * AppStyle.size1W
            border.color: Material.hintTextColor
            Text {
                id: somedayCategoryText
                text: qsTr("دسته بندی") + ":"
                anchors {
                    right: parent.right
                    rightMargin: 20 * AppStyle.size1W
                    top: parent.top
                    topMargin: 50 * AppStyle.size1W
                }
                font {
                    family: AppStyle.appFont
                    pixelSize: AppStyle.size1F * 30
                    bold: true
                }
                color: AppStyle.textColor
            }
            AppComboBox {
                id: somedayCategoryCombo
                textRole: "category_name"
                font.pixelSize: AppStyle.size1F * 28
                placeholderText: qsTr("دسته بندی") + " (" + qsTr(
                                     "اختیاری") + ")"
                currentIndex: prevPageModel ? somedayCategoryModel.count > 0 ? prevPageModel.category_id ? UsefulFunc.findInModel(prevPageModel.category_id, "id", somedayCategoryModel).index : -1 : -1 : -1
                anchors {
                    top: parent.top
                    topMargin: 10 * AppStyle.size1W
                    right: somedayCategoryText.left
                    rightMargin: currentIndex === -1 ? 20 * AppStyle.size1W : 50 * AppStyle.size1W
                    left: parent.left
                    leftMargin: 20 * AppStyle.size1W
                }
                model: ListModel{id: somedayCategoryModel}
                Component.onCompleted: {
                    CategoriesApi.getCategories(
                                somedayCategoryModel,
                                Memorito.Someday) // 9 = شاید یک روزی
                }
            }

            AppButton {
                id: somedayBtn
                width: 410 * AppStyle.size1W
                height: 70 * AppStyle.size1H
                checkable: true
                Material.accent: "transparent"
                Material.primary: "transparent"
                Material.background: AppStyle.primaryInt

                anchors {
                    top: somedayCategoryCombo ? somedayCategoryCombo.visible ? somedayCategoryCombo.bottom : parent.top : undefined
                    topMargin: 25 * AppStyle.size1W
                    horizontalCenter: parent.horizontalCenter
                }
                text: prevPageModel
                      && listId !== Memorito.Process ? qsTr("بروزرسانی") : qsTr(
                                                           "بفرست به شاید یک روزی")
                radius: 10 * AppStyle.size1W
                leftPadding: 35 * AppStyle.size1W
                rightPadding: 35 * AppStyle.size1W
                onClicked: {
                    let hasFiles = checking()
                    if(hasFiles === 2)
                        return

                    let categoryId = somedayCategoryCombo.currentIndex
                        !== -1 ? somedayCategoryModel.get(
                                     somedayCategoryCombo.currentIndex).id : null

                    let json = JSON.stringify(
                            {
                                title : titleInput.text.trim(),
                                user_id: User.id,
                                detail : flickTextArea.text.trim(),
                                list_id : Memorito.Someday,
                                has_files: parseInt(hasFiles),
                                priority_id : options["priorityId"]??null,
                                estimate_time : options["estimateTime"]??null,
                                context_id : options["contextId"]??null,
                                energy_id : options["energyId"]??null,
                                due_date : null,
                                friend_id : null,
                                category_id : categoryId
                            }, null, 1);

                    if (prevPageModel)
                        ThingsApi.editThing(prevPageModel.id,json,attachModel)
                    else
                    {
                        ThingsApi.addThing(json,attachModel)
                        flickTextArea.detailInput.clear()
                        titleInput.clear()
                        isDual = false
                    }
                }
            }
        }
    } // 9 is someday list id

    Component {
        id: projectCategoryComponent
        Rectangle {
            id: projectCategoryItem
            anchors { fill: parent }
            radius: 10 * AppStyle.size1W
            color: "transparent"
            border.width: 3 * AppStyle.size1W
            border.color: Material.hintTextColor
            Text {
                id: projectCategoryText
                text: qsTr("انتخاب پروژه") + ":"
                anchors {
                    right: parent.right
                    rightMargin: 20 * AppStyle.size1W
                    top: parent.top
                    topMargin: 50 * AppStyle.size1W
                }
                font {
                    family: AppStyle.appFont
                    pixelSize: AppStyle.size1F * 30
                    bold: true
                }
                color: AppStyle.textColor
            }
            AppComboBox {
                id: projectCategoryCombo
                textRole: "category_name"
                font.pixelSize: AppStyle.size1F * 28
                placeholderText: qsTr("پروژه موردنظر را انتخاب کنید")
                currentIndex: prevPageModel ? projectCategoryModel.count > 0 ? prevPageModel.category_id ? UsefulFunc.findInModel(prevPageModel.category_id, "id", projectCategoryModel).index : -1 : -1 : categoryId !== -1 ? UsefulFunc.findInModel(categoryId, "id", projectCategoryModel).index : -1
                anchors {
                    top: parent.top
                    topMargin: 10 * AppStyle.size1W
                    right: projectCategoryText.left
                    rightMargin: currentIndex === -1 ? 20 * AppStyle.size1W : 50 * AppStyle.size1W
                    left: parent.left
                    leftMargin: 20 * AppStyle.size1W
                }
                model: ListModel{ id: projectCategoryModel}
                Component.onCompleted: {
                    CategoriesApi.getCategories(projectCategoryModel,
                                                Memorito.Project)
                }
            }
            AppButton {
                id: projectCategoryBtn
                width: 410 * AppStyle.size1W
                height: 70 * AppStyle.size1H
                checkable: true
                Material.accent: "transparent"
                Material.primary: "transparent"
                Material.background: AppStyle.primaryInt

                anchors {
                    top: projectCategoryCombo.visible ? projectCategoryCombo.bottom : parent.top
                    topMargin: 25 * AppStyle.size1W
                    horizontalCenter: parent.horizontalCenter
                }
                text: prevPageModel
                      && listId !== Memorito.Process ? qsTr("بروزرسانی") : qsTr(
                                                           "بفرست به پروژه")
                radius: 10 * AppStyle.size1W
                leftPadding: 35 * AppStyle.size1W
                rightPadding: 35 * AppStyle.size1W
                onClicked: {
                    if (projectCategoryCombo.currentIndex === -1)
                    {
                        UsefulFunc.showLog(
                                    qsTr("لطفا پروژه موردنظر را انتخاب کن"),
                                    true)
                        return
                    }
                    let hasFiles = checking()
                    if(hasFiles === 2)
                        return

                    let projectId = projectCategoryCombo.currentIndex
                        !== -1 ? projectCategoryModel.get(
                                     projectCategoryCombo.currentIndex).id : null

                    let json = JSON.stringify(
                            {
                                title : titleInput.text.trim(),
                                user_id: User.id,
                                detail : flickTextArea.text.trim(),
                                list_id : Memorito.Project,
                                has_files: parseInt(hasFiles),
                                priority_id : options["priorityId"]??null,
                                estimate_time : options["estimateTime"]??null,
                                context_id : options["contextId"]??null,
                                energy_id : options["energyId"]??null,
                                due_date : null,
                                friend_id : null,
                                category_id : projectId
                            }, null, 1);

                    if (prevPageModel)
                        ThingsApi.editThing(prevPageModel.id,json,attachModel)
                    else
                    {
                        ThingsApi.addThing(json,attachModel)
                        flickTextArea.detailInput.clear()
                        titleInput.clear()
                        isDual = false
                    }
                }
            }
        }
    } // 10 is project list id
}
