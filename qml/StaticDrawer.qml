import QtQuick 2.14            // Reqiure For Loader
import "qrc:/AppBase" as Base  // Require For DrawerBody

Loader{
    id:staticDrawer
    width: nRow===1?0:appSetting.value("staticDrawerWidth",0)>staticDrawerMaxWidth?staticDrawerMaxWidth:
                                                                                   appSetting.value("staticDrawerWidth",0)<staticDrawerMinSize?staticDrawerMinSize:
                                                                                                                                              appSetting.value("staticDrawerWidth",0)
    onActiveChanged:{ // required for open app in nrow == 2
        if(active)
            width = nRow===1?0:appSetting.value("staticDrawerWidth",0)>staticDrawerMaxWidth?staticDrawerMaxWidth:
                                                                                           appSetting.value("staticDrawerWidth",0)<staticDrawerMinSize?staticDrawerMinSize:
                                                                                                                                                      appSetting.value("staticDrawerWidth",0)
        else width=0
    }

    height: parent.height
    sourceComponent: Item{
        Base.DrawerBody{id:drawer}
        Loader{
            id:resizerLoader
            asynchronous:true
            active: !ltr
            width: 10*size1W
            height: parent.height
            anchors.left: parent.left
            sourceComponent:Item{
                anchors.fill: parent
                Rectangle{
                    height: parent.height
                    width: 2*size1W
                    color: appStyle.primaryColor
                    anchors.left: parent.left
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
                            if(((staticDrawer.width - (mouseX)) >= staticDrawerMinSize && (staticDrawer.width - (mouseX)) <= staticDrawerMaxWidth))
                                staticDrawer.width = staticDrawer.width - (mouseX)
                            else if(staticDrawer.width - (mouseX) < staticDrawerMinSize )
                                staticDrawer.width = staticDrawerMinSize
                            else if((staticDrawer.width - (mouseX)) > staticDrawerMaxWidth)
                                staticDrawer.width = staticDrawerMaxWidth
                        }
                    }
                    onReleased: {
                        appSetting.setValue("staticDrawerWidth",staticDrawer.width)
                    }
                }

            }
        }
    }

}
