import QtQuick 2.14

Loader {
    asynchronous: true
    Shortcut{
        sequence: "Alt+L"
        onActivated: {
            translator.updateLanguage(AppStyle.ltr?translator.getLanguages().FA:translator.getLanguages().ENG);
        }
        context: Qt.ApplicationShortcut
    }
    Shortcut{
        sequence: "Alt+T"
        onActivated: {
            AppStyle.setAppTheme(!AppStyle.appTheme)
        }
        context: Qt.ApplicationShortcut
    }
    Shortcut{
        sequence: "Alt+]"
        onActivated: {
            AppStyle.primaryInt = (AppStyle.primaryInt+1)%19
            console.log("]", AppStyle.primaryInt)
        }
        context: Qt.ApplicationShortcut
    }
    Shortcut{
        sequence: "Alt+["
        onActivated: {
            AppStyle.primaryInt =  AppStyle.primaryInt!==0?(AppStyle.primaryInt-1)%19:18
            console.log("[", AppStyle.primaryInt)
        }
        context: Qt.ApplicationShortcut
    }
    Shortcut{
        sequence: "Alt+Y"
        onActivated: {
            AppStyle.textOnPrimaryInt = !AppStyle.textOnPrimaryInt
        }
        context: Qt.ApplicationShortcut
    }

}
