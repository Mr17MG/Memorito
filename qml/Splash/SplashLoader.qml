import QtQuick 2.15
import QtGraphicalEffects 1.14 // Require for DropShadow
import QtQuick.Controls.Material 2.15 // // Require For Material Theme
import MSysInfo 1.0                       // Require For SystemInfo
import MSecurity 1.0                      // Require For MSecurity
import Components 1.0
import Global 1.0

Item {
    MSecurity           {   id: security    }
    MSysInfo            {   id: sysInfo     }

    Component.onCompleted: {
        User.users.append(UserApi.getUsers())
        if(User.users.count > 0)
        {
            User.set(UserApi.getUserByUserId(User.users.get(0).id))
            let token = User.authToken?User.authToken:"-1"
            let userId = User.id?User.id:-1
            if(token ==="-1" || userId === -1)
            {
                mainLoader.source = "qrc:/Account/AccountMain.qml"
            }
            else
                UserApi.validateToken(token,userId)

        }
        else{
            mainLoader.source = "qrc:/Account/AccountMain.qml"
        }

    }

    Image {
        id:iconLogo
        source: "qrc:/icon.png"
        width: 150*AppStyle.size1W
        height: width
        anchors.centerIn: parent
    }
    DropShadow {
        id:dropShadow
        anchors.fill: iconLogo
        horizontalOffset: 0*AppStyle.size1W
        verticalOffset: 0*AppStyle.size1H
        radius: 50*AppStyle.size1W
        samples: 30*AppStyle.size1W
        color: Material.color(AppStyle.primaryInt,Material.Shade200)
        source: iconLogo
    }

    Text {
        id: waitText
        text: qsTr("ساخته شده با ♥")
        font{family: AppStyle.appFont;pixelSize: 30*AppStyle.size1F;bold: true}
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40*AppStyle.size1W
        anchors.horizontalCenter: parent.horizontalCenter
        color: AppStyle.textColor
    }
}
