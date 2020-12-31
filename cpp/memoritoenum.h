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
        Project
    };
    Q_ENUM(Lists)
    explicit MemoritoEnum(QObject *parent = nullptr);

signals:

};

#endif // MEMORITOENUM_H
