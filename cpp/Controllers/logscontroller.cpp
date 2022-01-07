#include "logscontroller.h"

LogsController::LogsController(QObject *parent)
    : QObject(parent)
{
    logger = Logger::getInstance();
    baseApi = new BaseController();
    logsModel = new LogsModel();

    QObject::connect(baseApi,SIGNAL(requestError(int,QNetworkReply::NetworkError,QByteArray,QNetworkAccessManager::Operation,QUrl)),
                     this,SLOT(onRequestError(int,QNetworkReply::NetworkError,QByteArray,QNetworkAccessManager::Operation,QUrl)));

    QObject::connect(baseApi,SIGNAL(requestSuccess(int,QJsonObject,QNetworkAccessManager::Operation,QUrl)),
                     this,SLOT(onRequestSuccess(int,QJsonObject,QNetworkAccessManager::Operation,QUrl)));

    baseApi->setApiName("logs");
    baseApi->setHasAuthentication(true);
}

void LogsController::addNewLog(int thingId, QString logText)
{
    QJsonObject json
    {
        {"log_text", logText},
        {"thing_id", thingId},
    };

    QJsonDocument doc(json);

    QNetworkRequest postReq = baseApi->createRequest();
    baseApi->sendRequest(QNetworkAccessManager::PostOperation,postReq,&doc);
}


void LogsController::onRequestError(int statusCode, QNetworkReply::NetworkError error, QByteArray rawData,QNetworkAccessManager::Operation method, QUrl url)
{
    qDebug()<< statusCode << error << rawData << method << url;
}

void LogsController::onRequestSuccess(int statusCode, QJsonObject data,QNetworkAccessManager::Operation method, QUrl url)
{
    Q_UNUSED(url)
    QString path = url.path().split("/").last();
    if(method == QNetworkAccessManager::GetOperation)
    {
        if(statusCode == 200)
        {
            if(path.contains(QRegularExpression("^\\d+$")))
            {
            }
            else {
                QJsonArray result = data["result"].toArray();
                QList <QVariantMap> data;
                foreach(QJsonValue row, result){
                    data.append(row.toObject().toVariantMap());
                }
                logsModel->addMulltiLog(data);
            }
        }
    }
    else if(method == QNetworkAccessManager::PostOperation)
    {
        QJsonObject result = data["result"].toObject();
        int insertRow = logsModel->addNewLog(result.toVariantMap());
        emit newLogAdded(insertRow);
        emit logger->successLog(tr("لاگ جدید اضافه شد."));
    }
    else if(method == QNetworkAccessManager::CustomOperation)
    {
        QJsonObject result = data["result"].toObject();
        result["server_id"] = result["id"];
        result.remove("id");

        logsModel->updateLogByServerId(path.toInt(),result.toVariantMap());
        emit logUpdated(path.toInt(),result["log_name"].toString());
        emit logger->successLog(tr("لاگ مورد نظر بروزرسانی شد."));
    }
    else if(method == QNetworkAccessManager::DeleteOperation)
    {
        logsModel->deleteLogByServerId(path.toInt());
        emit this->logDeleted(path.toInt());
        emit logger->successLog(tr("لاگ مورد نظر حذف شد."));
    }
}
