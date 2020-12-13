import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import "qrc:/Components/" as App
import QtGraphicalEffects 1.1

Item {
    ProjectApi{id: projectApi}
    Component.onCompleted: {
        projectApi.getProjects(projectModel)
    }

    GridView{
        id: control
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
        anchors{
            top: parent.top
            topMargin: 15*size1H
            right: parent.right
            rightMargin: 20*size1W
            bottom: parent.bottom
            bottomMargin: 15*size1H
            left: parent.left
            leftMargin: 20*size1W
        }
        width: parent.width
        layoutDirection:Qt.RightToLeft
        cellHeight: 200*size1W
        cellWidth: width / (parseInt(width / parseInt(500*size1W))===0?1:(parseInt(width / parseInt(500*size1W))))

        /***********************************************/
        delegate: Rectangle {
            radius: 15*size1W
            width: control.cellWidth - 10*size1W
            height:  control.cellHeight - 10*size1H
            color: Material.color(appStyle.primaryInt,Material.Shade50)
            Text{
                id: projectText
                text: project_name
                font{family: appStyle.appFont;pixelSize:  25*size1F;bold:true}
                anchors{
                    top:  parent.top
                    topMargin: 30*size1W
                    right: parent.right
                    rightMargin: 20*size1W
                    left: menuImg.right
                }
                wrapMode: Text.WordWrap
            }
            Text{
                text: qsTr("هدف پروژه") + ": " + project_goal
                font{family: appStyle.appFont;pixelSize:  23*size1F;bold:false}
                anchors{
                    top:  projectText.bottom
                    topMargin: 10*size1W
                    right: parent.right
                    rightMargin: 20*size1W
                    left: menuImg.right
                }
                wrapMode: Text.WordWrap
                maximumLineCount: 3
                elide: ltr?Text.ElideLeft:Text.ElideRight
            }
            Image {
                id: menuImg
                source: "qrc:/dots.svg"
                width: 40*size1W
                height: width
                sourceSize.width: width*2
                sourceSize.height: height*2
                anchors{
                    left: parent.left
                    leftMargin: 5*size1W
                    top: parent.top
                    topMargin: 20*size1W
                }
                MouseArea{
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        menuLoader.active = true
                        menuLoader.item.open()
                    }
                }
            }
            Loader{
                id: menuLoader
                active: false
                x: menuImg.x + (menuImg.width - 15*size1W)
                y: menuImg.y + (menuImg.height/2)
                sourceComponent: App.Menu{
                    id:menu
                    App.MenuItem{
                        text: qsTr("ویرایش")
                        onTriggered: {
                            menuLoader.active = false
                            dialogLoader.active = true
                            dialogLoader.item.projectId = id
                            dialogLoader.item.isAdd = false
                            dialogLoader.item.modelIndex = model.index
                            dialogLoader.item.projectName.text = project_name
                            dialogLoader.item.projectGoalArea.text =  project_goal
                            dialogLoader.item.open()
                        }
                    }
                    App.MenuItem{
                        text: qsTr("حذف")
                        onTriggered: {
                            menuLoader.active = false
                            deleteLoader.active = true
                            deleteLoader.item.projectName = project_name
                            deleteLoader.item.projectId = id
                            deleteLoader.item.modelIndex = model.index
                            deleteLoader.item.open()
                        }
                    }
                }
            }
        }

        /***********************************************/
        model: projectModel
    }

    App.Button{
        text: qsTr("افزودن پروژه")
        anchors{
            left: parent.left
            leftMargin: 20*size1W
            bottom: parent.bottom
            bottomMargin: 20*size1W
        }
        radius: 20*size1W
        width: 275*size1W
        leftPadding: 35*size1W
        onClicked: {
            dialogLoader.active = true
            dialogLoader.item.isAdd = true
            dialogLoader.item.open()
        }

        Image {
            id:submitIcon
            width: 30*size1W
            height: width
            source: "qrc:/plus.svg"
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
    Loader{
        id: dialogLoader
        active:false
        sourceComponent: App.Dialog{
            id: addDialog
            property bool isAdd: true
            property alias projectName: projectName
            property alias projectGoalArea: projectGoalArea
            property int projectId : -1
            property int modelIndex: -1
            parent: mainColumn
            width: 600*size1W
            height: 570*size1H
            onClosed: {
                dialogLoader.active = false
            }
            hasButton: true
            hasCloseIcon: true
            hasTitle: true
            buttonTitle: isAdd?qsTr("اضافه کن"):qsTr("تغییرش بده")
            dialogButton.onClicked:{
                if(projectName.text.trim() !== "")
                {
                    if(isAdd){
                        projectApi.addProject(projectName.text.trim(),projectGoalArea.text.trim(),projectModel)
                    } else {
                        projectApi.editProject(projectId,projectName.text.trim(),projectGoalArea.text.trim(),projectModel,modelIndex)
                    }
                    addDialog.close()
                }
                else {
                    usefulFunc.showLog(qsTr("لطفا نام پروژه خود را وارد نمایید"),true,null,400*size1W, ltr)
                }
            }
            App.TextInput{
                id: projectName
                placeholderText: qsTr("نام پروژه")
                anchors{
                    right: parent.right
                    rightMargin: 40*size1W
                    left: parent.left
                    leftMargin: 40*size1W
                    top: parent.top
                    topMargin: 30*size1W
                }
                EnterKey.type: Qt.EnterKeyGo
                Keys.onReturnPressed: projectGoalArea.focus = true
                Keys.onEnterPressed: projectGoalArea.focus = true
                height: 100*size1H
                filedInDialog: true
                maximumLength: 50
            }

            Flickable{
                id: projectFlick
                anchors{
                    top: projectName.bottom
                    topMargin: 30*size1H
                    right: parent.right
                    rightMargin: 40*size1W
                    left: parent.left
                    leftMargin: 40*size1W
                }
                width: parent.width
                height: 230*size1H
                clip: true
                contentHeight: 220*size1H
                contentWidth: parent.width - 40 *size1W
                flickableDirection: Flickable.VerticalFlick
                onContentYChanged: {
                    if(contentY<0 || contentHeight < projectFlick.height)
                        contentY = 0
                    else if(contentY > (contentHeight - projectFlick.height))
                        contentY = (contentHeight - projectFlick.height)
                }
                onContentXChanged: {
                    if(contentX<0 || contentWidth < projectFlick.width)
                        contentX = 0
                    else if(contentX > (contentWidth-projectFlick.width))
                        contentX = (contentWidth-projectFlick.width)
                }

                TextArea.flickable: App.TextArea{
                    id:projectGoalArea
                    placeholderText: qsTr("هدف پروژه") + " ("+qsTr("اختیاری")+")"
                    horizontalAlignment: ltr?Text.AlignLeft:Text.AlignRight
                    rightPadding: 20*size1W
                    leftPadding: 20*size1W
                    topPadding: 20*size1H
                    bottomPadding: 10*size1H
                    clip: true
                    color: appStyle.textColor
                    wrapMode: Text.WordWrap
                    areaInDialog: true
                    Material.accent: appStyle.primaryColor
                    font{family: appStyle.appFont;pixelSize:  25*size1F;bold:false}
                    placeholderTextColor: getAppTheme()?"#ADffffff":"#8D000000"
                    background: Rectangle{border.width: 2*size1W; border.color: projectGoalArea.focus? appStyle.primaryColor : getAppTheme()?"#ADffffff":"#8D000000";color: "transparent";radius: 15*size1W}
                    placeholder.anchors.rightMargin: 20*size1W
                }

                ScrollBar.vertical: ScrollBar {
                    hoverEnabled: true
                    active: hovered || pressed
                    orientation: Qt.Vertical
                    anchors.right: projectFlick.right
                    height: parent.height
                    width: hovered || pressed?18*size1W:8*size1W
                }
            }

        }
    }

    Loader{
        id: deleteLoader
        active: false
        sourceComponent: App.ConfirmDialog{
            parent: mainColumn
            onClosed: {
                deleteLoader.active = false
            }
            property string projectName: ""
            property int projectId: -1
            property int modelIndex: -1
            dialogTitle: qsTr("حذف")
            dialogText: qsTr("آیا مایلید که") + " '" + projectName + "' " + qsTr("را حذف کنید؟")
            accepted: function() {
                projectApi.deleteProject(projectId,projectModel,modelIndex)
            }
        }
    }
}
