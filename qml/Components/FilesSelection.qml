import QtQuick 2.15
import "qrc:/Components/" as App
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtGraphicalEffects 1.14

Rectangle{
    id: backRect
    radius: 15*size1W
    width: 450*size1W
    height: 450*size1W
    border.width: 2*size1W
    border.color: appStyle.borderColor
    color: "transparent"
    clip: true
    property ListModel model
    Loader{
        id:gridLoader
        anchors{
            fill: parent
            margins: 10*size1W
        }
        active: backRect.model.count>0
        sourceComponent: GridView{
            id:grid
            anchors{
                fill: parent
                topMargin: 10*size1H
                bottomMargin: 10*size1H
            }
            cellWidth: width / (parseInt(width / parseInt(500*size1W))===0?1:(parseInt(width / parseInt(500*size1W))))
            cellHeight:  200*size1H
            clip: true
            layoutDirection: GridView.RightToLeft
            displaced: Transition {
                NumberAnimation { properties: "x,y"; duration: 200 }
            }
            ScrollBar.vertical: ScrollBar {
                hoverEnabled: true
                active: hovered || pressed
                orientation: Qt.Vertical
                anchors{
                    right: grid.right
                    rightMargin: -10*size1W
                }
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
                Rectangle{
                    id:fullRect
                    anchors{
                        fill: parent
                        margins: 5*size1W
                    }
                    color: Material.color(appStyle.primaryInt,Material.Shade50)
                    radius: 15*size1W
                    Rectangle{
                        id:topRect
                        width: parent.width
                        height: 90*size1H
                        radius: 15*size1W
                        Rectangle{
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 15*size1W
                            color: parent.color
                        }
                        color: Material.color(appStyle.primaryInt,Material.ShadeA700)
                        property var extensions: ["aac","ace","ai","aut","avi","bin","bmp","cad","cdr","css","db","dmg","doc","docx","dwf","dwg","eps",
                            "exe","flac","gif","hlp","htm","html","ini","iso","java","jpg","js","mkv","mov","mp3","mp4","mpg","pdf","php","png","ppt",
                            "ps","psd","rar","rss","rtf","svg","swf","sys","tiff","txt","xls","xlsx","zip",
                        ]
                        Image {
                            id: unprocessImg
                            source: parent.extensions.indexOf(model.file_extension)!== -1?"qrc:/pack/"+model.file_extension+".svg":"qrc:/pack/unknown.svg"
                            width: 70*size1W
                            height: width
                            sourceSize.width: width*2
                            sourceSize.height: height*2
                            anchors{
                                verticalCenter: parent.verticalCenter
                                right: parent.right
                                rightMargin: 15*size1W
                            }
                        }
                        Image {
                            id: sourceImg
                            /*source:  initial in visible: */
                            visible: (source = model.file_extension.match(/svg|png|jpg|gif|jpeg/g)?model.file_source:"") !==""
                            width: 70*size1W
                            height: width
                            sourceSize.width: width*2
                            sourceSize.height: height*2
                            anchors{
                                verticalCenter: parent.verticalCenter
                                left: parent.left
                                leftMargin: 15*size1W
                            }
                            fillMode:Image.PreserveAspectFit
                        }
                        Text{
                            id: thingText
                            text: model.file_name + "."+ model.file_extension
                            font{family: appStyle.appFont;pixelSize:  25*size1F;bold:true}
                            color: "white"
                            anchors{
                                top:  parent.top
                                bottom: parent.bottom
                                right: unprocessImg.left
                                rightMargin: 20*size1W
                                left: sourceImg.visible?sourceImg.right:parent.left
                                leftMargin: 20*size1W
                            }
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.WordWrap
                        }
                    }
                    Flow{
                        anchors{
                            bottom: parent.bottom
                            bottomMargin: 20*size1W
                            horizontalCenter: parent.horizontalCenter
                        }
                        spacing:  20*size1W
                        App.Button{
                            id:deleteBtn
                            width: (parent.parent.width/2) - 20*size1W
                            text: fullRect.opacity === 0.3?qsTr("بازگرداندن"):qsTr("حذف")
                            Material.background: Material.Red
                            onClicked: {
                                if(model.file)
                                {
                                    if(deleteBtn.text === qsTr("بازگرداندن"))
                                        fullRect.opacity = 1
                                    else fullRect.opacity = 0.3
                                }
                                else
                                backRect.model.remove(index)
                            }

                        }
                        App.Button{
                            id:openBtn
                            width: (parent.parent.width/2)- 20*size1W
                            text: qsTr("باز کردن")
                            visible: !downloadBtn.visible
                            Material.background: Material.BlueGrey
                            onClicked: {
                                Qt.openUrlExternally(model.file_source)
                            }
                        }
                        App.Button{
                            id:downloadBtn
                            width: (parent.parent.width/2)- 20*size1W
                            text: qsTr("دانلود")
                            visible: model.file_source === "" && !myTools.checkFileExist(model.file_name,model.file_extension)
                            Material.background: Material.LightGreen
                            onClicked: {
                                model.file_source = "file://"+myTools.saveBase64asFile(model.file_name,model.file_extension,model.file)
                            }
                        }
                    }
                }
            }
            model: backRect.model
        }
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
                visible: backRect.model.count === 0
                height: width
                source: dragItem.opacity === 1? "qrc:/TaskFlow/first-shot.svg" :"qrc:/TaskFlow/first-shot-drop.svg"
                anchors{
                    right: parent.right
                    bottom: parent.bottom
                }
                mirror: !ltr
                sourceSize.width:width*2
                sourceSize.height:height*2
            }
            DropArea{
                anchors.fill: parent
                onEntered: {
                    dragItem.opacity = 0.3
                    addLoader.item.addText.opacity = 0.3
                }
                onExited: {
                    dragItem.opacity = 1
                    addLoader.item.addText.opacity = 1
                }
                onDropped: {
                    dragItem.opacity = 1
                    let files = drop.text.trim().split("\n");
                    for(let i=0;i<files.length;i++)
                    {
                        files[i] = decodeURIComponent(files[i].trim())
                        if(usefulFunc.findInModel(files[i],"file_source",backRect.model).index !== null)
                            continue
                        backRect.model.append(
                                    {
                                        "file_source": files[i],
                                        "file_name": decodeURIComponent(files[i].split('/').pop().split('.')).replace(files[i].split('.').pop(),"").slice(0, -1),
                                        "file_extension": files[i].split('.').pop()
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
            property alias addText: addText
            Loader{
                id:fileLoader
                active: false
                sourceComponent: FileDialog{
                    id:fileDialog
                    selectMultiple: true
                    title: qsTr("لطفا فایل‌های خود را انتخاب نمایید")
                    nameFilters: [ "All files (*)" ]
                    folder: shortcuts.pictures
                    sidebarVisible: false
                    onAccepted: {
                        let files = fileDialog.fileUrls;
                        for(let i=0;i<files.length;i++)
                        {
                            let file = myTools.getFileInfo(decodeURIComponent((files[i].trim())))
                            if(usefulFunc.findInModel("file://"+file.file_source,"file_source",backRect.model).index !== null)
                            {
                                usefulFunc.showLog(qsTr("فایل")+"' "+file.file_name+" '"+qsTr("قبلا به لیست اضافه شده است"),true,null,900*size1W, ltr)
                                continue
                            }

                            backRect.model.append(
                                        {
                                            "file_source":"file://"+file.file_source,
                                            "file_name":file.file_name,
                                            "file_extension":file.file_extension
                                        }
                                        )
                        }
                        fileLoader.active = false
                    }
                    onRejected: {
                        fileLoader.active = false
                    }
                }
            }
            Text {
                id: addText
                text: !dargLoader.active?qsTr("فایلتو با استفاده از دکمه + انتخاب کن"): qsTr("فایلتو بکش و اینجا رها کن") +"\n"+ qsTr("یا از دکمه + انتخاب کن")
                visible: backRect.model.count === 0?true:false
                anchors{
                    left: parent.left
                    right: parent.right
                    rightMargin: !dargLoader.active?0:300*size1W
                }

                height: parent.height
                font{family: appStyle.appFont;pixelSize: 25*size1F;bold:true}
                color: appStyle.textColor
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            App.Button{
                id: plusRect
                width: 75*size1W
                height: width
                radius: width/2
                anchors{
                    left: parent.left
                    leftMargin: -15*size1W
                    top: parent.top
                    topMargin: -15*size1W
                }
                onClicked: {
                    fileLoader.active = true
                    fileLoader.item.open()
                }
                Image {
                    id:plusIcon
                    anchors{
                        right: parent.right
                        rightMargin: width/3
                        bottom: parent.bottom
                        bottomMargin: width/3
                    }
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