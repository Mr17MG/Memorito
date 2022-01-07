#ifndef LOGSCONTROLLER_H
#define LOGSCONTROLLER_H

#include "basecontroller.h"
#include "../Models/logsmodel.h"

class LogsController : public QObject
{
    Q_OBJECT
    BaseController *baseApi;
    Logger *logger;
    LogsModel *logsModel;

public:
    LogsController(QObject *parent = nullptr);

    Q_INVOKABLE void addNewLog(int thingId,QString logText);
//    Q_INVOKABLE void getLogs(QString idList="");
//    Q_INVOKABLE void getLogById(int logId);
//    Q_INVOKABLE void editLog(int logId, QString logText);
//    Q_INVOKABLE void deleteLog(int id);

public slots:
    void onRequestError(int statusCode, QNetworkReply::NetworkError error, QByteArray rawData,QNetworkAccessManager::Operation method, QUrl url);
    void onRequestSuccess(int statusCode, QJsonObject data,QNetworkAccessManager::Operation method, QUrl url);

signals:
    void newLogAdded(int);
    void logUpdated(int,QString);
    void logDeleted(int);
};

#endif // LOGSCONTROLLER_H
