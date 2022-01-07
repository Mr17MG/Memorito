import QtQuick
import Qt5Compat.GraphicalEffects // Require for DropShadow
import QtQuick.Controls.Material  // // Require For Material Theme
import Memorito.Components
import Memorito.Global
import Memorito.Users

Item {
    UsersModel {
        id:userModel
    }

    UsersController {
        id: usersController
    }

    Connections {
        target: usersController
        function onUserAuthenticated(){
            mainLoader.source = "qrc:/StartMemorito.qml"
        }
    }

    Component.onCompleted: {
        User.users.append(userModel.getUsers())
        if(User.users.count > 0)
        {
            User.set(userModel.getUserByUserId(User.users.get(0).server_id))
            let token = User.authToken?User.authToken:"-1"
            let userId = User.id?User.id:-1
            if(token ==="-1" || userId === -1)
            {
                mainLoader.source = "qrc:/Account/AccountMain.qml"
            }
            else
                usersController.validateToken()
        }
        else{
            mainLoader.source = "qrc:/Account/AccountMain.qml"
        }

    }

    Image {
        id:iconLogo
        source: "qrc:/icon.png"
        width: 400*AppStyle.size1W
        height: width
        anchors.centerIn: parent
    }

    DropShadow {
        id:dropShadow
        anchors.fill: iconLogo
        horizontalOffset: 0*AppStyle.size1W
        verticalOffset: 0*AppStyle.size1H
        radius: 30
        color: AppStyle.appTheme?"#6F6F6F":"#0C0C0C"
        source: iconLogo
    }

    AppButton {
        text: qsTr("ساخته شده با")
        flat: true
        spacing: 10*AppStyle.size1W
        contentMirorred: AppStyle.ltr

        font {
            pixelSize: 30*AppStyle.size1F
            bold: true
        }

        icon{
            source: "qrc:/heart.svg"
            width: 50*AppStyle.size1W
            height:  50*AppStyle.size1W
            color: AppStyle.textColor
        }

        anchors{
            bottom: parent.bottom
            bottomMargin: 40*AppStyle.size1W
            horizontalCenter: parent.horizontalCenter
        }
    }
}
