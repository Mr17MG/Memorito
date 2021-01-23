#ifndef MEMORITOENUM_H
#define MEMORITOENUM_H

#include <QObject>

class MemoritoEnum : public QObject
{
    Q_OBJECT
public:
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
    };
    enum TablesId{
        CHCategories = 1,
        CHContexts,
        CHFriends,
        CHThings,
        CHFiles,
        CHUsers,
        CHLogs
    };
    enum ChageType{
        Insert = 1,
        Update,
        Delete
    };

    Q_ENUM(Lists)
    Q_ENUM(TablesId)
    Q_ENUM(ChageType)

    explicit MemoritoEnum(QObject *parent = nullptr);

signals:

};

#endif // MEMORITOENUM_H
