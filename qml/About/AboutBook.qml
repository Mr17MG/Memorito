import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import Components 1.0
import Global 1.0
import MTools 1.0

Item {
    id:main

    property int pageCount
    property int currentPage : 1

    MTools{id:mTools}

    ColumnLayout {

        anchors.fill: parent
        anchors.margins: 25*AppStyle.size1W

        Rectangle {
            id: container
            clip: true
            color: "transparent"
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 30*AppStyle.size1W

            border{
                color: Material.color(AppStyle.primaryInt)
                width: 3*AppStyle.size1W
            }

            Rectangle{
                anchors.fill: parent
                color: Material.color(AppStyle.primaryInt,Material.Shade50)
                opacity: AppStyle.appTheme?0.1:0.5
            }
            Flickable{
                id:flick
                anchors{
                    topMargin: 25*AppStyle.size1W
                    bottomMargin: 25*AppStyle.size1W
                    leftMargin: 15*AppStyle.size1W
                    rightMargin: 15*AppStyle.size1W
                }
                clip: true
                anchors.fill: parent
                contentHeight: msg.height + 100*AppStyle.size1W
                onContentYChanged:      currentPage = Math.round( flick.contentY      / container.height ) + 1
                onContentHeightChanged: pageCount   = Math.round( flick.contentHeight / container.height )

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
                    }
                }

                Text{
                    id: msg
                    width: parent.width
                    color: AppStyle.textColor
                    padding: 35*AppStyle.size1W
                    textFormat: TextEdit.MarkdownText
                    horizontalAlignment: Qt.AlignRight
                    wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere
                    text: mTools.readFile(":/About/GTD-Farsi.md")
                    font{ family: AppStyle.appFont; pixelSize: 30*AppStyle.size1F }
                }
            }
        }

        RowLayout {

            Layout.preferredHeight: 100*AppStyle.size1H
            Layout.alignment: Qt.AlignHCenter

            AppButton{
                id:backBtn
                width: AppStyle.size1W*200
                height: AppStyle.size1W*60
                radius: 20*AppStyle.size1W
                rotation:180
                icon{
                    source: "qrc:/next.svg"
                    width: 25*AppStyle.size1W
                    height: 25*AppStyle.size1W
                    color: AppStyle.textOnPrimaryColor

                }
                onClicked: {
                    main.currentPage --;
                    flick.contentY = (main.currentPage - 1) * container.height
                }
            }

            Text {
                text: Math.round(flick.contentY/container.height)+1 + " / " + main.pageCount
                Layout.preferredWidth: 170*AppStyle.size1W
                font{ family: AppStyle.appFont;pixelSize: 30*AppStyle.size1F }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: AppStyle.textColor
            }

            AppButton{
                id:forwardBtn
                width: AppStyle.size1W*200
                height: AppStyle.size1W*60
                radius: 15*AppStyle.size1W
                icon{
                    source: "qrc:/next.svg"
                    width: 25*AppStyle.size1W
                    height: 25*AppStyle.size1W
                    color: AppStyle.textOnPrimaryColor

                }
                onClicked: {
                    main.currentPage ++;
                    if( ( main.currentPage * container.height ) >= flick.contentHeight )
                        flick.contentY = flick.contentHeight - container.height
                    else
                        flick.contentY = ( main.currentPage - 1 ) * container.height
                }
            }
        }
    }
}
