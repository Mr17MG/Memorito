#ifndef LOGSMODEL_H
#define LOGSMODEL_H

#include <QObject>
#include "basemodel.h"

class LogsModel : public QObject, private BaseModel
{
    Q_OBJECT
    void makeTable();

public:
    explicit LogsModel();

    Q_INVOKABLE QVariant getAllLogs();
    Q_INVOKABLE QVariant getLogById(int id);
    Q_INVOKABLE int addNewLog(QVariantMap data);
    Q_INVOKABLE int addNewLog(QString logText,int thingId,int userId, int serverId=-1,QString registerDate="",QString modifiedDate ="");
    Q_INVOKABLE void addMulltiLog(QList <QVariantMap> logList);
    Q_INVOKABLE bool deleteLogByServerId(int id);
    Q_INVOKABLE bool deleteLogByLocalId(int id);
    Q_INVOKABLE QVariant updateLogByServerId(int serverId, QVariantMap data);
    Q_INVOKABLE QVariant updateLogByLocalId(int localId, QVariantMap data);
};

#endif // LOGSMODEL_H
