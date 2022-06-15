#include "logsmodel.h"

LogsModel::LogsModel()
{
    this->makeTable();
    this->setTableName("Logs");
}
QVariant LogsModel::getAllLogs()
{
    return QVariant::fromValue(this->getAll());
}

QVariant LogsModel::getAllLogsByThingLocalId(int thingLocalId)
{
    QVariantMap map;
    map[":thing_id_local"] = thingLocalId;
    return QVariant::fromValue(this->getAllByCondition("thing_id_local=:thing_id_local",map));
}

QVariant LogsModel::getAllLogsByThingServerId(int thingServerId)
{
    QVariantMap map;
    map[":thing_id_server"] = thingServerId;
    return QVariant::fromValue(this->getAllByCondition("thing_id_server=:thing_id_server",map));
}

QVariant LogsModel::getLogByLocalId(int id)
{
    QVariantMap map;
    map[":local_id"] = id;
    QList rows = this->getAllByCondition("local_id=:local_id",map);
    return QVariant::fromValue(rows[0]);
}
QVariant LogsModel::getLogByServerId(int id)
{
    QVariantMap map;
    map[":server_id"] = id;
    QList rows = this->getAllByCondition("server_id=:server_id",map);
    return QVariant::fromValue(rows[0]);
}

int LogsModel::addNewLog(QVariantMap data)
{
    ThingsModel thingsModel;

    data["server_id"] = data["id"];
    data["thing_id_server"] = data["thing_id"];
    data["thing_id_local"] = thingsModel.getThingByServerId(data["thing_id"].toInt()).toMap().value("local_id").toInt();

    data.remove("id");
    data.remove("thing_id");

    return this->insert(data);
}

int LogsModel::addNewLog(QString logText,int thingId,int userId, int serverId,QString registerDate,QString modifiedDate)
{
    QVariantMap data;
    data["log_text"] = '"'+logText+'"';
    data["user_id"] = userId;
    data["thing_id_local"] = thingId;
    if(serverId>-1)
        data["server_id"] = serverId;
    if(registerDate != "")
        data["register_date"]= '"'+registerDate+'"';
    if(modifiedDate != "")
        data["modified_date"]= '"'+modifiedDate+'"';

    return this->insert(data);
}

void LogsModel::addMulltiLogs(QList<QVariantMap> logList)
{
    ThingsModel thingsModel;
    foreach(QVariantMap logRow,logList)
    {

        logRow["server_id"] = logRow["id"];
        logRow["thing_id_server"] = logRow["thing_id"];
        logRow["thing_id_local"] = thingsModel.getThingByServerId(logRow["thing_id"].toInt()).toMap().value("local_id").toInt();

        logRow.remove("id");
        logRow.remove("thing_id");

        this->insert(logRow);
    }
}

bool LogsModel::deleteLogsByServerId(QString idList)
{
    return this->deleteRows("server_id",idList);
}

bool LogsModel::deleteLogsByLocalId(QString idList)
{
    return this->deleteRows("local_id",idList);
}

QVariant LogsModel::updateLogByServerId(int serverId, QVariantMap data)
{
    return this->update("server_id",serverId,data);
}

QVariant LogsModel::updateLogByLocalId(int localId, QVariantMap data)
{
    return this->update("local_id",localId,data);
}

void LogsModel::makeTable()
{
    QSqlQuery sqlQuery(this->db);
    QString queryStr("CREATE TABLE IF NOT EXISTS 'Logs' ("
                     "'local_id'	INTEGER NOT NULL UNIQUE,"
                     "'server_id'	INTEGER,"
                     "'log_text'	TEXT NOT NULL,"
                     "'user_id'	INTEGER,"
                     "'thing_id_local'	INTEGER NOT NULL,"
                     "'thing_id_server'	INTEGER,"
                     "'register_date'	TEXT DEFAULT CURRENT_TIMESTAMP,"
                     "'modified_date'	TEXT,"
                     "PRIMARY KEY('local_id' AUTOINCREMENT)"
                     ");"
                     );

    sqlQuery.prepare(queryStr);
    if(sqlQuery.exec() != true)
    {
        QSqlError error = sqlQuery.lastError();
        emit logger->warningLog(error.text());
    }
}
