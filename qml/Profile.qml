import QtQuick 2.12
import QtGraphicalEffects 1.0
//import "qrc:/Components/" as App
import QtQuick.Controls.Material 2.12
import QtQuick.Controls 2.12
import "qrc:/Components/" as App

Item {
    property bool isEditable: false
    property bool modified: false
    function popOut(args){
        profilePicture.source = args
    }

    Rectangle{
        id: root
        width: 250*size1W
        height: width
        radius: width
        anchors{
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 15*size1H
        }
        border.color: Material.color(appStyle.primaryInt)
        border.width: 5*size1W

        Image {
            id: profileImage
            source: "qrc:/user.svg"
            anchors{
                fill: parent
                margins: root.border.width
            }
            sourceSize.width: parent.width
            sourceSize.height: parent.height
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    x: root.x
                    y: root.y
                    width: root.width
                    height: root.height
                    radius: root.radius
                }
            }
            onSourceChanged: {
                if(modified===false && isEditable)
                    modified=true
            }
        }
        MouseArea{
            anchors.fill: parent
            enabled: isEditable
            cursorShape:Qt.PointingHandCursor
        }
    }

    Item{
        id:usernameItem
        width: parent.width/3*2
        height: 100*size1H
        anchors{
            top: root.bottom
            topMargin: 20*size1H
            horizontalCenter: parent.horizontalCenter
        }

        SequentialAnimation {
            id:usernameMoveAnimation
            running: false
            loops: 3
            NumberAnimation { target: usernameItem; property: "anchors.horizontalCenterOffset"; to: -10; duration: 50}
            NumberAnimation { target: usernameItem; property: "anchors.horizontalCenterOffset"; to: 10; duration: 100}
            NumberAnimation { target: usernameItem; property: "anchors.horizontalCenterOffset"; to: 0; duration: 50}
        }

        App.TextField{
            id:usernameInput
            width: parent.width
            height: 100*size1H
            enabled: isEditable
            anchors.bottom: parent.bottom
            inputMethodHints: Qt.ImhPreferLowercase
            placeholderText: qsTr("نام کاربری")
            text: currentUser.username
            validator: RegExpValidator{regExp: /[A-Za-z0-9_.]{50}/}
            EnterKey.type: Qt.EnterKeyNext
            Keys.onEnterPressed:  emailInput.forceActiveFocus()
            Keys.onReturnPressed:  emailInput.forceActiveFocus()
            onEditingFinished: {
                if(modified===false && text.trim()!==currentUser.username)
                    modified=true
            }
        }
    }
    Item{
        id:emailItem
        width: parent.width/3*2
        height: 100*size1H
        anchors{
            top: usernameItem.bottom
            horizontalCenter: parent.horizontalCenter
        }
        SequentialAnimation {
            id:emailMoveAnimation
            running: false
            loops: 3
            NumberAnimation { target: emailItem; property: "anchors.horizontalCenterOffset"; to: -10; duration: 50}
            NumberAnimation { target: emailItem; property: "anchors.horizontalCenterOffset"; to: 10; duration: 100}
            NumberAnimation { target: emailItem; property: "anchors.horizontalCenterOffset"; to: 0; duration: 50}
        }
        App.TextField{
            id:emailInput
            width: parent.width
            height: 100*size1H
            enabled: isEditable
            anchors.bottom: parent.bottom
            inputMethodHints: Qt.ImhEmailCharactersOnly
            placeholderText: qsTr("ایمیل")
            text: currentUser.email
            validator: RegExpValidator{regExp: /[A-Za-z0-9_]*/}
            EnterKey.type: Qt.EnterKeyGo
            Keys.onEnterPressed:  edit.forceActiveFocus()
            Keys.onReturnPressed:  edit.forceActiveFocus()
            onEditingFinished: {
                if(modified===false && text.trim()!==currentUser.email)
                    modified=true
            }
        }
    }
    App.Button{
        id: edit
        height: size1H*75
        width: usernameItem.width
        anchors{
            top: emailItem.bottom
            topMargin: size1H*20
            horizontalCenter: parent.horizontalCenter
        }
        flat: true
        Material.background: isEditable? appStyle.primaryInt:"transparent"
        radius: size1W*20
        text: isEditable?qsTr("بروزرسانی اطلاعات"):qsTr("ویرایش اطلاعات")
        font { family: appStyle.appFont; pixelSize: size1F*30;bold:true}
        Material.foreground: isEditable? appStyle.textOnPrimaryColor:appStyle.textColor
        onClicked: {
            usernameInput.focus = false
            if(!modified)
            {
                isEditable = !isEditable;
                return
            }

            if(usernameInput.text.trim()==="" || emailInput.text.trim()==="")
            {
                usefulFunc.showLog(qsTr("اطلاعات وارد شده صحیح نمی‌باشد."),true)
                if(usernameInput.text.trim()==="")
                    usernameMoveAnimation.start()
                if(emailInput.text.trim()==="")
                    emailMoveAnimation.start()
                return
            }
            isEditable = !isEditable;
            if(!isEditable){
                modified=false
            }
        }
    }
    App.Button{
        id: logoutBtn
        height: size1H*75
        width: 300*size1W
        anchors{
            bottom: parent.bottom
            bottomMargin: 20*size1H
            right: parent.right
            rightMargin: 30*size1W
        }
        flat: !isEditable
        enabled: isEditable
        radius: size1W*20
        text: qsTr("خروج از حساب")
        font { family: appStyle.appFont; pixelSize: size1F*30;bold:true}
        onClicked: {
            usefulFunc.showConfirm(
                        qsTr("خروج از حساب"),
                        qsTr("آیا مطمئن هستید که می‌خواهید از حساب خود خارج شوید؟"),
                        function()
                        {
                            userDbFunc.deleteUser(currentUser.localId)
                            mainLoader.source = "qrc:/Account/AccountMain.qml"
                            currentUser = []
                        }
                        )
        }
    }

}
