import QtQuick 
import QtQuick.Layouts
import QtQuick.Controls 
import QtQuick.Controls.Material 
import Qt5Compat.GraphicalEffects

import Memorito.Components
import Memorito.Global

import Memorito.Things
import Memorito.Files
import Memorito.Tools

Item {
    id: root

    ListModel { id: attachModel }

    property var options: []
    property var prevPageModel
    property bool isDual: prevPageModel ? true : false

    property int listId: -1
    property int parentId: -1
    property int thingLocalId: -1

    property bool waitingForAddFiles: false
    property bool waitingForDeleteFiles: false

    function cameInToPage(object)
    {
        if (object)
        {
            if (object.thingLocalId)
            {
                prevPageModel = thingsModel.getThingByLocalId(object.thingLocalId)
                attachModel.append(filesModel.getAllFilesByThingLocalId(object.thingLocalId))

                if (listId === Memorito.Process)
                    collectLoader.item.submitBtn.isUpdate = true
            }
        }
    }

    function checking()
    {
        if(titleInput.text.trim() === "")
        {
            UsefulFunc.showLog(qsTr("لطفا قسمت 'چی تو ذهنته؟' رو پر کن"),true)
            titleMoveAnimation.start()
            return 2
        }

        if (attachModel.count > 0)
        {
            for (var i = 0; i < attachModel.count; i++)
                if (attachModel.get(i).change_type !== 3)
                {
                    return 1
                }
        }

        return 0
    }

    function prepareFilesForAdd()
    {
        let fileList= [];
        for(let i = 0; i < attachModel.count; i++)
        {
            let file = attachModel.get(i)
            if(file.change_type === 1) {
                let base64 = mTools.encodeToBase64(String(file.file_source.replace("file://","")))
                fileList.push({"base64_file" : base64 , "file_extension": file.file_extension ,"file_name" :file.file_name})
            }
        }
        return fileList;
    }

    function prepareFilesForDelete()
    {
        let deletedFile= [];
        for(let i = 0; i < attachModel.count; i++)
        {
            let file = attachModel.get(i)
            if( file.change_type === 3)
            {
                deletedFile.push(file.server_id)
            }
        }
        return deletedFile;
    }

    MTools { id: mTools }

    ThingsController { id: thingsController }
    ThingsModel { id: thingsModel }

    FilesController { id: filesController }
    FilesModel { id: filesModel }

    Connections {
        target: thingsController

        function onNewThingAdded(serverId)
        {
            isDual = false
            titleInput.clear()
            flickTextArea.detailInput.clear()

            // Send Files To Server
            if(attachModel.count > 0)
            {
                let fileList= prepareFilesForAdd();
                if(fileList.length <= 0)
                    return

                let json = JSON.stringify(
                        {
                            thing_id: serverId,
                            file_list: fileList
                        }, null, 1);
                filesController.addNewFiles(json)
            }
        }

        function onThingUpdated(serverId)
        {
            if(attachModel.count > 0)
            {
                let deletedFile = prepareFilesForDelete();
                for(let j = 0; j < deletedFile.length; j++)
                {
                    filesController.deleteFile(deletedFile[j])
                    waitingForDeleteFiles= true
                }

                let fileList= prepareFilesForAdd();
                if(fileList.length > 0)
                {
                    let json = JSON.stringify(
                            {
                                thing_id: serverId,
                                file_list: fileList
                            }, null, 1);
                    filesController.addNewFiles(json)
                    waitingForAddFiles = true
                }
            }
            if( !(waitingForAddFiles || waitingForDeleteFiles))
                UsefulFunc.mainStackPop({"thingLocalId":thingLocalId,"chnageType":Memorito.Update})
        }
    }

    Connections {
        target: filesController
        function onNewFilesAdded(rows)
        {
            attachModel.clear()
            waitingForAddFiles = false
            if( !(waitingForAddFiles || waitingForDeleteFiles) && listId !== Memorito.Collect)
                UsefulFunc.mainStackPop({"thingLocalId":thingLocalId,"chnageType":Memorito.Update})
        }

        function onFileDeleted(rowId)
        {
            waitingForDeleteFiles = false
            if( !(waitingForAddFiles || waitingForDeleteFiles))
                UsefulFunc.mainStackPop({"thingLocalId":thingLocalId,"chnageType":Memorito.Update})
        }
    }


    Flickable {
        id: mainFlick

        clip: true
        height: parent.height
        flickableDirection: Flickable.VerticalFlick
        contentHeight: mainFlow.height + (processLoader.active === false ? 0 : 120*AppStyle.size1H)
        width: (nRow === 3 && (listId === Memorito.Process || listId === Memorito.Collect) && isDual) ? parent.width / 2
                                                                                                      : parent.width
        anchors {
            right: parent.right
            top: parent.top
        }

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

                    maximumLength: 50
                    width: parent.width
                    height: parent.height
                    text: prevPageModel?.title ?? "";
                    placeholderText: qsTr("چی تو ذهنته؟")
                    inputMethodHints: Qt.ImhPreferLowercase

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

            AppSplitView {
                width: parent.width
                orientation: Qt.Vertical
                spacing: 100 * AppStyle.size1W
                height: 190 * AppStyle.size1H + Math.max( (mainFlick.height - titleItem.height - 415 * AppStyle.size1H),450 * AppStyle.size1H)

                Item{
                    SplitView.minimumHeight: 100 * AppStyle.size1H
                    SplitView.preferredHeight: 240 * AppStyle.size1H

                    AppFlickTextArea {
                        id: flickTextArea
                        placeholderText: qsTr("بیشتر در مورد چیزی که تو ذهنته بگو") + " (" + qsTr("اختیاری") + ")"
                        text: prevPageModel?.detail ?? "";
                        width: parent.width

                        anchors{
                            top: parent.top
                            bottom: parent.bottom
                            bottomMargin: 10*AppStyle.size1H
                        }
                    }

                }

                Item{
                    SplitView.minimumHeight: 275 * AppStyle.size1H
                    SplitView.preferredHeight: 450 * AppStyle.size1W

                    AppFilesSelection {
                        id: fileRect

                        model: attachModel
                        width: parent.width
                        anchors{
                            top: parent.top
                            topMargin: 10*AppStyle.size1H
                            bottom: parent.bottom
                        }
                    }

                }

            }

            Loader {
                id: optionLoader

                width: flickTextArea.width
                height: active ? 600 * AppStyle.size1H : 0
                active: listId !== Memorito.Collect && listId !== Memorito.Process

                sourceComponent: optionsComponent
            }

            Loader {
                id: collectLoader

                width: flickTextArea.width
                height: active ? (listId === Memorito.Calendar ? 320 * AppStyle.size1H
                                                               : (   listId === Memorito.Project
                                                                  || listId === Memorito.Someday
                                                                  || listId === Memorito.Waiting
                                                                  || listId === Memorito.Refrence) ? 220 * AppStyle.size1H
                                                                                                   : 110 * AppStyle.size1H
                                  )
                               : 0
                sourceComponent: listId === Memorito.NextAction ? nextComponent
                                                                : listId === Memorito.Someday ? somedayComponent
                                                                                              : listId === Memorito.Refrence ? refrenceComponent
                                                                                                                             : listId === Memorito.Waiting ? friendComponent
                                                                                                                                                           : listId === Memorito.Calendar ? calendarComponent
                                                                                                                                                                                          : listId === Memorito.Trash ? trashComponent
                                                                                                                                                                                                                      : listId === Memorito.Done ? doComponent
                                                                                                                                                                                                                                                 : listId === Memorito.Project ? projectCategoryComponent
                                                                                                                                                                                                                                                                               : collectComponent
            }

            Loader {
                id: processLoader

                visible: active
                width: flickTextArea.width
                height: active ? 1800 * AppStyle.size1W : 0
                active: nRow <= 2 && (listId === Memorito.Process || listId === Memorito.Collect) && isDual

                sourceComponent: processComponent
            }
        } // end of Flow
    } //end of Flickable

    Loader {
        asynchronous: true
        width: parent.width / 2
        height: active ? mainFlick.height : 0
        active: nRow === 3 && (listId === Memorito.Process || listId === Memorito.Collect) && isDual

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

                active: true
                asynchronous: true
                width: parent.width
                height: 2000 * AppStyle.size1H

                sourceComponent: processComponent
            }
        } //end of Flickable
    } //end of Loader

    Component {
        id: processComponent

        Item {
            Flow {
                spacing: 10 * AppStyle.size1H

                anchors {
                    top: parent.top
                    right: parent.right
                    rightMargin: 15 * AppStyle.size1W
                    bottom: parent.bottom
                    bottomMargin: 20 * AppStyle.size1H
                    left: parent.left
                    leftMargin: 15 * AppStyle.size1W
                }

                Text {
                    text: qsTr("بهتره که پردازش رو الان انجام ندی و بزاری برای بعد، چون الان ذهنت به این موضوع خیلی اهمیت میده و واقع‌بینانه نیست.")
                    width: parent.width
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    visible: listId === Memorito.Collect
                    horizontalAlignment: Text.AlignHCenter
                    color: Material.color(AppStyle.appTheme?Material.Yellow:Material.Oranges)

                    font {
                        family: AppStyle.appFont
                        pixelSize: AppStyle.size1F * 25
                        bold: true
                    }
                }
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

                    text: qsTr("شاید یک‌روزی انحامش دادم.")
                    width: parent.width
                    rightPadding: AppStyle.ltr ? 0 : 50 * AppStyle.size1W
                    leftPadding:  AppStyle.ltr ? 50 * AppStyle.size1W : 0

                    Image {
                        id: somedayIcon
                        width: 45 * AppStyle.size1W
                        height: width
                        source: "qrc:/someday.svg"
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        sourceSize:Qt.size(width * 2,height * 2)
                        visible: false
                    }

                    ColorOverlay {
                        anchors.fill: somedayIcon
                        source: somedayIcon
                        color: Qt.lighter(AppStyle.primaryColor,AppStyle.appTheme?1.5:1.2)
                    }
                }
                Loader {
                    id: somedayLoader

                    clip: true
                    width: parent.width
                    active: height !== 0
                    height: somedayRadio.checked ? 240 * AppStyle.size1W
                                                 : 0

                    Behavior on height {
                        NumberAnimation {
                            duration: 200
                        }
                    }

                    sourceComponent: somedayComponent
                }

                /*********************************/
                AppRadioButton {
                    id: refrenceRadio

                    text: qsTr("اطلاعات مفیدیه میخوام بعدا بهش مراجعه کنم.")
                    width: parent.width
                    rightPadding: AppStyle.ltr ? 0 : 50 * AppStyle.size1W
                    leftPadding:  AppStyle.ltr ? 50 * AppStyle.size1W : 0

                    Image {
                        id: refrenceIcon

                        height: width
                        visible: false
                        width: 45 * AppStyle.size1W
                        source: "qrc:/refrence.svg"
                        sourceSize:Qt.size(width * 2,height * 2)
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                    }

                    ColorOverlay {
                        anchors.fill: refrenceIcon
                        source: refrenceIcon
                        color: Qt.lighter(AppStyle.primaryColor,AppStyle.appTheme?1.5:1.2)
                    }

                }

                Loader {
                    id: refrenceLoader

                    clip: true
                    width: parent.width
                    active: height !== 0
                    height: refrenceRadio.checked ? 240 * AppStyle.size1W : 0

                    Behavior on height {
                        NumberAnimation {
                            duration: 200
                        }
                    }

                    sourceComponent: refrenceComponent
                }

                /*********************************/
                AppRadioButton {
                    id: trashRadio

                    text: qsTr("به درد نمیخوره، میندازمش سطل آشغال.")
                    width: parent.width
                    rightPadding: AppStyle.ltr ? 0 : 50 * AppStyle.size1W
                    leftPadding:  AppStyle.ltr ? 50 * AppStyle.size1W : 0

                    Image {
                        id: trashIcon

                        height: width
                        visible: false
                        source: "qrc:/trash.svg"
                        width: 45 * AppStyle.size1W
                        sourceSize:Qt.size(width * 2,height * 2)

                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                    }

                    ColorOverlay {
                        anchors.fill: trashIcon
                        source: trashIcon
                        color: Qt.lighter(AppStyle.primaryColor,AppStyle.appTheme?1.5:1.2)
                    }

                }

                Loader {
                    id: trashLoader

                    clip: true
                    width: parent.width
                    active: height !== 0
                    height: trashRadio.checked ? 120 * AppStyle.size1W : 0

                    Behavior on height {
                        NumberAnimation {
                            duration: 200
                        }
                    }

                    sourceComponent: trashComponent
                }
                /*********************************/

                /*********** انجام شدنی‌ها*****************/
                Text {
                    id: action2Text

                    text: "⏺ " + qsTr("این چیز انجام شدنیه") + ":"
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

                    text: "⏺ " + qsTr("این چیز با انجام یک کاری به پایان نمی‌رسه") + ":"

                    width: parent.width
                    color: AppStyle.textColor
                    height: 50 * AppStyle.size1H
                    rightPadding: 50 * AppStyle.size1W
                    verticalAlignment: Text.AlignBottom

                    font {
                        family: AppStyle.appFont
                        pixelSize: AppStyle.size1F * 24
                        bold: true
                    }
                }

                AppRadioButton {
                    id: projectRadio

                    text: qsTr("میخوام یک پروژه جدید بسازم.")
                    width: parent.width
                    rightPadding: AppStyle.ltr ? 0 : 80 * AppStyle.size1W
                    leftPadding:  AppStyle.ltr ? 80 * AppStyle.size1W : 0

                    Image {
                        id: projectIcon
                        width: 45 * AppStyle.size1W
                        height: width
                        source: "qrc:/project.svg"
                        anchors {
                            right: parent.right
                            rightMargin: 25*AppStyle.size1W
                            verticalCenter: parent.verticalCenter
                        }
                        sourceSize:Qt.size(width * 2,height * 2)
                        visible: false
                    }

                    ColorOverlay {
                        anchors.fill: projectIcon
                        source: projectIcon
                        color: Qt.lighter(AppStyle.primaryColor,AppStyle.appTheme?1.5:1.2)
                    }
                }

                Loader {
                    id: projectLoader

                    clip: true
                    width: parent.width
                    active: height !== 0
                    height: projectRadio.checked ? 120 * AppStyle.size1W : 0

                    Behavior on height {
                        NumberAnimation {
                            duration: 200
                        }
                    }

                    sourceComponent: projectComponent
                }

                /*********************************/
                AppRadioButton {
                    id: projectCategoryRadio

                    text: qsTr("میخوام این عمل رو به پروژه های قبلیم اضافه کنم.")
                    width: parent.width
                    rightPadding: AppStyle.ltr ? 0 : 80 * AppStyle.size1W
                    leftPadding:  AppStyle.ltr ? 80 * AppStyle.size1W : 0

                    Image {
                        id: projectCategoryIcon

                        height: width
                        visible: false
                        width: 45 * AppStyle.size1W
                        source: "qrc:/ThingsListIcon/project-item.svg"
                        sourceSize:Qt.size(width * 2,height * 2)

                        anchors {
                            right: parent.right
                            rightMargin: 25*AppStyle.size1W
                            verticalCenter: parent.verticalCenter
                        }
                    }

                    ColorOverlay {
                        anchors.fill: projectCategoryIcon
                        source: projectCategoryIcon
                        color: Qt.lighter(AppStyle.primaryColor,AppStyle.appTheme?1.5:1.2)
                    }

                }

                Loader {
                    id: projectCategoryLoader

                    clip: true
                    width: parent.width
                    active: height !== 0
                    height: projectCategoryRadio.checked ? 240 * AppStyle.size1W : 0

                    Behavior on height {
                        NumberAnimation {
                            duration: 200
                        }
                    }

                    sourceComponent: projectCategoryComponent
                }

                /*********************************/
                Text {
                    id: action4Text

                    text: "⏺ " + qsTr("این چیز نیاز به بیشتر از ۵ دقیقه داره") + ":"
                    width: parent.width
                    color: AppStyle.textColor
                    height: 50 * AppStyle.size1H
                    verticalAlignment: Text.AlignBottom
                    rightPadding: 50 * AppStyle.size1W

                    font {
                        family: AppStyle.appFont
                        pixelSize: AppStyle.size1F * 24
                        bold: true
                    }
                }

                AppRadioButton {
                    id: friendRadio

                    text: qsTr("میخوام اینو یکی دیگه انجام بده.")
                    width: parent.width
                    rightPadding: AppStyle.ltr ? 0 : 80 * AppStyle.size1W
                    leftPadding:  AppStyle.ltr ? 80 * AppStyle.size1W : 0

                    Image {
                        id: waitingIcon

                        height: width
                        visible: false
                        source: "qrc:/waiting.svg"
                        width: 45 * AppStyle.size1W
                        sourceSize:Qt.size(width * 2,height * 2)

                        anchors {
                            right: parent.right
                            rightMargin: 25*AppStyle.size1W
                            verticalCenter: parent.verticalCenter
                        }
                    }
                    ColorOverlay {
                        anchors.fill: waitingIcon
                        source: waitingIcon
                        color: Qt.lighter(AppStyle.primaryColor,AppStyle.appTheme?1.5:1.2)
                    }

                }

                Loader {
                    id: friendLoader

                    clip: true
                    width: parent.width
                    active: height !== 0
                    height: friendRadio.checked ? 240 * AppStyle.size1W : 0

                    Behavior on height {
                        NumberAnimation {
                            duration: 200
                        }
                    }

                    sourceComponent: friendComponent
                }

                /*********************************/
                AppRadioButton {
                    id: calendarRadio

                    text: qsTr("میخوام تو زمان مشخصی انجامش بدم.")
                    width: parent.width
                    rightPadding: AppStyle.ltr ? 0 : 80 * AppStyle.size1W
                    leftPadding:  AppStyle.ltr ? 80 * AppStyle.size1W : 0

                    Image {
                        id: calendarIcon

                        height: width
                        visible: false
                        source: "qrc:/calendar.svg"
                        width: 45 * AppStyle.size1W
                        sourceSize: Qt.size(width * 2,height * 2)

                        anchors {
                            right: parent.right
                            rightMargin: 25*AppStyle.size1W
                            verticalCenter: parent.verticalCenter
                        }
                    }

                    ColorOverlay {
                        anchors.fill: calendarIcon
                        source: calendarIcon
                        color: Qt.lighter(AppStyle.primaryColor,AppStyle.appTheme?1.5:1.2)
                    }
                }

                Loader {
                    id: calendarLoader

                    clip: true
                    active: height !== 0
                    width: parent.width
                    height: calendarRadio.checked ? 320 * AppStyle.size1W : 0

                    Behavior on height {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                    sourceComponent: calendarComponent
                }

                /*********************************/
                AppRadioButton {
                    id: nextRadio

                    text: qsTr("میخوام تو اولین فرصت انجامش بدم.")
                    width: parent.width
                    rightPadding: AppStyle.ltr ? 0 : 80 * AppStyle.size1W
                    leftPadding:  AppStyle.ltr ? 80 * AppStyle.size1W : 0

                    Image {
                        id: nextActionIcon

                        height: width
                        visible: false
                        width: 45 * AppStyle.size1W
                        source: "qrc:/nextAction.svg"
                        sourceSize:Qt.size(width * 2,height * 2)

                        anchors {
                            right: parent.right
                            rightMargin: 25*AppStyle.size1W
                            verticalCenter: parent.verticalCenter
                        }
                    }

                    ColorOverlay {
                        anchors.fill: nextActionIcon
                        source: nextActionIcon
                        color: Qt.lighter(AppStyle.primaryColor,AppStyle.appTheme?1.5:1.2)
                    }
                }

                Loader {
                    id: nextLoader

                    clip: true
                    width: parent.width
                    active: height !== 0
                    height: nextRadio.checked ? 120 * AppStyle.size1W : 0

                    Behavior on height {
                        NumberAnimation {
                            duration: 200
                        }
                    }

                    sourceComponent: nextComponent
                }

                /*********************************/
                Text {
                    id: action5Text

                    text: "⏺ " + qsTr("این چیز کمتر از ۵ دقیقه انجام میشه") + ":"
                    width: parent.width
                    color: AppStyle.textColor
                    height: 50 * AppStyle.size1H
                    verticalAlignment: Text.AlignBottom
                    rightPadding: 50 * AppStyle.size1W

                    font {
                        family: AppStyle.appFont
                        pixelSize: AppStyle.size1F * 24
                        bold: true
                    }
                }

                AppRadioButton {
                    id: doRadio

                    text: qsTr("میخوام الان انجامش بدم.")
                    width: parent.width
                    rightPadding: AppStyle.ltr ? 0 : 80 * AppStyle.size1W
                    leftPadding:  AppStyle.ltr ? 80 * AppStyle.size1W : 0

                    Image {
                        id: doneIcon
                        width: 45 * AppStyle.size1W
                        height: width
                        source: "qrc:/done.svg"
                        sourceSize:Qt.size(width * 2,height * 2)
                        visible: false

                        anchors {
                            right: parent.right
                            rightMargin: 25*AppStyle.size1W
                            verticalCenter: parent.verticalCenter
                        }
                    }
                    ColorOverlay {
                        anchors.fill: doneIcon
                        source: doneIcon
                        color: Qt.lighter(AppStyle.primaryColor,AppStyle.appTheme?1.5:1.2)
                    }
                }
                Loader {
                    id: doLoader

                    clip: true
                    width: parent.width
                    active: height !== 0
                    height: doRadio.checked ? 120 * AppStyle.size1W : 0

                    Behavior on height {
                        NumberAnimation {
                            duration: 200
                        }
                    }

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
                layoutDirection: Qt.RightToLeft

                AppButton {
                    id: submitBtn

                    property bool isUpdate: false
                    text: qsTr("بفرست به پردازش نشده‌ها")

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
                                    type_id         : 1,
                                    title           : titleInput.text.trim(),
                                    detail          : flickTextArea.text.trim(),
                                    status          : 1,
                                    parent_id       : root.parentId === -1? null:root.parentId,

                                    priority_id     : null,
                                    estimated_time   : null,
                                    context_id      : null,
                                    energy_id       : null
                                }, null, 1);

                        if ((listId === Memorito.Collect || listId === Memorito.Process) && !isUpdate)
                        {
                            thingsController.addNewThing(json)
                        }
                        else
                            thingsController.updateThing(prevPageModel.server_id,json)
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
                    Material.background: checked ? AppStyle.primaryInt : "transparent"
                    Material.foreground: checked ? AppStyle.textOnPrimaryColor
                                                 : AppStyle.textColor

                    checked: isDual
                    onCheckedChanged: {
                        isDual = checked
                    }

                    radius: 10 * AppStyle.size1W
                    leftPadding: AppStyle.ltr ? 0 : 35 * AppStyle.size1W
                    rightPadding: AppStyle.ltr ? 35 * AppStyle.size1W : 0

                    Image {
                        id: processIcon

                        height: width
                        visible: false
                        source: "qrc:/arrow.svg"
                        width: 20 * AppStyle.size1W

                        anchors {
                            left: parent.left
                            leftMargin: 30 * AppStyle.size1W
                            verticalCenter: parent.verticalCenter
                        }
                        sourceSize {
                            width: width * 2
                            height: height * 2
                        }
                    }
                    ColorOverlay {
                        rotation: processBtn.checked ? (nRow === 3 ? 90 : 180) : (nRow === 3 ? 270 : 0)
                        anchors.fill: processIcon
                        source: processIcon
                        color:     parent.Material.foreground
                    }
                }
            }
        }
    } //end of collectComponent

    Component {
        id: optionsComponent

        Flow {
            property alias energyInput: energyInput
            property alias contextInput: contextInput
            property alias priorityInput: priorityInput
            property alias estimateInput: estimateInput

            width: parent.width
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

                    color: AppStyle.textColor
                    text: qsTr("محل انجام") + ":"
                    width: 250 * AppStyle.size1W

                    anchors {
                        right: parent.right
                        rightMargin: 15 * AppStyle.size1W
                        verticalCenter: parent.verticalCenter
                    }

                    font {
                        family: AppStyle.appFont
                        pixelSize: AppStyle.size1F * 30
                        bold: true
                    }
                }
                AppButton{
                    text: qsTr("ثبت اولین محل‌انجام")
                    visible: !contextInput.visible

                    anchors {
                        right: contextText.left
                        rightMargin: 15 * AppStyle.size1W
                        left: parent.left
                        leftMargin: 15 * AppStyle.size1W
                        verticalCenter: contextText.verticalCenter
                    }

                    onClicked: {
                        UsefulFunc.mainStackPush("qrc:/Contexts/Contexts.qml",qsTr("محل‌های انجام"),{})
                    }
                }

                AppComboBox {
                    id: contextInput

                    visible: Constants.contextsListModel.count>0
                    font.pixelSize: AppStyle.size1F * 28
                    textRole: "context_name"
                    placeholderText: qsTr("محل انجام") + " (" + qsTr("اختیاری") + ")"
                    currentIndex: prevPageModel && Constants.contextsListModel.count > 0 ? ( prevPageModel.context_id_local ? UsefulFunc.findInModel(prevPageModel.context_id_local, "local_id", Constants.contextsListModel).index
                                                                                                                            : -1)
                                                                                         : -1

                    anchors {
                        right: contextText.left
                        rightMargin: 15 * AppStyle.size1W
                        left: parent.left
                        leftMargin: 15 * AppStyle.size1W
                        bottom: contextText.bottom
                        bottomMargin: -20 * AppStyle.size1W
                    }

                    model: Constants.contextsListModel
                    onCurrentIndexChanged: {
                        options["contextId"] = contextInput.currentIndex === -1 ? null
                                                                                : Constants.contextsListModel.get(contextInput.currentIndex).server_id
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
                    color: AppStyle.textColor

                    anchors {
                        right: parent.right
                        rightMargin: 15 * AppStyle.size1W
                        verticalCenter: parent.verticalCenter
                    }
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
                    placeholderText: qsTr("اولویت") + " (" + qsTr("اختیاری") + ")"
                    currentIndex: prevPageModel ? prevPageModel.priority_id ? UsefulFunc.findInModel(prevPageModel.priority_id, "Id", Constants.priorityListModel).index : -1 : -1

                    model: Constants.priorityListModel
                    onCurrentIndexChanged: {
                        options["priorityId"] = priorityInput.currentIndex === -1 ? null : Constants.priorityListModel.get( priorityInput.currentIndex).Id
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

                    color: AppStyle.textColor
                    text: qsTr("سطح انرژی") + ":"
                    width: 250 * AppStyle.size1W

                    anchors {
                        right: parent.right
                        rightMargin: 15 * AppStyle.size1W
                        verticalCenter: parent.verticalCenter
                    }
                    font {
                        family: AppStyle.appFont
                        pixelSize: AppStyle.size1F * 30
                        bold: true
                    }
                }

                AppComboBox {
                    id: energyInput

                    textRole: "Text"
                    iconRole: "iconSource"
                    font.pixelSize: AppStyle.size1F * 28
                    placeholderText: qsTr("سطح انرژی") + " (" + qsTr("اختیاری") + ")"
                    currentIndex: prevPageModel ? prevPageModel.energy_id ? UsefulFunc.findInModel(prevPageModel.energy_id, "Id", Constants.energyListModel).index : -1 : -1

                    anchors {
                        right: energyText.left
                        rightMargin: 15 * AppStyle.size1W
                        left: parent.left
                        leftMargin: 15 * AppStyle.size1W
                        bottom: energyText.bottom
                        bottomMargin: -20 * AppStyle.size1W
                    }

                    model: Constants.energyListModel
                    onCurrentIndexChanged: {
                        options["energyId"] = energyInput.currentIndex === -1 ? null : Constants.energyListModel.get( energyInput.currentIndex).Id
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

                    color: AppStyle.textColor
                    width: 250 * AppStyle.size1W
                    text: qsTr("تخمین زمان انجام") + ":"

                    anchors {
                        right: parent.right
                        rightMargin: 15 * AppStyle.size1W
                        verticalCenter: parent.verticalCenter
                    }

                    font {
                        family: AppStyle.appFont
                        pixelSize: AppStyle.size1F * 30
                        bold: true
                    }
                }

                TextField {
                    id: estimateInput

                    selectByMouse: true
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignBottom
                    Material.accent: AppStyle.primaryColor
                    text: prevPageModel?.estimated_time??"";
                    placeholderTextColor: AppStyle.textColor
                    placeholderText: qsTr("تخمین به دقیقه") + " (" + qsTr("اختیاری") + ")"
                    horizontalAlignment: Text.AlignHCenter

                    font {
                        family: AppStyle.appFont
                        pixelSize: 28 * AppStyle.size1F
                    }
                    validator: RegularExpressionValidator {
                        regularExpression: /[0123456789۰۱۲۳۴۵۶۷۸۹]{3}/ig
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

                        options["estimateTime"] = estimateInput.text.trim() === "" ? null : parseInt(estimateInput.text.trim())
                    }
                }
            }
        }
    } // end of optionsComponent

    Component {
        id: projectComponent

        Rectangle {
            id: projectItem

            radius: 10 * AppStyle.size1W
            color: "transparent"

            border {
                width: 3 * AppStyle.size1W
                color: Material.hintTextColor
            }

            anchors {
                fill: parent
            }

            AppButton {
                id: projectBtn

                width: 410 * AppStyle.size1W
                height: 70 * AppStyle.size1H
                text: qsTr("ساخت پروژه جدید")
                radius: 10 * AppStyle.size1W
                leftPadding: 35 * AppStyle.size1W

                Material.accent: "transparent"
                Material.primary: "transparent"
                Material.background: AppStyle.primaryInt

                anchors {
                    centerIn: parent
                }

                onClicked: {
                    let hasFiles = checking()
                    if(hasFiles === 2)
                        return

                    let json = JSON.stringify(
                            {
                                type_id         : 2,
                                title           : titleInput.text.trim(),
                                detail          : flickTextArea.text.trim(),
                                status          : 2,
                                parent_id       : root.parentId === -1? null:root.parentId,

                                energy_id : options["energyId"]??null,
                                context_id : options["contextId"]??null,
                                priority_id : options["priorityId"]??null,
                                estimated_time : options["estimateTime"]??null,
                            }, null, 1);

                    if (listId === Memorito.Collect)
                    {
                        thingsController.addNewThing(json)
                    }
                    else {
                        thingsController.updateThing(prevPageModel.server_id,json)
                    }
                }
            }
        }
    }

    Component {
        id: nextComponent

        Rectangle {
            id: nextItem

            radius: 10 * AppStyle.size1W
            color: "transparent"

            border {
                width: 3 * AppStyle.size1W
                color: Material.hintTextColor
            }

            anchors {
                fill: parent
            }

            AppButton {
                id: nextBtn

                width: 410 * AppStyle.size1W
                height: 70 * AppStyle.size1H
                radius: 10 * AppStyle.size1W
                leftPadding: 35 * AppStyle.size1W
                rightPadding: 35 * AppStyle.size1W
                text: prevPageModel && listId !== Memorito.Process ? qsTr("بروزرسانی") : qsTr("بفرست به عملیات بعدی")

                Material.accent: "transparent"
                Material.primary: "transparent"
                Material.background: AppStyle.primaryInt

                anchors {
                    centerIn: parent
                }

                onClicked: {
                    let hasFiles = checking()
                    if(hasFiles === 2)
                        return

                    let json = JSON.stringify(
                            {
                                type_id         : prevPageModel?.type_id??1,
                                title           : titleInput.text.trim(),
                                detail          : flickTextArea.text.trim(),
                                status          : 2,
                                parent_id       : root.parentId === -1? null:root.parentId,

                                energy_id : options["energyId"]??null,
                                context_id : options["contextId"]??null,
                                priority_id : options["priorityId"]??null,
                                estimated_time : options["estimateTime"]??null,
                            }, null, 1);

                    if (listId === Memorito.Collect)
                    {
                        thingsController.addNewThing(json)
                    }
                    else {
                        thingsController.updateThing(prevPageModel.server_id,json)
                    }
                }
            }
        }
    } // 3 is next action list id

    Component {
        id: refrenceComponent

        Rectangle {
            id: refrenceItem

            radius: 10 * AppStyle.size1W
            color: "transparent"

            border{
                width: 3 * AppStyle.size1W
                color: Material.hintTextColor
            }

            anchors {
                fill: parent
            }

            Text {
                id: refrenceCategoryText

                color: AppStyle.textColor
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
            }

            AppButton{
                radius: 10 * AppStyle.size1W
                text: qsTr("ثبت اولین دسته‌بندی")
                visible: !refrenceCategoryCombo.visible

                anchors {
                    right: refrenceCategoryText.left
                    rightMargin: 15 * AppStyle.size1W
                    left: parent.left
                    leftMargin: 15 * AppStyle.size1W
                    verticalCenter: refrenceCategoryText.verticalCenter
                }
                onClicked: {
                    UsefulFunc.mainStackPush("qrc:/Things/ThingsList.qml",qsTr("مرجع"),{listId: Memorito.Refrence,pageTitle:qsTr("مرجع")})
                }
            }
            AppComboBox {
                id: refrenceCategoryCombo

                visible: refrenceCategoryModel.count>0
                textRole: "title"
                font.pixelSize: AppStyle.size1F * 28
                placeholderText: qsTr("دسته بندی")
                currentIndex: prevPageModel && refrenceCategoryModel.count > 0 ? (prevPageModel.parent_id_local ? UsefulFunc.findInModel(prevPageModel.parent_id_local, "local_id", refrenceCategoryModel).index
                                                                                                              : -1)
                                                                               : -1

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
                    refrenceCategoryModel.clear()
                    refrenceCategoryModel.append(thingsModel.getAllRefrencesGroup())
                }
            }

            AppButton {
                id: refrenceBtn

                width: 410 * AppStyle.size1W
                height: 70 * AppStyle.size1H
                radius: 10 * AppStyle.size1W
                leftPadding: 35 * AppStyle.size1W
                rightPadding: 35 * AppStyle.size1W
                visible: refrenceCategoryCombo.visible
                text: prevPageModel && listId !== Memorito.Process ? qsTr("بروزرسانی") : qsTr("بفرست به مرجع")

                Material.accent: "transparent"
                Material.primary: "transparent"
                Material.background: AppStyle.primaryInt

                anchors {
                    top: refrenceCategoryCombo ? refrenceCategoryCombo.visible ? refrenceCategoryCombo.bottom : parent.top : undefined
                    topMargin: 25 * AppStyle.size1W
                    horizontalCenter: parent.horizontalCenter
                }

                onClicked: {
                    let hasFiles = checking()
                    if(hasFiles === 2)
                        return

                    let parentId = refrenceCategoryCombo.currentIndex !== -1 ? refrenceCategoryModel.get(refrenceCategoryCombo.currentIndex).server_id
                                                                               : null

                    let json = JSON.stringify(
                            {
                                type_id         : prevPageModel?.type_id??1,
                                title           : titleInput.text.trim(),
                                detail          : flickTextArea.text.trim(),
                                status          : 4,
                                parent_id       : root.parentId === -1? parentId
                                                                      : root.parentId,

                                energy_id : options["energyId"]??null,
                                context_id : options["contextId"]??null,
                                priority_id : options["priorityId"]??null,
                                estimated_time : options["estimateTime"]??null
                            }, null, 1);

                    if (prevPageModel && listId !== Memorito.Process)
                    {
                        thingsController.updateThing(prevPageModel.server_id,json)
                    }
                    else {
                        thingsController.addNewThing(json)
                    }
                }
            }
        }
    } // 4 is refrence list id

    Component {
        id: friendComponent

        Rectangle {
            id: friendItem

            color: "transparent"
            radius: 10 * AppStyle.size1W

            border{
                width: 3 * AppStyle.size1W
                color: Material.hintTextColor
            }

            anchors {
                fill: parent
            }

            Text {
                id: friendCategoryText

                color: AppStyle.textColor
                text: qsTr("انتخاب دوست") + ":"

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
            }

            AppButton{
                text: qsTr("ثبت اولین دوست")
                radius: 10 * AppStyle.size1W
                visible: !friendCombo.visible

                anchors {
                    right: friendCategoryText.left
                    rightMargin: 15 * AppStyle.size1W
                    left: parent.left
                    leftMargin: 15 * AppStyle.size1W
                    verticalCenter: friendCategoryText.verticalCenter
                }

                onClicked: {
                    UsefulFunc.mainStackPush("qrc:/Friends/Friends.qml",qsTr("دوستان"),{listId: Memorito.Waiting,pageTitle:qsTr("لیست انتظار")})
                }
            }
            AppComboBox {
                id: friendCombo

                visible: Constants.friendsListModel.count >0
                textRole: "friend_name"
                font.pixelSize: AppStyle.size1F * 28
                placeholderText: qsTr("دوست موردنظرت رو انتخاب کن.")
                currentIndex: prevPageModel ? Constants.friendsListModel.count > 0 ? prevPageModel.friend_id ? UsefulFunc.findInModel(prevPageModel.friend_id, "id", Constants.friendsListModel).index : -1 : -1 : -1

                anchors {
                    top: parent.top
                    topMargin: 10 * AppStyle.size1W
                    right: friendCategoryText.left
                    rightMargin: currentIndex === -1 ? 20 * AppStyle.size1W : 50 * AppStyle.size1W
                    left: parent.left
                    leftMargin: 20 * AppStyle.size1W
                }
                model: Constants.friendsListModel
            }

            AppButton {
                id: friendBtn

                width: 410 * AppStyle.size1W
                height: 70 * AppStyle.size1H
                visible: friendCombo.visible
                radius: 10 * AppStyle.size1W
                leftPadding: 35 * AppStyle.size1W
                rightPadding: 35 * AppStyle.size1W
                text: prevPageModel && listId !== Memorito.Process ? qsTr("بروزرسانی") : qsTr("بفرست به لیست انتظار")

                Material.accent: "transparent"
                Material.primary: "transparent"
                Material.background: AppStyle.primaryInt

                anchors {
                    top: friendCombo ? friendCombo.visible ? friendCombo.bottom : parent.top : undefined
                    topMargin: 25 * AppStyle.size1W
                    horizontalCenter: parent.horizontalCenter
                }
                onClicked: {

                    if (friendCombo.currentIndex === -1) {
                        if (Constants.friendsListModel.count > 0){
                            UsefulFunc.showLog( qsTr("لطفا دوست خودتو انتخاب کن."), true)
                            return
                        }
                    }

                    let hasFiles = checking()
                    if(hasFiles === 2)
                        return

                    let friendId = Constants.friendsListModel.get(friendCombo.currentIndex).id

                    let json = JSON.stringify(
                            {
                                title : titleInput.text.trim(),
                                user_id: User.id,
                                detail : flickTextArea.text.trim(),
                                list_id : Memorito.Waiting,
                                has_files: parseInt(hasFiles),
                                priority_id : options["priorityId"]??null,
                                estimated_time : options["estimateTime"]??null,
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

            clip: true
            color: "transparent"
            radius: 10 * AppStyle.size1W

            border {
                width: 3 * AppStyle.size1W
                color: Material.hintTextColor
            }

            anchors {
                fill: parent
            }

            Behavior on height {
                NumberAnimation {
                    duration: 200
                }
            }

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

                TabButton{
                    text: qsTr("زمان دلخواه")
                    width: 200 * AppStyle.size1W
                    font {
                        family: AppStyle.appFont
                        pixelSize: AppStyle.size1F * 25
                    }
                }

                TabButton{
                    text: qsTr("فردا")
                    width: 200 * AppStyle.size1W
                    font {
                        family: AppStyle.appFont
                        pixelSize: AppStyle.size1F * 25
                    }
                    onCheckedChanged: {
                        if(checked)
                        {
                            var today = new Date()
                            today.setDate(today.getDate()+1)
                            datePicker.selectedDate = today
                        }
                    }
                }

                TabButton{
                    text: qsTr("پس فردا")
                    width: 200 * AppStyle.size1W
                    font {
                        family: AppStyle.appFont
                        pixelSize: AppStyle.size1F * 25
                    }
                    onCheckedChanged: {
                        if(checked)
                        {
                            var today = new Date()
                            today.setDate(today.getDate()+2)
                            datePicker.selectedDate = today
                        }
                    }
                }

                TabButton{
                    text: qsTr("آخرهفته")
                    width: 200 * AppStyle.size1W
                    font {
                        family: AppStyle.appFont
                        pixelSize: AppStyle.size1F * 25
                    }
                    onCheckedChanged: {
                        if(checked)
                        {
                            var today = new Date()
                            today.setDate((AppStyle.ltr?6:4)-today.getDay()+today.getDate())
                            datePicker.selectedDate = today
                        }
                    }
                }

                TabButton{
                    text: qsTr("اول هفته‌ی بعد")
                    width: 200 * AppStyle.size1W
                    font {
                        family: AppStyle.appFont
                        pixelSize: AppStyle.size1F * 25
                    }
                    onCheckedChanged: {
                        if(checked)
                        {
                            var today = new Date()
                            today.setDate((AppStyle.ltr?8:6)-today.getDay()+today.getDate())
                            datePicker.selectedDate = today
                        }
                    }
                }

                TabButton{
                    text: qsTr("آخر ماه")
                    width: 200 * AppStyle.size1W
                    font {
                        family: AppStyle.appFont
                        pixelSize: AppStyle.size1F * 25
                    }
                    onCheckedChanged: {
                        if(checked)
                        {
                            let localeToday = UsefulFunc.convertDateToLocale(new Date())
                            let lastdayofMonth = UsefulFunc.convertLocaleDateToGregotian(localeToday[0],Number(localeToday[1])+1,1)
                            lastdayofMonth.setDate(lastdayofMonth.getDate()-1)

                            datePicker.selectedDate = lastdayofMonth
                        }
                    }
                }

                TabButton{
                    text: qsTr("اول ماه بعد")
                    width: 200 * AppStyle.size1W
                    font {
                        family: AppStyle.appFont
                        pixelSize: AppStyle.size1F * 25
                    }
                    onCheckedChanged: {
                        if(checked)
                        {

                            let localeToday = UsefulFunc.convertDateToLocale(new Date())
                            let lastdayofMonth = UsefulFunc.convertLocaleDateToGregotian(localeToday[0],Number(localeToday[1])+1,1)

                            datePicker.selectedDate = lastdayofMonth
                        }
                    }
                }
            }

            property date dueDate: prevPageModel?.due_date ? new Date(prevPageModel.due_date) : new Date("Invalid") ?? new Date("Invalid");
            AppCheckBox {
                id: clockCheck

                text: qsTr("تعیین ساعت")
                visible: suggestionTab.currentIndex === 0

                anchors {
                    left: parent.left
                    leftMargin: 20 * AppStyle.size1W
                    top: suggestionTab.bottom
                    topMargin: 20 * AppStyle.size1W
                }
                checked: prevPageModel ? prevPageModel.due_date ? !(calendarItem.dueDate.getHours() === 5 && calendarItem.dueDate.getMinutes() === 17
                                                                    && calendarItem.dueDate.getSeconds() === 17)
                                                                : false : false
            }

            AppDatePicker {
                id: datePicker

                minDate: new Date()
                selectedDate: calendarItem.dueDate
                hasTimeSelection: clockCheck.checked
                visible: suggestionTab.currentIndex === 0
                placeholderText: qsTr("زمان مورد نظرت رو انتخاب کن.")
                height: 100*AppStyle.size1H

                anchors {
                    top: suggestionTab.bottom
                    right: clockCheck.left
                    rightMargin: 30 * AppStyle.size1W
                    left: parent.left
                    leftMargin: 20 * AppStyle.size1W
                }
            }

            Text{
                color: AppStyle.textColor
                visible: suggestionTab.currentIndex !== 0
                text: qsTr("زمان انتخاب شده") + ": "+ datePicker.selectedDateText

                anchors {
                    top: suggestionTab.bottom
                    topMargin: 20 * AppStyle.size1W
                    right: parent.right
                    rightMargin: 20 * AppStyle.size1W
                    left: parent.left
                    leftMargin: 20 * AppStyle.size1W
                }

                font {
                    family: AppStyle.appFont
                    pixelSize: AppStyle.size1F * 30
                }

            }

            AppButton {
                id: calendarBtn

                width: 410 * AppStyle.size1W
                height: 70 * AppStyle.size1H
                radius: 10 * AppStyle.size1W
                leftPadding: 35 * AppStyle.size1W
                text: prevPageModel && listId !== Memorito.Process ? qsTr("بروزرسانی") : qsTr("بفرست به تقویم")

                Material.accent: "transparent"
                Material.primary: "transparent"
                Material.background: AppStyle.primaryInt

                anchors {
                    top: datePicker.bottom
                    topMargin: 20 * AppStyle.size1W
                    horizontalCenter: parent.horizontalCenter
                }

                onClicked: {

                    if (datePicker.selectedDate.toString() === "Invalid Date") {
                        UsefulFunc.showLog( qsTr("لطفا زمانی که میخوای این کار رو بکنی مشخص کن"), true)
                        return
                    }
                    let hasFiles = checking()
                    if(hasFiles === 2)
                        return

                    if (!clockCheck.checked) {
                        datePicker.selectedDate = new Date(datePicker.selectedDate.setHours(
                                                               5))
                        datePicker.selectedDate = new Date(datePicker.selectedDate.setMinutes(
                                                               17))
                        datePicker.selectedDate = new Date(datePicker.selectedDate.setSeconds(
                                                               17))
                    }
                    let dueDate = encodeURIComponent(UsefulFunc.formatDate( datePicker.selectedDate, false ))
                    let json = JSON.stringify(
                            {
                                title : titleInput.text.trim(),
                                user_id: User.id,
                                detail : flickTextArea.text.trim(),
                                list_id : Memorito.Calendar,
                                has_files: parseInt(hasFiles),
                                priority_id : options["priorityId"]??null,
                                estimated_time : options["estimateTime"]??null,
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

            radius: 10 * AppStyle.size1W
            color: "transparent"

            border {
                width: 3 * AppStyle.size1W
                color: Material.hintTextColor
            }

            anchors {
                fill: parent
            }

            AppButton {
                id: trashBtn

                width: 410 * AppStyle.size1W
                height: 70 * AppStyle.size1H
                radius: 10 * AppStyle.size1W
                leftPadding: 35 * AppStyle.size1W
                rightPadding: 35 * AppStyle.size1W
                text: prevPageModel && listId !== Memorito.Process ? qsTr("بروزرسانی") : qsTr("بفرست به سطل آشغال")

                Material.accent: "transparent"
                Material.primary: "transparent"
                Material.background: AppStyle.primaryInt

                anchors {
                    centerIn: parent
                }

                onClicked: {
                    let hasFiles = checking()
                    if(hasFiles === 2)
                        return
                    let json = JSON.stringify(
                            {
                                type_id         : prevPageModel?.type_id??1,
                                title           : titleInput.text.trim(),
                                detail          : flickTextArea.text.trim(),
                                status          : 2,
                                parent_id       : root.parentId === -1? null:root.parentId,
                                display_type    : 3,

                                energy_id : options["energyId"]??null,
                                context_id : options["contextId"]??null,
                                priority_id : options["priorityId"]??null,
                                estimated_time : options["estimateTime"]??null,
                            }, null, 1);

                    if (listId === Memorito.Collect)
                    {
                        thingsController.addNewThing(json)
                    }
                    else {
                        thingsController.updateThing(prevPageModel.server_id,json)
                    }
                }
            }
        }
    } // 7 is trash list id

    Component {
        id: doComponent

        Rectangle {
            id: doItem

            radius: 10 * AppStyle.size1W
            color: "transparent"

            border {
                width: 3 * AppStyle.size1W
                color: Material.hintTextColor
            }

            anchors {
                fill: parent
            }

            AppButton {
                id: doBtn

                width: 410 * AppStyle.size1W
                height: 70 * AppStyle.size1H
                radius: 10 * AppStyle.size1W
                leftPadding: 35 * AppStyle.size1W
                rightPadding: 35 * AppStyle.size1W
                text: prevPageModel && listId !== Memorito.Process ? qsTr("بروزرسانی") : qsTr("بفرست به انجام شده ها")

                Material.accent: "transparent"
                Material.primary: "transparent"
                Material.background: AppStyle.primaryInt

                anchors {
                    centerIn: parent
                }

                onClicked: {
                    let hasFiles = checking()
                    if(hasFiles === 2)
                        return
                    let json = JSON.stringify(
                            {
                                type_id         : prevPageModel?.type_id??1,
                                title           : titleInput.text.trim(),
                                detail          : flickTextArea.text.trim(),
                                status          : 3,
                                parent_id       : root.parentId === -1? null:root.parentId,

                                energy_id : options["energyId"]??null,
                                context_id : options["contextId"]??null,
                                priority_id : options["priorityId"]??null,
                                estimated_time : options["estimateTime"]??null,
                            }, null, 1);

                    if (listId === Memorito.Collect)
                    {
                        thingsController.addNewThing(json)
                    }
                    else {
                        thingsController.updateThing(prevPageModel.server_id,json)
                    }
                }
            }
        }
    } // 8 is Done list id

    Component {
        id: somedayComponent

        Rectangle {
            id: somedayItem

            radius: 10 * AppStyle.size1W
            color: "transparent"

            border {
                width: 3 * AppStyle.size1W
                color: Material.hintTextColor
            }

            anchors {
                fill: parent
            }

            Text {
                id: somedayCategoryText

                text: qsTr("دسته بندی") + ":"
                color: AppStyle.textColor

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
            }

            AppComboBox {
                id: somedayCategoryCombo


                textRole: "title"
                font.pixelSize: AppStyle.size1F * 28
                placeholderText: qsTr("دسته بندی") + " (" + qsTr("اختیاری") + ")"
                currentIndex: prevPageModel ? somedayCategoryModel.count > 0 ? prevPageModel.category_id ? UsefulFunc.findInModel(prevPageModel.category_id, "id", somedayCategoryModel).index : -1 : -1 : -1
                visible: somedayCategoryModel.count !== 0

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
                    somedayCategoryModel.clear()
                    somedayCategoryModel.append(thingsModel.getAllSomedayGroup())
                }
            }

            AppButton{
                radius: 10 * AppStyle.size1W
                text: qsTr("ثبت اولین دسته‌بندی")
                visible: !somedayCategoryCombo.visible

                anchors {
                    right: somedayCategoryText.left
                    rightMargin: 15 * AppStyle.size1W
                    left: parent.left
                    leftMargin: 15 * AppStyle.size1W
                    verticalCenter: somedayCategoryText.verticalCenter
                }

                onClicked: {
                    UsefulFunc.mainStackPush("qrc:/Things/ThingsList.qml",qsTr("شاید یک‌روزی"),{listId: Memorito.Someday,pageTitle:qsTr("شاید یک‌روزی")})
                }
            }
            AppButton {
                id: somedayBtn

                width: 410 * AppStyle.size1W
                height: 70 * AppStyle.size1H
                radius: 10 * AppStyle.size1W
                leftPadding: 35 * AppStyle.size1W
                rightPadding: 35 * AppStyle.size1W
                visible: somedayCategoryCombo.visible
                text: prevPageModel && listId !== Memorito.Process ? qsTr("بروزرسانی") : qsTr("بفرست به شاید یک روزی")

                Material.accent: "transparent"
                Material.primary: "transparent"
                Material.background: AppStyle.primaryInt

                anchors {
                    top: somedayCategoryCombo ? somedayCategoryCombo.visible ? somedayCategoryCombo.bottom : parent.top : undefined
                    topMargin: 25 * AppStyle.size1W
                    horizontalCenter: parent.horizontalCenter
                }

                onClicked: {
                    let hasFiles = checking()
                    if(hasFiles === 2)
                        return

                    let parentId = refrenceCategoryCombo.currentIndex !== -1 ? refrenceCategoryModel.get(refrenceCategoryCombo.currentIndex).server_id
                                                                               : null

                    let json = JSON.stringify(
                            {
                                type_id         : prevPageModel?.type_id??1,
                                title           : titleInput.text.trim(),
                                detail          : flickTextArea.text.trim(),
                                status          : 5,
                                parent_id       : root.parentId === -1? parentId
                                                                      : root.parentId,

                                energy_id : options["energyId"]??null,
                                context_id : options["contextId"]??null,
                                priority_id : options["priorityId"]??null,
                                estimated_time : options["estimateTime"]??null
                            }, null, 1);

                    if (prevPageModel && listId !== Memorito.Process)
                    {
                        thingsController.updateThing(prevPageModel.server_id,json)
                    }
                    else {
                        thingsController.addNewThing(json)
                    }
                }
            }
        }
    } // 9 is someday list id

    Component {
        id: projectCategoryComponent

        Rectangle {
            id: projectCategoryItem

            radius: 10 * AppStyle.size1W
            color: "transparent"

            border {
                width: 3 * AppStyle.size1W
                color: Material.hintTextColor
            }

            anchors {
                fill: parent
            }

            Text {
                id: projectCategoryText

                color: AppStyle.textColor
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
            }

            AppButton{
                radius: 10 * AppStyle.size1W
                text: qsTr("ثبت اولین پروژه")
                visible: !projectCategoryCombo.visible

                anchors {
                    right: projectCategoryText.left
                    rightMargin: 15 * AppStyle.size1W
                    left: parent.left
                    leftMargin: 15 * AppStyle.size1W
                    verticalCenter: projectCategoryText.verticalCenter
                }

                onClicked: {
                    UsefulFunc.mainStackPush("qrc:/Things/ThingsList.qml",qsTr("پروژه‌ها"),{listId: Memorito.Project,pageTitle:qsTr("پروژه‌ها")})
                }
            }

            AppComboBox {
                id: projectCategoryCombo

                textRole: "title"
                font.pixelSize: AppStyle.size1F * 28
                placeholderText: qsTr("پروژه موردنظرت رو انتخاب کن.")
                currentIndex: prevPageModel && projectCategoryModel.count > 0 ? (prevPageModel.parent_id_local ? UsefulFunc.findInModel(prevPageModel.parent_id_local, "local_id", projectCategoryModel).index
                                                                                                              : -1)
                                                                              : -1

                anchors {
                    top: parent.top
                    topMargin: 10 * AppStyle.size1W
                    right: projectCategoryText.left
                    rightMargin: currentIndex === -1 ? 20 * AppStyle.size1W : 50 * AppStyle.size1W
                    left: parent.left
                    leftMargin: 20 * AppStyle.size1W
                }

                visible: projectCategoryCombo.count > 0
                model: ListModel{ id: projectCategoryModel}
                Component.onCompleted: {
                    projectCategoryModel.clear()
                    projectCategoryModel.append(thingsModel.getAllThingsGroup())
                }
            }
            AppButton {
                id: projectCategoryBtn

                width: 410 * AppStyle.size1W
                height: 70 * AppStyle.size1H
                radius: 10 * AppStyle.size1W
                leftPadding: 35 * AppStyle.size1W
                rightPadding: 35 * AppStyle.size1W
                visible: projectCategoryCombo.visible
                text: prevPageModel && listId !== Memorito.Process ? qsTr("بروزرسانی") : qsTr("بفرست به پروژه")

                Material.accent: "transparent"
                Material.primary: "transparent"
                Material.background: AppStyle.primaryInt

                anchors {
                    top: projectCategoryCombo.visible ? projectCategoryCombo.bottom : parent.top
                    topMargin: 25 * AppStyle.size1W
                    horizontalCenter: parent.horizontalCenter
                }
                onClicked: {
                    if (projectCategoryCombo.currentIndex === -1)
                    {
                        UsefulFunc.showLog( qsTr("لطفا پروژه موردنظرت رو انتخاب کن."), true)
                        return
                    }
                    let hasFiles = checking()
                    if(hasFiles === 2)
                        return


                    let parentId = projectCategoryCombo.currentIndex !== -1 ? projectCategoryCombo.get(projectCategoryCombo.currentIndex).server_id
                                                                            : null

                    let json = JSON.stringify(
                            {
                                type_id         : prevPageModel?.type_id??1,
                                title           : titleInput.text.trim(),
                                detail          : flickTextArea.text.trim(),
                                status          : 5,
                                parent_id       : root.parentId === -1? parentId
                                                                      : root.parentId,

                                energy_id : options["energyId"]??null,
                                context_id : options["contextId"]??null,
                                priority_id : options["priorityId"]??null,
                                estimated_time : options["estimateTime"]??null
                            }, null, 1);

                    if (prevPageModel && listId !== Memorito.Process)
                    {
                        thingsController.updateThing(prevPageModel.server_id,json)
                    }
                    else {
                        thingsController.addNewThing(json)
                    }
                }
            }
        }
    } // 10 is project list id
}
