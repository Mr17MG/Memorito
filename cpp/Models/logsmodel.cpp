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

QVariant LogsModel::getLogById(int id)
{
    QVariantMap map;
    map[":local_id"] = id;
    map[":server_id"] = id;
    QList rows = this->getAllByCondition("local_id=:local_id OR server_id=:server_id",map);
    return QVariant::fromValue(rows[0]);
}

int LogsModel::addNewLog(QVariantMap data)
{
    data["server_id"] = data["id"];
    data.remove("id");
    return this->insert(data);
}

int LogsModel::addNewLog(QString logText,int thingId,int userId, int serverId,QString registerDate,QString modifiedDate)
{
    QVariantMap data;
    data["log_text"] = '"'+logText+'"';
    data["user_id"] = userId;
    data["thing_id"] = thingId;
    if(serverId>-1)
        data["server_id"] = serverId;
    if(registerDate != "")
        data["register_date"]= '"'+registerDate+'"';
    if(modifiedDate != "")
        data["modified_date"]= '"'+modifiedDate+'"';

    return this->insert(data);
}

void LogsModel::addMulltiLog(QList<QVariantMap> logList)
{
    foreach(QVariantMap logRow,logList)
    {
        logRow["server_id"] = logRow["id"];
        logRow.remove("id");
        this->insert(logRow);
    }
}

bool LogsModel::deleteLogByServerId(int id)
{
    return this->deleteRows("server_id",QString::number(id));
}

bool LogsModel::deleteLogByLocalId(int id)
{
    return this->deleteRows("local_id",QString::number(id));
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
