#ifndef USERSMODEL_H
#define USERSMODEL_H

#include <QObject>
#include "basemodel.h"

class UsersModel : public QObject, private BaseModel
{
    Q_OBJECT
    void makeTable();
public:
    explicit UsersModel();
    Q_INVOKABLE void addNewUser(QString username,int serverId=-1,QString email="",QString authToken="", QString avatar="", bool two_step=false,bool hasOnlineAccount=true,bool hasAesKey = false);
    Q_INVOKABLE QVariant getUsers();
    Q_INVOKABLE QVariant getUserByUserId(int userId);
    Q_INVOKABLE QString getUserAuthToken();
    Q_INVOKABLE QString getUserEmail();


};

#endif // USERSMODEL_H
