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

void LogsController::getAllLogs()
{
    QNetworkRequest getReq = baseApi->createRequest();
    baseApi->sendRequest(QNetworkAccessManager::GetOperation,getReq);
}

void LogsController::getLogsByListOfId(QString list)
{
    QUrlQuery query;
    query.addQueryItem("log_id_list",list);
    QNetworkRequest getReq = baseApi->createRequest("",&query);
    baseApi->sendRequest(QNetworkAccessManager::GetOperation,getReq);
}

void LogsController::getLogById(int id)
{
    QNetworkRequest getReq = baseApi->createRequest(QString::number(id));
    baseApi->sendRequest(QNetworkAccessManager::GetOperation,getReq);
}

void LogsController::addNewLog(QString rawJson)
{
    QJsonDocument doc = QJsonDocument::fromJson(rawJson.toUtf8());
    QNetworkRequest postReq = baseApi->createRequest();
    baseApi->sendRequest(QNetworkAccessManager::PostOperation,postReq,&doc);
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

void LogsController::updateLog(int id, QString rawJson)
{
    QJsonDocument doc = QJsonDocument::fromJson(rawJson.toUtf8());
    QNetworkRequest patchReq = baseApi->createRequest(QString::number(id));
    baseApi->sendRequest(QNetworkAccessManager::CustomOperation,patchReq ,&doc);
}

void LogsController::deleteLog(int id)
{
    QNetworkRequest deleteReq = baseApi->createRequest(QString::number(id));
    baseApi->sendRequest(QNetworkAccessManager::DeleteOperation,deleteReq);
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
                logsModel->addMulltiLogs(data);
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
        ThingsModel thingsModel;

        QJsonObject result = data["result"].toObject();

        result["server_id"] = result["id"];
        result["thing_id_server"] = result["thing_id"];
        result["thing_id_local"] = thingsModel.getThingByServerId(result["thing_id"].toInt()).toMap().value("local_id").toInt();

        result.remove("id");
        result.remove("thing_id");

        logsModel->updateLogByServerId(path.toInt(),result.toVariantMap());
        emit logUpdated(path.toInt());
        emit logger->successLog(tr("لاگ مورد نظر بروزرسانی شد."));
    }
    else if(method == QNetworkAccessManager::DeleteOperation)
    {
        logsModel->deleteLogsByServerId(path);
        emit this->logDeleted(path.toInt());
        emit logger->successLog(tr("لاگ مورد نظر حذف شد."));
    }
}
