import QtQuick 2.14 // Require For Loader and other ...
import QtGraphicalEffects 1.14 // Require for ColorOverlay
import "qrc:/Components/" as App // Require for Button

Loader{
    id:headerRect
    width: parent.width - (firstColumn.active?firstColumn.width:0)
    height: 100*size1H
    anchors.right: firstColumn.active?firstColumn.left:undefined
    sourceComponent:Item{
        Rectangle{
            anchors.bottom: parent.bottom
            width: parent.width
            color: appStyle.primaryColor
            height: 3*size1H
        }
        Text{
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("مموریتو")
            font{family: appStyle.appFont;pixelSize: 50*size1F;}
            color: appStyle.textColor
        }

        App.Button{
            flat: true
            implicitWidth: 90*size1W
            implicitHeight: 90*size1H
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                if(nRow===1)
                {
                    if(!drawerLoader.item.visible)
                        drawerLoader.item.open()
                    else drawerLoader.item.close()
                }
                else {
                    resizeAnim.start()
                }
            }
            Image{
                id:menuImg
                anchors.centerIn: parent
                width: 40*size1W
                height: width
                source: drawerLoader.active && drawerLoader.status === Loader.Ready?
                            (drawerLoader.item.visible?"qrc:/close.svg":"qrc:/menu.svg")
                          :(firstColumn.width !== firstColumnMinSize?"qrc:/close.svg":"qrc:/menu.svg")
                sourceSize.width: width*2
                sourceSize.height: height*2
                visible: false
            }
            ColorOverlay{
                rotation: ltr?0:180
                id:menuImgColor
                anchors.fill: menuImg
                source:menuImg
                color: appStyle.primaryColor
            }
        }
        PropertyAnimation{
            id:resizeAnim
            duration: 150
            to : firstColumn.width === firstColumnMinSize?firstColumnMaxWidth: firstColumnMinSize
            target: firstColumn
            properties: "width"
        }
        App.Button{
            flat: true
            implicitWidth: 90*size1W
            implicitHeight: 90*size1H
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            visible: false
            Image{
                id:backIcon
                anchors.centerIn: parent
                width: 50*size1W
                height: width
                visible: false
                source: "qrc:/arrow.svg"
                sourceSize.width: width*2
                sourceSize.height: height*2
            }
            ColorOverlay{
                rotation: ltr?270:90
                source: backIcon
                anchors.fill: backIcon
                color: appStyle.primaryColor
            }
        }
    }
}
