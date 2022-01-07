#include "usersmodel.h"

UsersModel::UsersModel()
{
    this->makeTable();
    this->setTableName("Users");
}

void UsersModel::addNewUser(QString username, int serverId, QString email, QString authToken, QString avatar, bool two_step, bool hasOnlineAccount, bool hasAesKey)
{
    QVariantMap data;
    data["username"] = username;
    if(serverId>-1)
        data["server_id"] = serverId;
    if(email != "")
        data["email"]= email;
    if(authToken != "")
        data["auth_token"]= authToken;
    if(avatar != "")
        data["avatar"]= avatar;

    data["two_step"]= two_step?1:0;
    data["has_online_account"]= hasOnlineAccount?1:0;
    data["has_aes_key"]= hasAesKey?1:0;

    this->insert(data);
}

QVariant UsersModel::getUsers()
{
    return QVariant::fromValue(this->getAll());
}

QVariant UsersModel::getUserByUserId(int userId)
{
    QVariantMap map;
    map[":local_id"] = userId;
    map[":server_id"] = userId;
    QList user = this->getAllByCondition("local_id=:local_id OR server_id=:server_id",map);
    return QVariant::fromValue(user[0]);
}

QString UsersModel::getUserAuthToken()
{
    QList user = this->getAll();
    return user[0]["auth_token"].toString();
}

QString UsersModel::getUserEmail()
{
    QList user = this->getAll();
    return user[0]["email"].toString();
}

void UsersModel::makeTable()
{
    QSqlQuery sqlQuery(this->db);
    QString queryStr("CREATE TABLE IF NOT EXISTS 'Users' ("
                     "'local_id'	INTEGER NOT NULL UNIQUE,"
                     "'server_id'	INTEGER DEFAULT NULL UNIQUE,"
                     "'username'	TEXT NOT NULL UNIQUE,"
                     "'email'	TEXT DEFAULT NULL,"
                     "'auth_token'	TEXT DEFAULT NULL,"
                     "'local_password'	TEXT DEFAULT NULL,"
                     "'avatar'	TEXT DEFAULT NULL,"
                     "'two_step'	INTEGER DEFAULT 0 CHECK(two_step IN (0,1)),"
                     "'has_online_account'	INTEGER DEFAULT 0 CHECK(has_online_account IN (0,1)),"
                     "'has_aes_key'	INTEGER DEFAULT 0 CHECK(has_aes_key IN (0,1)),"
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
