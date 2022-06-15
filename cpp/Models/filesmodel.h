#ifndef FILESMODEL_H
#define FILESMODEL_H

#include <QObject>
#include "basemodel.h"
#include "thingsmodel.h"

class FilesModel : public QObject, private BaseModel
{
    Q_OBJECT
    void makeTable();

public:
    explicit FilesModel();

    Q_INVOKABLE QVariant getAllFilesByThingLocalId(int thingLocalId);
    Q_INVOKABLE QVariant getAllFilesByThingServerId(int thingServerId);

    Q_INVOKABLE int addNewFile(QVariantMap data);
    Q_INVOKABLE void addMulltiFiles(QList <QVariantMap> filesList);

    Q_INVOKABLE bool deleteFilesByServerId(QString idList);
    Q_INVOKABLE bool deleteFilesByLocalId(QString idList);

};

#endif // FILESMODEL_H
