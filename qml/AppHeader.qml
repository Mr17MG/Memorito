import QtQuick 2.14
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.14

Loader{
        id:headerRect
        width: parent.width
        height: 40*size1H
        active: nRow===1
        visible: nRow===1
        sourceComponent: Item{
            Rectangle{
                anchors.bottom: parent.bottom
                width: parent.width
                color: "gray"
                height: 1*size1H
            }

            Text{
                anchors.centerIn: parent
                text: qsTr("مموریتو")
                font{pixelSize: 17*size1F;}

            }

            Button{
                flat: true
                implicitWidth: 40*size1W
                implicitHeight: 40*size1H
                anchors.right: parent.right
                visible: drawerLoader.active
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    if(!drawerLoader.item.visible)
                        drawerLoader.item.open()
                    else drawerLoader.item.close()
                }
                Image{
                    anchors.centerIn: parent
                    width: 20*size1W
                    height: width
                    rotation: ltr?0:180
                    source: drawerLoader.active?drawerLoader.item.visible?"qrc:/close.svg":"qrc:/menu.svg":""
                    sourceSize.width: width*2
                    sourceSize.height: height*2
                }
            }

            Button{
                flat: true
                implicitWidth: 40*size1W
                implicitHeight: 40*size1H
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                Image{
                    id:backIcon
                    anchors.centerIn: parent
                    width: 20*size1W
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
                    color: "Black"
                }
            }
        }
    }

