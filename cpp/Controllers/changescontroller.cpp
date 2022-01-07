#include "changescontroller.h"

ChangesController::ChangesController(QObject *parent)
    : QObject{parent}
{
    logger = Logger::getInstance();
    baseApi = new BaseController();
    changesModel = new ChangesModel();

    QObject::connect(baseApi,SIGNAL(requestError(int,QNetworkReply::NetworkError,QByteArray,QNetworkAccessManager::Operation,QUrl)),
                     this,SLOT(onRequestError(int,QNetworkReply::NetworkError,QByteArray,QNetworkAccessManager::Operation,QUrl)));

    QObject::connect(baseApi,SIGNAL(requestSuccess(int,QJsonObject,QNetworkAccessManager::Operation,QUrl)),
                     this,SLOT(onRequestSuccess(int,QJsonObject,QNetworkAccessManager::Operation,QUrl)));

    baseApi->setApiName("changes");
    baseApi->setHasAuthentication(true);
}


void ChangesController::onRequestError(int statusCode, QNetworkReply::NetworkError error, QByteArray rawData,QNetworkAccessManager::Operation method, QUrl url)
{
}

void ChangesController::onRequestSuccess(int statusCode, QJsonObject data,QNetworkAccessManager::Operation method, QUrl url)
{

}
