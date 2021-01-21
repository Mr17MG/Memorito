import QtQuick 2.14 // Require For Loader
import QtQuick.Controls 2.14 // Require For Stackview
import QtGraphicalEffects 1.14 // Require For ColorOverlay

Loader{
    id:mainPage
    active: true
    asynchronous: true
    width: nRow===1?rootWindow.width
                   :rootWindow.width - staticDrawer.width
    height: parent.height
    sourceComponent: Item {
        clip: true
        property alias mainStackView: mainStackView
        Rectangle{
            id: disconnectRect
            width: parent.width
            height: 100*size1W
            color: "yellow"
            visible: false
        }

        StackView{
            id:mainStackView
            anchors{
                right: resizerLoader.active?resizerLoader.left:parent.right
                left: parent.left
                top: disconnectRect.visible?disconnectRect.bottom:parent.top
                bottom: parent.bottom
            }
            clip: true
            initialItem: Item{}

            function callInItemFunction(object)
            {
                if(typeof currentItem.popOut === "function"){
                    return currentItem.popOut(object)
                }
                else
                {
                    console.log("no function in this page")
                }
            }
        }

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
                }
            }
        }
    }
}

