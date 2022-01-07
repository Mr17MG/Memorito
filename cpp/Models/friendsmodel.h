#ifndef FRIENDSMODEL_H
#define FRIENDSMODEL_H

#include <QObject>
#include "basemodel.h"

class FriendsModel : public QObject, private BaseModel
{
    Q_OBJECT
    void makeTable();
public:
    explicit FriendsModel();

    Q_INVOKABLE QVariant getAllFriends();
    Q_INVOKABLE QVariant getFriendById(int id);
    Q_INVOKABLE int addNewFriend(QVariantMap data);
    Q_INVOKABLE int addNewFriend(int userId, QString username,QString friend2Nickname);
    Q_INVOKABLE void addMulltiFriend(QList <QVariantMap> friendList);
    Q_INVOKABLE bool deleteFriendByServerId(int id);
    Q_INVOKABLE bool deleteFriendByLocalId(int id);
    Q_INVOKABLE QVariant updateFriendByServerId(int serverId, QVariantMap data);
    Q_INVOKABLE QVariant updateFriendByLocalId(int localId, QVariantMap data);
};

#endif // FRIENDSMODEL_H
