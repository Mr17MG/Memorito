import QtQuick 2.14 // Require for Item And Loader
import QtQuick.Controls 2.14 // require for stackview
import QtQuick.Controls.Material 2.14 // Require For Material.color
import "qrc:/Components" as App
import QtQuick.Window 2.14 // Require for Window
import ".."
Item {
    id:item1
    property bool isSignIn: true
    InitLocalDatabase   {   id: localDB     }
    Component.onCompleted: {
        localDB.dropAallLocalTables()
        localDB.makeLocalTables()
    }
    onIsSignInChanged: {
        if(isSignIn)
        {
            authLoader.item.replace("qrc:/Account/SignIn.qml")
        }
        else
        {
            authLoader.item.replace("qrc:/Account/SignUp.qml")

        }
    }
    Shortcut {
        sequences: ["Esc", "Back"]
        onActivated: {
            if(authLoader.item.depth > 1)
                authLoader.item.pop();
            else
                usefulFunc.showConfirm( qsTr("خروج؟") , qsTr("آیا مایلید از نرم‌افزار خارج شوید؟"), function(){Qt.quit()} )
        }
    }

    function checkSplit(window)
    {
        if(Qt.platform.os === "android" || Qt.platform.os === "ios")
        {
            return false
        }
        else {
            if(rootWindow.width>window.width/3)
            {
                return true;
            }
            else
                return false;
        }
    }
    UserAPI{id:userApi}
    Loader{
        id: authLoader
        x: splashLoader.active?(splashLoader.active?isSignIn == !ltr ? width : 0:0):0
        width: parent.width - splashLoader.width
        height: parent.height
        sourceComponent: StackView{
            id: authStack
            anchors.fill: parent
            initialItem: splashLoader.active === false?"qrc:/Splash/MainSplash.qml":isSignIn?"qrc:/Account/SignIn.qml":"qrc:/Account/SignUp.qml"
        }

        Behavior on x {
            NumberAnimation{ duration: 160}
        }
    }

    Loader{
        id: splashLoader
        x: isSignIn == !ltr ?0:width
        width: active?parent.width/2:0
        height: parent.height
        source: "qrc:/Splash/MainSplash.qml"
        active: checkSplit(Screen)
        onActiveChanged:{
            if(active)
            {
                if(isSignIn)
                {
                    authLoader.item.replace("qrc:/Account/SignIn.qml")
                }
                else
                {
                    authLoader.item.replace("qrc:/Account/SignUp.qml")

                }
            }
        }

        Behavior on x {
            NumberAnimation{ duration: 160}
        }
    }
}
