import QtQuick 2.14 // Require For Listview
import QtGraphicalEffects 1.14 // Require For ColorOverlay
import "qrc:/Components/" as App // Require For App.Button

Item{
    anchors.fill: parent
    anchors.left: parent.left
    anchors.leftMargin: firstColumn.active && resizerLoader.active?resizerLoader.width:0
    clip: true
    Item {
        id:profileItem
        width: parent.width
        height: parent.width >= 210*size1H?210*size1H:parent.width+10*size1H
        anchors.right: parent.right
        Text {
            id: userNameText
            text: "محمد گلکار"
            color: appStyle.textColor
            font{family: appStyle.appFont;pixelSize: 25*size1F;bold:false}
            anchors.verticalCenter: profileRect.verticalCenter
            anchors.right: profileRect.left
            anchors.rightMargin: 10*size1W
            anchors.left: parent.left
            wrapMode: Text.WordWrap
            visible: drawerLoader.active?true:firstColumn.width > firstColumnMinSize + 50*size1W
        }
        Rectangle{
            id: profileRect
            width: drawerLoader.active?200*size1W:firstColumn.width <= 170*size1W?firstColumn.width - 30*size1W:150*size1W
            height: width
            radius: width
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10*size1W
            border.color: appStyle.primaryColor
            border.width: 3*size1W
            Image {
                id: profileImage
                source: "file:///media/MrMG/Pictures/photo_2019-08-13_10-01-14.jpg"
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

    }

    App.ListView{
        id:listView
        clip: true
        anchors.top: profileItem.bottom
        height:parent.height
        width:parent.width
        spacing: 5*size1H
        delegate: App.Button{
            id: listDelegate
            width: listView.width
            height: firstColumn.width === firstColumnMinSize?120*size1H:100*size1H
            flat:true
            implicitHeight: height
            implicitWidth: width

            MouseArea{
                id: itemMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if(nRow === 1)
                        drawerLoader.item.close()
                    if(pageSource)
                    {
                        mainColumn.item.mainStackView.push(pageSource)
                    }
                }
            }
            Image {
                id: icon
                width: 50*size1W
                height: width
                source: iconSrc
                sourceSize.width: width*2
                sourceSize.height: height*2
                anchors.right: parent.right
                anchors.rightMargin: firstColumn.width === firstColumnMinSize?(parent.width-width-(nRow===2?20*size1W:0))/2:20*size1W
                anchors.top: parent.top
                anchors.topMargin: firstColumn.width === firstColumnMinSize?10*size1H:20*size1H
                visible: false
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
                font{family: appStyle.appFont;pixelSize: firstColumn.width === firstColumnMinSize?20*size1F:25*size1F;bold:false}
                color: iconColor.color
                anchors.right: firstColumn.width === firstColumnMinSize?parent.right:icon.left
                anchors.rightMargin: firstColumn.width === firstColumnMinSize?10*size1W:20*size1W
                anchors.left: parent.left
                anchors.leftMargin: nRow===2?20*size1W:0
                anchors.top: firstColumn.width === firstColumnMinSize?icon.bottom:parent.top
                anchors.topMargin: firstColumn.width === firstColumnMinSize?8*size1H:32*size1H
                elide: Text.ElideRight
                horizontalAlignment: firstColumn.width === firstColumnMinSize?Text.AlignHCenter:Text.AlignRight
            }
            Rectangle{
                anchors.bottom: parent.bottom
                width: parent.width
                height: 2*size1H
                color: appStyle.primaryColor
                z:2
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