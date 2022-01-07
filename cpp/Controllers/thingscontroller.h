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

    void getAllThings();
    void getThingsByListOfId(QString list);
    void getThingById(int id);

    void addNewThing(QString rawJson);
    void updateThing(int id, QString rawJson);
    void deleteThing(int id);

public slots:
    void onRequestError(int statusCode, QNetworkReply::NetworkError error, QByteArray rawData,QNetworkAccessManager::Operation method, QUrl url);
    void onRequestSuccess(int statusCode, QJsonObject data,QNetworkAccessManager::Operation method, QUrl url);

signals:

};

#endif // THINGSCONTROLLER_H
