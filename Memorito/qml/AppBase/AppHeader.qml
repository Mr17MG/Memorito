import QtQuick 2.15 // Require For Loader and other ...
import QtGraphicalEffects 1.15 // Require for ColorOverlay
import Components 1.0  // Require for Button
import Global 1.0

Loader{
    id:headerRect
    width: parent.width
    height: 100*AppStyle.size1H
    sourceComponent:Item{
        Rectangle{
            anchors.bottom: parent.bottom
            width: parent.width - 40*AppStyle.size1W
            color: AppStyle.primaryColor
            height: 4*AppStyle.size1H
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text{
            anchors{
                right: menuBtn.visible?menuBtn.left:parent.right
                rightMargin: AppStyle.size1W*10
                left : backButton.visible?backButton.right:menuBtn.visible?backButton.right:parent.left
                leftMargin: AppStyle.size1W*10
                verticalCenter: parent.verticalCenter
            }
            horizontalAlignment: Text.AlignHCenter
            elide: AppStyle.ltr?Text.ElideLeft:Text.ElideRight
            text: UsefulFunc.stackPages.get(UsefulFunc.mainPage.item.mainStackView.depth-1).title
            font{family: AppStyle.appFont;pixelSize: 50*AppStyle.size1F;}
            color: AppStyle.textColor
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
}
