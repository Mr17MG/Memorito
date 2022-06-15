pragma Singleton
import QtQuick

QtObject {
    property ListModel contextsListModel: ListModel{}

    property ListModel friendsListModel: ListModel{}

    property ListModel priorityListModel : ListModel{  id: priorityModel
        ListElement{ Id:1; Text:qsTr("کم")    ; iconSource: "qrc:/priorities/low.svg"    ;  }
        ListElement{ Id:2; Text:qsTr("متوسط") ; iconSource: "qrc:/priorities/medium.svg" ;  }
        ListElement{ Id:3; Text:qsTr("زیاد")  ; iconSource: "qrc:/priorities/high.svg"   ;  }
        ListElement{ Id:4; Text:qsTr("فوری")  ; iconSource: "qrc:/priorities/higher.svg" ;  }
    }

    property ListModel energyListModel :ListModel{  id: energyModel
        ListElement{ Id:1; Text:qsTr("کم")        ; iconSource: "qrc:/energies/low.svg"   ; }
        ListElement{ Id:2; Text:qsTr("متوسط")     ; iconSource: "qrc:/energies/medium.svg"; }
        ListElement{ Id:3; Text:qsTr("زیاد")      ; iconSource: "qrc:/energies/high.svg"  ; }
        ListElement{ Id:4; Text:qsTr("خیلی زیاد") ; iconSource: "qrc:/energies/higher.svg"; }
    }

    readonly property ListModel firstPageModel: ListModel{
        id: firstPageModel
        ListElement{
            title:qsTr("مموریتو")
            pageSource :"qrc:/HomePage.qml"
            listId: 0
        }
        ListElement{
            title: qsTr("جمع‌آوری")
            pageSource :"qrc:/Things/AddEditThing.qml"
            listId: Memorito.Collect
        }
        ListElement{
            title:qsTr("پردازش نشده‌ها")
            pageSource: "qrc:/Things/ThingList.qml"
            listId: Memorito.Process
        }
        ListElement{
            title:qsTr("عملیات بعدی")
            pageSource: "qrc:/Things/ThingList.qml"
            listId: Memorito.NextAction
        }
        ListElement{
            title:qsTr("تقویم")
            pageSource: "qrc:/Things/ThingList.qml"
            listId: Memorito.Calendar
        }
        ListElement{
            title:qsTr("پروژه‌ها")
            pageSource: "qrc:/Categories/CategoriesList.qml"
            listId: Memorito.Project
        }
    }

}
