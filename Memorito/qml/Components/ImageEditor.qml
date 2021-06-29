import QtQuick 2.15
import QtQuick.Controls 2.15
import Global 1.0
import MTools 1.0

Item{
    MTools{id:myTools}
    property real lastValue: 0
    property bool onlySquare: true
    property bool hasSquareLine: true
    property int rulersSize: 30*AppStyle.size1W
    property alias selectedArea: selectedArea
    property alias imageFlickable:imageFlickable
    property alias mainImage:mainImage
    property string imageSource: ""
    property string rotateCheckImage: ""

    function cameInToPage(object){
        let rSource = myTools.checkOrientation(imageSource);
        if(rSource !== ""){
            rotateCheckImage="file://"+rSource
        }
        else {
            rotateCheckImage= imageSource
        }
        imageSource=""
    }

    function setZoom(value,isPinch = false)
    {
        if(!isPinch)
            value = lastValue+value
        if(isPinch)
        {
            if(mainImage.width*(value).toFixed(2) <selectedArea.width || mainImage.height*(value).toFixed(2) < selectedArea.height
                    ||  mainImage.height*(value).toFixed(2) > imageArea.height*2 || mainImage.width*(value).toFixed(2)>imageArea.width*2)
                return false
            mainImage.width=mainImage.width*(value).toFixed(2)
            mainImage.height=mainImage.height*(value).toFixed(2)
            return true
        }
        else if(value <= 2 && value >= -2)
        {
            let scale = 1+(value-lastValue)
            if(mainImage.width*(scale).toFixed(2) <selectedArea.width || mainImage.height*(scale).toFixed(2) < selectedArea.height)
                return false
            mainImage.width=mainImage.width*(scale).toFixed(2)
            mainImage.height=mainImage.height*(scale).toFixed(2)
            lastValue= parseFloat(value.toFixed(2))
            return true
        }
    }
    Item{
        id:imageArea
        width: Math.min(height,parent.width)
        height: Math.min(parent.height,parent.width) - (btnArea.height+ 30*AppStyle.size1W)
        anchors{
            top: parent.top
            bottom: btnArea.top
            horizontalCenter: parent.horizontalCenter
        }

        Flickable{
            id: imageFlickable
            anchors.fill: parent
            clip: true

            contentWidth: mainImage.width
            contentHeight: mainImage.height
            onWidthChanged: {
                if(selectedArea.width === 0 && imageArea.width>0)
                    selectedArea.width = width/2
            }
            onHeightChanged: {
                if(selectedArea.height === 0 && imageArea.height>0)
                    selectedArea.height = height/2
            }

            ScrollBar.vertical  : ScrollBar { id:vScrollBar }
            ScrollBar.horizontal: ScrollBar { id:hScrollbar }
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
                asynchronous: true
                source: rotateCheckImage
                onStatusChanged:  {
                    if(status === Image.Ready)
                    {
                        if(sourceSize.width === sourceSize.height)
                        {
                            mainImage.width  = imageArea.width
                            mainImage.height = imageArea.height
                        }
                        else{
                            let scale =0
                            while(true){
                                scale =0.9
                                if((parseFloat(mainImage.width*(scale).toFixed(2)) < imageArea.width) && (parseFloat(mainImage.height*(scale).toFixed(2)) < imageArea.height))
                                    break

                                mainImage.width=   parseFloat(mainImage.width*(scale).toFixed(2))
                                mainImage.height=  parseFloat(mainImage.height*(scale).toFixed(2))
                            }
                            selectedArea.width = mainImage.width
                        }
                    }
                }
            }
        }

        Loader{
            active: true
            asynchronous: true
            anchors{
                right: selectedArea.left
                left: imageArea.left
                top: imageArea.top
                bottom: imageArea.bottom
            }
            sourceComponent: Rectangle{ color:"black"; opacity: 0.6 }
        }

        Loader{
            active: true
            asynchronous: true
            anchors{
                left : selectedArea.right
                right: imageArea.right
                top: imageArea.top
                bottom: imageArea.bottom
            }
            sourceComponent: Rectangle{ color:"black"; opacity: 0.6 }

        }

        Loader{
            active: true
            asynchronous: true
            anchors{
                bottom: selectedArea.top
                top: imageArea.top
                right: selectedArea.right
                left: selectedArea.left
            }
            sourceComponent: Rectangle{ color:"black"; opacity: 0.6 }

        }

        Loader{
            active: true
            asynchronous: true
            anchors{
                top: selectedArea.bottom
                bottom: imageArea.bottom
                left: selectedArea.left
                right: selectedArea.right
            }
            sourceComponent: Rectangle{ color:"black"; opacity: 0.6 }
        }

        Rectangle {
            id:selectedArea
            width: mainImage.width
            height: width
            color: "transparent"
            border { width: 4*AppStyle.size1W; color: "white"}
            MouseArea {     // drag mouse area
                enabled: !pinchArea.enabled
                anchors.fill: parent
                cursorShape: Qt.DragMoveCursor
                drag{
                    target: selectedArea
                    smoothed: true
                }
                onWheel: {
                    var delta = wheel.angleDelta.y/120;
                    if(delta > 0)
                        setZoom(0.1)
                    else
                        setZoom(-0.1)
                    imageFlickable.forceActiveFocus()
                }
            }

            PinchArea{
                id: pinchArea
                enabled: Qt.platform.os === "android" || Qt.platform.os === "ios"
                anchors.fill: parent
                pinch.target: selectedArea
                property real lastScale: 0
                onPinchUpdated: {
                    if(lastScale<pinch.scale)
                    {
                        setZoom(pinch.scale/1,true)
                        lastScale = pinch.scale
                    }
                    else
                    {
                        setZoom(-pinch.scale/1,true)
                        lastScale = -pinch.scale
                    }
                }
                MouseArea{
                    anchors.fill: parent
                    drag{
                        target: selectedArea
                        smoothed: true
                    }
                }
            }

            Component.onCompleted: {
                x = 0
                y = 0
            }
            onXChanged: {
                if(mainImage.status !== Image.Ready)
                    return
                if(x < 0)
                    x = 0
                else if(x+selectedArea.width > Math.min(mainImage.width,imageArea.width))
                {
                    x = Math.min(mainImage.width,imageArea.width) - selectedArea.width
                }
            }
            onYChanged: {
                if(mainImage.status !== Image.Ready)
                    return
                if( y < 0)
                    y = 0
                else if(y+selectedArea.height > Math.min(mainImage.height,imageArea.height))
                    y = Math.min(mainImage.height,imageArea.height) - selectedArea.height

            }

            onWidthChanged: {
                if(mainImage.status !== Image.Ready)
                    return
                if(x+width > Math.min(mainImage.width,imageArea.width) )
                {
                    width = Math.min(mainImage.width,imageArea.width)-x
                }

                if(onlySquare)
                    height = width
            }
            onHeightChanged: {
                if(mainImage.status !== Image.Ready)
                    return
                if(y+height > Math.min(mainImage.height,imageArea.height) )
                {
                    height = Math.min(mainImage.height,imageArea.height)-y
                }
                if(onlySquare)
                    width = height
            }

            Rectangle{ width  : parent.width  ; height: 2*AppStyle.size1W; y: parent.height /3    ; x:0 ; color: "white"; opacity: 0.5 ; visible:hasSquareLine}
            Rectangle{ width  : parent.width  ; height: 2*AppStyle.size1W; y: parent.height /3 *2 ; x:0 ; color: "white"; opacity: 0.5 ; visible:hasSquareLine}
            Rectangle{ height : parent.height ; width:  2*AppStyle.size1W; x: parent.width  /3    ; y:0 ; color: "white"; opacity: 0.5 ; visible:hasSquareLine}
            Rectangle{ height : parent.height ; width:  2*AppStyle.size1W; x: parent.width  /3 *2 ; y:0 ; color: "white"; opacity: 0.5 ; visible:hasSquareLine}

            Loader{
                active: rotateCheckImage !== ""
                asynchronous: true
                sourceComponent: Canvas {
                    id:canvas
                    width: selectedArea.width
                    height: selectedArea.height
                    opacity: 0.6
                    onAvailableChanged: {
                        canvas.markDirty()
                        let maskcontext = canvas.getContext('2d');
                        maskcontext.fillStyle = "black";
                        if(onlySquare)
                            maskcontext.arc(parent.width/2,parent.width/2,parent.width/2,parent.width/2,Math.PI);
                        else
                            maskcontext.fillRect(0, 0, canvas.width, canvas.height);
                        maskcontext.fillRect(0, 0, canvas.width, canvas.height);
                        maskcontext.globalCompositeOperation = 'xor';

                        canvas.markDirty()

                        maskcontext.fill();
                    }
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

    Loader{
        id:btnArea
        active: true
        asynchronous: true
        width: parent.width
        height: 100*AppStyle.size1W
        anchors{
            bottom: parent.bottom
            bottomMargin: 15*AppStyle.size1W
            horizontalCenter: parent.horizontalCenter
        }
        sourceComponent: Item { Flow
            {
                spacing:20*AppStyle.size1W
                anchors{ centerIn: parent }
                layoutDirection: Qt.RightToLeft

                AppButton{
                    id: submitBtn
                    radius: width
                    height: width
                    width: 70*AppStyle.size1W
                    icon{
                        source: "qrc:/tick.svg"
                        color: AppStyle.textOnPrimaryColor
                        width: 40*AppStyle.size1W
                    }
                    display: AppButton.IconOnly
                    onClicked: {
                        let source = "file://" + myTools.cropImageAndSave(rotateCheckImage,"profile-"+User.id,
                                                                          (selectedArea.x + imageFlickable.contentX),
                                                                          (selectedArea.y + imageFlickable.contentY),
                                                                          selectedArea.width,
                                                                          selectedArea.height,
                                                                          mainImage.width,
                                                                          mainImage.height
                                                                          )

                        UsefulFunc.mainStackPop({"profile_source":source,"base64":myTools.encodeToBase64(source)})
                        myTools.deleteFile("tempSelection","jpeg")
                    }
                }
                AppButton{
                    id: zoomInBtn
                    radius: width
                    height: width
                    width: 70*AppStyle.size1W
                    icon{
                        source: "qrc:/zoom-in.svg"
                        color: AppStyle.textOnPrimaryColor
                        width: 40*AppStyle.size1W
                    }
                    display: AppButton.IconOnly
                    onClicked: {
                        setZoom(0.3)
                    }
                }
                AppButton{
                    id: zoomOutBtn
                    radius: width
                    height: width
                    width: 70*AppStyle.size1W
                    icon{
                        source: "qrc:/zoom-out.svg"
                        color: AppStyle.textOnPrimaryColor
                        width: 40*AppStyle.size1W
                    }
                    display: AppButton.IconOnly
                    onClicked: {
                        setZoom(-0.2)
                    }
                }
                AppButton{
                    id: discardBtn
                    radius: width
                    height: width
                    width: 70*AppStyle.size1W
                    icon{
                        source: "qrc:/close.svg"
                        color: AppStyle.textOnPrimaryColor
                        width: 30*AppStyle.size1W
                    }
                    display: AppButton.IconOnly
                    onClicked: {
                        UsefulFunc.mainStackPop()
                    }
                }
            }
        }
    }
}
