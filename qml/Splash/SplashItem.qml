import QtQuick  // require For Item and Image and Text
import Memorito.Global

Item {
    property string imageSource: ""
    property string title: ""

    Image {
        id:sImage
        source: imageSource
        width: parent.width >=600*AppStyle.size1W?550*AppStyle.size1W:(parent.width - 50*AppStyle.size1W)
        height: width
        sourceSize.width: width*2
        sourceSize.height: height*2
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -AppStyle.size1H*50
    }

    Text {
        id: sText
        text: title
        width: parent.width
        padding: 10*AppStyle.size1W
        wrapMode: Text.WordWrap
        anchors.top: sImage.bottom
        anchors.topMargin: AppStyle.size1H*5
        anchors.horizontalCenter: sImage.horizontalCenter
        color: AppStyle.textOnPrimaryColor
        horizontalAlignment: Text.AlignHCenter
        font { family: AppStyle.appFont; pixelSize: AppStyle.size1F*35;bold: false}
    }
}
