import QtQuick 2.14 // Reqiure For Loader
import QtGraphicalEffects 1.14
import "qrc:/" as App

Loader{
    id:firstColumn
    active: nRow>1
    width: nRow===1?0:firstColumnMinSize
    height: parent.height
    onActiveChanged: {
        if(!active)
            width = 0
        else width = firstColumnMinSize
    }
    sourceComponent: Item{
        App.DrawerBody{id:drawer}
        Rectangle{
            id:drawerBackground
            anchors.fill: parent
            color: appStyle.shadowColor
            z:-1
        }

        Loader{
            id:resizerLoader
            active: !ltr
            width: 20*size1W
            height: parent.height
            anchors.left: parent.left
            sourceComponent:Rectangle{
                anchors.fill: parent
                color: drawerBackground.color
                Image{
                    id:dotsImg
                    anchors.centerIn: parent
                    width: 50*size1W
                    height: width
                    source: "qrc:/dots.svg"
                    sourceSize.width: width*2
                    sourceSize.height: height*2
                    visible: false
                }
                ColorOverlay{
                    source: dotsImg
                    anchors.fill: dotsImg
                    color: appStyle.textColor
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
                }

            }
        }
    }

}
