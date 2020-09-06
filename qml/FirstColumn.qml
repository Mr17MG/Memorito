import QtQuick 2.14 // Reqiure For Loader
import "qrc:/AppBase" as Base // Require For DrawerBody

Loader{
    id:firstColumn
    width: nRow===1?0:appSetting.value("firstColumnWidth",0)>firstColumnMaxWidth?firstColumnMaxWidth:
                                                                                   appSetting.value("firstColumnWidth",0)<firstColumnMinSize?firstColumnMinSize:
                                                                                                                                              appSetting.value("firstColumnWidth",0)
    onActiveChanged:{ // required for open app in nrow == 2
        if(active)
            width = nRow===1?0:appSetting.value("firstColumnWidth",0)>firstColumnMaxWidth?firstColumnMaxWidth:
                                                                                           appSetting.value("firstColumnWidth",0)<firstColumnMinSize?firstColumnMinSize:
                                                                                                                                                      appSetting.value("firstColumnWidth",0)
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
                        if(firstColumn.width === firstColumnMaxWidth)
                            firstColumn.width = firstColumnMinSize
                        else if(firstColumn.width >= firstColumnMinSize)
                            firstColumn.width = firstColumnMaxWidth
                        appSetting.setValue("firstColumnWidth",firstColumn.width)
                    }
                    onMouseXChanged: {
                        if( drag.active )
                        {
                            if(((firstColumn.width - (mouseX)) >= firstColumnMinSize && (firstColumn.width - (mouseX)) <= firstColumnMaxWidth))
                                firstColumn.width = firstColumn.width - (mouseX)
                            else if(firstColumn.width - (mouseX) < firstColumnMinSize )
                                firstColumn.width = firstColumnMinSize
                            else if((firstColumn.width - (mouseX)) > firstColumnMaxWidth)
                                firstColumn.width = firstColumnMaxWidth
                        }
                    }
                    onReleased: {
                        appSetting.setValue("firstColumnWidth",firstColumn.width)
                    }
                }

            }
        }
    }

}
