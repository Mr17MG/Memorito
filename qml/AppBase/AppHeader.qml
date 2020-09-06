import QtQuick 2.14 // Require For Loader and other ...
import QtGraphicalEffects 1.14 // Require for ColorOverlay
import "qrc:/Components/" as App // Require for Button

Loader{
    id:headerRect
    anchors.left: parent.left
    anchors.right: firstColumn.active?firstColumn.left:parent.right
    height: 100*size1H
    sourceComponent:Item{
        Loader{
            id: resizerLoader
            active: ltr && firstColumn.active
            width: 10*size1W
            height: parent.height
            anchors.right: parent.right
            sourceComponent:Item{
                anchors.fill: parent
                Rectangle{
                    height: parent.height
                    width: 2*size1W
                    color: appStyle.primaryColor
                    anchors.right: parent.right
                }
                MouseArea {
                    anchors.fill: parent
                    drag.target: parent
                    drag.axis: Drag.XAxis
                    cursorShape: Qt.SizeHorCursor
                    onClicked: {
                        if(firstColumn.width === firstColumnMaxWidth)
                            firstColumn.width = firstColumnMinSize
                        else if(firstColumn.width >= firstColumnMinSize)
                            firstColumn.width = firstColumnMaxWidth
                        appSetting.setValue("firstColumnWidth",firstColumn.width)
                    }

                    onMouseXChanged: {
                        if( drag.active )
                        {
                            if ((firstColumn.width + (mouseX)) >= firstColumnMinSize && (firstColumn.width + (mouseX)) <= firstColumnMaxWidth)
                                firstColumn.width = firstColumn.width + (mouseX)
                            else if(firstColumn.width + (mouseX) < firstColumnMinSize )
                                firstColumn.width = firstColumnMinSize
                            else if((firstColumn.width + (mouseX)) > firstColumnMaxWidth)
                                firstColumn.width = firstColumnMaxWidth
                        }
                    }
                    onReleased: {
                        appSetting.setValue("firstColumnWidth",firstColumn.width)
                    }
                }
            }
        }
        Rectangle{
            anchors.bottom: parent.bottom
            width: parent.width
            color: appStyle.primaryColor
            height: 3*size1H
        }

        Text{
            anchors.verticalCenter: parent.verticalCenter
            width: nRow===3 && secondRowTitle.visible ?parent.width/2:parent.width
            anchors.right: parent.right
            horizontalAlignment: Text.AlignHCenter
            text: mainHeaderTitle
            font{family: appStyle.appFont;pixelSize: 50*size1F;}
            color: appStyle.textColor
        }

        Text{
            id: secondRowTitle
            anchors.verticalCenter: parent.verticalCenter
            width: nRow===3?parent.width/2:parent.width
            anchors.left: parent.left
            visible: nRow ===3 && text !== ""
            horizontalAlignment: Text.AlignHCenter
            text: anotherHeaderTitle
            font{family: appStyle.appFont;pixelSize: 50*size1F;}
            color: appStyle.textColor
        }

        App.Button{
            flat: true
            implicitWidth: 90*size1W
            implicitHeight: 90*size1H
            anchors.right: parent.right
            anchors.rightMargin: 10*size1W
            visible: nRow === 1
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                if(!drawerLoader.item.visible)
                    drawerLoader.item.open()
                else drawerLoader.item.close()
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
                id:menuImgColor
                rotation: ltr?0:180
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
            width:  90*size1W
            height: width
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            visible: mainColumn.item.mainStackView.depth > 1
            onClicked: {
                mainColumn.item.mainStackView.pop()
            }

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
