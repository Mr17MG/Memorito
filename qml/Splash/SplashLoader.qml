import QtQuick 2.14
import QtGraphicalEffects 1.14 // Require for DropShadow
import QtQuick.Controls.Material 2.14 // // Require For Material Theme
import "qrc:/Account/" as Account
import MSysInfo 1.0 // For SystemInfo

Item {
    SystemInfo{id:sysInfo}
    Component.onCompleted: {
        users.append(userDbFunc.getUsers())
        if(users.count > 0)
        {
            currentUser = userDbFunc.getUserByUserId(users.get(0).userId)
            api.validateToken(currentUser.authToken,currentUser.userId)
        }
        else{
            mainLoader.source = "qrc:/Account/AccountMain.qml"
        }

    }
    Account.API{ id: api }

    Image {
        id:iconLogo
        source: "qrc:/icon.png"
        width: 150*size1W
        height: width
        anchors.centerIn: parent
    }
    DropShadow {
        id:dropShadow
        anchors.fill: iconLogo
        horizontalOffset: 0*size1W
        verticalOffset: 0*size1H
        radius: 50*size1W
        samples: 30*size1W
        color: Material.color(appStyle.primaryInt,Material.Shade200)
        source: iconLogo
    }

    Text {
        id: waitText
        text: qsTr("ساخته شده با ♥")
        font{family: appStyle.appFont;pixelSize: 30*size1F;bold: true}
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40*size1W
        anchors.horizontalCenter: parent.horizontalCenter
        color: appStyle.textColor
    }
}
