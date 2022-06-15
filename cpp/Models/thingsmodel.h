#ifndef THINGSMODEL_H
#define THINGSMODEL_H

#include <QObject>
#include "basemodel.h"
#include "contextsmodel.h"

class ThingsModel : public QObject, private BaseModel
{
    Q_OBJECT
    void makeTable();
public:
    explicit ThingsModel();

    Q_INVOKABLE QVariant getAllThings();
    Q_INVOKABLE QVariant getThingsByQuery(QString query);
    Q_INVOKABLE QVariant getThingByLocalId(int localId);
    Q_INVOKABLE QVariant getThingByServerId(int serverId);

    Q_INVOKABLE QVariant getAllRefrencesGroup();
    Q_INVOKABLE QVariant getAllSomedayGroup();
    Q_INVOKABLE QVariant getAllThingsGroup();

    Q_INVOKABLE int addNewThing(QVariantMap data);
    Q_INVOKABLE void addMulltiThing(QList <QVariantMap> thingList);
    Q_INVOKABLE bool deleteThingByServerId(int id);
    Q_INVOKABLE bool deleteThingByLocalId(int id);
    Q_INVOKABLE QVariant updateThingByServerId(int serverId, QVariantMap data);
    Q_INVOKABLE QVariant updateThingByLocalId(int localId, QVariantMap data);
};

#endif // THINGSMODEL_H
