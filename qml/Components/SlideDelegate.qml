import QtQuick 2.14
import QtQuick.Controls.Material 2.14
import QtGraphicalEffects 1.14

Item {
    id: container

    // public:

    property color contentRectangleColor: "transparent"
    property color contentRectanglePressedColor: appStyle.primaryColor

    property color deleteButtonColor: "#FF0000"
    property color deleteButtonPressedColor: appStyle.textColor === "#000000"?"#10000000":"#80000000"
    property int deleteButtonWidth: 50

    property int hideOrShowAnimationDuration: 200
    property int slidingDistanceTriggerChangeState: 5

    signal deleteButtonCanceled()
    signal deleteButtonClicked()
    signal deleteButtonHidden()
    signal deleteButtonPressed()
    signal deleteButtonReleased()
    signal deleteButtonShown()

    signal editButtonCanceled()
    signal editButtonClicked()
    signal editButtonHidden()
    signal editButtonPressed()
    signal editButtonReleased()
    signal editButtonShown()

    signal contentRectangleCanceled()
    signal contentRectangleClicked(var mouse)
    signal contentRectangleDoubleClicked(var mouse)
    signal contentRectangleEntered()
    signal contentRectangleExited()
    signal contentRectanglePositionChanged(var mouse)
    signal contentRectanglePressAndHold(var mouse)
    signal contentRectanglePressed(var mouse)
    signal contentRectangleReleased(var mouse)
    signal contentRectangleWheel(var wheel)

    function hideDeleteButton(withAnimation) {
        if (withAnimation) {
            contentRect.state = "hidden"
        } else {
            contentRect.x = 0
        }
    }

    function showDeleteButton(withAnimation) {
        if (withAnimation) {
            contentRect.state = "shownDelete"
        } else {
            contentRect.x = 0 - deleteButton.width
        }
    }
    function showEditButton(withAnimation) {
        if (withAnimation) {
            contentRect.state = "shownEdit"
        } else {
            contentRect.x = editButton.width
        }
    }

    // private:

//    onContentRectangleClicked: {
//        if (ListView.view !== null) {
//            ListView.view.currentItem.hideDeleteButton(true)
//            ListView.view.currentIndex = index
//        }
//    }

    onDeleteButtonShown: {
        if (ListView.view !== null) {
            if (ListView.view.currentItem !== null) {
                ListView.view.currentItem.hideDeleteButton(true)
            }
            ListView.view.currentIndex = index
        }
    }
    onEditButtonShown: {
        if (ListView.view !== null) {
            if (ListView.view.currentItem !== null) {
                ListView.view.currentItem.hideDeleteButton(true)
            }
            ListView.view.currentIndex = index
        }
    }

    Rectangle {
        id: deleteButton
        width: parent.deleteButtonWidth
        height: parent.height

        color: deleteButtonMouseArea.pressed ? deleteButtonPressedColor
                                             : "transparent"
        anchors.left: contentRect.right
        opacity: Math.max((0 - contentRect.x) / deleteButton.width, 0)

        Rectangle{
            width: parent.height > 25 ? 30 : 20
            height: width
            radius: width
            color: "transparent"
            anchors.centerIn: parent
            Image {
                id: trashIcon
                source: "qrc:/Icons/trashIcon.svg"
                width: parent.width-5
                height: width
                anchors.centerIn: parent
                sourceSize.width: width*2
                sourceSize.height: height*2
            }
            ColorOverlay{
                anchors.fill: trashIcon
                source:trashIcon
                color:Material.color(primaryColor)
                transform:rotation
                antialiasing: true
            }
        }

        MouseArea {
            id: deleteButtonMouseArea
            anchors.fill: parent
            onCanceled: {deleteButtonCanceled()}
            onClicked: {deleteButtonClicked()}
            onPressed: {deleteButtonPressed()}
            onReleased: {deleteButtonReleased()}
        }
    }

    Rectangle {
        id: editButton
        width: parent.deleteButtonWidth
        height: parent.height

        color: editButtonMouseArea.pressed ? deleteButtonPressedColor
                                             : "transparent"
        anchors.right: contentRect.left
        opacity: Math.max((contentRect.x) / editButton.width, 0)

        Rectangle{
            width: parent.height > 25 ? 30 : 20
            height: width
            radius: width
            color: "transparent"
            anchors.centerIn: parent
            Image {
                id: editImage
                source: "qrc:/Icons/EditIcon.svg"
                width: parent.width-5
                height: width
                anchors.centerIn: parent
                sourceSize.width: width*2
                sourceSize.height: height*2
                antialiasing: true
                visible: false
            }
            ColorOverlay{
                anchors.fill: editImage
                source:editImage
                color:Material.color(primaryColor)
                transform:rotation
                antialiasing: true
            }
        }

        MouseArea {
            id: editButtonMouseArea
            anchors.fill: parent
            onCanceled: {editButtonCanceled()}
            onClicked: {editButtonClicked()}
            onPressed: {editButtonPressed()}
            onReleased: {editButtonReleased()}
        }
    }


    Rectangle {
        id: contentRect
        width: parent.width
        height: parent.height
        color: contentMouseArea.pressed ? contentRectanglePressedColor
                                        : contentRectangleColor
        state: "hidden"

        states: [
            State {
                name: "hidden"
                PropertyChanges { target: contentRect; x: 0 }
            },State {
                name: "shownDelete"
                PropertyChanges { target: contentRect; x: 0-deleteButton.width }
            },State {
                name: "shownEdit"
                PropertyChanges { target: contentRect; x: editButton.width }
            }
        ]

        onStateChanged: {
            if ("hidden" == state)
            {
                deleteButtonHidden()
            }
            else if ("shownDelete" == state)
            {
                deleteButtonShown()
            }
            else if ("shownEdit" == state)
            {
                editButtonShown()
            }
        }

        transitions: Transition {
            NumberAnimation { properties: "x"; duration: hideOrShowAnimationDuration }
        }

        MouseArea {
            id: contentMouseArea
            anchors.fill: parent
            drag.target: contentRect
            drag.axis: Drag.XAxis
            drag.maximumX: editButton.width
            drag.minimumX: -deleteButton.width

            readonly property bool draging: drag.active
            onDragingChanged: {
                if (!draging) {
                    if(contentRect.state == "hidden")
                    {
                        if(contentRect.x < (0-slidingDistanceTriggerChangeState))
                        {
                            contentRect.state = "shownDelete"
                        }
                        else if (contentRect.x > slidingDistanceTriggerChangeState)
                        {
                            contentRect.state = "shownEdit"
                        }
                        else
                        {
                            contentRect.state = "hidden"
                        }
                    }
                    else if(contentRect.state == "shownDelete")
                    {
                        if(contentRect.x > (slidingDistanceTriggerChangeState - deleteButton.width))
                        {
                            contentRect.state = "hidden"
                        }
                        else
                        {
                            contentRect.state = "shownDelete"
                        }
                    }
                    else if (contentRect.state == "shownEdit")
                    {
                        if (contentRect.x < (slidingDistanceTriggerChangeState + editButton.width))
                        {
                            contentRect.state = "hidden"
                        }
                        else
                        {
                            contentRect.state = "shownEdit"
                        }
                    }
                }
            }

            onCanceled: {contentRectangleCanceled()}
            onClicked: {contentRectangleClicked(mouse)}
            onDoubleClicked: {contentRectangleDoubleClicked(mouse)}
            onEntered: {contentRectangleEntered()}
            onExited: {contentRectangleExited()}
            onPositionChanged: {contentRectanglePositionChanged(mouse)}
            onPressAndHold: {contentRectanglePressAndHold(mouse)}
            onReleased: {contentRectangleReleased(mouse)}
            onWheel: {contentRectangleWheel(wheel)}
        }
    }

    // private:
    default property alias __content: contentMouseArea.data

}
