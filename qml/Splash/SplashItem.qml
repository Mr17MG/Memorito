import QtQuick 2.14 // require For Item and Image and Text

Item {
    property string imageSource: ""
    property string title: ""
    Image {
        id:sImage
        source: imageSource
        width: parent.width >=600*size1W?550*size1W:(parent.width - 50*size1W)
        height: width
        sourceSize.width: width*2
        sourceSize.height: height*2
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -size1H*50
    }

    Text {
        id: sText
        text: title
        width: parent.width
        padding: 10*size1W
        wrapMode: Text.WordWrap
        anchors.top: sImage.bottom
        anchors.topMargin: size1H*5
        anchors.horizontalCenter: sImage.horizontalCenter
        color: "White"// appStyle.textColor
        horizontalAlignment: Text.AlignHCenter
        font { family: appStyle.appFont; pixelSize: size1F*35;bold: false}
    }
}
