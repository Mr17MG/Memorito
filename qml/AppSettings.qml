import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtGraphicalEffects 1.14

Item {
    Flow{
        id:themeFlow
        width: parent.width
        anchors.top: parent.top
        anchors.topMargin: 20*size1W
        anchors.right: parent.right
        spacing: 10*size1W
        layoutDirection: ltr?Qt.LeftToRight:Qt.RightToLeft
        Text{
            text: qsTr("طرح زمینه") + " :"
            font{pixelSize: 35*size1F;bold:false}
            verticalAlignment: Text.AlignVCenter
            color: appStyle.textColor
            height: themeSwitch.height
            leftPadding: 10*size1W
        }
        Text{
            text: qsTr("روشن")
            font{pixelSize: 35*size1F;bold:true}
            verticalAlignment: Text.AlignVCenter
            color: appStyle.textColor
            height: themeSwitch.height
        }
        Switch{
            id: themeSwitch
            Material.accent: appStyle.primaryColor
            Material.theme: Material.Light
            checked: getAppTheme()?false:true
            width: 100*size1W
            height: 90*size1W
            implicitWidth: width
            implicitHeight: height
            onCheckedChanged: {
                setAppTheme(checked?0:1)
            }
        }
        Text{
            text: qsTr("تیره")
            font{pixelSize: 35*size1F;bold:true}
            verticalAlignment: Text.AlignVCenter
            color: appStyle.textColor
            height: themeSwitch.height
        }
    }

    Item {
        id: colorItem
        anchors.top: themeFlow.bottom
        anchors.topMargin: 15*size1W
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        Text{
            id:colorText
            text: qsTr("انتخاب رنگ اصلی") + " :"
            font{pixelSize: 35*size1F;bold:false}
            verticalAlignment: Text.AlignBottom
            color: appStyle.textColor
            height: primaryCombo.height
            anchors.right: parent.right
            anchors.leftMargin: 10*size1W
            anchors.bottom: primaryCombo.bottom
        }
        ComboBox{
            id:primaryCombo
            width: 260*size1W
            height: 70*size1H
            implicitWidth: width
            implicitHeight:height
            anchors.right: colorText.left
            anchors.rightMargin: 20*size1W
            displayText : currentIndex === -1 ? qsTr("رنگ ها")
                                              : currentText
            indicator.width: 70*size1W
            indicator.height: 70*size1W
            currentIndex : appStyle.primaryInt
            popup.height : 350*size1H
            popup.y:height
            font{pixelSize: 35*size1F;bold:true}
            model: [
                qsTr("قرمز"),
                qsTr("صورتی"),
                qsTr("بنفش"),
                qsTr("بنفش تیره"),
                qsTr("نیلی"),
                qsTr("آبی"),
                qsTr("آبی روشن"),
                qsTr("فیروزه‌ای"),
                qsTr("سبز تیره"),
                qsTr("سبز"),
                qsTr("سبز روشن"),
                qsTr("لیمویی"),
                qsTr("زرد"),
                qsTr("کهربایی"),
                qsTr("نارنجی"),
                qsTr("نارنجی تیره"),
                qsTr("قهوه‌ای"),
                qsTr("خاکستری"),
                qsTr("آبی خاکستری")
            ]

            delegate: ItemDelegate {
                id: colorDelegate
                Text{
                    text: modelData
                    color: "#FFFFFF"
                    font{pixelSize: 35*size1F;bold:true}
                    anchors.centerIn: parent
                }

                width: primaryCombo.popup.width
                height: 70*size1H
                Rectangle {
                    z: -1
                    anchors.fill: parent
                    parent: colorDelegate.background
                    color: Material.color(index)
                }
            }
            onCurrentIndexChanged: {
                appStyle.primaryInt = currentIndex
            }
        }
    }
}
