#include "contextscontroller.h"

ContextsController::ContextsController(QObject *parent)
    : QObject(parent)
{
    logger = Logger::getInstance();
    baseApi = new BaseController();
    contextsModel = new ContextsModel();

    QObject::connect(baseApi,SIGNAL(requestError(int,QNetworkReply::NetworkError,QByteArray,QNetworkAccessManager::Operation,QUrl)),
                     this,SLOT(onRequestError(int,QNetworkReply::NetworkError,QByteArray,QNetworkAccessManager::Operation,QUrl)));

    QObject::connect(baseApi,SIGNAL(requestSuccess(int,QJsonObject,QNetworkAccessManager::Operation,QUrl)),
                     this,SLOT(onRequestSuccess(int,QJsonObject,QNetworkAccessManager::Operation,QUrl)));

    baseApi->setApiName("contexts");
    baseApi->setHasAuthentication(true);
}

void ContextsController::getAllContexts()
{
    QNetworkRequest getReq = baseApi->createRequest();
    baseApi->sendRequest(QNetworkAccessManager::GetOperation,getReq);
}

void ContextsController::getContexts(QString idList)
{
    QUrlQuery query;
    query.addQueryItem("context_id_list",idList);
    QNetworkRequest getReq = baseApi->createRequest("",&query);
    baseApi->sendRequest(QNetworkAccessManager::GetOperation, getReq);
}

void ContextsController::getContextById(int contextId)
{
    QNetworkRequest getReq = baseApi->createRequest(QString::number(contextId));
    baseApi->sendRequest(QNetworkAccessManager::GetOperation, getReq);
}

void ContextsController::addNewContext(QString contextName)
{
    QJsonObject json
    {
        {"context_name", contextName}
    };

    QJsonDocument doc(json);
    QNetworkRequest postReq = baseApi->createRequest();
    baseApi->sendRequest(QNetworkAccessManager::PostOperation,postReq,&doc);
}

void ContextsController::editContext(int contextId,QString contextName)
{
    QJsonObject json
    {
        {"context_name", contextName}
    };

    QJsonDocument doc(json);
    QNetworkRequest postReq = baseApi->createRequest(QString::number(contextId));
    baseApi->sendRequest(QNetworkAccessManager::CustomOperation,postReq,&doc);
}

void ContextsController::deleteContext(int id)
{
    QNetworkRequest deleteReq = baseApi->createRequest(QString::number(id));
    baseApi->sendRequest(QNetworkAccessManager::DeleteOperation,deleteReq);
}

void ContextsController::onRequestError(int statusCode, QNetworkReply::NetworkError error, QByteArray rawData, QNetworkAccessManager::Operation method, QUrl url)
{
    qDebug()<< statusCode << error << rawData << method << url;
}

void ContextsController::onRequestSuccess(int statusCode, QJsonObject data, QNetworkAccessManager::Operation method, QUrl url)
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
                contextsModel->addMulltiContext(data);
            }
        }
    }
    else if(method == QNetworkAccessManager::PostOperation)
    {
        QJsonObject result = data["result"].toObject();
        int insertRow = contextsModel->addNewContext(result.toVariantMap());
        emit newContextAdded(insertRow);
        emit logger->successLog(tr("محل انجام جدید اضافه شد."));
    }
    else if(method == QNetworkAccessManager::CustomOperation)
    {
        QJsonObject result = data["result"].toObject();
        result["server_id"] = result["id"];
        result.remove("id");

        contextsModel->updateContextByServerId(path.toInt(),result.toVariantMap());
        emit contextUpdated(path.toInt(),result["context_name"].toString());
        emit logger->successLog(tr("محل انجام مورد نظر بروزرسانی شد."));
    }
    else if(method == QNetworkAccessManager::DeleteOperation)
    {
        contextsModel->deleteContextByServerId(path.toInt());
        emit this->contextDeleted(path.toInt());
        emit logger->successLog(tr("محل انجام مورد نظر حذف شد."));
    }
}
