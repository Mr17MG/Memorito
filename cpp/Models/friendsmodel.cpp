#include "friendsmodel.h"

FriendsModel::FriendsModel()
{
    this->makeTable();
    this->setTableName("Friends");
}

QVariant FriendsModel::getAllFriends()
{
    return QVariant::fromValue(this->getAll());
}

QVariant FriendsModel::getFriendById(int id)
{
    QVariantMap map;
    map[":local_id"] = id;
    map[":server_id"] = id;
    QList rows = this->getAllByCondition("local_id=:local_id OR server_id=:server_id",map);
    return QVariant::fromValue(rows[0]);
}

int FriendsModel::addNewFriend(QVariantMap data)
{
    data["server_id"] = data["id"];
    data.remove("id");
    return this->insert(data);
}

int FriendsModel::addNewFriend(int userId, QString username,QString friend2Nickname)
{
    QVariantMap data;
    data["friend1"] = userId;
    data["friend1_nickname"] = username;
    data["friend2_nickname"] = friend2Nickname;
    data["friendship_state"] = 2;

    return this->insert(data);
}

void FriendsModel::addMulltiFriend(QList<QVariantMap> friendList)
{
    foreach(QVariantMap friendRow,friendList)
    {
        friendRow["server_id"] = friendRow["id"];
        friendRow.remove("id");
        this->insert(friendRow);
    }
}

bool FriendsModel::deleteFriendByServerId(int id)
{
    return this->deleteRows("server_id",QString::number(id));
}

bool FriendsModel::deleteFriendByLocalId(int id)
{
    return this->deleteRows("local_id",QString::number(id));
}

QVariant FriendsModel::updateFriendByServerId(int serverId, QVariantMap data)
{
    return this->update("server_id",serverId,data);
}

QVariant FriendsModel::updateFriendByLocalId(int localId, QVariantMap data)
{
    return this->update("local_id",localId,data);
}

void FriendsModel::makeTable()
{
    QSqlQuery sqlQuery(this->db);
    QString queryStr("CREATE TABLE IF NOT EXISTS 'Friends' ("
                     "'local_id'	INTEGER NOT NULL UNIQUE,"
                     "'server_id'	INTEGER,"
                     "'friend1'	INTEGER,"
                     "'friend1_nickname'	TEXT,"
                     "'friend2'	INTEGER,"
                     "'friend2_nickname'	TEXT,"
                     "'friendship_state'	INTEGER DEFAULT 1 CHECK(friendship_state IN (1,2,3,4)),"
                     "PRIMARY KEY('local_id' AUTOINCREMENT)"
                     ");"
                     );

    sqlQuery.prepare(queryStr);
    if(sqlQuery.exec() != true)
    {
        QSqlError error = sqlQuery.lastError();
        emit logger->warningLog(error.text());
    }
}
