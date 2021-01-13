import QtQuick 2.14 // Require For Loader and other ...
import QtGraphicalEffects 1.14 // Require for ColorOverlay
import "qrc:/Components/" as App // Require for Button

Loader{
    id:headerRect
    anchors.left: parent.left
    anchors.right: staticDrawer.active?staticDrawer.left:parent.right
    height: 100*size1H
    sourceComponent:Item{
        Loader{
            id: resizerLoader
            active: ltr && staticDrawer.active
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
                        if(staticDrawer.width === staticDrawerMaxWidth)
                            staticDrawer.width = staticDrawerMinSize
                        else if(staticDrawer.width >= staticDrawerMinSize)
                            staticDrawer.width = staticDrawerMaxWidth
                        appSetting.setValue("staticDrawerWidth",staticDrawer.width)
                    }

                    onMouseXChanged: {
                        if( drag.active )
                        {
                            if ((staticDrawer.width + (mouseX)) >= staticDrawerMinSize && (staticDrawer.width + (mouseX)) <= staticDrawerMaxWidth)
                                staticDrawer.width = staticDrawer.width + (mouseX)
                            else if(staticDrawer.width + (mouseX) < staticDrawerMinSize )
                                staticDrawer.width = staticDrawerMinSize
                            else if((staticDrawer.width + (mouseX)) > staticDrawerMaxWidth)
                                staticDrawer.width = staticDrawerMaxWidth
                        }
                    }
                    onReleased: {
                        appSetting.setValue("staticDrawerWidth",staticDrawer.width)
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
            anchors{
                right: parent.right
                left : parent.left
                verticalCenter: parent.verticalCenter
            }
            horizontalAlignment: Text.AlignHCenter
            elide: ltr?Text.ElideRight:Text.ElideLeft
            text: mainHeaderTitle
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
                          :(staticDrawer.width !== staticDrawerMinSize?"qrc:/close.svg":"qrc:/menu.svg")
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
        App.Button{
            flat: true
            width:  90*size1W
            height: width
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            visible: mainColumn.item.mainStackView.depth > 1
            onClicked: {
                 usefulFunc.mainStackPop()
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
