#include "contextsmodel.h"

ContextsModel::ContextsModel()
{
    this->makeTable();
    this->setTableName("Contexts");
}

QVariant ContextsModel::getAllContexts()
{
    return QVariant::fromValue(this->getAll());
}

QVariant ContextsModel::getContextByLocalId(int localId)
{
    QVariantMap map;
    map[":local_id"] = localId;
    QList rows = this->getAllByCondition("local_id=:local_id",map);
    return QVariant::fromValue(rows[0]);
}

QVariant ContextsModel::getContextByServerId(int serverId)
{
    QVariantMap map;
    map[":server_id"] = serverId;
    QList rows = this->getAllByCondition("server_id=:server_id",map);
    return QVariant::fromValue(rows[0]);
}

int ContextsModel::addNewContext(QVariantMap data)
{
    data["server_id"] = data["id"];
    data.remove("id");
    return this->insert(data);
}

int ContextsModel::addNewContext(QString contextName, int userId, int serverId, QString registerDate, QString modifiedDate)
{
    QVariantMap data;
    data["context_name"] = '"'+contextName+'"';
    data["user_id"] = '"'+userId+'"';
    if(serverId>-1)
        data["server_id"] = serverId;
    if(registerDate != "")
        data["register_date"]= '"'+registerDate+'"';
    if(modifiedDate != "")
        data["modified_date"]= '"'+modifiedDate+'"';

    return this->insert(data);
}

void ContextsModel::addMulltiContext(QList<QVariantMap> contextList)
{
    foreach(QVariantMap contextRow,contextList)
    {
        contextRow["server_id"] = contextRow["id"];
        contextRow.remove("id");
        this->insert(contextRow);
    }
}

bool ContextsModel::deleteContextByServerId(int id)
{
    return this->deleteRows("server_id",QString::number(id));
}

bool ContextsModel::deleteContextByLocalId(int id)
{
    return this->deleteRows("local_id",QString::number(id));
}

QVariant ContextsModel::updateContextByServerId(int serverId, QVariantMap data)
{
    return this->update("server_id",serverId,data);
}

QVariant ContextsModel::updateContextByLocalId(int localId, QVariantMap data)
{
    return this->update("local_id",localId,data);
}

void ContextsModel::makeTable()
{
    QSqlQuery sqlQuery(this->db);
    QString queryStr("CREATE TABLE IF NOT EXISTS 'Contexts' ("
                     "'local_id'	INTEGER NOT NULL UNIQUE,"
                     "'server_id'	INTEGER,"
                     "'context_name'	TEXT NOT NULL,"
                     "'user_id'	INTEGER,"
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
