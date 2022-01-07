#ifndef CHANGESCONTROLLER_H
#define CHANGESCONTROLLER_H

#include <QObject>
#include "basecontroller.h"
#include "../logger.h"
#include "../Models/changesmodel.h"

class ChangesController : public QObject
{
    Q_OBJECT
    BaseController *baseApi;
    Logger *logger;
    ChangesModel *changesModel;

public:
    explicit ChangesController(QObject *parent = nullptr);

public slots:
    void onRequestError(int statusCode, QNetworkReply::NetworkError error, QByteArray rawData,QNetworkAccessManager::Operation method, QUrl url);
    void onRequestSuccess(int statusCode, QJsonObject data,QNetworkAccessManager::Operation method, QUrl url);

signals:

};

#endif // CHANGESCONTROLLER_H
