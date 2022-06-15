#ifndef LOGSCONTROLLER_H
#define LOGSCONTROLLER_H

#include "basecontroller.h"
#include "../Models/logsmodel.h"
#include "../Models/thingsmodel.h"

class LogsController : public QObject
{
    Q_OBJECT
    BaseController *baseApi;
    Logger *logger;
    LogsModel *logsModel;

public:
    LogsController(QObject *parent = nullptr);

    Q_INVOKABLE void getAllLogs();
    Q_INVOKABLE void getLogsByListOfId(QString list);
    Q_INVOKABLE void getLogById(int id);

    Q_INVOKABLE void addNewLog(QString rawJson);
    Q_INVOKABLE void addNewLog(int thingId,QString logText);
    Q_INVOKABLE void updateLog(int id, QString rawJson);
    Q_INVOKABLE void deleteLog(int id);

public slots:
    void onRequestError(int statusCode, QNetworkReply::NetworkError error, QByteArray rawData,QNetworkAccessManager::Operation method, QUrl url);
    void onRequestSuccess(int statusCode, QJsonObject data,QNetworkAccessManager::Operation method, QUrl url);

signals:
    void newLogAdded(int);
    void logUpdated(int);
    void logDeleted(int);
};

#endif // LOGSCONTROLLER_H
