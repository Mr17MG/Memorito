import QtQuick 2.14
import QtQuick.Controls 2.14

Item{

    property real lastValue: 0
    property bool onlySquare: true
    property bool hasSquareLine: true
    property int rulersSize: 18
    property alias selectedArea: selectedArea
    property alias imageFlickable:imageFlickable
    property alias mainImage:mainImage
    property string imageSource: ""

    function setZoom(value,mouseX,mouseY)
    {
        value = lastValue+value
        if(value <= 2 && value >= -2)
        {
            let scale = 1+(value-lastValue)
            mainImage.width=mainImage.width*(scale).toFixed(2)
            mainImage.height=mainImage.height*(scale).toFixed(2)
            lastValue=value.toFixed(2)
        }
    }
    Item{
        id:imageArea
        anchors.centerIn: parent
        width: height
        height: parent.height
        Flickable{
            id: imageFlickable
            anchors.fill: parent
            clip: true

            contentWidth: mainImage.width
            contentHeight: mainImage.height

            onWidthChanged: {
                if(mainImage.width < imageArea.width)
                    mainImage.width = imageArea.width

                if(selectedArea.width === 0 && imageArea.width>0)
                    selectedArea.width = width/2
            }
            onHeightChanged: {
                if(mainImage.height < imageArea.height)
                    mainImage.height = imageArea.height

                if(selectedArea.height === 0 && imageArea.height>0)
                    selectedArea.height = height/2
            }

            ScrollBar.vertical  : ScrollBar {id:vScrollBar}
            ScrollBar.horizontal: ScrollBar {id:hScrollbar }
            Keys.onUpPressed    : vScrollBar.decrease()
            Keys.onLeftPressed  : hScrollbar.decrease()
            Keys.onDownPressed  : vScrollBar.increase()
            Keys.onRightPressed : hScrollbar.increase()


            onContentYChanged: {
                if(contentY<0 || contentHeight < imageArea.height)
                    contentY = 0
                else if(contentY > (contentHeight - imageArea.height))
                    contentY = contentHeight - imageArea.height
            }
            onContentXChanged: {
                if(contentX<0 || contentWidth < imageArea.width)
                    contentX = 0
                else if(contentX > (contentWidth-imageArea.width))
                    contentX = (contentWidth-imageArea.width)
            }

            Image {
                id: mainImage
                width: imageArea.width
                height: imageArea.height
                onWidthChanged: {
                    if(width < imageArea.width)
                        width = imageArea.width
                }
                onHeightChanged: {
                    if(height < imageArea.height)
                        height = imageArea.height
                }

                clip:true
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                source: imageSource
            }
        }
        Rectangle{
            id:a
            anchors{
                right: selectedArea.left
                left: imageArea.left
                top: imageArea.top
                bottom: imageArea.bottom
            }
            color:"black"
            opacity: 0.4
        }

        Rectangle{
            id:c
            anchors{
                left : selectedArea.right
                right: imageArea.right
                top: imageArea.top
                bottom: imageArea.bottom
            }
            color:"black"
            opacity: 0.4
        }

        Rectangle{
            id:b
            anchors{
                bottom: selectedArea.top
                top: imageArea.top
                right: selectedArea.right
                left: selectedArea.left
            }
            color:"black"
            opacity: 0.4
        }

        Rectangle{
            id:d
            anchors{
                top: selectedArea.bottom
                bottom: imageArea.bottom
                left: selectedArea.left
                right: selectedArea.right
            }
            color:"black"
            opacity: 0.4
        }

        Rectangle {
            id:selectedArea
            width: imageArea.width  / 2
            height: imageArea.width / 2
            color: "transparent"
            border { width: 2; color: "white"}
            MouseArea {     // drag mouse area
                anchors.fill: parent
                cursorShape: Qt.DragMoveCursor
                drag{
                    target: selectedArea
                    smoothed: true
                }
                onWheel: {
                    var delta = wheel.angleDelta.y/120;
                    if(delta > 0)
                        setZoom(0.1,wheel.x,wheel.y)
                    else
                        setZoom(-0.1,wheel.x,wheel.y)
                    imageFlickable.forceActiveFocus()
                }
            }
            Component.onCompleted: {
                x = (imageArea.width  - selectedArea.width ) /2
                y = (imageArea.height - selectedArea.height) /2
            }
            onXChanged: {
                if(x < 0)
                    x = 0
                else if(x+selectedArea.width > (Math.min(mainImage.width,imageArea.width)))
                {
                    x = (Math.min(mainImage.width,imageArea.width)) - selectedArea.width
                }
            }
            onYChanged: {
                if( y < 0)
                    y = 0
                else if(y+selectedArea.height > imageArea.height)
                    y = imageArea.height - selectedArea.height
            }

            onWidthChanged: {
                if(x+width > (Math.min(mainImage.width,imageArea.width)) )
                {
                    width = (Math.min(mainImage.width,imageArea.width))-x
                }

                if(onlySquare)
                    height = width
            }
            onHeightChanged: {
                if(y+height > (Math.min(mainImage.height,imageArea.height)))
                {
                    height = (Math.min(mainImage.height,imageArea.height))-y
                }
                if(onlySquare)
                    width = height
            }

            Rectangle{ width  : parent.width  ; height: 2; y: parent.height /3    ; x:0 ; color: "white"; opacity: 0.5 ; visible:hasSquareLine}
            Rectangle{ width  : parent.width  ; height: 2; y: parent.height /3 *2 ; x:0 ; color: "white"; opacity: 0.5 ; visible:hasSquareLine}
            Rectangle{ height : parent.height ; width:  2; x: parent.width  /3    ; y:0 ; color: "white"; opacity: 0.5 ; visible:hasSquareLine}
            Rectangle{ height : parent.height ; width:  2; x: parent.width  /3 *2 ; y:0 ; color: "white"; opacity: 0.5 ; visible:hasSquareLine}

            Canvas {
                id:canvas
                width: selectedArea.width
                height: selectedArea.height
                opacity: 0.4
                onAvailableChanged: {
                    let maskcontext = canvas.getContext('2d');
                    canvas.markDirty()
                    maskcontext.fillStyle = "black";
                    if(onlySquare)
                        maskcontext.arc(parent.width/2,parent.width/2,parent.width/2,parent.width/2,Math.PI);
                    else
                        maskcontext.fillRect(0, 0, canvas.width, canvas.height);
                    maskcontext.fillRect(0, 0, canvas.width, canvas.height);
                    maskcontext.globalCompositeOperation = 'xor';


                    maskcontext.fill();
                }
            }


            Rectangle {
                id:leftRect
                width: rulersSize
                height: rulersSize
                radius: rulersSize
                color: "#ebebeb"
                anchors.horizontalCenter: parent.left
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    anchors.fill: parent
                    drag{ target: parent; axis: Drag.XAxis; smoothed: true }
                    onMouseXChanged: {
                        if(drag.active){
                            if(selectedArea.width - mouseX > 50 && selectedArea.x + mouseX > 0 && selectedArea.x + mouseX < mainImage.width)
                            {
                                selectedArea.width = selectedArea.width - mouseX
                                selectedArea.x = selectedArea.x + mouseX
                            }
                        }
                    }
                }
            }
            Rectangle {
                id:rightRect
                width: rulersSize
                height: rulersSize
                radius: rulersSize
                color: "#ebebeb"
                anchors.horizontalCenter: parent.right
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    anchors.fill: parent
                    drag{ target: parent; axis: Drag.XAxis; smoothed: true }
                    onMouseXChanged: {
                        if(drag.active){
                            if(selectedArea.width + mouseX > 50 && selectedArea.width + mouseX < mainImage.width - selectedArea.x)
                            {
                                selectedArea.width = selectedArea.width + mouseX
                            }
                        }
                    }
                }
            }
            Rectangle {
                id:topRect
                width: rulersSize
                height: rulersSize
                radius: rulersSize
                x: parent.x / 2
                y: 0
                color: "#ebebeb"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.top

                MouseArea {
                    anchors.fill: parent
                    drag{ target: parent; axis: Drag.YAxis; smoothed: true }
                    onMouseYChanged: {
                        if(drag.active){
                            if(selectedArea.height - mouseY > 50 && selectedArea.y + mouseY > 0)
                            {
                                selectedArea.height = selectedArea.height - mouseY
                                selectedArea.y = selectedArea.y + mouseY
                            }
                        }
                    }
                }
            }
            Rectangle {
                id:bottomRect
                width: rulersSize
                height: rulersSize
                radius: rulersSize
                x: parent.x / 2
                y: parent.y
                color: "#ebebeb"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.bottom

                MouseArea {
                    anchors.fill: parent
                    drag{ target: parent; axis: Drag.YAxis; smoothed: true }
                    onMouseYChanged: {
                        if(drag.active){
                            if(selectedArea.height + mouseY > 50 && selectedArea.height + mouseY < mainImage.height - selectedArea.y)
                            {
                                selectedArea.height = selectedArea.height + mouseY
                            }
                        }
                    }
                }
            }
            Rectangle {
                id:rightBottomRect
                width: rulersSize
                height: rulersSize
                radius: rulersSize
                x: parent.x / 2
                y: parent.y
                color: "#ebebeb"
                anchors.horizontalCenter: parent.right
                anchors.verticalCenter: parent.bottom
                visible: !onlySquare
                MouseArea {
                    anchors.fill: parent
                    drag{ target: parent; axis: Drag.XAndYAxis; smoothed: true }
                    onMouseYChanged: {
                        if(drag.active){
                            if(selectedArea.height + mouseY > 50 && selectedArea.height + mouseY < mainImage.height - selectedArea.y)
                                selectedArea.height = selectedArea.height + mouseY
                        }
                    }
                    onMouseXChanged: {
                        if(drag.active){
                            if(selectedArea.width + mouseX > 50 && selectedArea.width + mouseX < mainImage.width - selectedArea.x)
                                selectedArea.width = selectedArea.width + mouseX
                        }
                    }
                }
            }
            Rectangle {
                id:leftBottomRect
                width: rulersSize
                height: rulersSize
                radius: rulersSize
                x: parent.x / 2
                y: parent.y
                color: "#ebebeb"
                anchors.horizontalCenter: parent.left
                anchors.verticalCenter: parent.bottom
                visible: !onlySquare
                MouseArea {
                    anchors.fill: parent
                    drag{ target: parent; axis: Drag.XAndYAxis; smoothed: true }
                    onMouseYChanged: {
                        if(drag.active){
                            if((selectedArea.height + mouseY > 50) && (selectedArea.height + mouseY < mainImage.height - selectedArea.y))
                            {
                                selectedArea.height = selectedArea.height + mouseY
                                selectedArea.y = selectedArea.y + mouseY
                            }

                        }
                    }
                    onMouseXChanged: {
                        if(drag.active){
                            if((selectedArea.width + mouseX > 50) && v(isi_area.width + mouseX < mainImage.width - selectedArea.x))
                            {
                                selectedArea.width = selectedArea.width + mouseX
                                selectedArea.x = selectedArea.x + mouseX
                            }
                        }
                    }
                }
            }
            Rectangle {
                id:leftTopRect
                width: rulersSize
                height: rulersSize
                radius: rulersSize
                x: parent.x / 2
                y: parent.y
                color: "#ebebeb"
                anchors.horizontalCenter: parent.left
                anchors.verticalCenter: parent.top
                visible: !onlySquare
                MouseArea {
                    anchors.fill: parent
                    drag{ target: parent; axis: Drag.XAndYAxis }
                    onMouseYChanged: {
                        if(drag.active){
                            if(selectedArea.height - mouseY > 50 && selectedArea.y + mouseY > 0)
                            {
                                selectedArea.height = selectedArea.height - mouseY
                                selectedArea.y = selectedArea.y + mouseY
                            }
                        }
                    }
                    onMouseXChanged: {
                        if(drag.active){
                            if(selectedArea.width - mouseX > 50 && selectedArea.x + mouseX > 0 && selectedArea.x + mouseX < mainImage.width)
                            {
                                selectedArea.width = selectedArea.width - mouseX
                                selectedArea.x = selectedArea.x + mouseX
                            }
                        }
                    }
                }
            }
            Rectangle {
                id:rightTopRect
                width: rulersSize
                height: rulersSize
                radius: rulersSize
                x: parent.x / 2
                y: parent.y
                color: "#ebebeb"
                anchors.horizontalCenter: parent.right
                anchors.verticalCenter: parent.top
                visible: !onlySquare

                MouseArea {
                    anchors.fill: parent
                    drag{ target: parent; axis: Drag.XAndYAxis }
                    onMouseYChanged: {
                        if(drag.active){
                            if(selectedArea.height - mouseY > 50 && selectedArea.y + mouseY > 0)
                            {
                                selectedArea.height = selectedArea.height - mouseY
                                selectedArea.y = selectedArea.y + mouseY
                            }
                        }
                    }
                    onMouseXChanged: {
                        if(drag.active){
                            if(selectedArea.width + mouseX > 50 && selectedArea.width + mouseX < mainImage.width - selectedArea.x)
                                selectedArea.width = selectedArea.width + mouseX
                        }
                    }
                }
            }

        }
    }

}
