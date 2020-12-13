import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtGraphicalEffects 1.14
import "qrc:/Components/" as App
import QtQuick.Dialogs 1.2
import "qrc:/Managment/" as Managment

Item{
    Flickable{
        id: mainFlick
        height: parent.height
        width: nRow==3 && processBtn.checked?parent.width/2 : parent.width
        clip:true
        contentHeight: item1.height
        anchors{
            right: parent.right
            top: parent.top
        }
        flickableDirection: Flickable.VerticalFlick
        onContentYChanged: {
            if(contentY<0 || contentHeight < mainFlick.height)
                contentY = 0
            else if(contentY > (contentHeight-mainFlick.height))
                contentY = contentHeight-mainFlick.height
        }
        onContentXChanged: {
            if(contentX<0 || contentWidth < mainFlick.width)
                contentX = 0
            else if(contentX > (contentWidth-mainFlick.width))
                contentX = (contentWidth-mainFlick.width)
        }
        ScrollBar.vertical: ScrollBar {
            hoverEnabled: true
            active: hovered || pressed
            orientation: Qt.Vertical
            anchors.right: mainFlick.right
            height: parent.height
            width: hovered || pressed?18*size1W:8*size1W
        }
        Item{
            id:item1
            width: parent.width
            height: titleItem.height+control.height+fileRect.height+processBtn.height + 100*size1H + processLoader.height
            Item{
                id: titleItem
                width: parent.width
                height: 100*size1H
                anchors{
                    top: parent.top
                    topMargin: 15*size1H
                    left: parent.left
                    right: parent.right
                    rightMargin: 25*size1W
                    leftMargin: 25*size1W
                }
                App.TextInput{
                    id:usernameInput
                    placeholderText: qsTr("چی تو ذهنته؟")
                    width: parent.width
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    inputMethodHints: Qt.ImhPreferLowercase
                    font.bold:false
                    maximumLength: 50
                    SequentialAnimation {
                        id:usernameMoveAnimation
                        running: false
                        loops: 3
                        NumberAnimation { target: usernameInput; property: "anchors.horizontalCenterOffset"; to: -10; duration: 50}
                        NumberAnimation { target: usernameInput; property: "anchors.horizontalCenterOffset"; to: 10; duration: 100}
                        NumberAnimation { target: usernameInput; property: "anchors.horizontalCenterOffset"; to: 0; duration: 50}
                    }
                }
            }

            Flickable{
                id: control
                anchors{
                    top: titleItem.bottom
                    topMargin: 25*size1H
                    right: parent.right
                    rightMargin: 25*size1W
                    left: parent.left
                    leftMargin: 25*size1W
                }
                width: parent.width
                height: 190*size1H
                clip: true
                flickableDirection: Flickable.VerticalFlick
                onContentYChanged: {
                    if(contentY<0 || contentHeight < control.height)
                        contentY = 0
                    else if(contentY > (contentHeight - control.height))
                        contentY = (contentHeight - control.height)
                }
                onContentXChanged: {
                    if(contentX<0 || contentWidth < control.width)
                        contentX = 0
                    else if(contentX > (contentWidth-control.width))
                        contentX = (contentWidth-control.width)

                }
                TextArea.flickable: App.TextArea{
                    id:summaryInput
                    horizontalAlignment: ltr?Text.AlignLeft:Text.AlignRight
                    rightPadding: 12*size1W
                    leftPadding: 12*size1W
                    topPadding: 20*size1H
                    bottomPadding: 20*size1H
                    clip: true
                    color: appStyle.textColor
                    wrapMode: Text.WordWrap
                    Material.accent: appStyle.primaryColor
                    font{family: appStyle.appFont;pixelSize:  25*size1F;bold:false}
                    placeholderTextColor: getAppTheme()?"#ADffffff":"#8D000000"
                    background: Rectangle{border.width: 2*size1W; border.color: summaryInput.focus? appStyle.primaryColor : getAppTheme()?"#ADffffff":"#8D000000";color: "transparent";radius: 15*size1W}

                }

                ScrollBar.vertical: ScrollBar {
                    hoverEnabled: true
                    active: hovered || pressed
                    orientation: Qt.Vertical
                    anchors.right: control.right
                    height: parent.height
                    width: hovered || pressed?18*size1W:8*size1W
                }
            }
            Label {
                id: controlPlaceHolder
                text: qsTr("توضیحاتی از چیزی که تو ذهنته رو بنویس")
                color: summaryInput.focus || summaryInput.text!==""?appStyle.textColor: getAppTheme()?"#B3ffffff":"#B3000000"
                anchors.top: control.top
                anchors.topMargin: summaryInput.focus || summaryInput.text!==""?-10*size1H:15*size1H
                anchors.right:  control.right
                anchors.rightMargin: 20*size1W
                font{family: appStyle.appFont;pixelSize:( summaryInput.focus || summaryInput.text!=""?20*size1F:25*size1F);bold:summaryInput.focus || summaryInput.text}
                Behavior on anchors.topMargin { NumberAnimation{ duration: 160 } }
                Rectangle{
                    width: parent.width + 30*size1W
                    anchors.right: parent.right
                    anchors.rightMargin: -15*size1W
                    height: parent.height
                    z:-1
                    color: getAppTheme()?"#2f2f2f":"#fafafa"
                    visible: summaryInput.focus || summaryInput.text!==""
                    radius: 15*size1W
                }
            }
            Rectangle{
                id: fileRect
                anchors{
                    top: control.bottom
                    topMargin: 25*size1W
                    horizontalCenter: parent.horizontalCenter
                }
                radius: 15*size1W
                width: control.width
                height: 450*size1W
                border.width: 1*size1W
                border.color: getAppTheme()?"#ADffffff":"#8D000000"
                color: "transparent"
                clip: true
                GridView{
                    id:grid
                    anchors.fill: parent
                    anchors.margins: 10*size1W
                    cellWidth: width / (parseInt(width / parseInt(200*size1W))===0?1:(parseInt(width / parseInt(200*size1W))))
                    cellHeight:  cellWidth + 20*size1H
                    clip: true
                    ScrollBar.vertical: ScrollBar {
                        hoverEnabled: true
                        active: hovered || pressed
                        orientation: Qt.Vertical
                        anchors.right: grid.right
                        height: parent.height
                        width: 15*size1W
                    }
                    onContentYChanged: {
                        if(contentY<0 || contentHeight < grid.height)
                            contentY = 0
                        else if(contentY > (contentHeight-grid.height))
                            contentY = contentHeight-grid.height
                    }
                    onContentXChanged: {
                        if(contentX<0 || contentWidth < grid.width)
                            contentX = 0
                        else if(contentX > (contentWidth-grid.width))
                            contentX = (contentWidth-grid.width)
                    }
                    delegate: Item{
                        width: grid.cellWidth
                        height: grid.cellHeight
                        MouseArea{
                            anchors.fill: parent
                            cursorShape: Qt.WhatsThisCursor
                            onClicked: {
                                mtooltip.show(model.fileName+"."+model.fileExtension,1000)

                            }
                            onDoubleClicked: {
                                Qt.openUrlExternally(model.fileSource)
                            }
                        }
                        Image{
                            id:img
                            source: (model.fileExtension === "jpg" || model.fileExtension === "png" || model.fileExtension === "svg")?model.fileSource:"qrc:/TaskFlow/files.svg"
                            width: source === "qrc:/TaskFlow/files.svg"?40*size1W:parent.width - 20*size1W
                            height: width
                            sourceSize.width: width*2
                            sourceSize.height: height*2
                            anchors.horizontalCenter: parent.horizontalCenter
                            fillMode: Image.PreserveAspectFit
                            clip: true
                            Item{
                                width: 140*size1W
                                height: 70*size1H
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 28*size1H
                                anchors.left: parent.left
                                anchors.leftMargin: 12*size1W
                                visible: !(model.fileExtension === "jpg" || model.fileExtension === "png")
                                Text {
                                    text: model.fileExtension
                                    color: "white"
                                    font{family: appStyle.appFont;pixelSize: 30*size1F;bold:true}
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            ToolTip{ id: mtooltip }

                        }
                        Text {
                            anchors.bottom: parent.bottom
                            color: appStyle.textColor
                            font{family: appStyle.appFont;pixelSize: 25*size1F;bold:true}
                            text: model.fileName
                            width: parent.width
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                            anchors.bottomMargin: 5*size1W
                        }
                        Rectangle{
                            width: 50*size1W
                            height: width
                            radius: width
                            color: Material.color(Material.Red)
                            anchors.right: parent.right
                            anchors.verticalCenter: img.verticalCenter
                            Image {
                                id: removeIcon
                                source: "qrc:/close.svg"
                                width: 25*size1W
                                height: width
                                anchors.centerIn: parent
                                sourceSize.width: width*2
                                sourceSize.height: height*2
                                visible: false
                            }
                            ColorOverlay{
                                id:removeColor
                                source: removeIcon
                                anchors.fill: removeIcon
                                color: "white"
                            }
                            MouseArea{
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    attachModel.remove(index)
                                }
                            }
                        }
                    }
                    model:ListModel{id:attachModel}
                }

                Loader{
                    id:dargLoader
                    anchors.fill: parent
                    active: !(Qt.platform.os ==="android" || Qt.platform.os ==="ios")
                    asynchronous : true
                    sourceComponent: Item{
                        id:dragItem
                        anchors.fill: parent
                        Image {
                            id: dragImg
                            width: 300*size1W
                            visible: attachModel.count === 0
                            height: width
                            source: dragItem.opacity === 1? "qrc:/TaskFlow/first-shot.svg" :"qrc:/TaskFlow/first-shot-drop.svg"
                            anchors.left: parent.left
                            anchors.bottom: parent.bottom
                            sourceSize.width:width*2
                            sourceSize.height:height*2
                        }
                        Text {
                            id: dragText
                            visible: attachModel.count === 0
                            text: qsTr("فایلتو بکش و اینجا رها کن") +"\n"+ qsTr("یا از دکمه + انتخاب کن")
                            font{family: appStyle.appFont;pixelSize: 25*size1F;bold:true}
                            color: appStyle.textColor
                            anchors.left: dragImg.right
                            anchors.right: parent.right
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        DropArea{
                            anchors.fill: parent
                            onEntered: {
                                dragItem.opacity = 0.1
                            }
                            onExited: {
                                dragItem.opacity = 1
                            }
                            onDropped: {
                                dragItem.opacity = 1
                                var files = drop.text.trim().split("\n");
                                for(var i=0;i<files.length;i++)
                                {
                                    files[i] = files[i].trim()
                                    attachModel.append(
                                                {
                                                    "fileSource": files[i],
                                                    "fileName": decodeURIComponent(files[i].split('/').pop().split('.')[0]),
                                                    "fileExtension": files[i].split('.').pop()
                                                }
                                                )
                                }
                            }
                        }
                    }
                }
                Loader{
                    id:addLoader
                    anchors.fill: parent
                    sourceComponent: Item {
                        clip: true
                        FileDialog{
                            id:fileDialog
                            selectMultiple: true
                            title: qsTr("لطفا فایل‌های خود را انتخاب نمایید")
                            nameFilters: [ "All files (*)" ]
                            folder: shortcuts.pictures
                            sidebarVisible: false
                            onAccepted: {
                                var files = fileDialog.fileUrls;
                                for(var i=0;i<files.length;i++)
                                {
                                    attachModel.append(
                                                {
                                                    "fileSource":files[i],
                                                    "fileName":files[i].split('/').pop().split('.')[0],
                                                    "fileExtension":files[i].split('.').pop()
                                                }
                                                )
                                }
                            }
                        }

                        Text {
                            id: name
                            text: qsTr("فایلتو با استفاده از دکمه + انتخاب کن")
                            visible: !dargLoader.active && attachModel.count === 0
                            anchors.centerIn: parent
                            font{family: appStyle.appFont;pixelSize: 25*size1F;bold:false}
                            color: appStyle.textColor
                            wrapMode: Text.WordWrap
                            width: parent.width-15*size1W
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        App.Button{
                            id: plusRect
                            width: 75*size1W
                            height: width
                            radius: width/2
                            anchors.right: parent.right
                            anchors.rightMargin: -15*size1W
                            anchors.top: parent.top
                            anchors.topMargin: -15*size1W
                            MouseArea{
                                id: mousePlus
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    fileDialog.open()
                                }
                            }
                            Image {
                                id:plusIcon
                                anchors.left: parent.left
                                anchors.leftMargin: width/3
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: width/3
                                width: parent.width/2
                                height: width
                                source: "qrc:/plus.svg"
                                sourceSize.width: width*2
                                sourceSize.height: height*2
                                visible: false
                            }
                            DropShadow {
                                anchors.fill: plusColor
                                horizontalOffset: 3
                                verticalOffset: 3
                                radius: 8.0
                                samples: 17
                                color: "#80000000"
                                source: plusColor
                            }
                            ColorOverlay{
                                id:plusColor
                                source: plusIcon
                                anchors.fill: plusIcon
                                color: "white"
                            }
                        }
                    }
                }
            }
            App.Button{
                id:submitBtn
                width: enabled?370*size1W:350*size1W
                height: 70*size1H
                anchors{
                    top: fileRect.bottom
                    topMargin: 10*size1W
                    right: parent.right
                    rightMargin: 25*size1W
                }
                text: qsTr("بفرست به پردازش نشده ها")
                radius: 15*size1W
                leftPadding: 35*size1W
                enabled: !processBtn.checked
                icon.source: "qrc:/check.svg"
                icon.width: 20*size1W
            }
            App.Button{
                id: processBtn
                width: 210*size1W
                height: 70*size1H
                checkable: true
                Material.accent: "transparent"
                Material.primary: "transparent"

                Material.background: checked ? appStyle.primaryInt :"transparent"
                Material.foreground: checked ? "white" : appStyle.primaryInt
                anchors{
                    top: fileRect.bottom
                    topMargin: 10*size1W
                    left: parent.left
                    leftMargin: 25*size1W
                }
                text: qsTr("پردازش")
                radius: 10*size1W
                leftPadding: ltr?0:35*size1W
                rightPadding:ltr?35*size1W:0
                Image {
                    id: processIcon
                    width: 20*size1W
                    height: width
                    source: "qrc:/arrow.svg"
                    anchors{
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: 30*size1W
                    }
                    sourceSize.width:width*2
                    sourceSize.height:height*2
                    visible: false
                }
                ColorOverlay{
                    rotation: processBtn.checked ?nRow===3?270
                                                          :180
                    :nRow===3?90:0
                    anchors.fill: processIcon
                    source: processIcon
                    color: processBtn.checked ? "white" : appStyle.primaryColor
                }
            }
            Loader{
                id: processLoader
                width: parent.width
                height: active?1500*size1W:0
                active: nRow <= 2 && processBtn.checked
                anchors{
                    top: processBtn.bottom
                    topMargin: 20*size1W
                    left: parent.left
                    right: parent.right
                    leftMargin: 10*size1W
                    rightMargin: 10*size1W
                }
                sourceComponent: secondRect
            }
        }
    }
    Loader{
        active: nRow === 3 && processBtn.checked
        width: parent.width /2
        height: active?mainFlick.height:0
        asynchronous: true
        anchors{
            top: parent.top
            topMargin: 20*size1W
            left: parent.left
            leftMargin: 10*size1W
        }
        sourceComponent: Flickable{
            id: secondFlick
            flickableDirection: Flickable.VerticalFlick
            onContentYChanged: {
                if(contentY<0 || contentHeight < secondFlick.height)
                    contentY = 0
                else if(contentY > (contentHeight-secondFlick.height))
                    contentY = contentHeight-secondFlick.height
            }
            onContentXChanged: {
                if(contentX<0 || contentWidth < secondFlick.width)
                    contentX = 0
                else if(contentX > (contentWidth-secondFlick.width))
                    contentX = (contentWidth-secondFlick.width)
            }
            ScrollBar.vertical: ScrollBar {
                hoverEnabled: true
                active: hovered || pressed
                orientation: Qt.Vertical
                anchors.right: secondFlick.right
                height: parent.height
                width: hovered || pressed?18*size1W:8*size1W
            }
            contentHeight: processLoader2.height
            Loader{
                id: processLoader2
                width: parent.width
                height: 1700*size1H
                active: true
                asynchronous: true
                sourceComponent: secondRect
            }
        }
    }
    Managment.API{id: managmentApi}
    CategoryApi{ id: categoryApi}
    ProjectApi{ id: projectApi}

    Component{
        id:secondRect
        Item{
            Flow{
                anchors{
                    top: parent.top
                    topMargin: 20*size1H
                    right: parent.right
                    rightMargin: 15*size1W
                    bottom: parent.bottom
                    bottomMargin: 20*size1H
                    left: parent.left
                    leftMargin: 15*size1W
                }

                Item{
                    width: parent.width
                    height: 100*size1H
                    Text {
                        id: contextText
                        text: qsTr("محل انجام") +":"
                        width: 250*size1W
                        anchors{
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        color: appStyle.textColor
                        font { family: appStyle.appFont; pixelSize: size1F*30;bold:true}
                    }
                    App.ComboBox{
                        id: contextInput
                        anchors{
                            right: contextText.left
                            rightMargin: 15*size1W
                            left: parent.left
                            bottom: contextText.bottom
                            bottomMargin: -5*size1W
                        }
                        font.pixelSize: size1F*28
                        textRole: "context_name"
                        placeholderText: qsTr("محل انجام مورد نیاز را انتخاب کنید")
                        currentIndex: -1
                        model: contextModel
                        Component.onCompleted: {
                            managmentApi.getContexts(contextModel)
                        }
                    }
                }
                Item{
                    width: parent.width
                    height: 100*size1H
                    Text {
                        id: priorityText
                        text: qsTr("اولویت‌ها") +":"
                        width: 250*size1W
                        anchors{
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        color: appStyle.textColor
                        font { family: appStyle.appFont; pixelSize: size1F*30;bold:true}
                    }
                    App.ComboBox{
                        id:priorityInput
                        anchors{
                            right: priorityText.left
                            rightMargin: 15*size1W
                            left: parent.left
                            bottom: priorityText.bottom
                            bottomMargin: -5*size1W
                        }
                        textRole: "Text"
                        iconRole: "iconSource"
                        font.pixelSize: size1F*28
                        placeholderText: qsTr("اولویت خود را انتخاب کنید")
                        currentIndex: -1
                        model: ListModel{
                            ListElement{
                                Id:0
                                Text:qsTr("کم")
                                iconSource: "qrc:/priorities/low.svg"
                            }
                            ListElement{
                                Id:1
                                Text:qsTr("متوسط")
                                iconSource: "qrc:/priorities/medium.svg"
                            }
                            ListElement{
                                Id:2
                                Text:qsTr("زیاد")
                                iconSource: "qrc:/priorities/high.svg"
                            }
                            ListElement{
                                Id:3
                                Text:qsTr("فوری")
                                iconSource: "qrc:/priorities/higher.svg"
                            }
                        }
                    }
                }
                Item{
                    width: parent.width
                    height: 100*size1H
                    Text {
                        id: energyText
                        text: qsTr("سطح انرژی") +":"
                        width: 250*size1W
                        anchors{
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        color: appStyle.textColor
                        font { family: appStyle.appFont; pixelSize: size1F*30;bold:true}
                    }
                    App.ComboBox{
                        id: energyInput
                        anchors{
                            right: energyText.left
                            rightMargin: 15*size1W
                            left: parent.left
                            bottom: energyText.bottom
                            bottomMargin: -5*size1W
                        }
                        textRole: "Text"
                        iconRole: "iconSource"
                        font.pixelSize: size1F*28
                        placeholderText: qsTr("سطح انرژی مورد نیاز را انتخاب کنید")
                        currentIndex: -1
                        model: ListModel{
                            ListElement{
                                Id:0
                                Text:qsTr("کم")
                                iconSource: "qrc:/energies/low.svg"
                            }
                            ListElement{
                                Id:1
                                Text:qsTr("متوسط")
                                iconSource: "qrc:/energies/medium.svg"
                            }
                            ListElement{
                                Id:2
                                Text:qsTr("زیاد")
                                iconSource: "qrc:/energies/high.svg"
                            }
                            ListElement{
                                Id:3
                                Text:qsTr("خیلی زیاد")
                                iconSource: "qrc:/energies/higher.svg"
                            }
                        }
                    }
                }
                Item{
                    width: parent.width
                    height: 100*size1H
                    Text {
                        id: estimateText
                        text: qsTr("تخمین زمان انجام") +":"
                        anchors{
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        width: 250*size1W
                        color: appStyle.textColor
                        font { family: appStyle.appFont; pixelSize: size1F*30;bold:true}
                    }
                    TextField{
                        id:textField
                        font{family: appStyle.appFont;pixelSize: 28*size1F}
                        selectByMouse: true
                        renderType:Text.NativeRendering
                        placeholderTextColor: appStyle.textColor
                        verticalAlignment: Text.AlignBottom
                        Material.accent: appStyle.primaryColor
                        placeholderText: qsTr("تخمین مدت زمان (به دقیقه)")
                        horizontalAlignment: Text.AlignHCenter
                        anchors{
                            right: estimateText.left
                            rightMargin: 15*size1W
                            left: parent.left
                            bottom: estimateText.bottom
                            bottomMargin: -5*size1W
                        }
                    }
                }
                Item{
                    width: parent.width
                    height: 100*size1H
                    /*********** انجام نشدنی‌ها*****************/
                    Text {
                        id: actionText
                        text: "⏺ "+qsTr("این چیز انجام شدنی نیست") +":"
                        anchors{
                            right: parent.right
                            top: parent.top
                            rightMargin: 20*size1W
                        }
                        width: 250*size1W
                        color: appStyle.textColor
                        font { family: appStyle.appFont; pixelSize: size1F*30;bold:true}
                    }

                    App.RadioButton{
                        id: somedayRadio
                        anchors{
                            top: actionText.bottom
                            left: parent.left // Because LayoutMirroring.enabled === true
                            leftMargin: 20*size1W
                            right: parent.right
                        }
                        text: qsTr("شاید یک روزی این را انجام دادم")
                    }
                    Loader{
                        id: somedayLoader
                        width: parent.width
                        height: somedayRadio.checked?240*size1W:0
                        active: height!==0
                        anchors{
                            top: somedayRadio.bottom
                        }
                        Behavior on height {
                            NumberAnimation{
                                duration: 200
                            }
                        }
                        clip:true
                        sourceComponent: Rectangle {
                            id: somedayItem
                            anchors{
                                fill: parent
                            }
                            radius: 10*size1W
                            color: "transparent"
                            border.width: 3*size1W
                            border.color: Material.hintTextColor
                            Text {
                                id: somedayCategoryText
                                text: qsTr("دسته بندی") + ":"
                                visible: somedayModel.count!==0
                                anchors{
                                    right: parent.right
                                    rightMargin: 20*size1W
                                    top: parent.top
                                    topMargin: 50*size1W
                                }
                                font { family: appStyle.appFont; pixelSize: size1F*30;bold:true}
                                color: appStyle.textColor
                            }
                            App.ComboBox{
                                id: somedayCategoryCombo
                                textRole: "category_name"
                                font.pixelSize: size1F*28
                                placeholderText: qsTr("دسته بندی موردنظر را انتخاب کنید")
                                currentIndex: -1
                                visible: somedayModel.count!==0
                                anchors{
                                    top: parent.top
                                    topMargin: 10*size1W
                                    right: somedayCategoryText.left
                                    rightMargin: 20*size1W
                                    left: parent.left
                                    leftMargin: 20*size1W
                                }
                                model: somedayModel
                                Component.onCompleted: {
                                    categoryApi.getCategories(somedayModel,9) // 9 = شاید یک روزی
                                }
                            }

                            App.Button{
                                id: somedayBtn
                                width: 410*size1W
                                height: 70*size1H
                                checkable: true
                                Material.accent: "transparent"
                                Material.primary: "transparent"
                                Material.background: appStyle.primaryInt
                                Material.foreground: "white"
                                anchors{
                                    top: somedayCategoryCombo.visible?somedayCategoryCombo.bottom:parent.top
                                    topMargin: 25*size1W
                                    horizontalCenter: parent.horizontalCenter
                                }
                                text: qsTr("بفرست به شاید یک روزی")
                                radius: 10*size1W
                                leftPadding: 35*size1W
                            }
                        }
                    }


                    App.RadioButton{
                        id: refrenceRadio
                        anchors{
                            top: somedayLoader.height!==0?somedayLoader.bottom:somedayRadio.bottom
                            left: parent.left // Because LayoutMirroring.enabled === true
                            leftMargin: 20*size1W
                            right: parent.right
                        }
                        text: qsTr("اطلاعات مفیدی است میخواهم بعدا به آن مراجعه کنم")
                    }
                    Loader{
                        id: refrenceLoader
                        width: parent.width
                        height: refrenceRadio.checked?240*size1W:0
                        active: height!==0
                        anchors{
                            top: refrenceRadio.bottom
                        }
                        Behavior on height {
                            NumberAnimation{
                                duration: 200
                            }
                        }
                        clip:true
                        sourceComponent: Rectangle {
                            id: refrenceItem
                            width: parent.width
                            anchors{
                                fill: parent
                            }
                            radius: 10*size1W
                            color: "transparent"
                            border.width: 3*size1W
                            border.color: Material.hintTextColor
                            Text {
                                id: refrenceCategoryText
                                text: qsTr("دسته بندی") + ":"
                                visible: refrenceModel.count!==0
                                anchors{
                                    right: parent.right
                                    rightMargin: 20*size1W
                                    top: parent.top
                                    topMargin: 50*size1W
                                }
                                font { family: appStyle.appFont; pixelSize: size1F*30;bold:true}
                                color: appStyle.textColor
                            }
                            App.ComboBox{
                                id: refrenceCategoryCombo
                                textRole: "category_name"
                                font.pixelSize: size1F*28
                                placeholderText: qsTr("دسته بندی موردنظر را انتخاب کنید")
                                currentIndex: -1
                                visible: refrenceModel.count!==0
                                anchors{
                                    top: parent.top
                                    topMargin: 10*size1W
                                    right: refrenceCategoryText.left
                                    rightMargin: 50*size1W
                                    left: parent.left
                                    leftMargin: 20*size1W
                                }
                                model: refrenceModel
                                Component.onCompleted: {
                                    categoryApi.getCategories(refrenceModel,4) // 4= مرجع
                                }
                            }

                            App.Button{
                                id: refrenceBtn
                                width: 410*size1W
                                height: 70*size1H
                                checkable: true
                                Material.accent: "transparent"
                                Material.primary: "transparent"
                                Material.background: appStyle.primaryInt
                                Material.foreground: "white"
                                anchors{
                                    top: refrenceCategoryCombo.visible?refrenceCategoryCombo.bottom:parent.top
                                    topMargin: 25*size1W
                                    horizontalCenter: parent.horizontalCenter
                                }
                                text: qsTr("بفرست به مرجع")
                                radius: 10*size1W
                                leftPadding: 35*size1W
                            }
                        }
                    }

                    App.RadioButton{
                        id: trashRadio
                        anchors{
                            top: refrenceLoader.height!==0?refrenceLoader.bottom:refrenceRadio.bottom
                            left: parent.left // Because LayoutMirroring.enabled === true
                            leftMargin: 20*size1W
                            right: parent.right
                        }
                        text: qsTr("اطلاعات به درد نخوری است میخواهم به سطل آشغال بیاندازم")
                    }
                    Loader{
                        id: trashLoader
                        width: parent.width
                        height: trashRadio.checked?120*size1W:0
                        active: height!==0
                        anchors{
                            top: trashRadio.bottom
                        }
                        Behavior on height {
                            NumberAnimation{
                                duration: 200
                            }
                        }
                        clip:true
                        sourceComponent: Rectangle {
                            id: trashItem
                            anchors{
                                fill: parent
                            }
                            radius: 10*size1W
                            color: "transparent"
                            border.width: 3*size1W
                            border.color: Material.hintTextColor
                            App.Button{
                                id: trashBtn
                                width: 410*size1W
                                height: 70*size1H
                                checkable: true
                                Material.accent: "transparent"
                                Material.primary: "transparent"
                                Material.background: appStyle.primaryInt
                                Material.foreground: "white"
                                anchors{
                                    centerIn: parent
                                }
                                text: qsTr("بفرست به سطل آشغال")
                                radius: 10*size1W
                                leftPadding: 35*size1W
                            }
                        }
                    }
                    /*********** انجام نشدنی‌ها*****************/

                    /*********** انجام شدنی‌ها*****************/
                    /*********************************/
                    Text {
                        id: action2Text
                        text: "⏺ "+qsTr("این چیز انجام شدنی است") +":"
                        anchors{
                            right: parent.right
                            top: trashLoader.height!==0?trashLoader.bottom:trashRadio.bottom
                            rightMargin: 20*size1W
                        }
                        width: 250*size1W
                        color: appStyle.textColor
                        font { family: appStyle.appFont; pixelSize: size1F*30;bold:true}
                    }

                    /*********************************/

                    Text {
                        id: action3Text
                        text: "⏺ "+qsTr("این چیز با یک انجام یک عمل به پایان نمی‌رسد") +":"
                        anchors{
                            right: parent.right
                            top: action2Text.bottom
                            rightMargin: 50*size1W
                        }
                        width: 250*size1W
                        color: appStyle.textColor
                        height: 50*size1H
                        verticalAlignment: Text.AlignBottom
                        font { family: appStyle.appFont; pixelSize: size1F*24;bold:true}
                    }
                    App.RadioButton{
                        id: projectRadio
                        anchors{
                            top: action3Text.bottom
                            left: parent.left // Because LayoutMirroring.enabled === true
                            leftMargin: 60*size1W
                            right: parent.right
                        }
                        text: qsTr("می‌خواهم یک پروژه جدید بسازم")
                    }
                    Loader{
                        id: projectLoader
                        active: height!==0
                        width: parent.width
                        height: projectRadio.checked?120*size1W:0
                        anchors{
                            top: projectRadio.bottom
                        }
                        Behavior on height {
                            NumberAnimation{
                                duration: 200
                            }
                        }
                        clip:true
                        sourceComponent: Rectangle {
                            id: projectItem
                            anchors{
                                fill: projectLoader
                            }
                            radius: 10*size1W
                            color: "transparent"
                            border.width: 3*size1W
                            border.color: Material.hintTextColor

                            App.Button{
                                id: projectBtn
                                width: 410*size1W
                                height: 70*size1H
                                checkable: true
                                Material.accent: "transparent"
                                Material.primary: "transparent"
                                Material.background: appStyle.primaryInt
                                Material.foreground: "white"
                                anchors{
                                    centerIn: parent
                                }
                                text: qsTr("بفرست به پروژه ها")
                                radius: 10*size1W
                                leftPadding: 35*size1W
                            }
                        }
                    }
                    App.RadioButton{
                        id: projectCategoryRadio
                        anchors{
                            top: projectLoader.height!==0?projectLoader.bottom:projectRadio.bottom
                            left: parent.left // Because LayoutMirroring.enabled === true
                            leftMargin: 60*size1W
                            right: parent.right
                        }
                        text: qsTr("می‌خواهم این عمل را به پروژه های قدیمی اضافه کنم")
                    }
                    Loader{
                        id: projectCategoryLoader
                        active: height!==0
                        width: parent.width
                        height: projectCategoryRadio.checked?240*size1W:0
                        anchors{
                            top: projectCategoryRadio.bottom
                        }
                        Behavior on height {
                            NumberAnimation{
                                duration: 200
                            }
                        }
                        clip:true
                        sourceComponent: Rectangle {
                            id: projectCategoryItem
                            anchors{
                                fill: projectCategoryLoader
                            }
                            radius: 10*size1W
                            color: "transparent"
                            border.width: 3*size1W
                            border.color: Material.hintTextColor
                            Text {
                                id: projectCategoryText
                                text: qsTr("انتخاب پروژه") + ":"
                                anchors{
                                    right: parent.right
                                    rightMargin: 20*size1W
                                    top: parent.top
                                    topMargin: 50*size1W
                                }
                                font { family: appStyle.appFont; pixelSize: size1F*30;bold:true}
                                color: appStyle.textColor
                            }
                            App.ComboBox{
                                id: projectCategoryCombo
                                textRole: "project_name"
                                font.pixelSize: size1F*28
                                placeholderText: qsTr("پروژه موردنظر را انتخاب کنید")
                                currentIndex: -1
                                anchors{
                                    top: parent.top
                                    topMargin: 10*size1W
                                    right: projectCategoryText.left
                                    rightMargin: 50*size1W
                                    left: parent.left
                                    leftMargin: 20*size1W
                                }
                                model: projectModel
                                Component.onCompleted: {
                                    projectApi.getProjects(projectModel)
                                }
                            }
                            App.Button{
                                id: projectCategoryBtn
                                width: 410*size1W
                                height: 70*size1H
                                checkable: true
                                Material.accent: "transparent"
                                Material.primary: "transparent"
                                Material.background: appStyle.primaryInt
                                Material.foreground: "white"
                                anchors{
                                    top: projectCategoryCombo.visible?projectCategoryCombo.bottom:parent.top
                                    topMargin: 25*size1W
                                    horizontalCenter: parent.horizontalCenter
                                }
                                text: qsTr("بفرست به پروژه")
                                radius: 10*size1W
                                leftPadding: 35*size1W
                            }
                        }
                    }

                    /*********************************/

                    Text {
                        id: action4Text
                        text: "⏺ "+qsTr("این عمل بیشتر از ۵ دقیقه زمان نیاز دارد") +":"
                        anchors{
                            right: parent.right
                            top: projectCategoryLoader.height!==0?projectCategoryLoader.bottom:projectCategoryRadio.bottom
                            rightMargin: 50*size1W
                        }
                        width: 250*size1W
                        color: appStyle.textColor
                        height: 50*size1H
                        verticalAlignment: Text.AlignBottom
                        font { family: appStyle.appFont; pixelSize: size1F*24;bold:true}
                    }
                    App.RadioButton{
                        id: friendRadio
                        anchors{
                            top: action4Text.bottom
                            left: parent.left // Because LayoutMirroring.enabled === true
                            leftMargin: 60*size1W
                            right: parent.right
                        }
                        text: qsTr("می‌خواهم این را شخص دیگری انجام دهد")
                    }
                    Loader{
                        id: friendLoader
                        active: height!==0
                        width: parent.width
                        height: friendRadio.checked?240*size1W:0
                        anchors{
                            top: friendRadio.bottom
                        }
                        Behavior on height {
                            NumberAnimation{
                                duration: 200
                            }
                        }
                        clip: true
                        sourceComponent: Rectangle {
                            id: friendItem
                            anchors{
                                fill: parent
                            }
                            radius: 10*size1W
                            color: "transparent"
                            border.width: 3*size1W
                            border.color: Material.hintTextColor
                            Text {
                                id: friendCategoryText
                                text: qsTr("انتخاب دوست") + ":"
                                visible: friendModel.count!==0
                                anchors{
                                    right: parent.right
                                    rightMargin: 20*size1W
                                    top: parent.top
                                    topMargin: 50*size1W
                                }
                                font { family: appStyle.appFont; pixelSize: size1F*30;bold:true}
                                color: appStyle.textColor
                            }
                            App.ComboBox{
                                id: friendCombo
                                textRole: "friend_name"
                                font.pixelSize: size1F*28
                                placeholderText: qsTr("دوست موردنظر را انتخاب کنید")
                                currentIndex: -1
                                visible: friendModel.count!==0
                                anchors{
                                    top: parent.top
                                    topMargin: 10*size1W
                                    right: friendCategoryText.left
                                    rightMargin: 50*size1W
                                    left: parent.left
                                    leftMargin: 20*size1W
                                }
                                model: friendModel
                                Component.onCompleted: {
                                    managmentApi.getFriends(friendModel)
                                }
                            }

                            App.Button{
                                id: friendBtn
                                width: 410*size1W
                                height: 70*size1H
                                checkable: true
                                Material.accent: "transparent"
                                Material.primary: "transparent"
                                Material.background: appStyle.primaryInt
                                Material.foreground: "white"
                                anchors{
                                    top: friendCombo.visible?friendCombo.bottom:parent.top
                                    topMargin: 25*size1W
                                    horizontalCenter: parent.horizontalCenter
                                }
                                text: qsTr("بفرست به لیست انتظار")
                                radius: 10*size1W
                                leftPadding: 35*size1W
                            }
                        }
                    }
                    App.RadioButton{
                        id: calendarRadio
                        anchors{
                            top: friendLoader.height!==0?friendLoader.bottom:friendRadio.bottom
                            left: parent.left // Because LayoutMirroring.enabled === true
                            leftMargin: 60*size1W
                            right: parent.right
                        }
                        text: qsTr("می‌خواهم این عمل را در زمان مشخصی انجام دهم")
                    }
                    Loader{
                        id: calendarLoader
                        active: height!==0
                        width: parent.width
                        height: calendarRadio.checked?220*size1W:0
                        anchors{
                            top: calendarRadio.bottom
                        }
                        Behavior on height {
                            NumberAnimation{
                                duration: 200
                            }
                        }
                        clip: true
                        sourceComponent: Rectangle {
                            id: calendarItem
                            anchors{
                                fill: parent
                            }
                            radius: 10*size1W
                            color: "transparent"
                            border.width: 3*size1W
                            border.color: Material.hintTextColor
                            Behavior on height {
                                NumberAnimation{
                                    duration: 200
                                }
                            }
                            clip:true
                            App.CheckBox{
                                id:clockCheck
                                anchors{
                                    left: parent.left
                                    leftMargin: 20*size1W
                                    top: parent.top
                                    topMargin: 20*size1W
                                }
                                text: qsTr("تعیین ساعت")
                            }
                            App.DateInput{
                                id: dateInput
                                placeholderText: qsTr("زمان مورد نظر را انتخاب نمایید")
                                hasTime: clockCheck.checked
                                minSelectedDate: new Date()
                                anchors{
                                    top: parent.top
                                    right: clockCheck.left
                                    rightMargin: 30*size1W
                                    left: parent.left
                                    leftMargin: 20*size1W
                                }
                            }

                            App.Button{
                                id: calendarBtn
                                width: 410*size1W
                                height: 70*size1H
                                checkable: true
                                Material.accent: "transparent"
                                Material.primary: "transparent"
                                Material.background: appStyle.primaryInt
                                Material.foreground: "white"
                                anchors{
                                    top: dateInput.bottom
                                    topMargin: 20*size1W
                                    horizontalCenter: parent.horizontalCenter
                                }
                                text: qsTr("بفرست به تقویم")

                                radius: 10*size1W
                                leftPadding: 35*size1W
                            }
                        }
                    }

                    App.RadioButton{
                        id: nextRadio
                        anchors{
                            top: calendarLoader.height!==0?calendarLoader.bottom:calendarRadio.bottom
                            left: parent.left // Because LayoutMirroring.enabled === true
                            leftMargin: 60*size1W
                            right: parent.right
                        }
                        text: qsTr("می‌خواهم این عمل را در بعدا انجام دهم")
                    }

                    Loader{
                        id: nextLoader
                        active: height!==0
                        width: parent.width
                        height: nextRadio.checked?120*size1W:0
                        anchors{
                            top: nextRadio.bottom
                        }
                        Behavior on height {
                            NumberAnimation{
                                duration: 200
                            }
                        }
                        clip: true
                        sourceComponent:Rectangle {
                            id: nextItem
                            anchors{
                                fill: parent
                            }
                            radius: 10*size1W
                            color: "transparent"
                            border.width: 3*size1W
                            border.color: Material.hintTextColor
                            App.Button{
                                id: nextBtn
                                width: 410*size1W
                                height: 70*size1H
                                checkable: true
                                Material.accent: "transparent"
                                Material.primary: "transparent"
                                Material.background: appStyle.primaryInt
                                Material.foreground: "white"
                                anchors{
                                    centerIn: parent
                                }
                                text: qsTr("بفرست به عملیات بعدی")
                                radius: 10*size1W
                                leftPadding: 35*size1W
                            }
                        }
                    }

                    /*********************************/
                    Text {
                        id: action5Text
                        text: "⏺ "+qsTr("این عمل کمتر از ۵ دقیقه انجام می‌شود") +":"
                        anchors{
                            right: parent.right
                            top: nextLoader.height!==0?nextLoader.bottom:nextRadio.bottom
                            rightMargin: 50*size1W
                        }
                        width: 250*size1W
                        color: appStyle.textColor
                        height: 50*size1H
                        verticalAlignment: Text.AlignBottom
                        font { family: appStyle.appFont; pixelSize: size1F*24;bold:true}
                    }

                    App.RadioButton{
                        id: doRadio
                        width: parent.width
                        anchors{
                            top: action5Text.bottom
                            left: parent.left // Because LayoutMirroring.enabled === true
                            leftMargin: 60*size1W
                            right: parent.right
                        }
                        text: qsTr("می‌خواهم این عمل را در الان انجام دهم")
                    }
                    Loader{
                        id: doLoader
                        active: height!==0
                        width: parent.width
                        height: doRadio.checked?120*size1W:0
                        anchors{
                            top: doRadio.bottom
                        }
                        Behavior on height {
                            NumberAnimation{
                                duration: 200
                            }
                        }
                        clip: true
                        sourceComponent:Rectangle {
                            id: doItem
                            anchors{
                                fill: parent
                            }
                            radius: 10*size1W
                            color: "transparent"
                            border.width: 3*size1W
                            border.color: Material.hintTextColor
                            App.Button{
                                id: doBtn
                                width: 410*size1W
                                height: 70*size1H
                                checkable: true
                                Material.accent: "transparent"
                                Material.primary: "transparent"
                                Material.background: appStyle.primaryInt
                                Material.foreground: "white"
                                anchors{
                                    centerIn: parent
                                }
                                text: qsTr("بفرست به انجام شده ها")
                                radius: 10*size1W
                                leftPadding: 35*size1W
                            }
                        }
                    }
                    /*********************************/

                    /*********** انجام شدنی‌ها*****************/
                }
            }
        }
    }
}












