#ifndef FRIENDSCONTROLLER_H
#define FRIENDSCONTROLLER_H

#include "basecontroller.h"
#include "../Models/friendsmodel.h"

class FriendsController : public QObject
{
    Q_OBJECT
    BaseController *baseApi;
    Logger *logger;
    FriendsModel *friendsModel;

public:
    explicit FriendsController(QObject *parent = nullptr);

    Q_INVOKABLE void getFriends(QString idList="");
    Q_INVOKABLE void getFriendById(int friendId);
    Q_INVOKABLE void addNewFriend(int friend1, QString friend1Nickname, int friend2, QString friend2Nickname);
    Q_INVOKABLE void editFriend(int friendId, int friend1Id, QString friend1Nickname, int friend2Id, QString friend2Nickname, int friendshipState);
    Q_INVOKABLE void updateFriendshipState(int friendId, int friendshipState);
    Q_INVOKABLE void deleteFriend(int id);
    Q_INVOKABLE void searchFriend(QString text);

public slots:
    void onRequestError(int statusCode, QNetworkReply::NetworkError error, QByteArray rawData,QNetworkAccessManager::Operation method, QUrl url);
    void onRequestSuccess(int statusCode, QJsonObject data,QNetworkAccessManager::Operation method, QUrl url);

signals:
    void newFriendAdded(int);
    void friendUpdated(int,QVariantMap);
    void friendDeleted(int);
    void friendSerched(QVariant);
};

#endif // FRIENDSCONTROLLER_H
