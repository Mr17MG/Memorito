import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtGraphicalEffects 1.14
import "qrc:/Components/" as App
import QtQuick.Dialogs 1.2

Item {

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
            width: 8*size1W
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
        anchors{
            top: control.bottom
            topMargin: 25*size1W
            bottom: submitBtn.top
            bottomMargin: 15*size1H
            horizontalCenter: parent.horizontalCenter
        }
        radius: 15*size1W
        width: control.width
        border.width: 1*size1W
        border.color: getAppTheme()?"#ADffffff":"#8D000000"
        color: "transparent"
        clip: true
        GridView{
            id:grid
            anchors.fill: parent
            anchors.margins: 10*size1W
            cellWidth: 200*size1W
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
                        if(Qt.platform.os === "android" || Qt.platform.os === "ios")
                            Qt.openUrlExternally(model.fileSource)
                    }
                    onDoubleClicked: {
                        if( !(Qt.platform.os === "android" || Qt.platform.os === "ios"))
                            Qt.openUrlExternally(model.fileSource)
                    }
                }
                Image{
                    id:img
                    source: (model.fileExtension === "jpg" || model.fileExtension === "png")?model.fileSource:"qrc:/TaskFlow/files.svg"
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
                    width: 25*size1W
                    height: width
                    radius: width
                    color: Material.color(Material.Red)
                    anchors.right: parent.right
                    anchors.verticalCenter: img.verticalCenter
                    Image {
                        id: removeIcon
                        source: "qrc:/close.svg"
                        width: 15*size1W
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
                                            "fileSource":files[i]
                                            ,"fileName": decodeURIComponent(files[i].split('/').pop().split('.')[0])
                                            ,"fileExtension":files[i].split('.').pop()
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
                    title: qsTr("Please choose your files")
                    nameFilters: [ "All files (*)" ]
                    folder: shortcuts.pictures
                    sidebarVisible: false
                    onAccepted: {
                        var files = fileDialog.fileUrls;
                        for(var i=0;i<files.length;i++)
                        {
                            attachModel.append(
                                        {
                                            "fileSource":files[i]
                                            ,"fileName":files[i].split('/').pop().split('.')[0]
                                            ,"fileExtension":files[i].split('.').pop()
                                        }
                                        )
                        }
                    }
                    onRejected: {
                        console.log("Canceled")
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
                Rectangle{
                    width: 75*size1W
                    height: width
                    radius: width/2
                    anchors.right: parent.right
                    anchors.rightMargin: -15*size1W
                    anchors.top: parent.top
                    anchors.topMargin: -15*size1W
                    color: appStyle.primaryColor
                    MouseArea{
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
        width: 370*size1W
        height: 70*size1H
        anchors{
            bottom: parent.bottom
            bottomMargin: 10*size1W
            right: parent.right
            rightMargin: 25*size1W
        }
        text: qsTr("بفرست به پردازش نشده ها")
        radius: 15*size1W
        leftPadding: 35*size1W
        Image {
            id:submitIcon
            width: 20*size1W
            height: width
            source: "qrc:/check.svg"
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
            anchors.fill: submitIcon
            source: submitIcon
            color: "white"
        }
    }
    App.Button{
        id: advanceBtn
        width: 250*size1W
        height: 70*size1H
        flat: true
        anchors{
            bottom: parent.bottom
            bottomMargin: 10*size1W
            left: parent.left
            leftMargin: 25*size1W
        }
        text: qsTr("حالت پیشرفته")
        radius: 10*size1W
        leftPadding: 35*size1W
        Image {
            id: advanceIcon
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
            anchors.fill: advanceIcon
            source: advanceIcon
            color: appStyle.textColor
        }
    }
}
