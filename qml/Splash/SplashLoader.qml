import QtQuick 2.14
import QtGraphicalEffects 1.14 // Require for DropShadow
import QtQuick.Controls.Material 2.14 // // Require For Material Theme
import "../"
Item {
    InitLocalDatabase   {   id: localDB     }
    Component.onCompleted: {
        users.append(userApi.getUsers())
        if(users.count > 0)
        {
            currentUser = userApi.getUserByUserId(users.get(0).id)
            let token = currentUser.authToken?currentUser.authToken:"-1"
            let userId = currentUser.id?currentUser.id:-1
            if(token ==="-1" || userId === -1)
            {
                mainLoader.source = "qrc:/Account/AccountMain.qml"
            }
            else
                userApi.validateToken(token,userId)

        }
        else{
            mainLoader.source = "qrc:/Account/AccountMain.qml"
        }

    }

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
