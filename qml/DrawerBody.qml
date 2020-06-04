import QtQuick 2.14 // Require For Listview
import QtGraphicalEffects 1.14 // Require For ColorOverlay

ListView{
    property color background: "white"
    Rectangle{
        id : backRect
        anchors.fill: parent
        color: background
        z:-1
    }

    id:listView
    anchors.fill: parent
    clip: true
    onContentYChanged: {
        if(contentY<0 || contentHeight < listView.height)
            contentY = 0
        else if(contentY > (contentHeight + (model.count)-listView.height))
            contentY = (contentHeight + model.count)-listView.height
    }
    delegate: Item {
        id: listDelegate
        width: listView.width
        height: 60*size1H

        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                drawer.close()
                if(pageSource!=="")
                    stack.push(pageSource)
            }
        }
        Image {
            id: icon
            width: 20*size1W
            height: width
            source: iconSrc
            sourceSize.width: width*2
            sourceSize.height: height*2
            anchors.right: parent.right
            anchors.rightMargin: firstRow.width === firstRowMinSize?(parent.width-width)/2:10*size1W
            anchors.top: parent.top
            anchors.topMargin: firstRow.width === firstRowMinSize?10*size1H:20*size1H
            visible: false
        }
        ColorOverlay{
            anchors.fill: icon
            source:icon
            color: "Black"
            transform:rotation
            antialiasing: true
        }
        Text {
            id: titleText
            text: title
            font{pixelSize: firstRow.width === firstRowMinSize?11*size1F:14*size1F;bold:false}
            color: "Black"
            anchors.right: firstRow.width === firstRowMinSize?parent.right:icon.left
            anchors.rightMargin: firstRow.width === firstRowMinSize?5*size1W:10*size1W
            anchors.left: parent.left
            anchors.top: firstRow.width === firstRowMinSize?icon.bottom:parent.top
            anchors.topMargin: firstRow.width === firstRowMinSize?5*size1H:20*size1H
            elide: Text.ElideRight
            horizontalAlignment: firstRow.width === firstRowMinSize?Text.AlignHCenter:Text.AlignRight
        }
        Rectangle{
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1*size1H
            color: "gray"
        }
    }
    model: ListModel{
        ListElement{
            title:qsTr("تنظیمات")
            //            pageSource : "qrc:/Pages/Friends/FriendsMain.qml"
            iconSrc: "file:///media/MrMG/Codes/03-Qt/TestProjects/TestColumn/Icons/setting.svg"
        }ListElement{
            title:qsTr("پروژه ها")
            //            pageSource : "qrc:/Pages/Friends/FriendsMain.qml"
            iconSrc: "file:///media/MrMG/Codes/03-Qt/TestProjects/TestColumn/Icons/setting.svg"
        }

    }
}
