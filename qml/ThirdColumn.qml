import QtQuick 2.14

Loader{
    id:thirdRow
    active: nRow>=3
    width:  nRow===3?(rootWindow.width-firstColumn.width)/2:0
    height: parent.height
    sourceComponent: Item{
        Rectangle{
            anchors.right: parent.right
            height: parent.height
            color: appStyle.primaryColor
            width: 2*size1W
            visible: nRow === 3
        }
    }
}
