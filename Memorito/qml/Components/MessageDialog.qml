import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import Components 1.0
import Global 1.0

AppDialog {

    id: messageDialog
    padding: 0
    property string text : ""
    property var callback
    property string msgTitle :""

    onVisibleChanged: {
        try{
            if(!visible && typeof destroy === "function")
                destroy()
        }catch(e){}
    }
    onClosed: {
        try{
            if(callback!==undefined )
                callback();
            if(!visible && typeof destroy === "function")
                destroy()
        }catch(e){}
    }


    Shortcut {
        sequences: ["Esc", "Back"]
        enabled: messageDialog.visible
        onActivated: {
            messageDialog.close()
        }
    }
    width: Math.max(
               Math.max( UsefulFunc.rootWindow.width/2, 480*AppStyle.size1W  ),
               Math.min( UsefulFunc.rootWindow.width/2, 1000*AppStyle.size1W )
               )

    height: AppStyle.size1H*280 + textContainer.height
    hasButton: true
    dialogButton.onClicked: {close()}
    x: -parent.x + (parent===null?0:(parent.width- width)/2)
    y: -parent.y + (parent===null?0:(parent.height- height)/2)
    buttonTitle: qsTr("باشه")
    dialogButton.anchors.bottomMargin: AppStyle.size1W*25
    Text {
        id: title
        text: msgTitle?msgTitle:qsTr("خطا")
        color: AppStyle.textColor
        font { family: AppStyle.appFont; pixelSize: AppStyle.size1F*32;bold: true }
        width: parent.width
        height: 75*AppStyle.size1H
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignHCenter
    }
    Rectangle{
        color: Material.color(AppStyle.primaryInt)
        height: 2*AppStyle.size1H
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: title.bottom
        anchors.bottomMargin: -AppStyle.size1H*5
        width: parent.width - AppStyle.size1W*40
    }
    Text {
        id: textContainer
        text: messageDialog.text
        color: AppStyle.textColor
        font { family: AppStyle.appFont; pixelSize: AppStyle.size1F*30 }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors{
            top: title.bottom
            topMargin: AppStyle.size1H*40
            right: parent.right
            rightMargin:  AppStyle.size1W*20
            left: parent.left
            leftMargin:  AppStyle.size1W*20
        }
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    }

}
