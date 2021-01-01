import QtQuick 2.14 // Require For Listview
import QtGraphicalEffects 1.14 // Require For ColorOverlay
import "qrc:/Components/" as App // Require For App.Button
import QtQuick.Controls.Material 2.14
import QtQuick.Controls 2.14 // Require For ScrollBar
import MEnum 1.0

Item{
    anchors.fill: parent
    anchors.leftMargin: firstColumn.active && resizerLoader.active?resizerLoader.width:0
    clip: true

    Text {
        id: userNameText
        text: "@"+currentUser.username
        color: appStyle.textColor
        font{family: appStyle.appFont;pixelSize: 25*size1F;bold:false}
        horizontalAlignment: Text.AlignHCenter
        elide: Qt.ElideRight

        anchors{
            verticalCenter: drawerLoader.active?profileRect.verticalCenter:undefined
            top: drawerLoader.active?undefined:profileRect.bottom
            topMargin: 10*size1H
            right: drawerLoader.active?profileRect.left:parent.right
            rightMargin: 5*size1W
            left: parent.left
            leftMargin: 0*size1W
        }

    }
    Rectangle{
        id: profileRect
        width: height
        height: parent.width >= 200*size1H?200*size1H:parent.width-10*size1H
        radius: width
        border.color: appStyle.primaryColor
        border.width: 3*size1W
        color: Material.color(appStyle.primaryInt,Material.Shade50)
        anchors{
            top: parent.top
            topMargin: 20*size1H
            right:drawerLoader.active? parent.right:undefined
            horizontalCenter: drawerLoader.active?undefined:parent.horizontalCenter
            rightMargin: 10*size1W
        }

        Image {
            id: profileImage
            source: "qrc:/user.svg"
            anchors.fill: parent
            sourceSize.width: width*2
            sourceSize.height: height*2
            anchors.margins: profileRect.border.width
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
            id:profileMouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if(nRow === 1)
                    drawerLoader.item.close()
                usefulFunc.mainStackPush("qrc:/Profile.qml",qsTr("پروفایل"))

            }
        }

    }

    App.ListView{
        id:listView
        clip: true
        anchors{
            top: drawerLoader.active?profileRect.bottom:userNameText.bottom
            topMargin : 10*size1H
            bottom: parent.bottom
        }
        ScrollBar.vertical: ScrollBar {
            hoverEnabled: true
            visible: nRow !== 1
            active: hovered || pressed
            orientation: Qt.Vertical
            anchors.right: listView.right
            height: parent.height
            width: hovered || pressed?18*size1W:8*size1W
        }

        width:parent.width
        delegate: App.Button{
            id: listDelegate
            property bool state1: firstColumn.width <= (firstColumnMaxWidth*2/3) && drawerLoader.active === false
            width: listView.width
            height: listDelegate.state1 ? 120*size1H : 100*size1H
            flat:true
            onClicked: {
                if(nRow === 1)
                    drawerLoader.item.close()
                if(pageSource)
                {
                    usefulFunc.mainStackPush(model.pageSource,model.title,{listId:model.listId,title:title})
                }
            }
            Image {
                id: icon
                width: 50*size1W
                height: width
                source: iconSrc
                sourceSize.width: width*2
                sourceSize.height: height*2
                visible: false
                anchors{
                    top: parent.top
                    topMargin: listDelegate.state1?20*size1H:(parent.height-height)/2
                    right: parent.right
                    rightMargin: listDelegate.state1
                                 ?(parent.width-width)/2 // Center in parent
                                 :20*size1W
                }
            }
            ColorOverlay{
                id:iconColor
                anchors.fill: icon
                source:icon
                color:stackPages.get(stackPages.count-1).title === title?appStyle.primaryColor
                                                                            :appStyle.textColor

            }
            Text {
                id: titleText
                text: title
                font{
                    family: appStyle.appFont
                    pixelSize: listDelegate.state1  ? 20*size1F : 25*size1F
                }
                color: iconColor.color
                elide: Text.ElideRight
                horizontalAlignment: listDelegate.state1 ?Text.AlignHCenter:Text.AlignRight

                anchors {
                    top: listDelegate.state1 ? icon.bottom : parent.top
                    topMargin: listDelegate.state1 ? 8*size1H : 32*size1H
                    right: listDelegate.state1 ? parent.right : icon.left
                    rightMargin: listDelegate.state1 ? 0 : 20*size1W
                    left: parent.left
                    leftMargin: nRow === 2 ? 10*size1W : 0
                }
            }
        }
        model: ListModel{
            id:modelList
            ListElement{
                title: qsTr("جمع‌آوری")
                pageSource :"qrc:/Flow/Collect.qml"
                iconSrc: "qrc:/collect.svg"
                listId: Memorito.Collect
            }
            ListElement{
                title:qsTr("پردازش نشده‌ها")
                iconSrc: "qrc:/process.svg"
                pageSource: "qrc:/Flow/NextAction.qml"
                listId: Memorito.Process
            }
            ListElement{
                title:qsTr("عملیات بعدی")
                iconSrc: "qrc:/nextAction.svg"
                pageSource: "qrc:/Flow/NextAction.qml"
                listId: Memorito.NextAction
            }
            ListElement{
                title:qsTr("لیست انتظار")
                iconSrc: "qrc:/waiting.svg"
                pageSource: "qrc:/Flow/NextAction.qml"
                listId: Memorito.Waiting
            }
            ListElement{
                title:qsTr("تقویم")
                iconSrc: "qrc:/calendar.svg"
                pageSource: "qrc:/Flow/NextAction.qml"
                listId: Memorito.Calendar
            }
            ListElement{
                title:qsTr("مرجع")
                iconSrc: "qrc:/refrence.svg"
                pageSource: "qrc:/Flow/NextAction.qml"
                listId: Memorito.Refrence
            }
            ListElement{
                title:qsTr("شاید یک‌روزی")
                iconSrc: "qrc:/someday.svg"
                pageSource: "qrc:/Flow/NextAction.qml"
                listId: Memorito.Someday
            }
            ListElement{
                title:qsTr("پروژه‌ها")
                iconSrc: "qrc:/project.svg"
                pageSource: "qrc:/Flow/Projects.qml"
                listId: Memorito.Project
            }
            ListElement{
                title:qsTr("انجام شده‌ها")
                iconSrc: "qrc:/done.svg"
                pageSource: "qrc:/Flow/NextAction.qml"
                listId: Memorito.Done
            }
            ListElement{
                title:qsTr("سطل زباله")
                iconSrc: "qrc:/trash.svg"
                pageSource: "qrc:/Flow/NextAction.qml"
                listId: Memorito.Trash
            }
            ListElement{
                title:qsTr("محل‌های انجام")
                pageSource:"qrc:/Managment/Contexts.qml"
                iconSrc: "qrc:/contexts.svg"
                listId: Memorito.Contexts
            }
            ListElement{
                title:qsTr("دوستان")
                iconSrc: "qrc:/friends.svg"
                pageSource: "qrc:/Managment/Friends.qml"
                listId: Memorito.Friends
            }
            ListElement{
                title: qsTr("تنظیمات")
                pageSource : "qrc:/AppBase/AppSettings.qml"
                iconSrc: "qrc:/setting.svg"
            }
        }
    }
}
