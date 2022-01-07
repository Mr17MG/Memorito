pragma Singleton
import QtQuick 

QtObject {
    enum Lists{
        Collect=1,
        Process,
        NextAction,
        Refrence,
        Waiting,
        Calendar,
        Trash,
        Done,
        Someday,
        Project,
        Contexts,
        Friends
    }
    enum TablesId{
        CHCategories = 1,
        CHContexts,
        CHFriends,
        CHThings,
        CHFiles,
        CHUsers,
        CHLogs
    }
    enum ChageType{
        Insert = 1,
        Update,
        Delete
    }

    enum LogTypes{
        Success,
        Error,
        Warning,
        Info
    }
}
