import QtQuick 2.14 // Require for Item And Loader
import QtQuick.Controls.Material 2.14 // Require For Material.color
import "qrc:/Components" as App
import QtQuick.Window 2.14 // Require for Window

Item {
    property bool isSignIn: true
    property bool closeSplash: false

    function checkSplit(window)
    {
        if(Qt.platform.os === "android" || Qt.platform.os === "ios")
        {
            return false
        }
        else {
            if(rootWindow.width>window.width/3)
                return true;
            else
                return false;
        }
    }
    Loader{
        id: authLoader
        x: splashLoader.active?isSignIn == !ltr ? width : 0:0
        width: parent.width - splashLoader.width
        height: parent.height
        source: splashLoader.active === false && closeSplash === false?"qrc:/Splash/MainSplash.qml":isSignIn?"qrc:/Account/SignIn.qml":"qrc:/Account/SignUp.qml"
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
        Behavior on x {
            NumberAnimation{ duration: 160}
        }
    }
}
