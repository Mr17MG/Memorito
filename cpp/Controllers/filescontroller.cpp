#include "filescontroller.h"

FilesController::FilesController(QObject *parent)
    : QObject(parent)
{
    logger = Logger::getInstance();
    baseApi = new BaseController();
    filesModel = new FilesModel();

    QObject::connect(baseApi,SIGNAL(requestError(int,QNetworkReply::NetworkError,QByteArray,QNetworkAccessManager::Operation,QUrl)),
                     this,SLOT(onRequestError(int,QNetworkReply::NetworkError,QByteArray,QNetworkAccessManager::Operation,QUrl)));

    QObject::connect(baseApi,SIGNAL(requestSuccess(int,QJsonObject,QNetworkAccessManager::Operation,QUrl)),
                     this,SLOT(onRequestSuccess(int,QJsonObject,QNetworkAccessManager::Operation,QUrl)));

    baseApi->setApiName("files");
    baseApi->setHasAuthentication(true);
}

void FilesController::getAllFiles()
{
    QNetworkRequest getReq = baseApi->createRequest();
    baseApi->sendRequest(QNetworkAccessManager::GetOperation,getReq);
}

void FilesController::getFilesByListOfId(QString list)
{
    QUrlQuery query;
    query.addQueryItem("file_id_list",list);
    QNetworkRequest getReq = baseApi->createRequest("",&query);
    baseApi->sendRequest(QNetworkAccessManager::GetOperation,getReq);
}

void FilesController::getFileById(int id)
{
    QNetworkRequest getReq = baseApi->createRequest(QString::number(id));
    baseApi->sendRequest(QNetworkAccessManager::GetOperation,getReq);
}

void FilesController::addNewFiles(QString rawJson)
{
    QJsonDocument doc = QJsonDocument::fromJson(rawJson.toUtf8());
    QNetworkRequest postReq = baseApi->createRequest();
    baseApi->sendRequest(QNetworkAccessManager::PostOperation,postReq,&doc);
}

void FilesController::deleteFile(int id)
{
    QNetworkRequest deleteReq = baseApi->createRequest(QString::number(id));
    baseApi->sendRequest(QNetworkAccessManager::DeleteOperation,deleteReq);
}


void FilesController::onRequestError(int statusCode, QNetworkReply::NetworkError error, QByteArray rawData,QNetworkAccessManager::Operation method, QUrl url)
{
    qDebug() << statusCode << error << rawData << method << url;
}

void FilesController::onRequestSuccess(int statusCode, QJsonObject data,QNetworkAccessManager::Operation method, QUrl url)
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
                filesModel->addMulltiFiles(data);
            }
        }
    }
    else if(method == QNetworkAccessManager::PostOperation)
    {
        QJsonArray result = data["result"].toArray();
        QList<int> idList;
        foreach(QJsonValue row, result)
        {
            int insertId = filesModel->addNewFile(row.toObject().toVariantMap());
            idList.append(insertId);
        }
        emit newFilesAdded(idList);

        if(result.count()>1)
            emit logger->successLog(tr("فایل‌های جدید اضافه شدند."));
        else
            emit logger->successLog(tr("فایل جدید اضافه شد."));
    }
    else if(method == QNetworkAccessManager::DeleteOperation)
    {
        filesModel->deleteFilesByServerId(path);
        emit this->fileDeleted(path.toInt());
        emit logger->successLog(tr("فایل مورد نظر حذف شد."));
    }
}
