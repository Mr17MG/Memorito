import QtQuick 2.14 // Require for Item And Loader
import QtQuick.Controls.Material 2.14 // Require For Material.color
import "qrc:/Components" as App
import QtQuick.Window 2.14 // Require for Window

Item {
    property bool isSignIn: true
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
        id:mainLoader
        x: splashLoader.active?isSignIn == !ltr ? width : 0:0
        width: parent.width - splashLoader.width
        height: parent.height
        source: isSignIn?"qrc:/Account/SignIn.qml":"qrc:/Account/SignUp.qml"
        Behavior on x {
            NumberAnimation{ duration: 160}
        }
    }

    Loader{
        id: splashLoader
        x: isSignIn == !ltr ?0:width
        width: active?parent.width/2:0
        height: parent.height
        active: checkSplit(Screen)
        sourceComponent: Rectangle{
            color: Material.color(appStyle.primaryInt,Material.Shade400)
        }
        Behavior on x {
            NumberAnimation{ duration: 160}
        }
    }
}
