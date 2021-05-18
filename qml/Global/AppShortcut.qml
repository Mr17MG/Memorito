import QtQuick 2.15

Loader {
    asynchronous: true
    Shortcut{
        sequence: "Alt+L"
        onActivated: {
            AppStyle.languageChanged = true
            translator.updateLanguage(AppStyle.ltr?translator.getLanguages().FA:translator.getLanguages().ENG);
            AppStyle.languageChanged = false
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
        }
        context: Qt.ApplicationShortcut
    }
    Shortcut{
        sequence: "Alt+["
        onActivated: {
            AppStyle.primaryInt =  AppStyle.primaryInt!==0?(AppStyle.primaryInt-1)%19:18
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
