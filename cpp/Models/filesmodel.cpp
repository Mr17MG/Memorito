#include "filesmodel.h"

FilesModel::FilesModel()
{
    this->makeTable();
    this->setTableName("Files");
}

QVariant FilesModel::getAllFilesByThingLocalId(int thingLocalId)
{
    QVariantMap map;
    map[":thing_id_local"] = thingLocalId;
    return QVariant::fromValue(this->getAllByCondition("thing_id_local=:thing_id_local",map));
}

QVariant FilesModel::getAllFilesByThingServerId(int thingServerId)
{
    QVariantMap map;
    map[":thing_id_server"] = thingServerId;
    return QVariant::fromValue(this->getAllByCondition("thing_id_server=:thing_id_server",map));
}

int FilesModel::addNewFile(QVariantMap data)
{
    ThingsModel thingModel;

    data["thing_id_server"] = data["thing_id"];
    data["thing_id_local"] = thingModel.getThingByServerId(data["thing_id"].toInt()).toMap().value("local_id").toInt();

    data["server_id"] = data["id"];

    data.remove("id");
    data.remove("thing_id");
    return this->insert(data);
}

void FilesModel::addMulltiFiles(QList<QVariantMap> filesList)
{
    ThingsModel thingModel;

    foreach(QVariantMap fileRow,filesList)
    {
        fileRow["thing_id_server"] = fileRow["thing_id"];
        fileRow["thing_id_local"] = thingModel.getThingByServerId(fileRow["thing_id"].toInt()).toMap().value("local_id").toInt();

        fileRow["server_id"] = fileRow["id"];

        fileRow.remove("id");
        fileRow.remove("thing_id");

        this->insert(fileRow);
    }
}

bool FilesModel::deleteFilesByServerId(QString idList)
{
    return this->deleteRows("server_id",idList);
}

bool FilesModel::deleteFilesByLocalId(QString idList)
{
    return this->deleteRows("local_id",idList);
}

void FilesModel::makeTable()
{
    QSqlQuery sqlQuery(this->db);
    QString queryStr("CREATE TABLE IF NOT EXISTS 'Files' ("
                     "'local_id'	INTEGER NOT NULL UNIQUE,"
                     "'server_id'	INTEGER,"
                     "'user_id'	INTEGER,"
                     "'thing_id_local'	INTEGER NOT NULL,"
                     "'thing_id_server'	INTEGER,"
                     "'file'	TEXT NOT NULL,"
                     "'file_name'	TEXT NOT NULL,"
                     "'file_extension'	TEXT NOT NULL,"
                     "'register_date'	INTEGER NOT NULL DEFAULT CURRENT_TIMESTAMP,"
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
