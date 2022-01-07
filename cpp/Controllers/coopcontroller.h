#ifndef COOPCONTROLLER_H
#define COOPCONTROLLER_H

#include "basecontroller.h"
#include "../Models/coopmodel.h"

class CoopController : public QObject
{
    Q_OBJECT
    BaseController *baseApi;
    Logger *logger;
    CoopModel *coopModel;

public:
    CoopController(QObject *parent = nullptr);

public slots:
    void onRequestError(int statusCode, QNetworkReply::NetworkError error, QByteArray rawData,QNetworkAccessManager::Operation method, QUrl url);
    void onRequestSuccess(int statusCode, QJsonObject data,QNetworkAccessManager::Operation method, QUrl url);
};

#endif // COOPCONTROLLER_H
