#ifndef BASEMODEL_H
#define BASEMODEL_H

#include <QDir>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QSqlDatabase>
#include <QStandardPaths>
#include <QCoreApplication>

#include "../logger.h"

class BaseModel
{
public:
    BaseModel();
    ~BaseModel();

    static QSqlDatabase db;
    Logger * logger;
    QString tableName;

    int insert(QVariantMap data);
    QVariant update(QString columnName, int id, QVariantMap data);
    bool deleteRows(QString columnName, QString Ids);

    QList<QVariantMap> getAll();
    QVariant getByLocalId(int id);
    QVariant getByServerId(int id);
    QList<QVariantMap> getAllByCondition(QString condition,QVariantMap data);
    QList<QVariantMap> getByQuery(QString query);

    const QString &getTableName() const;
    void setTableName(const QString &newTableName);

};

#endif // BASEMODEL_H
