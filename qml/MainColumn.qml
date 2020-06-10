import QtQuick 2.14 // Require For Loader
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.14 // Require For ColorOverlay

Loader{
    id:mainColumn
    active: nRow>=1
    width: nRow===1?rootWindow.width
                   :nRow===2?rootWindow.width-firstColumn.width
                            :(rootWindow.width-firstColumn.width)/2
    height: parent.height
    sourceComponent: Item {
        clip: true
        property alias mainStackView: mainStackView
        StackView{
            id:mainStackView
            anchors.right: resizerLoader.active?resizerLoader.left:parent.right
            anchors.left: parent.left
            height: parent.height
        }

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
                }
            }
        }
    }

}

