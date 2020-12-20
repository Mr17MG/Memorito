import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtQuick.Controls.Material.impl 2.14

import "qrc:/Components/" as App
import QtGraphicalEffects 1.1

Item {
    ThingsApi{id: thingApi}
    Component.onCompleted: {
        thingApi.getThings(thingModel,2)
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
            id:rootItem
            radius: 15*size1W
            width: control.cellWidth - 10*size1W
            height:  control.cellHeight - 10*size1H
            color: Material.color(appStyle.primaryInt,Material.Shade50)
            clip: true
            MouseArea{
                id: mouseArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {

                }
            }
            Ripple {
                clipRadius: 15*size1W
                z:1
                width: mouseArea.width
                height: mouseArea.height
                pressed: mouseArea.pressed
                anchor: mouseArea
                active: mouseArea.focus
                color: getAppTheme()?"#22171717":"#22EAEAEA"
                OpacityMask {
                    source: mouseArea
                    maskSource: Rectangle {
                        x: mouseArea.mouseX
                        y: mouseArea.mouseY
                        width: mouseArea.width
                        height: mouseArea.height
                        radius: 10*size1W
                    }
                }
            }
            Rectangle{
                id:topRect
                width: parent.width
                height: 70*size1H
                radius: 15*size1W
                Rectangle{
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 15*size1W
                    color: parent.color
                }
                color: Material.color(appStyle.primaryInt,Material.ShadeA400)
                Text{
                    id: thingText
                    text: title
                    font{family: appStyle.appFont;pixelSize:  25*size1F;bold:true}
                    anchors{
                        top:  parent.top
                        bottom: parent.bottom
                        right: parent.right
                        rightMargin: 20*size1W
                        left: parent.left
                        leftMargin: 20*size1W
                    }
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                }
            }
            Text{
                text: qsTr("توضیحات") + ": " + detail
                font{family: appStyle.appFont;pixelSize:  23*size1F;bold:false}
                anchors{
                    top:  topRect.bottom
                    topMargin: 20*size1W
                    right: parent.right
                    rightMargin: 20*size1W
                    left: parent.left
                }
                wrapMode: Text.WordWrap
                maximumLineCount: 3
                elide: ltr?Text.ElideLeft:Text.ElideRight
            }
        }

        /***********************************************/
        model: thingModel
    }

    App.Button{
        text: qsTr("افزودن چیز")
        anchors{
            left: parent.left
            leftMargin: 20*size1W
            bottom: parent.bottom
            bottomMargin: 20*size1W
        }
        radius: 20*size1W
        leftPadding: 35*size1W
        rightPadding: 35*size1W
        onClicked: {
            dialogLoader.active = true
            dialogLoader.item.isAdd = true
            dialogLoader.item.open()
        }
        icon.width: 30*size1W
        icon.source:"qrc:/plus.svg"
        icon.color: "white"
    }
    Loader{
        id: dialogLoader
        active:false
        sourceComponent: App.Dialog{
            id: addDialog
            property bool isAdd: true
            property alias thingTitle: thingTitle
            property alias thingDetailArea: thingDetailArea
            property int thingId : -1
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
                if(thingTitle.text.trim() !== "")
                {
                    if(isAdd){
                        thingApi.addThing(thingTitle.text.trim(),thingDetailArea.text.trim(),thingModel)
                    } else {
                        thingApi.editThing(thingId,thingTitle.text.trim(),thingDetailArea.text.trim(),thingModel,modelIndex)
                    }
                    addDialog.close()
                }
                else {
                    usefulFunc.showLog(qsTr("لطفاعنوان چیز را وارد نمایید"),true,null,400*size1W, ltr)
                }
            }
            App.TextInput{
                id: thingTitle
                placeholderText: qsTr("نام چیز")
                anchors{
                    right: parent.right
                    rightMargin: 40*size1W
                    left: parent.left
                    leftMargin: 40*size1W
                    top: parent.top
                    topMargin: 30*size1W
                }
                EnterKey.type: Qt.EnterKeyGo
                Keys.onReturnPressed: thingDetailArea.focus = true
                Keys.onEnterPressed: thingDetailArea.focus = true
                height: 100*size1H
                filedInDialog: true
                maximumLength: 50
            }

            Flickable{
                id: thingFlick
                anchors{
                    top: thingTitle.bottom
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
                    if(contentY<0 || contentHeight < thingFlick.height)
                        contentY = 0
                    else if(contentY > (contentHeight - thingFlick.height))
                        contentY = (contentHeight - thingFlick.height)
                }
                onContentXChanged: {
                    if(contentX<0 || contentWidth < thingFlick.width)
                        contentX = 0
                    else if(contentX > (contentWidth-thingFlick.width))
                        contentX = (contentWidth-thingFlick.width)
                }

                TextArea.flickable: App.TextArea{
                    id:thingDetailArea
                    placeholderText: qsTr("توضیحاتی از چیزی که تو ذهنته رو بنویس") + " (" + qsTr("اختیاری") + ")"
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
                    background: Rectangle{border.width: 2*size1W; border.color: thingDetailArea.focus? appStyle.primaryColor : getAppTheme()?"#ADffffff":"#8D000000";color: "transparent";radius: 15*size1W}
                    placeholder.anchors.rightMargin: 20*size1W
                }

                ScrollBar.vertical: ScrollBar {
                    hoverEnabled: true
                    active: hovered || pressed
                    orientation: Qt.Vertical
                    anchors.right: thingFlick.right
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
            property string thingTitle: ""
            property int thingId: -1
            property int modelIndex: -1
            dialogTitle: qsTr("حذف")
            dialogText: qsTr("آیا مایلید که") + " '" + thingTitle + "' " + qsTr("را حذف کنید؟")
            accepted: function() {
                thingApi.deleteThing(thingId,thingModel,modelIndex)
            }
        }
    }
}
