#include "thingsmodel.h"

ThingsModel::ThingsModel()
{
    this->makeTable();
    this->setTableName("Things");
}

QVariant ThingsModel::getAllThings()
{
    return QVariant::fromValue(this->getAll());
}

QVariant ThingsModel::getThingsByQuery(QString query)
{
    return QVariant::fromValue(this->getByQuery(query));
}

QVariant ThingsModel::getThingByLocalId(int localId)
{
    QVariantMap map;
    map[":local_id"] = localId;
    QList rows = this->getAllByCondition("local_id=:local_id",map);
    return QVariant::fromValue(rows[0]);
}

QVariant ThingsModel::getThingByServerId(int serverId)
{
    QVariantMap map;
    map[":server_id"] = serverId;
    QList rows = this->getAllByCondition("server_id=:server_id",map);
    return QVariant::fromValue(rows[0]);
}

QVariant ThingsModel::getAllSomedayGroup()
{
    QString query = "SELECT * FROM Things WHERE status=5 AND type_id=2 ORDER BY server_id";
    return QVariant::fromValue(this->getByQuery(query));
}

QVariant ThingsModel::getAllThingsGroup()
{
    QString query = "SELECT * FROM Things WHERE status=2 AND type_id=2 ORDER BY server_id";
    return QVariant::fromValue(this->getByQuery(query));

}

QVariant ThingsModel::getAllRefrencesGroup()
{
    QString query = "SELECT * FROM Things WHERE status=4 AND type_id=2 ORDER BY server_id";
    return QVariant::fromValue(this->getByQuery(query));
}

int ThingsModel::addNewThing(QVariantMap data)
{
    ContextsModel contextModel;
    data["server_id"] = data["id"];
    data["parent_id_server"] = data["parent_id"];
    data["context_id_server"] = data["context_id"];

    if(!data["context_id"].isNull() && data["context_id"].toInt() > 0)
    {
        QVariant tmp =  contextModel.getContextByServerId(data["context_id"].toInt());
        data["context_id_local"] = tmp.toMap().value("local_id").toInt();
    }

    if(!data["parent_id"].isNull() && data["context_id"].toInt() > 0)
    {
        QVariant tmp =  this->getThingByServerId(data["parent_id"].toInt());
        data["parent_id_local"] = tmp.toMap().value("local_id").toInt();
    }

    data.remove("id");
    data.remove("parent_id");
    data.remove("context_id");
    return this->insert(data);
}

void ThingsModel::addMulltiThing(QList<QVariantMap> thingList)
{
    ContextsModel contextModel;
    foreach( QVariantMap thingRow ,thingList )
    {
        thingRow["server_id"] = thingRow["id"];
        thingRow["parent_id_server"] = thingRow["parent_id"];
        thingRow["context_id_server"] = thingRow["context_id"];

        if(!thingRow["context_id"].isNull() && thingRow["context_id"].toInt() > 0)
        {
            QVariant tmp =  contextModel.getContextByServerId(thingRow["context_id"].toInt());
            thingRow["context_id_local"] = tmp.toMap().value("local_id").toInt();
        }

        if(!thingRow["parent_id"].isNull() && thingRow["context_id"].toInt() > 0)
        {
            QVariant tmp =  this->getThingByServerId(thingRow["parent_id"].toInt());
            thingRow["parent_id_local"] = tmp.toMap().value("local_id").toInt();
        }

        thingRow.remove("id");
        thingRow.remove("parent_id");
        thingRow.remove("context_id");

        this->insert(thingRow);
    }
}

bool ThingsModel::deleteThingByServerId(int id)
{
    return this->deleteRows("server_id",QString::number(id));
}

bool ThingsModel::deleteThingByLocalId(int id)
{
    return this->deleteRows("local_id",QString::number(id));
}

QVariant ThingsModel::updateThingByServerId(int serverId, QVariantMap data)
{
    return this->update("server_id",serverId,data);
}

QVariant ThingsModel::updateThingByLocalId(int localId, QVariantMap data)
{
    return this->update("local_id",localId,data);
}

void ThingsModel::makeTable()
{
    QSqlQuery sqlQuery(this->db);
    QString queryStr("CREATE TABLE IF NOT EXISTS 'Things'  ("
                     "'local_id'	INTEGER NOT NULL UNIQUE,"
                     "'server_id'	INTEGER UNIQUE,"
                     "'title'	TEXT NOT NULL,"
                     "'detail'	TEXT,"
                     "'user_id'	INTEGER NOT NULL,"
                     "'type_id'	INTEGER DEFAULT 1 CHECK(type_id IN (1,2)),"
                     "'parent_id_server'	INTEGER DEFAULT NULL,"
                     "'parent_id_local'	INTEGER DEFAULT NULL,"
                     "'status'	INTEGER DEFAULT 1 CHECK(status IN (1,2,3,4,5)),"
                     "'display_type'	INTEGER DEFAULT 1 CHECK(display_type IN (1,2,3)),"
                     "'context_id_local'	INTEGER DEFAULT NULL,"
                     "'context_id_server'	INTEGER DEFAULT NULL,"
                     "'priority_id'	INTEGER DEFAULT NULL CHECK(priority_id IN (1,2,3,4)),"
                     "'energy_id'	INTEGER DEFAULT NULL CHECK(energy_id IN (1,2,3,4)),"
                     "'estimated_time'	INTEGER DEFAULT NULL,"
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
