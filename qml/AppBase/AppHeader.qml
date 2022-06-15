import QtQuick  // Require For Loader and other ...
import Qt5Compat.GraphicalEffects // Require for ColorOverlay
import Memorito.Components  // Require for Button
import Memorito.Global

Loader{
    id:headerRect
    width: parent.width
    height: UsefulFunc.stackPages.count > 1 ?160*AppStyle.size1H:100*AppStyle.size1H

    Behavior on height {
        NumberAnimation {
            duration: 200
        }
    }

    sourceComponent: Item {

        Item {
            height: 100*AppStyle.size1H
            width: parent.width

            Text{
                color: AppStyle.textColor
                horizontalAlignment: Text.AlignHCenter
                elide: AppStyle.ltr?Text.ElideLeft:Text.ElideRight
                text: qsTr("مموریتو")
                anchors {
                    centerIn: parent
                }
                font {
                    family: AppStyle.appHeaderFont;
                    pixelSize: 50*AppStyle.size1F;
                }
            }

            AppButton{
                id: menuBtn
                flat: true
                implicitWidth: 90*AppStyle.size1W
                implicitHeight: 90*AppStyle.size1H
                anchors.right: parent.right
                anchors.rightMargin: 10*AppStyle.size1W
                visible: nRow === 1
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    if(!drawerLoader.item.visible)
                        drawerLoader.item.open()
                    else drawerLoader.item.close()
                }
                Image{
                    id:menuImg
                    anchors.centerIn: parent
                    width: 40*AppStyle.size1W
                    height: width
                    source: {
                        if(drawerLoader.active)
                            drawerLoader.item.visible?"qrc:/close.svg":"qrc:/menu.svg"
                        else ""
                    }

                    sourceSize.width: width*2
                    sourceSize.height: height*2
                    visible: false
                }
                ColorOverlay{
                    id:menuImgColor
                    rotation: AppStyle.ltr?0:180
                    anchors.fill: menuImg
                    source:menuImg
                    color: AppStyle.primaryColor
                }
            }
            AppButton{
                id: backButton
                flat: true
                width:  90*AppStyle.size1W
                height: width
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                visible: UsefulFunc.mainPage.item.mainStackView.depth > 1
                onClicked: {
                    UsefulFunc.mainStackPop()
                }

                Image{
                    id:backIcon
                    anchors.centerIn: parent
                    width: 50*AppStyle.size1W
                    height: width
                    visible: false
                    source: "qrc:/arrow.svg"
                    sourceSize.width: width*2
                    sourceSize.height: height*2
                }
                ColorOverlay{
                    rotation: AppStyle.ltr?270:90
                    source: backIcon
                    anchors.fill: backIcon
                    color: AppStyle.primaryColor
                }
            }

            Shortcut {
                sequences: ["Esc", "Back","Alt+Left"]
                onActivated: {
                    if(backButton.visible)
                        backButton.clicked(Qt.RightButton)
                    else
                        UsefulFunc.showConfirm( qsTr("خروج؟") , qsTr("میخوای از برنامه بری بیرون؟"), function(){Qt.quit()} )
                }
            }
        }



        ListView {
            id: pagesListView

            clip: true
            visible: model.count > 1
            width: bottomLineRect.width
            height: visible?60*AppStyle.size1H:0

            orientation: Qt.Horizontal
            layoutDirection: Qt.RightToLeft

            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }

            add: Transition {
                  NumberAnimation { properties: "x,y"; duration: 200 }
                  onRunningChanged: pagesListView.positionViewAtEnd()
              }

            model: UsefulFunc.stackPages
            delegate: AppButton{
                text: "> %1".arg(model?.title ?? "");
                flat: true
                highlighted: model?.title === UsefulFunc.stackPages.get(UsefulFunc.stackPages.count-1)?.title;
                onClicked: {
                    UsefulFunc.mainStackPush(model.page,model.title,{})
                }
            }
        }

        Rectangle {
            id: bottomLineRect

            height: 4*AppStyle.size1H
            color: AppStyle.primaryColor
            width: parent.width - 40*AppStyle.size1W

            anchors{
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
