import QtQuick 2.15
//import QtQuick.Controls 1.4 as OldControls
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import Qt.labs.folderlistmodel 2.15
import Qt.labs.platform 1.1
import QtQuick.Window 2.15
//import "utils.js" as Utils
import Global 1.0
import MTools 1.0
AppDialog {
    id:picker

    MTools{id: mTools}
    signal accepted()

    Material.theme: AppStyle.appTheme
    readonly property real buttonHeight: 80*AppStyle.size1H
    readonly property real rowHeight: 100*AppStyle.size1H
    readonly property real toolbarHeight: 100*AppStyle.size1H
    property bool showDotAndDotDot: true
    property bool showHidden: false
    property bool showDirsFirst: true
    property string folder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
    property var nameFilters: "*.*"
    property bool selectMultiple: true
    property var fileUrls:[]
    property ListModel selectedFile: ListModel{
        onCountChanged:{
            fileUrls=[]
            for(let i=0;i<selectedFile.count;i++)
                fileUrls.push(selectedFile.get(i).path)
        }
    }

    function currentFolder() {
        return folderListModel.folder;
    }

    function isFolder(fileName) {
        return folderListModel.isFolder( folderListModel.indexOf( folderListModel.folder + "/" + fileName) );
    }
    function canMoveUp() {
        return folderListModel.folder.toString() !== "file:///";
    }

    function onItemClick(fileName) {
        if(!isFolder(fileName)) {
            selectedFile.append({path:folderListModel.folder+"/"+fileName})
            return;
        }
        if(fileName === ".." && canMoveUp())
        {
            folderListModel.folder = folderListModel.parentFolder
        }
        else if(fileName !== ".")
        {
            if(folderListModel.folder.toString() === "file:///")
            {
                folderListModel.folder += fileName
            }
            else {
                folderListModel.folder += "/" + fileName
            }
        }
    }

    header: Rectangle {
        id: toolbar

        height: toolbarHeight
        color: AppStyle.primaryColor

        AppButton {
            id: button

            text: qsTr("بازگشت")
            flat: true
            enabled: canMoveUp()
            Material.foreground: AppStyle.textOnPrimaryColor

            anchors{
                right: closeButton.left
                leftMargin: 10*AppStyle.size1W
                bottom: parent.bottom
                top: parent.top
            }

            onClicked: {
                if(canMoveUp) {
                    folderListModel.folder = folderListModel.parentFolder
                }
            }
        }
        AppButton {
            id: closeButton

            text: qsTr("بستن")
            flat: true
            Material.foreground: AppStyle.textOnPrimaryColor
            anchors{
                right: openButton.left
                leftMargin: 10*AppStyle.size1W
                bottom: parent.bottom
                top: parent.top
            }

            onClicked: {
                picker.close()
            }
        }
        AppButton {
            id: openButton
            text: qsTr("بازکردن")
            flat: true
            enabled: selectedFile.count > 0
            Material.foreground: AppStyle.textOnPrimaryColor

            anchors{
                right: parent.right
                rightMargin: 20*AppStyle.size1W
                bottom: parent.bottom
                top: parent.top
            }

            onClicked: {
                accepted()
            }
        }
        Flickable{
            id: filesFlick
            anchors{
                top: parent.top
                right: button.left
                left: parent.left
                leftMargin: 20*AppStyle.size1W
                bottom: parent.bottom
            }
            clip: true
            contentWidth: filePath.width
            flickableDirection: Flickable.HorizontalFlick
            onContentYChanged: {
                if(contentY<0 || contentHeight < filesFlick.height)
                    contentY = 0
                else if(contentY > (contentHeight-filesFlick.height))
                    contentY = contentHeight-filesFlick.height
            }
            onContentXChanged: {
                if(contentX<0 || contentWidth < filesFlick.width)
                    contentX = 0
                else if(contentX > (contentWidth-filesFlick.width))
                    contentX = (contentWidth-filesFlick.width)
            }
            ScrollBar.horizontal: ScrollBar {
                id:listScroll
                width: parent.width
                orientation: Qt.Horizontal
                height:  hovered || pressed ? 20*AppStyle.size1W
                                            : 10*AppStyle.size1W
                anchors{
                    right: parent.right
                }
                contentItem: Rectangle {
                    visible: active
                    radius: parent.pressed || parent.hovered ? 20 * AppStyle.size1W
                                                             : 8  * AppStyle.size1W
                    color: parent.pressed ? Material.color( AppStyle.primaryInt , Material.Shade300 )
                                          : Material.color( AppStyle.primaryInt , Material.Shade100 )
                }
            }
            Flow {
                id: filePath
                height: parent.height
                flow:Flow.LeftToRight
                onChildrenChanged: {
                    filesFlick.contentX = filesFlick.contentWidth
                }
                Repeater{
                    model: folderListModel.folder.toString().replace("file:///", "").split('/')
                    delegate: Item{
                        height: parent.height
                        width: pathBtn.width+10*AppStyle.size1W
                        Text{
                            id: t
                            width: 10*AppStyle.size1W
                            text: ">"
                            color: AppStyle.textOnPrimaryColor
                            font: pathBtn.font
                            height: parent.height
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }

                        AppButton{
                            id: pathBtn
                            text: modelData
                            property string path
                            onTextChanged: path= "file:///"+(folderListModel.folder.toString().replace("file:///", "").split('/').slice(0,index+1).join('/'))
                            height: parent.height
                            flat: true
                            Material.foreground: AppStyle.textOnPrimaryColor
                            anchors.left: t.right
                            font{
                                family: AppStyle.appFont
                                pixelSize: 25*AppStyle.size1F
                            }
                            onClicked: {
                                if(folderListModel.folder !== path)
                                    folderListModel.folder = path
                            }
                        }
                    }

                }
            }
        }
    }

    footer: Flickable{

        id: devicesFlick

        height: toolbarHeight
        clip: true
        contentWidth: devicesFlow.width
        flickableDirection: Flickable.HorizontalFlick
        onContentYChanged: {
            if(contentY<0 || contentHeight < devicesFlick.height)
                contentY = 0
            else if(contentY > (contentHeight-devicesFlick.height))
                contentY = contentHeight-devicesFlick.height
        }
        onContentXChanged: {
            if(contentX<0 || contentWidth < devicesFlick.width)
                contentX = 0
            else if(contentX > (contentWidth-devicesFlick.width))
                contentX = (contentWidth-devicesFlick.width)
        }
        ScrollBar.horizontal: ScrollBar {
            width: parent.width
            orientation: Qt.Horizontal
            height:  hovered || pressed ? 20*AppStyle.size1W
                                        : 10*AppStyle.size1W
            anchors{
                right: parent.right
            }
            contentItem: Rectangle {
                visible: active
                radius: parent.pressed || parent.hovered ? 20 * AppStyle.size1W
                                                         : 8  * AppStyle.size1W
                color: parent.pressed ? Material.color( AppStyle.primaryInt , Material.Shade300 )
                                      : Material.color( AppStyle.primaryInt , Material.Shade100 )
            }
        }
        Flow {

            id: devicesFlow

            height: parent.height
            flow: Flow.LeftToRight

            Repeater{

                model:mTools.getMountedDevices()

                delegate: AppButton{

                    id: deviesBtn

                    flat: true
                    text: modelData
                    height: parent.height
                    width: 200*AppStyle.size1W
                    Material.foreground: checked?AppStyle.textOnPrimaryColor
                                                :AppStyle.textColor
                    checked: String(folderListModel.folder).indexOf(text)!==-1
                    font{
                        family: AppStyle.appFont
                        pixelSize: 25*AppStyle.size1F
                    }
                    onClicked: {
                        folderListModel.folder = "file://"+text
                    }
                }
            }

        }

    }

    ListView{

        id: foldersListView
        clip: true
        anchors{
            top: parent.top
            right: parent.right
            bottom: parent.bottom
            left: parent.left
        }
        ScrollBar.vertical: ScrollBar {
            height: parent.height
            orientation: Qt.Vertical
            width:  hovered || pressed ? 20*AppStyle.size1W
                                       : 10*AppStyle.size1W
            anchors{
                right: parent.right
            }
            contentItem: Rectangle {
                visible: active
                radius: parent.pressed || parent.hovered ? 20 * AppStyle.size1W
                                                         : 8  * AppStyle.size1W
                color: parent.pressed ? Material.color( AppStyle.primaryInt , Material.Shade300 )
                                      : Material.color( AppStyle.primaryInt , Material.Shade100 )
            }
        }

        model: FolderListModel {
            id:  folderListModel
            showDotAndDotDot: picker.showDotAndDotDot
            showHidden: picker.showHidden
            showDirsFirst: picker.showDirsFirst
            nameFilters: picker.nameFilters
            folder: picker.folder
            onFolderChanged: {
                selectedFile.clear()
            }
        }
        Popup{
            id:popUp
            property alias popImg: popImg.source
            width: parent.width/2
            height: width
            Image{
                id: popImg
                anchors.fill: parent
                sourceSize: Qt.size(width*4,height*4)
                fillMode: Image.PreserveAspectCrop
            }
        }

        delegate: Component {
            id: fileDelegate
            AppButton {

                id: fileNameText
                checkable: true
                enabled: selectMultiple || (selectedFile.count === 0 && !selectMultiple) || checked
                flat: true
                text: model.fileName
                height: rowHeight
                width: foldersListView.width
                horizontalAlignment: Text.AlignLeft
                Material.background: index % 2 === 1 ? Qt.darker(AppStyle.shadowColor,1.1)
                                                     : "transparent"
                rightPadding: 25*AppStyle.size1W
                leftPadding: 25*AppStyle.size1W
                font{
                    family: AppStyle.appFont
                    pixelSize: 25*AppStyle.size1F
                }

                icon{
                    width: buttonHeight
                    height: buttonHeight
                    color: (isFolder(text) || extensions.indexOf(model.fileSuffix.toLowerCase())=== -1) ? AppStyle.textColor
                                                                                                        : "transparent"
                    source: isFolder(text) ? "qrc:/folder.svg"
                                           :  (extensions.indexOf(model.fileSuffix.toLowerCase())!== -1 ? (model.fileSuffix.toLowerCase().match(/svg|png|jpg|gif|jpeg/g) ? folderListModel.folder+"/"+model.fileName
                                                                                                                                                                             : "qrc:/pack/"+(model.fileSuffix.toLowerCase())+".svg")
                                                                                                        : "qrc:/file.svg")

                }


                onPressAndHold: {

                    if (model.fileSuffix.toLowerCase().match(/svg|png|jpg|gif|jpeg/g))
                    {
                        popUp.popImg = folderListModel.folder+"/"+model.fileName
                        popUp.open()

                    }
                }
                onCheckedChanged: {
                    if(checked){
                        onItemClick(text)
                    }
                    else {
                        selectedFile.remove({path:text})
                    }
                }
            }
        }
    }
    property var extensions: ["aac","ace","ai","aut","avi","bin","bmp","cad","cdr","css","db","dmg","doc","docx","dwf","dwg","eps",
        "exe","flac","gif","hlp","htm","html","ini","iso","java","jpg","js","mkv","mov","mp3","mp4","mpg","pdf","php","png","ppt",
        "ps","psd","rar","rss","rtf","svg","swf","sys","tiff","txt","xls","xlsx","zip",
    ]
}
