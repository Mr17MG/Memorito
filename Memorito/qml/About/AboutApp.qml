import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import Components 1.0
import Global 1.0
import MTools 1.0

Item {
    MTools{id:mTools}
    Rectangle {
        id: container
        clip: true
        anchors{
            fill: parent
            margins: 25*AppStyle.size1W
        }
        color: "transparent"
        radius: 30*AppStyle.size1W
        border{
            color: Material.color(AppStyle.primaryInt)
            width: 3*AppStyle.size1W
        }
        Rectangle{
            radius:container.radius
            anchors.fill: parent
            color: Material.color(AppStyle.primaryInt,Material.Shade50)
            opacity: AppStyle.appTheme?0.1:0.5
        }
        Flickable{
            id:flick
            maximumFlickVelocity: AppStyle.size1H*3000
            anchors{
                topMargin: 25*AppStyle.size1W
                bottomMargin: 25*AppStyle.size1W
                leftMargin: 15*AppStyle.size1W
                rightMargin: 15*AppStyle.size1W
            }
            Keys.onUpPressed: contentY-=50
            Keys.onDownPressed: contentY+=50
            Keys.onRightPressed: forwardBtn.clicked()
            Keys.onLeftPressed: backBtn.clicked()
            flickableDirection: Flickable.VerticalFlick
            onContentYChanged: {
                if(contentY<0 || contentHeight < flick.height)
                    contentY = 0
                else if(contentY > (contentHeight-flick.height))
                    contentY = contentHeight-flick.height
            }
            onContentXChanged: {
                if(contentX<0 || contentWidth < flick.width)
                    contentX = 0
                else if(contentX > (contentWidth-flick.width))
                    contentX = (contentWidth-flick.width)
            }
            clip: true
            anchors.fill: parent
            contentHeight: msg.height + 100*AppStyle.size1W


            ScrollBar.vertical: ScrollBar {
                id:listScroll
                hoverEnabled: true
                height: parent.height
                orientation: Qt.Vertical
                policy: ScrollBar.AlwaysOn
                width:  hovered || pressed ? 20*AppStyle.size1W
                                           : 10*AppStyle.size1W
                anchors{
                    right: parent.right
                }
                contentItem: Rectangle {
                    radius: parent.pressed || parent.hovered ? 20 * AppStyle.size1W
                                                             : 8  * AppStyle.size1W
                    color: parent.pressed ? Material.color( AppStyle.primaryInt , Material.Shade900 )
                                          : Material.color( AppStyle.primaryInt , Material.Shade600 )
                    Popup{
                        id: pop
                        width: 80*AppStyle.size1W
                        height: 50*AppStyle.size1W
                        closePolicy: Popup.NoAutoClose
                        visible: listScroll.pressed || flick.moving
                        y: (parent.height-height)/2
                        x: AppStyle.ltr? listScroll.width*1.75
                                       : -width*1.25
                        Rectangle{
                            height: pop.height/2
                            width: height
                            rotation: 45
                            color: pop.background.color

                            anchors{
                                right: parent.right
                                rightMargin: -width
                                verticalCenter: parent.verticalCenter
                            }
                        }

                        background: Rectangle{
                            color: Material.color( AppStyle.primaryInt , Material.Shade50 )
                            radius: width
                        }

                        Text {
                            anchors.centerIn: parent
                            font{ family: AppStyle.appFont; pixelSize: 25*AppStyle.size1F }
                            color: Material.color( AppStyle.primaryInt , Material.Shade700)
                            property int percent: Number(((flick.contentY/(flick.contentHeight-flick.height)).toFixed(2)*100).toFixed(0))+1

                            text: Math.min(
                                      Math.max(percent,1),
                                      Math.min(percent,100)
                                      ) +"%"
                        }
                    }
                }
            }

            TextEdit{
                id: msg
                readOnly: true
                selectByMouse: Qt.platform.os !== "android" && Qt.platform.os !== "ios"?true:false
                width: parent.width
                color: AppStyle.textColor
                padding: 35*AppStyle.size1W
                textFormat: TextEdit.MarkdownText
                horizontalAlignment: Qt.AlignRight
                selectedTextColor: AppStyle.textOnPrimaryColor
                selectionColor: Material.color(AppStyle.primaryInt,Material.ShadeA700)
                wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere
                text: AppStyle.ltr ? mTools.readFile(":/About/About-English.md")
                                   : mTools.readFile(":/About/About-Farsi.md")
                font{ family: AppStyle.appFont; pixelSize: 27*AppStyle.size1F }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    hoverEnabled: true
                    onClicked: {
                        contextMenu.selectStart = msg.selectionStart;
                        contextMenu.selectEnd = msg.selectionEnd;
                        contextMenu.curPos = msg.cursorPosition;
                        contextMenu.x = mouse.x;
                        contextMenu.y = mouse.y;
                        contextMenu.open();
                    }
                    AppMenu {
                        id: contextMenu
                        property int selectStart
                        property int selectEnd
                        property int curPos
                        onOpened: {
                            msg.cursorPosition = curPos;
                            msg.select(selectStart,selectEnd);
                        }
                        AppMenuItem {
                            LayoutMirroring.enabled: false
                            text: "Copy"
                            onTriggered: {
                                msg.copy()
                            }
                        }
                    }
                }
            }
        }
    }

}
