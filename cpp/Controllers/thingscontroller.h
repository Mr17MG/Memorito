#ifndef THINGSCONTROLLER_H
#define THINGSCONTROLLER_H

#include <QObject>
#include "basecontroller.h"
#include "../Models/thingsmodel.h"

class ThingsController : public QObject
{
    Q_OBJECT
    BaseController *baseApi;
    Logger *logger;
    ThingsModel *thingsModel;

public:
    explicit ThingsController(QObject *parent = nullptr);

    Q_INVOKABLE void getAllThings();
    Q_INVOKABLE void getThingsByListOfId(QString list);
    Q_INVOKABLE void getThingById(int id);

    Q_INVOKABLE void addNewThing(QString rawJson);
    Q_INVOKABLE void updateThing(int id, QString rawJson);
    Q_INVOKABLE void deleteThing(int id);

public slots:
    void onRequestError(int statusCode, QNetworkReply::NetworkError error, QByteArray rawData,QNetworkAccessManager::Operation method, QUrl url);
    void onRequestSuccess(int statusCode, QJsonObject data,QNetworkAccessManager::Operation method, QUrl url);

signals:
    void newThingAdded(int);
    void thingUpdated(int);
    void thingDeleted(int);
};

#endif // THINGSCONTROLLER_H
