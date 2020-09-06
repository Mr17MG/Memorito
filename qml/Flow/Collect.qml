import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.1
import "qrc:/Components/" as C
import "qrc:/Pages/MainPages/"
import QtQuick.Dialogs 1.2
Item {
    Text {
        id: taskText
        text: qsTr("Collect your task here")
        anchors.horizontalCenter: parent.horizontalCenter
        font{family: styles.vazir;pixelSize: 14*size1F;bold:true}
        color: textColor
        anchors.top: parent.top
        anchors.topMargin: 5*size1H
    }
    C.TextField{
        id:titleInput
        anchors.top: taskText.bottom
        anchors.topMargin: 10*size1H
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60*size1H
        anchors{left: parent.left;leftMargin: 10*size1W;right: parent.right;rightMargin: 10*size1W}
        Material.primary: primaryColor
        placeholderText: qsTr("Title")
    }
    Flickable{
        id: control
        anchors.top: titleInput.bottom
        anchors.topMargin: 5*size1H
        anchors.right: parent.right
        anchors.left: parent.left
        height:200*size1H
        anchors.rightMargin: 10*size1W
        anchors.leftMargin: 10*size1W
        clip: true
        flickableDirection: Flickable.VerticalFlick
        TextArea.flickable: TextArea{
            id:summaryInput
            placeholderText: qsTr("Write Your Summary Here")
            horizontalAlignment: Text.AlignLeft
            rightPadding: 12*size1W
            leftPadding: 12*size1W
            clip:true
            color: textColor
            wrapMode: Text.WordWrap
            Material.accent: primaryColor
            font{family: styles.vazir;pixelSize: 14*size1F;bold:false}
            placeholderTextColor: isLightTheme?"#8D000000":"#ADffffff"
            background: Rectangle{color: isLightTheme?"#0D000000":"#0Dffffff";radius: 10*size1W}
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
    Rectangle{
        anchors.top: control.bottom
        anchors.topMargin: 5*size1W
        anchors.bottom: submitBtn.top
        anchors.bottomMargin: 15*size1H
        radius: 10*size1W
        width: control.width
        border.width: 1*size1W
        border.color:isLightTheme?"#8D000000":"#ADffffff"
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"
        clip: true
        GridView{
            id:grid
            anchors.fill: parent
            anchors.margins: 10*size1W
            cellWidth: width/3
            cellHeight:  cellWidth + 20*size1H
            clip: true
            ScrollBar.vertical: ScrollBar {
                hoverEnabled: true
                active: hovered || pressed
                orientation: Qt.Vertical
                anchors.right: grid.right
                height: parent.height
                width: 8*size1W
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
                    source: (model.fileExtension === "jpg" || model.fileExtension === "png")?model.fileSource:"qrc:/Icons/TaskFlow/files.svg"
                    width: source === "qrc:/Icons/TaskFlow/files.svg"?40*size1W:parent.width - 20*size1W
                    height: width
                    sourceSize.width: width*2
                    sourceSize.height: height*2
                    anchors.horizontalCenter: parent.horizontalCenter
                    fillMode: Image.PreserveAspectFit
                    clip: true
                    Text {
                        visible: !(model.fileExtension === "jpg" || model.fileExtension === "png")
                        text: model.fileExtension
                        color: "WHITE"
                        font{family: styles.vazir;pixelSize: 14*size1F;bold:true}
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 15*size1H
                        anchors.left: parent.left
                        anchors.leftMargin: 20*size1W
                    }
                }
                Text {
                    anchors.bottom: parent.bottom
                    color: textColor
                    font{family: styles.vazir;pixelSize: 14*size1F;bold:true}
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
                        source: "qrc:/Icons/close.svg"
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
                    width: 175*size1W
                    visible: attachModel.count === 0
                    height: width
                    source: "qrc:/Icons/TaskFlow/first-shot.svg"
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    sourceSize.width:width*2
                    sourceSize.height:height*2
                }
                Text {
                    id: dragText
                    visible: attachModel.count === 0
                    text: qsTr("Drop file here") +"\n"+ qsTr(" or click on plus button")
                    font{family: styles.vazir;pixelSize: 14*size1F;bold:true}
                    color: textColor
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
                    text: qsTr("for add files click on plus button")
                    visible: (Qt.platform.os ==="android" || Qt.platform.os ==="ios") && attachModel.count === 0
                    anchors.centerIn: parent
                    font{family: styles.vazir;pixelSize: 14*size1F;bold:false}
                    color: textColor
                    wrapMode: Text.WordWrap
                    width: parent.width-15*size1W
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                Rectangle{
                    width: 50*size1W
                    height: width
                    radius: width/2
                    anchors.right: parent.right
                    anchors.rightMargin: -15*size1W
                    anchors.top: parent.top
                    anchors.topMargin: -15*size1W
                    color: Material.color(primaryColor)
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
                        anchors.leftMargin: 7*size1W
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 7*size1H
                        width: 25*size1W
                        height: 25*size1W
                        source: "qrc:/Icons/plusIcon.svg"
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
    C.Button{
        id:submitBtn
        width: 150*size1W
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10*size1W
        anchors.horizontalCenter: parent.horizontalCenter
        Material.background: primaryColor
        font{family: styles.vazir;pixelSize: 14*size1F;bold:false;capitalization: Font.MixedCase}
        Material.foreground: "white"
        text: qsTr("Submit")
        Material.theme: Material.Light
        bottomRadius: 15*size1W
        height: 40*size1H
        leftPadding: 35*size1W
        padding: 0
        Image {
            id:submitIcon
            width: 20*size1W
            height: width
            source: "qrc:/Icons/TaskFlow/checked.svg"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 40*size1W
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
}
