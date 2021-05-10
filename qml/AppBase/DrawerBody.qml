import QtQuick 2.15 // Require For Listview
import QtGraphicalEffects 1.15 // Require For ColorOverlay
import QtQuick.Controls.Material 2.15
import QtQuick.Controls 2.15 // Require For ScrollBar
import Components 1.0  // Require For AppButton
import Global 1.0
import MTools 1.0
import QtQml 2.15
Item{
    MTools{id:myTools}
    property bool isDrawer: false
    anchors{
        fill: parent
        left: parent.left
        leftMargin: isDrawer?0:10*AppStyle.size1W
        right: parent.right
        rightMargin: isDrawer?0:10*AppStyle.size1W
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
        color: AppStyle.textColor
        font{family: AppStyle.appFont;pixelSize: 25*AppStyle.size1F;bold:false}
        horizontalAlignment: Text.AlignHCenter
        elide: Qt.ElideRight

        anchors{
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
        border.color: AppStyle.primaryColor
        border.width: 3*AppStyle.size1W
        color: Material.color(AppStyle.primaryInt,Material.Shade50)
        anchors{
            top: parent.top
            topMargin: 20*AppStyle.size1H
            right:isDrawer? parent.right:undefined
            horizontalCenter: isDrawer?undefined:parent.horizontalCenter
            rightMargin: 10*AppStyle.size1W
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
            anchors.fill: parent
            sourceSize: Qt.size(width*4,height*4)
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
            id: profileMouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if(nRow === 1)
                    drawerLoader.item.close()
                UsefulFunc.mainStackPush("qrc:/Account/Profile.qml",qsTr("پروفایل"))

            }
        }

    }

    ScrollBar {
        id:listScroll
        hoverEnabled: true
        visible: nRow !== 1
        active: hovered || pressed
        orientation: Qt.Vertical
        anchors{
            top: listView.top
            right: parent.right
            rightMargin: isDrawer?0:-10*AppStyle.size1W
        }
        height: listView.height
        width: hovered || pressed?18*AppStyle.size1W:8*AppStyle.size1W
        contentItem: Rectangle {
            visible: parent.active
            radius: parent.pressed || parent.hovered ?20*AppStyle.size1W:8*AppStyle.size1W
            color: parent.pressed ?Material.color(AppStyle.primaryInt,Material.Shade900):Material.color(AppStyle.primaryInt,Material.Shade600)
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
            width: listView.width
            height: listDelegate.state1 ? 120*AppStyle.size1H : 100*AppStyle.size1H
            flat:true
            onClicked: {
                if(nRow === 1)
                    drawerLoader.item.close()
                if(pageSource)
                {
                    UsefulFunc.mainStackPush(model.pageSource,model.title,{listId:model.listId,pageTitle:model.title})
                }
            }
            Image {
                id: icon
                width: 50*AppStyle.size1W
                height: width
                source: model.iconSrc
                sourceSize.width: width*2
                sourceSize.height: height*2
                visible: false
                anchors{
                    top: parent.top
                    topMargin: listDelegate.state1?20*AppStyle.size1H:(parent.height-height)/2
                    right: parent.right
                    rightMargin: listDelegate.state1
                                 ?(parent.width-width)/2 // Center in parent
                                 :20*AppStyle.size1W
                }

            }
            ColorOverlay{
                id:iconColor
                anchors.fill: icon
                source:icon
                color: UsefulFunc.stackPages.get(UsefulFunc.stackPages.count-1).title === model.title?AppStyle.primaryColor
                                                                                                     :AppStyle.textColor
            }

            Text {
                id: titleText
                text: model.title
                font{
                    family: AppStyle.appFont
                    pixelSize: listDelegate.state1  ? 20*AppStyle.size1F : 25*AppStyle.size1F
                }
                color: iconColor.color
                elide: Text.ElideRight
                horizontalAlignment: listDelegate.state1 ?Text.AlignHCenter:Text.AlignRight

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
                title: qsTr("جمع‌آوری")
                pageSource :"qrc:/Things/AddEditThing.qml"
                iconSrc: "qrc:/collect.svg"
                listId: Memorito.Collect
            }
            ListElement{
                title:qsTr("پردازش نشده‌ها")
                iconSrc: "qrc:/process.svg"
                pageSource: "qrc:/Things/ThingList.qml"
                listId: Memorito.Process
            }
            ListElement{
                title:qsTr("عملیات بعدی")
                iconSrc: "qrc:/nextAction.svg"
                pageSource: "qrc:/Things/ThingList.qml"
                listId: Memorito.NextAction
            }
            ListElement{
                title:qsTr("لیست انتظار")
                iconSrc: "qrc:/waiting.svg"
                pageSource: "qrc:/Things/ThingList.qml"
                listId: Memorito.Waiting
            }
            ListElement{
                title:qsTr("تقویم")
                iconSrc: "qrc:/calendar.svg"
                pageSource: "qrc:/Things/ThingList.qml"
                listId: Memorito.Calendar
            }
            ListElement{
                title:qsTr("مرجع")
                iconSrc: "qrc:/refrence.svg"
                pageSource: "qrc:/Categories/CategoriesList.qml"
                listId: Memorito.Refrence
            }
            ListElement{
                title:qsTr("شاید یک‌روزی")
                iconSrc: "qrc:/someday.svg"
                pageSource: "qrc:/Categories/CategoriesList.qml"
                listId: Memorito.Someday
            }
            ListElement{
                title:qsTr("پروژه‌ها")
                iconSrc: "qrc:/project.svg"
                pageSource: "qrc:/Categories/CategoriesList.qml"
                listId: Memorito.Project
            }
            ListElement{
                title:qsTr("انجام شده‌ها")
                iconSrc: "qrc:/done.svg"
                pageSource: "qrc:/Things/ThingList.qml"
                listId: Memorito.Done
            }
            ListElement{
                title:qsTr("سطل زباله")
                iconSrc: "qrc:/trash.svg"
                pageSource: "qrc:/Things/ThingList.qml"
                listId: Memorito.Trash
            }
            ListElement{
                title:qsTr("محل‌های انجام")
                pageSource:"qrc:/Contexts/Contexts.qml"
                iconSrc: "qrc:/contexts.svg"
                listId: Memorito.Contexts
            }
            ListElement{
                title:qsTr("دوستان")
                iconSrc: "qrc:/friends.svg"
                pageSource: "qrc:/Friends/Friends.qml"
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
