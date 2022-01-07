#ifndef USERSCONTROLLER_H
#define USERSCONTROLLER_H

#include <QObject>
#include "basecontroller.h"
#include "../systeminfo.h"
#include "../security.h"
#include "../logger.h"
#include "../Models/usersmodel.h"

class UsersController : public QObject
{
    Q_OBJECT
    BaseController *baseApi;
    Logger *logger;
    UsersModel *userModel;

public:
    explicit UsersController(QObject *parent = nullptr);
    Q_INVOKABLE void signUp(QString username,QString email,QString password);
    Q_INVOKABLE void signIn(QString identifier,QString password);
    Q_INVOKABLE void validateOTP(QString email, QString otp);
    Q_INVOKABLE void forgetPass(QString identifier);
    Q_INVOKABLE void resetPass(QString identifier, QString otp, QString password);
    Q_INVOKABLE void resendOTP(QString identifier);
    Q_INVOKABLE void validateToken();
    Q_INVOKABLE void deleteAccount(int userId, QString password);

    Q_INVOKABLE void getUser(int userId);
    Q_INVOKABLE void editUser(int userId,QString rawjson);


public slots:
    void onRequestError(int statusCode, QNetworkReply::NetworkError error, QByteArray rawData,QNetworkAccessManager::Operation method, QUrl url);
    void onRequestSuccess(int statusCode, QJsonObject data,QNetworkAccessManager::Operation method, QUrl url);

public: signals:
    void wrongEmail();
    void wrongUsername();
    void wrongPassword();

    void changePageToAuthentication(bool, QString);
    void accountDeleted();
    void userAuthenticated();
};

#endif // USERSCONTROLLER_H
