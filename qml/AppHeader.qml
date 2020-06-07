import QtQuick 2.14 // Require For Loader and other ...
import QtGraphicalEffects 1.14 // Require for ColorOverlay
import "qrc:/Components/" as App // Require for Button

Loader{
    id:headerRect
    width: parent.width
    height: 100*size1H
    sourceComponent:Item{
        Rectangle{
            anchors.bottom: parent.bottom
            width: parent.width
            color: "gray"
            height: 3*size1H
        }

        Text{
            anchors.centerIn: parent
            text: qsTr("مموریتو")
            font{family: appStyle.shabnam;pixelSize: 50*size1F;}
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
                    if(firstColumn.width === firstColumnMinSize )
                    {
                        firstColumn.width = firstColumnMaxWidth
                    }
                    else firstColumn.width = firstColumnMinSize
                }
            }
            Image{
                id:menuImg
                anchors.centerIn: parent
                width: 55*size1W
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
