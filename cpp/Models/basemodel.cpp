#include "basemodel.h"

QSqlDatabase BaseModel::db;

BaseModel::BaseModel()
{
    logger = Logger::getInstance();

    if(!db.isValid())
    {
        db = QSqlDatabase::addDatabase("QSQLITE");

        QDir path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        if(!path.exists())
            path.mkpath(path.path());

        db.setDatabaseName(path.path() + "/Memorito.db");
    }

    if (!db.isOpen() && !db.open())
    {
        qDebug() << "Error: connection with database failed"<< db.lastError();
        emit logger->warningLog(QCoreApplication::tr("اتصال به دیتابیس محل انجام نشد."));
    }
}

BaseModel::~BaseModel()
{
}

int BaseModel::insert(QVariantMap data)
{
    QString queryStr("INSERT INTO :table_name(:columns) VALUES(:values)");
    QStringList keys = data.keys();
    QStringList values;

    foreach(QVariant record, data.values())
    {
        QString temp;

        if(record.isNull())
            temp = "null";
        else if(record.userType() == QMetaType::QString)
            temp = QString("\'%1\'").arg(record.toString());
        else
            temp= record.toString();

        values.append(temp);
    }

    // NOTE: bindValue not work
    queryStr.replace(":table_name", this->getTableName());
    queryStr.replace(":columns", keys.join(","));
    queryStr.replace(":values", values.join(","));

    QSqlQuery sqlQuery(this->db);
    sqlQuery.prepare(queryStr);

    if(sqlQuery.exec() != true)
    {
        QSqlError error = sqlQuery.lastError();
        qDebug()<< sqlQuery.executedQuery() << error.text();
        emit logger->warningLog(error.text());
        return -1;
    }
    else return sqlQuery.lastInsertId().toInt();
}

QVariant BaseModel::update(QString columnName, int id, QVariantMap data)
{
    QSqlQuery sqlQuery(this->db);
    QString queryStr("UPDATE :table_name SET :data WHERE :column_name = :id");
    queryStr.replace(":table_name",this->getTableName());
    queryStr.replace(":column_name",columnName);

    QStringList setQuery;
    foreach(QString key, data.keys()){

        QString temp;

        if(data.value(key).isNull())
            temp = "null";
        else if(data.value(key).userType() == QMetaType::QString)
            temp = QString("\'%1\'").arg(data.value(key).toString());
        else
            temp= data.value(key).toString();

        setQuery.append(key+"="+temp);
    }
    queryStr.replace(":data",setQuery.join(","));

    sqlQuery.prepare(queryStr);
    sqlQuery.bindValue(":id",id);

    if(sqlQuery.exec() != true)
    {
        QSqlError error = sqlQuery.lastError();
        qDebug()<< sqlQuery.executedQuery() << error.text();
        emit logger->warningLog(error.text());
        return QVariantMap();
    }
    else {
        if(columnName == "server_id")
            return this->getByServerId(id);
        else
            return this->getByLocalId(id);
    }
}

bool BaseModel::deleteRows(QString columnName, QString Ids)
{
    QString queryStr("DELETE FROM :table_name WHERE :column_name IN (:ids)");
    queryStr.replace(":table_name", this->getTableName());
    queryStr.replace(":column_name",columnName);
    queryStr.replace(":ids",Ids);

    QSqlQuery sqlQuery(this->db);
    sqlQuery.prepare(queryStr);

    if(sqlQuery.exec() != true)
    {
        QSqlError error = sqlQuery.lastError();
        qDebug()<< sqlQuery.executedQuery() << error.text();
        emit logger->warningLog(error.text());
        return false;
    }
    else return true;
}

QList<QVariantMap> BaseModel::getAll()
{
    QSqlQuery sqlQuery(this->db);
    QString queryStr("SELECT * FROM :table_name");
    queryStr.replace(":table_name",this->getTableName());
    sqlQuery.prepare(queryStr);

    QList <QVariantMap> dataList;
    if(sqlQuery.exec() == true)
    {
        while (sqlQuery.next())
        {
            QSqlRecord record = sqlQuery.record();
            QVariantMap data;
            for(int i= 0; i< record.count();i++)
            {
                data[record.fieldName(i)] = record.value(i);
            }
            dataList.append(data);
        }
    }
    return dataList;
}

QVariant BaseModel::getByLocalId(int id)
{
    QVariantMap map;
    map[":server_id"] = id;
    QList user = this->getAllByCondition("local_id=:local_id",map);
    return QVariant::fromValue(user[0]);
}

QVariant BaseModel::getByServerId(int id)
{
    QVariantMap map;
    map[":server_id"] = id;
    QList user = this->getAllByCondition("server_id=:server_id",map);
    return QVariant::fromValue(user[0]);
}

QList<QVariantMap> BaseModel::getAllByCondition(QString condition, QVariantMap data)
{
    QSqlQuery sqlQuery(this->db);
    QString queryStr("SELECT * FROM :table_name WHERE :condition");
    queryStr.replace(":table_name",this->getTableName());
    queryStr.replace(":condition",condition);

    sqlQuery.prepare(queryStr);
    foreach(QString key, data.keys()){
        sqlQuery.bindValue(key,data.value(key));
    }

    QList <QVariantMap> dataList;
    if(sqlQuery.exec() == true)
    {
        while (sqlQuery.next())
        {
            QSqlRecord record = sqlQuery.record();
            QVariantMap data;
            for(int i= 0; i< record.count();i++)
            {
                data[record.fieldName(i)] = record.value(i);
            }
            dataList.append(data);
        }
    }
    return dataList;
}

const QString &BaseModel::getTableName() const
{
    return tableName;
}

void BaseModel::setTableName(const QString &newTableName)
{
    tableName = newTableName;
}
