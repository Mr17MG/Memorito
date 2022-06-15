import QtQuick  // require For Item and Image and Text
import Memorito.Global

Item {
    property string imageSource: ""
    property string title: ""

    Image {
        id:sImage
        source: imageSource
        width: parent.width >= 600*AppStyle.size1W ? 550*AppStyle.size1W
                                                  : (parent.width - 50*AppStyle.size1W)
        height: width
        sourceSize: Qt.size(width,height)

        anchors{
            centerIn: parent
            verticalCenterOffset: -AppStyle.size1H*50
        }
    }

    Text {
        id: sText
        text: title
        width: parent.width
        wrapMode: Text.WordWrap
        padding: 10*AppStyle.size1W
        color: AppStyle.textOnPrimaryColor
        horizontalAlignment: Text.AlignHCenter

        font {
            family: AppStyle.appFont
            pixelSize: AppStyle.size1F*35
            bold: false
        }

        anchors{
            top: sImage.bottom
            topMargin: AppStyle.size1H*5
            horizontalCenter: sImage.horizontalCenter
        }
    }
}
