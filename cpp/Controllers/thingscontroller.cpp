#include "thingscontroller.h"

ThingsController::ThingsController(QObject *parent)
    : QObject(parent)
{
    logger = Logger::getInstance();
    baseApi = new BaseController();
    thingsModel = new ThingsModel();

    QObject::connect(baseApi,SIGNAL(requestError(int,QNetworkReply::NetworkError,QByteArray,QNetworkAccessManager::Operation,QUrl)),
                     this,SLOT(onRequestError(int,QNetworkReply::NetworkError,QByteArray,QNetworkAccessManager::Operation,QUrl)));

    QObject::connect(baseApi,SIGNAL(requestSuccess(int,QJsonObject,QNetworkAccessManager::Operation,QUrl)),
                     this,SLOT(onRequestSuccess(int,QJsonObject,QNetworkAccessManager::Operation,QUrl)));

    baseApi->setApiName("things");
    baseApi->setHasAuthentication(true);
}

void ThingsController::getAllThings()
{
    QNetworkRequest getReq = baseApi->createRequest();
    baseApi->sendRequest(QNetworkAccessManager::GetOperation,getReq);
}

void ThingsController::getThingsByListOfId(QString list)
{
    QUrlQuery query;
    query.addQueryItem("thing_id_list",list);
    QNetworkRequest getReq = baseApi->createRequest("",&query);
    baseApi->sendRequest(QNetworkAccessManager::GetOperation,getReq);
}

void ThingsController::getThingById(int id)
{
    QNetworkRequest getReq = baseApi->createRequest(QString::number(id));
    baseApi->sendRequest(QNetworkAccessManager::GetOperation,getReq);
}

void ThingsController::addNewThing(QString rawJson)
{
    QJsonDocument doc = QJsonDocument::fromJson(rawJson.toUtf8());
    QNetworkRequest postReq = baseApi->createRequest();
    baseApi->sendRequest(QNetworkAccessManager::PostOperation,postReq,&doc);
}

void ThingsController::updateThing(int id,QString rawJson)
{
    QJsonDocument doc = QJsonDocument::fromJson(rawJson.toUtf8());
    QNetworkRequest patchReq = baseApi->createRequest(QString::number(id));
    baseApi->sendRequest(QNetworkAccessManager::CustomOperation,patchReq ,&doc);
}

void ThingsController::deleteThing(int id)
{
    QNetworkRequest deleteReq = baseApi->createRequest(QString::number(id));
    baseApi->sendRequest(QNetworkAccessManager::DeleteOperation,deleteReq);
}

void ThingsController::onRequestError(int statusCode, QNetworkReply::NetworkError error, QByteArray rawData,QNetworkAccessManager::Operation method, QUrl url)
{
    qDebug() << statusCode<< error << rawData << method<< url;
}

void ThingsController::onRequestSuccess(int statusCode, QJsonObject data,QNetworkAccessManager::Operation method, QUrl url)
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
                thingsModel->addMulltiThing(data);
            }
        }
    }
    else if(method == QNetworkAccessManager::PostOperation)
    {
        qDebug() << data<< statusCode;
        QJsonObject result = data["result"].toObject();
        /*int insertRow = */ thingsModel->addNewThing(result.toVariantMap());
        emit newThingAdded(result["id"].toInt());
        emit logger->successLog(tr("چیز جدید اضافه شد."));
    }
    else if(method == QNetworkAccessManager::CustomOperation)
    {
        ContextsModel *contextsModel= new ContextsModel();

        QJsonObject result = data["result"].toObject();
        result["server_id"] = result["id"];
        result.remove("id");

        result["parent_id_server"] = result["parent_id"];
        result["parent_id_local"] = result["parent_id"].isNull() ? QJsonValue::fromVariant("null")
                                                                 : thingsModel->getThingByServerId(result["parent_id"].toInt()).toMap().value("local_id").toInt();
        result.remove("parent_id");

        result["context_id_server"] = result["context_id"];
        result["context_id_local"] =  result["context_id"].isNull() ? QJsonValue::fromVariant("null")
                                                                    : contextsModel->getContextByServerId(result["context_id"].toInt()).toMap().value("local_id").toInt();
        result.remove("context_id");

        contextsModel->deleteLater();

        thingsModel->updateThingByServerId(path.toInt(),result.toVariantMap());
        emit thingUpdated(path.toInt());
        emit logger->successLog(tr("چیز مورد نظر بروزرسانی شد."));
    }
//    else if(method == QNetworkAccessManager::DeleteOperation)
//    {
//        thingsModel->deleteThingByServerId(path.toInt());
//        emit this->thingDeleted(path.toInt());
//        emit logger->successLog(tr("محل انجام مورد نظر حذف شد."));
//    }
}
