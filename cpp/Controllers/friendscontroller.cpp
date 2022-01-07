#include "friendscontroller.h"

FriendsController::FriendsController(QObject *parent)
    : QObject(parent)
{
    logger = Logger::getInstance();
    baseApi = new BaseController();
    friendsModel = new FriendsModel();

    QObject::connect(baseApi,SIGNAL(requestError(int,QNetworkReply::NetworkError,QByteArray,QNetworkAccessManager::Operation,QUrl)),
                     this,SLOT(onRequestError(int,QNetworkReply::NetworkError,QByteArray,QNetworkAccessManager::Operation,QUrl)));

    QObject::connect(baseApi,SIGNAL(requestSuccess(int,QJsonObject,QNetworkAccessManager::Operation,QUrl)),
                     this,SLOT(onRequestSuccess(int,QJsonObject,QNetworkAccessManager::Operation,QUrl)));

    baseApi->setApiName("friends");
    baseApi->setHasAuthentication(true);
}

void FriendsController::getFriends(QString idList)
{
    QUrlQuery query;
    query.addQueryItem("friend_id_list",idList);
    QNetworkRequest getReq = baseApi->createRequest("",&query);
    baseApi->sendRequest(QNetworkAccessManager::GetOperation, getReq);
}

void FriendsController::getFriendById(int friendId)
{
    QNetworkRequest getReq = baseApi->createRequest(QString::number(friendId));
    baseApi->sendRequest(QNetworkAccessManager::GetOperation, getReq);
}

void FriendsController::addNewFriend(int friend1, QString friend1Nickname, int friend2, QString friend2Nickname)
{
    QJsonObject json
    {
        {"friend1", friend1},
        {"friend1_nickname", friend1Nickname},
        {"friend2_nickname", friend2Nickname},
        {"friendship_state", 1}
    };

    if(friend2 > 0){
        json.insert("friend2",friend2);
    }
    else json["friendship_state"] = 2;

    QJsonDocument doc(json);
    QNetworkRequest postReq = baseApi->createRequest();
    baseApi->sendRequest(QNetworkAccessManager::PostOperation,postReq,&doc);
}

void FriendsController::editFriend(int friendId,int friend1, QString friend1Nickname, int friend2, QString friend2Nickname,int friendshipState)
{
    QJsonObject json
    {
        {"friend1", friend1},
        {"friend1_nickname", friend1Nickname},
        {"friend2", friend2},
        {"friend2_nickname", friend2Nickname},
        {"friendship_state", friendshipState}
    };

    QJsonDocument doc(json);
    QNetworkRequest postReq = baseApi->createRequest(QString::number(friendId));
    baseApi->sendRequest(QNetworkAccessManager::CustomOperation,postReq,&doc);
}

void FriendsController::updateFriendshipState(int friendId, int friendshipState)
{
    QJsonObject json
    {
        {"friendship_state", friendshipState}
    };

    QJsonDocument doc(json);
    QNetworkRequest postReq = baseApi->createRequest(QString::number(friendId));
    baseApi->sendRequest(QNetworkAccessManager::CustomOperation,postReq,&doc);
}

void FriendsController::deleteFriend(int id)
{
    QNetworkRequest deleteReq = baseApi->createRequest(QString::number(id));
    baseApi->sendRequest(QNetworkAccessManager::DeleteOperation,deleteReq);
}

void FriendsController::searchFriend(QString text)
{
    QUrlQuery query;
    query.addQueryItem("searched_text",text);
    QNetworkRequest getReq = baseApi->createRequest("search",&query);
    baseApi->sendRequest(QNetworkAccessManager::GetOperation, getReq);
}

void FriendsController::onRequestError(int statusCode, QNetworkReply::NetworkError error, QByteArray rawData, QNetworkAccessManager::Operation method, QUrl url)
{
    QString path = url.path().split("/").last();
    if(method == QNetworkAccessManager::GetOperation)
    {
        if(path == "search")
        {
            emit logger->warningLog(tr("شخصی با ایمیل یا نام کاربری موردنظر پیدا نشد"));
        }
    }
    qDebug()<< statusCode << error << rawData << method << url;
}

void FriendsController::onRequestSuccess(int statusCode, QJsonObject data, QNetworkAccessManager::Operation method, QUrl url)
{
    Q_UNUSED(url)
    QString path = url.path().split("/").last();
    qDebug()<< data;
    if(method == QNetworkAccessManager::GetOperation)
    {
        if(statusCode == 200)
        {
            if(path == "search")
            {
                QJsonArray result = data["result"].toArray();
                emit friendSerched(result.toVariantList());
            }
            else if(path.contains(QRegularExpression("^\\d+$")))
            {
            }
            else {
                QJsonArray result = data["result"].toArray();
                QList <QVariantMap> data;
                foreach(QJsonValue row, result){
                    data.append(row.toObject().toVariantMap());
                }
                friendsModel->addMulltiFriend(data);
            }
        }
    }
    else if(method == QNetworkAccessManager::PostOperation)
    {
        QJsonObject result = data["result"].toObject();
        int insertRow = friendsModel->addNewFriend(result.toVariantMap());
        emit newFriendAdded(insertRow);
        emit logger->successLog(tr("دوست جدید اضافه شد."));
    }
    else if(method == QNetworkAccessManager::CustomOperation)
    {
        QJsonObject result = data["result"].toObject();
        result["server_id"] = result["id"];
        result.remove("id");

        friendsModel->updateFriendByServerId(path.toInt(),result.toVariantMap());
        emit friendUpdated(path.toInt(),result.toVariantMap());
        emit logger->successLog(tr("دوست مورد نظر بروزرسانی شد."));
    }
    else if(method == QNetworkAccessManager::DeleteOperation)
    {
        friendsModel->deleteFriendByServerId(path.toInt());
        emit this->friendDeleted(path.toInt());
        emit logger->successLog(tr("دوست مورد نظر حذف شد."));
    }
}
