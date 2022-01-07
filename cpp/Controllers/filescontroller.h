#ifndef FILESCONTROLLER_H
#define FILESCONTROLLER_H

#include "basecontroller.h"
#include "../Models/filesmodel.h"

class FilesController : public QObject
{
    Q_OBJECT
    BaseController *baseApi;
    Logger *logger;
    FilesModel *filesModel;

public:
    FilesController(QObject *parent = nullptr);

public slots:
    void onRequestError(int statusCode, QNetworkReply::NetworkError error, QByteArray rawData,QNetworkAccessManager::Operation method, QUrl url);
    void onRequestSuccess(int statusCode, QJsonObject data,QNetworkAccessManager::Operation method, QUrl url);
};

#endif // FILESCONTROLLER_H
