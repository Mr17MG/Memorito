import QtQuick 2.14 // Require For Listview
import QtGraphicalEffects 1.14 // Require For ColorOverlay
import "qrc:/Components/" as App // Require For App.Button
import QtQuick.Controls.Material 2.14

Item{
    anchors.fill: parent
    anchors.leftMargin: firstColumn.active && resizerLoader.active?resizerLoader.width:0
    clip: true

    Text {
        id: userNameText
        text: "@"+"Mr17MG"
        color: appStyle.textColor
        font{family: appStyle.appFont;pixelSize: 25*size1F;bold:false}
        horizontalAlignment: Text.AlignHCenter
        elide: Qt.ElideRight

        anchors{
            verticalCenter: drawerLoader.active?profileRect.verticalCenter:undefined
            top: drawerLoader.active?undefined:profileRect.bottom
            topMargin: 10*size1H
            right: drawerLoader.active?profileRect.left:parent.right
            rightMargin: 10*size1W
            left: parent.left
            leftMargin: 10*size1W
        }

    }
    Rectangle{
        id: profileRect
        width: height
        height: parent.width >= 200*size1H?200*size1H:parent.width-10*size1H
        radius: width
        border.color: appStyle.primaryColor
        border.width: 3*size1W
        color: Material.color(appStyle.primaryInt,Material.shade300)
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
            }
        }

    }

    App.ListView{
        id:listView
        clip: true
        anchors{
            top: drawerLoader.active?profileRect.bottom:userNameText.bottom
            topMargin : 10*size1H
        }

        Rectangle{
            anchors.top: parent.top
            width: parent.width
            height: 2*size1H
            color: appStyle.primaryColor
        }

        height:parent.height
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
                    mainColumn.item.mainStackView.push(pageSource)
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
                    topMargin: 20*size1H
                    right: parent.right
                    rightMargin: listDelegate.state1
                                 ?(parent.width-width-(nRow===2?10*size1W:0))/2 // Center in parent
                                 :20*size1W
                }
            }
            ColorOverlay{
                id:iconColor
                anchors.fill: icon
                source:icon
                color: /*mainColumn.source.toString() === pageSource? appStyle.primaryColor:*/appStyle.textColor
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
                    rightMargin: listDelegate.state1 ? 10*size1W : 20*size1W
                    left: parent.left
                    leftMargin: nRow === 2 ? 20*size1W : 0
                }
            }
            Rectangle{
                anchors.bottom: parent.bottom
                width: parent.width
                height: 2*size1H
                color: appStyle.primaryColor
            }
        }
        model: ListModel{
            ListElement{
                title:qsTr("تنظیمات")
                pageSource : "qrc:/AppBase/AppSettings.qml"
                iconSrc: "qrc:/setting.svg"
            }ListElement{
                title:qsTr("پروژه ها")
                //            pageSource : "qrc:/Pages/Friends/FriendsMain.qml"
                iconSrc: "qrc:/setting.svg"
            }

        }
    }
}
