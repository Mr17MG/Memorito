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
    QJsonDocument doc = QJsonDocument::fromJson(rawJson.toLatin1());
    QNetworkRequest postReq = baseApi->createRequest();
    baseApi->sendRequest(QNetworkAccessManager::PostOperation,postReq,&doc);
}

void ThingsController::updateThing(int id,QString rawJson)
{
    QJsonDocument doc = QJsonDocument::fromJson(rawJson.toLatin1());

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
}

void ThingsController::onRequestSuccess(int statusCode, QJsonObject data,QNetworkAccessManager::Operation method, QUrl url)
{

}
