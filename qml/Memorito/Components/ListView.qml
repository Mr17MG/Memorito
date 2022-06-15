import QtQuick 
import QtQuick.Controls.Material 
import Memorito.Components
import Memorito.Global

ListView {
    id:control

    property bool isEmpty:!model.count
    property bool isLoading: false
    property string emptyListText: qsTr("داده‌ای ثبت نشده")
    property string emptyListColor: AppStyle.textColor
    property bool hasOverScroll: false

    onContentYChanged: {
        if(!hasOverScroll)
        {
            if(contentY<0 || contentHeight < control.height)
                contentY = 0
            else if(contentY > ((contentHeight + (model.count * spacing))-control.height))
                contentY = (contentHeight + (model.count * spacing))-control.height
        }
    }
    onContentXChanged: {
        if(!hasOverScroll)
        {
            if(contentX<0 || contentWidth < control.width)
                contentX = 0
            else if(contentX > (contentWidth-control.width))
                contentX = (contentWidth-control.width)
        }
    }

    Text {
        visible: isEmpty && !isLoading
        text: emptyListText
        anchors.top:parent.top
        anchors.topMargin: AppStyle.size1H*20
        anchors.horizontalCenter: parent.horizontalCenter
        color: emptyListColor
        font { family: AppStyle.appFont; pixelSize: AppStyle.size1F*15;bold:true}
    }

    Item{
        anchors.centerIn: parent
        width: parent.width
        height: AppStyle.size1H*150
        Text{
            visible:isLoading
            text: qsTr("در حال بارگذاری")
            anchors.top:parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            font { family: AppStyle.appFont; pixelSize: AppStyle.size1F*17;bold:true}
            color: emptyListColor
        }

        AppBusyIndicator{
            visible:isLoading
            anchors.bottom: parent.bottom
            anchors.centerIn: parent
            Material.accent: AppStyle.primaryColor
        }

    }

    cacheBuffer: Qt.platform.os=="android"?1000:500
    maximumFlickVelocity: AppStyle.size1H*3000
    highlightMoveDuration: AppStyle.size1H*500
    highlightFollowsCurrentItem: true
}
