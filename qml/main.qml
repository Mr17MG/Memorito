import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.14

ApplicationWindow {
    id:rootWindow
    visible: true
    title: qsTr("مموریتو")

    width: 640
    height: 480
    minimumWidth: Screen.width/5<380?380:Screen.width/5
    minimumHeight: Screen.height/3<480?480:Screen.height/3
    property bool ltr: false
    LayoutMirroring.enabled: ltr
    LayoutMirroring.childrenInherit: true

    property real size1W: uiFunctions.getWidthSize(1,Screen)
    property real size1H: uiFunctions.getHeightSize(1,Screen)
    property real size1F: uiFunctions.getFontSize(1,Screen)
    property int nRow : uiFunctions.checkDisplayForNumberofRows(Screen)
    property real firstRowMinSize: 60*size1W
    property real firstRowMaxWidth: nRow ==2?rootWindow.width*2.5/8:rootWindow.width*1.80/8

    UiFunctions { id : uiFunctions }

    onWidthChanged: {
        if(firstRow.width > firstRowMaxWidth)
            firstRow.width = firstRowMaxWidth
        else if(firstRow.width > firstRowMinSize)
            firstRow.width = firstRowMaxWidth
    }

    Loader{
        id:drawerLoader
        active: nRow===1
        width: rootWindow.width*2/3
        height: rootWindow.height

        sourceComponent: Drawer{
            DrawerBody{}
            height: drawerLoader.height
            width: drawerLoader.width
            edge: ltr?Qt.LeftEdge:Qt.RightEdge
            dragMargin:30
        }
    }

    header : Loader{
        id:headerRect
        width: parent.width
        height: 45*size1H
        active: nRow===1
        visible: nRow===1
        sourceComponent: Item{
            Button{
                anchors.right: parent.right
                anchors.top: parent.top
                text: qsTr("Menu")
                visible: drawerLoader.active
                onClicked: {
                    drawerLoader.item.open()
                }
            }
        }
    }

    Row {
        id:mainRow
        layoutDirection: Qt.RightToLeft
        height: parent.height
        Loader{
            id:firstRow
            active: nRow>=2
            width: nRow===1?0:firstRowMinSize
            height: parent.height
            property color background: "#cccccc"
            sourceComponent: Item{
                DrawerBody{id:drawer;background:firstRow.background }
                Loader{
                    active: !ltr
                    width: 3*size1W
                    height: parent.height
                    anchors.left: parent.left
                    sourceComponent:Rectangle{
                        anchors.fill: parent
                        color: drawer.background
                        MouseArea {
                            anchors.fill: parent
                            drag.target: parent
                            drag.axis: Drag.XAxis
                            cursorShape: Qt.SizeHorCursor
                            onMouseXChanged: {
                                if( drag.active )
                                {
                                    if(((firstRow.width - (mouseX)) >= firstRowMinSize && (firstRow.width - (mouseX)) <= firstRowMaxWidth))
                                        firstRow.width = firstRow.width - (mouseX)
                                    else if(firstRow.width - (mouseX) < firstRowMinSize )
                                        firstRow.width = firstRowMinSize
                                    else if((firstRow.width - (mouseX)) > firstRowMaxWidth)
                                        firstRow.width = firstRowMaxWidth
                                }
                            }
                        }
                    }
                }
            }

        }
        Loader{
            id:secondRow
            active: nRow>=1
            width: nRow===1?rootWindow.width
                           :nRow===2?rootWindow.width-firstRow.width
                                    :(rootWindow.width-firstRow.width)/2
            height: parent.height
            sourceComponent: Rectangle {
                color: "pink"
                clip: true
                Loader{
                    active: ltr
                    width: 3*size1W
                    height: parent.height
                    anchors.right: parent.right
                    sourceComponent:Rectangle{
                        anchors.fill: parent
                        color: firstRow.background
                        MouseArea {
                            anchors.fill: parent
                            drag.target: parent
                            drag.axis: Drag.XAxis
                            cursorShape: Qt.SizeHorCursor
                            onMouseXChanged: {
                                if( drag.active )
                                {
                                    if ((firstRow.width + (mouseX)) >= firstRowMinSize && (firstRow.width + (mouseX)) <= firstRowMaxWidth)
                                        firstRow.width = firstRow.width + (mouseX)
                                    else if(firstRow.width + (mouseX) < firstRowMinSize )
                                        firstRow.width = firstRowMinSize
                                    else if((firstRow.width + (mouseX)) > firstRowMaxWidth)
                                        firstRow.width = firstRowMaxWidth
                                }
                            }
                        }
                    }
                }
                Button{
                    anchors.centerIn: parent
                    text: qsTr("change Right to Left")
                    onClicked: {
                        ltr= !ltr
                    }
                }
            }

        }
        Loader{
            id:thirdRow
            active: nRow>=3
            width:  nRow===3?(rootWindow.width-firstRow.width)/2:0
            height: parent.height
            sourceComponent: Rectangle { color: "lightBlue"}
        }
    }

}
