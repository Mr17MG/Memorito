#ifndef CONTEXTSMODEL_H
#define CONTEXTSMODEL_H

#include <QObject>
#include "basemodel.h"

class ContextsModel : public QObject, private BaseModel
{
    Q_OBJECT
    void makeTable();
public:
    explicit ContextsModel();

    Q_INVOKABLE QVariant getAllContexts();
    Q_INVOKABLE QVariant getContextById(int id);
    Q_INVOKABLE int addNewContext(QVariantMap data);
    Q_INVOKABLE int addNewContext(QString contextName,int userId, int serverId=-1,QString registerDate="",QString modifiedDate ="");
    Q_INVOKABLE void addMulltiContext(QList <QVariantMap> contextList);
    Q_INVOKABLE bool deleteContextByServerId(int id);
    Q_INVOKABLE bool deleteContextByLocalId(int id);
    Q_INVOKABLE QVariant updateContextByServerId(int serverId, QVariantMap data);
    Q_INVOKABLE QVariant updateContextByLocalId(int localId, QVariantMap data);

};

#endif // CONTEXTSMODEL_H
