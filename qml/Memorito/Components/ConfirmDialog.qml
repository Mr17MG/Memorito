import QtQuick 
import QtQuick.Controls 
import QtQuick.Controls.Material 
import Memorito.Global

Dialog{
    id:dialog
    property string dialogText: ""
    property string dialogTitle: ""
    property string dialogButtonColor: AppStyle.primaryColor

    property var accepted
    property var rejected
    property real oneLineWidth
    Overlay.modal: Rectangle {
        color: AppStyle.appTheme?"#aa606060":"#80000000"
    }
    onVisibleChanged: {
        try{
            if(!visible && typeof destroy === "function")
                destroy()
        }catch(e){}
    }
    onClosed: {
        try{
            if(!visible && typeof destroy === "function")
                destroy()
        }catch(e){}
    }

    width: Math.max(
        Math.max( UsefulFunc.rootWindow.width/2, 480*AppStyle.size1W  ),
        Math.min( UsefulFunc.rootWindow.width/2, 1000*AppStyle.size1W )
    )
    height: AppStyle.size1H*300 + text.height
    modal: true
    closePolicy: Dialog.NoAutoClose
    Shortcut {
        sequences: ["Esc", "Back"]
        enabled: dialog.visible
        onActivated: {
            dialog.close()
        }
    }
    x: -parent.x + (parent===null?0:(parent.width- width)/2)
    y: -parent.y + (parent===null?0:(parent.height- height)/2)
    Text {
        id: title
        text: dialogTitle
        color: AppStyle.textColor
        font { family: AppStyle.appFont; pixelSize: AppStyle.size1F*32;bold: true }
        width: parent.width
        height: 65*AppStyle.size1H
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignHCenter
    }
    Rectangle{
        color: Material.color(AppStyle.primaryInt)
        height: 2*AppStyle.size1H
        anchors{
            horizontalCenter: try{parent.horizontalCenter}catch(e){}
            bottom: try{title.bottom}catch(e){}
            bottomMargin: -AppStyle.size1H*5
        }
        width: parent.width - AppStyle.size1W*40
    }
    Text {
        id: text
        text: dialogText
        color: AppStyle.textColor
        font { family: AppStyle.appFont; pixelSize: AppStyle.size1F*30 }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors{
            top: title.bottom
            topMargin: AppStyle.size1H*40
            right: try{parent.right}catch(e){}
            rightMargin:  AppStyle.size1W*20
            left: try{parent.left}catch(e){}
            leftMargin:  AppStyle.size1W*20
        }
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    }
    Flow{
        id:flow
        layoutDirection: AppStyle.ltr? Qt.LeftToRight : Qt.RightToLeft
        anchors{
            horizontalCenter: try{parent.horizontalCenter}catch(e){}
            bottom: try{parent.bottom}catch(e){}
            bottomMargin: AppStyle.size1H*0
        }
        spacing: AppStyle.size1W*30
        AppButton {
            width: AppStyle.size1W*200
            height: AppStyle.size1H*80
            text: qsTr("بلی")
            radius: AppStyle.size1W*20
            onClicked: {
                if(accepted)
                    accepted()
                dialog.close()
            }
        }

        AppButton {
            width: AppStyle.size1W*200
            height: AppStyle.size1H*80
            flat:true
            text: qsTr("خیر")
            borderColor: AppStyle.textColor
            radius: AppStyle.size1W*20
            onClicked: {
                if(rejected)
                    rejected()
                dialog.close()
            }
        }
    }
}
