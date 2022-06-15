#ifndef LOGSMODEL_H
#define LOGSMODEL_H

#include <QObject>
#include "basemodel.h"
#include "thingsmodel.h"

class LogsModel : public QObject, private BaseModel
{
    Q_OBJECT
    void makeTable();

public:
    explicit LogsModel();

    Q_INVOKABLE QVariant getAllLogs();

    Q_INVOKABLE QVariant getAllLogsByThingLocalId(int thingLocalId);
    Q_INVOKABLE QVariant getAllLogsByThingServerId(int thingServerId);

    Q_INVOKABLE QVariant getLogByLocalId(int id);
    Q_INVOKABLE QVariant getLogByServerId(int id);


    Q_INVOKABLE int addNewLog(QVariantMap data);
    Q_INVOKABLE int addNewLog(QString logText,int thingId,int userId, int serverId=-1,QString registerDate="",QString modifiedDate ="");
    Q_INVOKABLE void addMulltiLogs(QList <QVariantMap> logList);

    Q_INVOKABLE QVariant updateLogByServerId(int serverId, QVariantMap data);
    Q_INVOKABLE QVariant updateLogByLocalId(int localId, QVariantMap data);

    Q_INVOKABLE bool deleteLogsByLocalId(QString idList);
    Q_INVOKABLE bool deleteLogsByServerId(QString idList);
};

#endif // LOGSMODEL_H
