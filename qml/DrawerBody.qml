import QtQuick 2.14 // Require For Listview
import QtGraphicalEffects 1.14 // Require For ColorOverlay
import QtQuick.Controls 2.14 // Require for Button
//import QtQuick.Controls.Material 2.14

ListView{
    id:listView
    anchors.fill: parent
    clip: true
    onContentYChanged: {
        if(contentY<0 || contentHeight < listView.height)
            contentY = 0
        else if(contentY > (contentHeight + (model.count)-listView.height))
            contentY = (contentHeight + model.count)-listView.height
    }
    spacing: 5*size1H
    delegate: Button {
        id: listDelegate
        width: listView.width
        height: firstRow.width === firstRowMinSize?120*size1H:100*size1H
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
                    secondRow.source = pageSource
                }
            }
        }
        Image {
            id: icon
            width: 60*size1W
            height: width
            source: iconSrc
            sourceSize.width: width*2
            sourceSize.height: height*2
            anchors.right: parent.right
            anchors.rightMargin: firstRow.width === firstRowMinSize?(parent.width-width-(nRow===2?20*size1W:0))/2:20*size1W
            anchors.top: parent.top
            anchors.topMargin: firstRow.width === firstRowMinSize?10*size1H:20*size1H
            visible: false
        }
        ColorOverlay{
            id:iconColor
            anchors.fill: icon
            source:icon
            color: secondRow.source.toString() === pageSource? appStyle.primaryColor:appStyle.textColor
        }
        Text {
            id: titleText
            text: title
            font{pixelSize: firstRow.width === firstRowMinSize?25*size1F:30*size1F;bold:false}
            color: iconColor.color
            anchors.right: firstRow.width === firstRowMinSize?parent.right:icon.left
            anchors.rightMargin: firstRow.width === firstRowMinSize?10*size1W:20*size1W
            anchors.left: parent.left
            anchors.leftMargin: nRow===2?20*size1W:0
            anchors.top: firstRow.width === firstRowMinSize?icon.bottom:parent.top
            anchors.topMargin: firstRow.width === firstRowMinSize?5*size1H:23*size1H
            elide: Text.ElideRight
            horizontalAlignment: firstRow.width === firstRowMinSize?Text.AlignHCenter:Text.AlignRight
        }
        Rectangle{
            anchors.bottom: parent.bottom
            width: parent.width
            height: 3*size1H
            color: appStyle.textColor
        }
    }
    model: ListModel{
        ListElement{
            title:qsTr("تنظیمات")
            pageSource : "qrc:/AppSettings.qml"
            iconSrc: "qrc:/setting.svg"
        }ListElement{
            title:qsTr("پروژه ها")
            //            pageSource : "qrc:/Pages/Friends/FriendsMain.qml"
            iconSrc: "qrc:/setting.svg"
        }

    }
}
