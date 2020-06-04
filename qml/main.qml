import QtQuick 2.14 // Require For MouseArea and other
import QtQuick.Window 2.14 // Require For Screen
import QtQuick.Controls 2.14 // Require For Drawer and other
import QtQuick.Controls.Material 2.14 // // Require For Material Theme
import Qt.labs.settings 1.1 // Require For appSettings

ApplicationWindow {
    id:rootWindow
    visible: true
    title: qsTr("مموریتو")
    Settings{id:appSetting}

    // ApplicationWindow Settings
    width: Qt.platform.os === "android" || Qt.platform.os === "ios"?Screen.width:appSetting.value("width" ,640)
    height: Qt.platform.os === "android" || Qt.platform.os === "ios"?Screen.height:appSetting.value("height",480)

    minimumWidth: Screen.width/5<380?380:Screen.width/5
    minimumHeight: Screen.height/3<480?480:Screen.height/3

    x:Qt.platform.os === "android" || Qt.platform.os === "ios"?0:appSetting.value("appX",40)
    y:Qt.platform.os === "android" || Qt.platform.os === "ios"?0:appSetting.value("appY",40)

    onClosing: {
        if(Qt.platform.os !== "android" || Qt.platform.os !== "ios")
        {
            appSetting.setValue("appX",rootWindow.x)
            appSetting.setValue("appY",rootWindow.y)

            appSetting.setValue("width", rootWindow.width)
            appSetting.setValue("height",rootWindow.height)
        }
    }

    // Multi Language
    property bool ltr: Number(appSetting.value("language",translator.getLanguages().FA)) === translator.getLanguages().ENG
    LayoutMirroring.enabled: ltr
    LayoutMirroring.childrenInherit: true

    //Responsive UI
    property real size1W: uiFunctions.getWidthSize(1,Screen)
    property real size1H: uiFunctions.getHeightSize(1,Screen)
    property real size1F: uiFunctions.getFontSize(1,Screen)

    property int nRow : uiFunctions.checkDisplayForNumberofRows(Screen)
    property real firstRowMinSize: 60*size1W
    property real firstRowMaxWidth: nRow ==2?rootWindow.width*2.5/8:rootWindow.width*1.80/8

    UiFunctions { id : uiFunctions }
    onWidthChanged: {
        if(rootWindow.width>Screen.width/3 && drawerLoader.active && drawerLoader.item.visible)
        {
            drawerLoader.item.close()
            drawerLoader.item.modal=false
        }

        if(!firstRow.active)
            firstRow.width = 0
        else if(firstRow.width  < firstRowMinSize )
            firstRow.width = firstRowMinSize
        else if(firstRow.width > firstRowMaxWidth)
            firstRow.width = firstRowMaxWidth
    }

    //Header
    header : AppHeader{}

    //Drawer
    Loader{
        id:drawerLoader
        active: nRow===1
        width: rootWindow.width*2/3
        height: mainRow.height
        y: header.height

        sourceComponent: Drawer{
            background.layer.enabled:false
            DrawerBody{}
            y: header.height
            height: drawerLoader.height
            width: drawerLoader.width
            edge: ltr?Qt.LeftEdge:Qt.RightEdge
            dragMargin:30*size1W
        }
    }


    Row {
        id:mainRow
        layoutDirection: Qt.RightToLeft
        height: parent.height
        Loader{
            id:firstRow
            active: nRow>1
            width: nRow===1?0:firstRowMinSize
            height: parent.height
            onActiveChanged: {
                if(!active)
                    width = 0
                else width = firstRowMinSize
            }
            property color background: "#cccccc"

            sourceComponent: Item{
                DrawerBody{id:drawer;background:firstRow.background }
                Loader{
                    active: !ltr
                    width: 5*size1W
                    height: parent.height
                    anchors.left: parent.left
                    sourceComponent:Rectangle{
                        anchors.fill: parent
                        color: drawer.background
                        Image{
                            anchors.centerIn: parent
                            width: 15*size1W
                            height: width
                            source: "qrc:/dots.svg"
                            sourceSize.width: width*2
                            sourceSize.height: height*2
                        }

                        MouseArea {
                            anchors.fill: parent
                            drag.target: parent
                            drag.axis: Drag.XAxis
                            cursorShape: Qt.SizeHorCursor
                            onClicked: {
                                if(firstRow.width === firstRowMaxWidth)
                                    firstRow.width = firstRowMinSize
                                else if(firstRow.width >= firstRowMinSize)
                                    firstRow.width = firstRowMaxWidth
                            }
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
                    active: ltr && firstRow.active
                    width: 5*size1W
                    height: parent.height
                    anchors.right: parent.right
                    sourceComponent:Rectangle{
                        anchors.fill: parent
                        color: firstRow.background
                        Image{
                            anchors.centerIn: parent
                            width: 15*size1W
                            height: width
                            source: "qrc:/dots.svg"
                            sourceSize.width: width*2
                            sourceSize.height: height*2
                        }
                        MouseArea {
                            anchors.fill: parent
                            drag.target: parent
                            drag.axis: Drag.XAxis
                            cursorShape: Qt.SizeHorCursor
                            onClicked: {
                                if(firstRow.width === firstRowMaxWidth)
                                    firstRow.width = firstRowMinSize
                                else if(firstRow.width >= firstRowMinSize)
                                    firstRow.width = firstRowMaxWidth
                            }

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
                    text: qsTr("تغییر زبان")
                    onClicked: {
                        ltr= !ltr
                        if(!ltr)
                        {
                            translator.updateLanguage(translator.getLanguages().FA);
                            appSetting.setValue("language",translator.getLanguages().FA)
                        }
                        else {
                            translator.updateLanguage(translator.getLanguages().ENG);
                            appSetting.setValue("language",translator.getLanguages().ENG)

                        }
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
