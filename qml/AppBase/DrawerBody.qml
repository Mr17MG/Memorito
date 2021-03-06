import QtQuick  // Require For Listview
import QtQuick.Controls  // Require For ScrollBar
import QtQuick.Controls.Material 
import Qt5Compat.GraphicalEffects // Require For ColorOverlay

import Memorito.Tools
import Memorito.Global
import Memorito.Components  // Require For AppButton

Item{

    property bool isDrawer: false

    MTools{id:myTools}

    anchors {
        fill: parent
        left: parent.left
        leftMargin: isDrawer ? 0
                             : 10*AppStyle.size1W
        right: parent.right
        rightMargin: isDrawer ? 0
                              : 10*AppStyle.size1W
    }

    Connections{
        target: UsefulFunc
        function onGetAndroidAccessToFileResponsed(res) {
            if(res)
                User.set(UserApi.getUserByUserId(User.id))
        }
    }

    Text {
        id: userNameText

        text: {
            try{
                return "@"+(User.username??"")
            }
            catch(e){
                console.trace()
            }
        }

        elide: Qt.ElideRight
        color: AppStyle.textColor
        horizontalAlignment: Text.AlignHCenter

        font {
            family: AppStyle.appFont;
            pixelSize: 25*AppStyle.size1F;
        }

        anchors {
            verticalCenter: isDrawer?profileRect.verticalCenter:undefined
            top: isDrawer?undefined:profileRect.bottom
            topMargin: 10*AppStyle.size1H
            right: isDrawer?profileRect.left:parent.right
            rightMargin: 5*AppStyle.size1W
            left: parent.left
            leftMargin: 0*AppStyle.size1W
        }
    }

    Rectangle{
        id: profileRect

        width: height
        height: parent.width >= 300*AppStyle.size1H? 250*AppStyle.size1H
                                                   : parent.width-10*AppStyle.size1H
        radius: width
        color: Material.color(AppStyle.primaryInt,Material.Shade50)

        border {
            color: AppStyle.primaryColor
            width: 3*AppStyle.size1W
        }

        anchors{
            top: parent.top
            topMargin: 20*AppStyle.size1H
            rightMargin: 10*AppStyle.size1W
            right:isDrawer ? parent.right
                           : undefined
            horizontalCenter: isDrawer ? undefined
                                       : parent.horizontalCenter
        }

        Binding{
            target: profileImage
            property: "source"
            value: User.profile
            when: User.isSet
            restoreMode: Binding.RestoreBindingOrValue
        }

        Image {
            id: profileImage

            cache: false
            asynchronous: true
            sourceSize: Qt.size(width*4,height*4)

            anchors {
                fill: parent
                margins: profileRect.border.width
            }

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    x: profileRect.x
                    y: profileRect.y
                    width: profileRect.width
                    height: profileRect.height
                    radius: profileRect.radius
                }
            }
        }

        MouseArea{
            id: profileMouse

            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                if(nRow === 1)
                    drawerLoader.item.close()

                UsefulFunc.mainStackPush("qrc:/Account/Profile.qml",qsTr("??????????????"))

            }
        }

    }

    ScrollBar {
        id:listScroll

        hoverEnabled: true
        visible: nRow !== 1
        height: listView.height
        orientation: Qt.Vertical
        active: hovered || pressed
        width: hovered || pressed ? 18*AppStyle.size1W
                                  : 8*AppStyle.size1W

        anchors {
            top: listView.top
            right: parent.right
            rightMargin: isDrawer ? 0
                                  : -10*AppStyle.size1W
        }


        contentItem: Rectangle {
            visible: parent.active
            radius: parent.pressed || parent.hovered ? 20*AppStyle.size1W
                                                     : 8*AppStyle.size1W
            color: parent.pressed ? Material.color(AppStyle.primaryInt,Material.Shade900)
                                  : Material.color(AppStyle.primaryInt,Material.Shade600)
        }
    }

    AppListView{
        id:listView

        clip: true
        ScrollBar.vertical: listScroll

        anchors{
            top: isDrawer?profileRect.bottom:userNameText.bottom
            topMargin : 10*AppStyle.size1H
            bottom: parent.bottom
        }

        width:parent.width

        delegate: AppButton{
            id: listDelegate

            property bool state1: splitView.staticDrawerWidth <= (staticDrawer.SplitView.maximumWidth*2/3) && isDrawer === false

            flat:true
            width: listView.width
            height: listDelegate.state1 ? 120*AppStyle.size1H : 100*AppStyle.size1H

            onClicked: {
                if(nRow === 1)
                    drawerLoader.item.close()

                if(pageSource)
                    UsefulFunc.mainStackPush(model.pageSource,model.title,{listId:model.listId,pageTitle:model.title})
            }

            Image {
                id: icon

                visible: false
                height: width
                source: model.iconSrc
                width: 50*AppStyle.size1W
                sourceSize:Qt.size(width*2,height*2)

                anchors{
                    top: parent.top
                    topMargin: listDelegate.state1 ? 20*AppStyle.size1H
                                                   : (parent.height-height)/2
                    right: parent.right
                    rightMargin: listDelegate.state1 ? (parent.width-width)/2 // Center in parent
                                                     : 20*AppStyle.size1W
                }
            }

            ColorOverlay{
                id:iconColor

                source:icon
                anchors.fill: icon
                color: ( UsefulFunc.stackPages.get(UsefulFunc.stackPages.count-1)?.title ?? "") === model.title ? AppStyle.primaryColor
                                                                                                                : AppStyle.textColor
            }

            Text {
                id: titleText

                text: model?.title ?? "";
                color: iconColor.color
                elide: Text.ElideRight
                horizontalAlignment: listDelegate.state1 ?Text.AlignHCenter:Text.AlignRight

                font{
                    family: AppStyle.appFont
                    pixelSize: listDelegate.state1  ? 20*AppStyle.size1F : 25*AppStyle.size1F
                }

                anchors {
                    top: listDelegate.state1 ? icon.bottom : parent.top
                    topMargin: listDelegate.state1 ? 8*AppStyle.size1H : 32*AppStyle.size1H
                    right: listDelegate.state1 ? parent.right : icon.left
                    rightMargin: listDelegate.state1 ? 0 : 20*AppStyle.size1W
                    left: parent.left
                    leftMargin: nRow === 2 ? 10*AppStyle.size1W : 0
                }
            }
        } // end of delegate

        model: ListModel{
            id:modelList

            ListElement{
                title: qsTr("?????????????????")
                pageSource :"qrc:/Things/AddEditThing.qml"
                iconSrc: "qrc:/collect.svg"
                listId: Memorito.Collect
            }
            ListElement{
                title:qsTr("???????????? ???????????????")
                iconSrc: "qrc:/process.svg"
                pageSource: "qrc:/Things/ThingsList.qml"
                listId: Memorito.Process
            }
            ListElement{
                title:qsTr("???????????? ????????")
                iconSrc: "qrc:/nextAction.svg"
                pageSource: "qrc:/Things/ThingsList.qml"
                listId: Memorito.NextAction
            }
            ListElement{
                title:qsTr("???????? ????????????")
                iconSrc: "qrc:/waiting.svg"
                pageSource: "qrc:/Things/ThingsList.qml"
                listId: Memorito.Coop
            }
            ListElement{
                title:qsTr("??????????")
                iconSrc: "qrc:/calendar.svg"
                pageSource: "qrc:/Things/ThingsList.qml"
                listId: Memorito.Calendar
            }
            ListElement{
                title:qsTr("????????")
                iconSrc: "qrc:/refrence.svg"
                pageSource: "qrc:/Things/ThingsList.qml"
                listId: Memorito.Refrence
            }
            ListElement{
                title:qsTr("???????? ???????????????")
                iconSrc: "qrc:/someday.svg"
                pageSource: "qrc:/Things/ThingsList.qml"
                listId: Memorito.Someday
            }
            ListElement{
                title:qsTr("?????????????????")
                iconSrc: "qrc:/project.svg"
                pageSource: "qrc:/Things/ThingsList.qml"
                listId: Memorito.Project
            }
            ListElement{
                title:qsTr("?????????? ?????????????")
                iconSrc: "qrc:/done.svg"
                pageSource: "qrc:/Things/ThingsList.qml"
                listId: Memorito.Done
            }
            ListElement{
                title:qsTr("?????? ??????????")
                iconSrc: "qrc:/trash.svg"
                pageSource: "qrc:/Things/ThingsList.qml"
                listId: Memorito.Trash
            }
            ListElement{
                title:qsTr("??????????????? ??????????")
                pageSource:"qrc:/Contexts/Contexts.qml"
                iconSrc: "qrc:/contexts.svg"
                listId: Memorito.Contexts
            }
            ListElement{
                title:qsTr("????????????")
                iconSrc: "qrc:/friends.svg"
                pageSource: "qrc:/Friends/Friends.qml"
                listId: Memorito.Friends
            }
            ListElement{
                title: qsTr("??????????????")
                pageSource : "qrc:/AppBase/AppSettings.qml"
                iconSrc: "qrc:/setting.svg"
            }
        }
    }
}
