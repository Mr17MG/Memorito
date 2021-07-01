import QtQuick 2.15
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtGraphicalEffects 1.15
import Components 1.0
import Global 1.0
import MTools 1.0                         // Require For myTools

Rectangle{
    id: backRect
    MTools{id:myTools}
    radius: 15*AppStyle.size1W
    width: 450*AppStyle.size1W
    height: 450*AppStyle.size1W
    border.width: 2*AppStyle.size1W
    border.color: AppStyle.borderColor
    color: "transparent"
    clip: true
    property ListModel model
    Loader{
        id:gridLoader
        anchors{
            fill: parent
            margins: 10*AppStyle.size1W
        }
        active: backRect.model.count>0
        sourceComponent: GridView{
            id:grid
            anchors{
                fill: parent
                topMargin: 10*AppStyle.size1H
                bottomMargin: 10*AppStyle.size1H
            }
            cellWidth: width / (parseInt(width / parseInt(500*AppStyle.size1W))===0?1:(parseInt(width / parseInt(500*AppStyle.size1W))))
            cellHeight:  200*AppStyle.size1H
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
                    rightMargin: -10*AppStyle.size1W
                }
                height: parent.height
                width: 15*AppStyle.size1W
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
                        margins: 5*AppStyle.size1W
                    }
                    color: Material.color(AppStyle.primaryInt,Material.Shade50)
                    radius: 15*AppStyle.size1W
                    Rectangle{
                        id:topRect
                        width: parent.width
                        height: 90*AppStyle.size1H
                        radius: 15*AppStyle.size1W
                        Rectangle{
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 15*AppStyle.size1W
                            color: parent.color
                        }
                        color: Material.color(AppStyle.primaryInt,Material.ShadeA700)
                        property var extensions: ["aac","ace","ai","aut","avi","bin","bmp","cad","cdr","css","db","dmg","doc","docx","dwf","dwg","eps",
                            "exe","flac","gif","hlp","htm","html","ini","iso","java","jpg","js","mkv","mov","mp3","mp4","mpg","pdf","php","png","ppt",
                            "ps","psd","rar","rss","rtf","svg","swf","sys","tiff","txt","xls","xlsx","zip",
                        ]
                        Image {
                            id: unprocessImg
                            source: parent.extensions.indexOf(model.file_extension.toLowerCase())!== -1?"qrc:/pack/"+(model.file_extension.toLowerCase())+".svg":"qrc:/pack/unknown.svg"
                            width: 70*AppStyle.size1W
                            height: width
                            sourceSize:Qt.size(width*2,height*2)
                            anchors{
                                verticalCenter: parent.verticalCenter
                                right: parent.right
                                rightMargin: 15*AppStyle.size1W
                            }
                        }
                        Image {
                            id: sourceImg
                            /*source:  initial in visible: */
                            visible: (source =
                                      !model.local_id?
                                          (model.file_extension.toLowerCase().match(/svg|png|jpg|gif|jpeg/g)?model.file_source
                                                                                                            :"")
                                        :"file://"+myTools.getSaveDirectory()+"/"+model.file_name + "."+ model.file_extension)
                                     !==""

                            width: 70*AppStyle.size1W
                            height: width
                            sourceSize: Qt.size(width*2,height*2)
                            anchors{
                                verticalCenter: parent.verticalCenter
                                left: parent.left
                                leftMargin: 15*AppStyle.size1W
                            }
                            fillMode:Image.PreserveAspectFit
                        }
                        Text{
                            id: thingText
                            text: model.file_name + "."+ model.file_extension
                            font{family: AppStyle.appFont;pixelSize:  25*AppStyle.size1F;bold:true}
                            color: AppStyle.textOnPrimaryColor
                            anchors{
                                top:  parent.top
                                bottom: parent.bottom
                                right: unprocessImg.left
                                rightMargin: 20*AppStyle.size1W
                                left: sourceImg.visible?sourceImg.right:parent.left
                                leftMargin: 20*AppStyle.size1W
                            }
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            maximumLineCount: 2
                            elide: AppStyle.ltr?Text.ElideLeft:Text.ElideRight
                        }
                    }
                    Flow{
                        anchors{
                            bottom: parent.bottom
                            bottomMargin: 20*AppStyle.size1W
                            horizontalCenter: parent.horizontalCenter
                        }
                        spacing:  20*AppStyle.size1W
                        AppButton{
                            id:deleteBtn
                            width: (parent.parent.width/2) - 20*AppStyle.size1W
                            text: fullRect.opacity === 0.8?qsTr("بازگرداندن"):qsTr("حذف")
                            Material.background: Material.Red
                            onClicked: {
                                if(model.file)
                                {
                                    if(deleteBtn.text === qsTr("بازگرداندن"))
                                    {
                                        attachModel.set(index,{"change_type":0})
                                        fullRect.opacity = 1
                                    }
                                    else {
                                        attachModel.set(index,{"change_type":3})
                                        fullRect.opacity = 0.8
                                    }
                                }
                                else backRect.model.remove(index)
                            }

                        }
                        AppButton{
                            id:openBtn
                            width: (parent.parent.width/2)- 20*AppStyle.size1W
                            text: qsTr("باز کردن")
                            visible: !downloadBtn.visible
                            Material.background: Material.LightBlue
                            onClicked: {
                                Qt.openUrlExternally(model.file_source)
                            }
                        }
                        AppButton{
                            id:downloadBtn
                            width: (parent.parent.width/2)- 20*AppStyle.size1W
                            text: qsTr("دانلود")
                            visible: model.file_source === "" && !myTools.checkFileExist(model.file_name,model.file_extension)
                            Material.background: Material.LightGreen
                            onClicked: {
                                if(UsefulFunc.getAndroidAccessToFile())
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
                width: 300*AppStyle.size1W
                visible: backRect.model.count === 0
                height: width
                source: dragItem.opacity === 1? "qrc:/first-shot.svg" :"qrc:/first-shot-drop.svg"
                anchors{
                    right: parent.right
                    bottom: parent.bottom
                }
                mirror: !AppStyle.ltr
                sourceSize.width:width*2
                sourceSize.height:height*2
            }
            DropArea{
                anchors.fill: parent
                onEntered: {
                    dragItem.opacity = 0.7
                    addLoader.item.addText.opacity = 07
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
                        let file = myTools.getFileInfo(decodeURIComponent((files[i].trim())))
                        if(UsefulFunc.findInModel("file://"+file.file_source,"file_source",backRect.model).index !== null)
                        {
                            UsefulFunc.showLog(qsTr("فایل")+"' "+file.file_name+" '"+qsTr("قبلا به لیست اضافه شده"),true)
                            continue
                        }

                        if(file.file_size > 10485760) // Bigger than 10 Megabyte
                        {
                            UsefulFunc.showLog(qsTr("حجم فایل")+"' "+file.file_name+" '"+qsTr(" بیشتر از ۱۰ مگابایته"),true)
                            continue
                        }


                        backRect.model.append(
                                    {
                                        "file_source":"file://"+file.file_source,
                                        "file_name":file.file_name,
                                        "file_extension":file.file_extension,
                                        "change_type":1
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
                sourceComponent: AppFilePicker{
                    id:fileDialog
                    selectMultiple: true
                    width:UsefulFunc.rootWindow.width
                    height: UsefulFunc.rootWindow.height
                    parent: UsefulFunc.mainLoader
                    x:0
                    y:0
                    title: qsTr("فایل‌هاتو انتخاب کن")
                    nameFilters:  ["*.*"]
                    onAccepted: {
                        let files = fileDialog.fileUrls;
                        for(let i=0;i<files.length;i++)
                        {
                            let file = myTools.getFileInfo(decodeURIComponent((files[i].trim())))
                            if(UsefulFunc.findInModel("file://"+file.file_source,"file_source",backRect.model).index !== null)
                            {
                                UsefulFunc.showLog(qsTr("فایل")+"' "+file.file_name+" '"+qsTr("قبلا به لیست اضافه شده"),true)
                                continue
                            }
                            if(file.file_size > 10485760) // Bigger than 10 Megabyte
                            {
                                UsefulFunc.showLog(qsTr("حجم فایل")+"' "+file.file_name+" '"+qsTr("بیشتر از ۱۰ مگابایته"),true)
                                continue
                            }


                            backRect.model.append(
                                        {
                                            "file_source":"file://"+file.file_source,
                                            "file_name":file.file_name,
                                            "file_extension":file.file_extension,
                                            "change_type":1
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
                    rightMargin: !dargLoader.active?0:300*AppStyle.size1W
                }

                height: parent.height
                font{family: AppStyle.appFont;pixelSize: 25*AppStyle.size1F;bold:true}
                color: AppStyle.textColor
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            AppButton{
                id: plusRect
                width: 75*AppStyle.size1W
                height: width
                radius: width/2
                anchors{
                    left: parent.left
                    leftMargin: -15*AppStyle.size1W
                    top: parent.top
                    topMargin: -15*AppStyle.size1W
                }
                onClicked: {
                    if(UsefulFunc.getAndroidAccessToFile())
                    {
                        fileLoader.active = true
                        fileLoader.item.open()
                    }
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
                    color: AppStyle.textOnPrimaryColor
                }
            }
        }
    }
}
