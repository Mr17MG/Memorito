#include "userscontroller.h"

UsersController::UsersController(QObject *parent)
    : QObject(parent)
{
    logger = Logger::getInstance();
    baseApi = new BaseController();
    userModel = new UsersModel();

    QObject::connect(baseApi,SIGNAL(requestError(int,QNetworkReply::NetworkError,QByteArray,QNetworkAccessManager::Operation,QUrl)),
                     this,SLOT(onRequestError(int,QNetworkReply::NetworkError,QByteArray,QNetworkAccessManager::Operation,QUrl)));

    QObject::connect(baseApi,SIGNAL(requestSuccess(int,QJsonObject,QNetworkAccessManager::Operation,QUrl)),
                     this,SLOT(onRequestSuccess(int,QJsonObject,QNetworkAccessManager::Operation,QUrl)));

    baseApi->setHasAuthentication(false);
}

void UsersController::signUp(QString username, QString email, QString password)
{
    SystemInfo sysInfo;
    Security security;
    baseApi->setApiName("account");
    QJsonObject json
    {
        {"email", email},
        {"username", username},
        {"password", security.hashPass(password)},
        {"os_name", sysInfo.getOsName()} ,
        {"cpu_arch", sysInfo.getCpuArch()},
        {"app_name", sysInfo.getAppName()},
        {"os_version", sysInfo.getOsVersion()},
        {"app_version", sysInfo.getAppVersion()},
        {"kernel_version", sysInfo.getKernelVersion()},
        {"machine_unique_id", sysInfo.getMachineUniqueId()}
    };

    QJsonDocument doc(json);

    QNetworkRequest postReq = baseApi->createRequest("signup");
    baseApi->sendRequest(QNetworkAccessManager::PostOperation,postReq,&doc);
}

void UsersController::signIn(QString identifier, QString password)
{
    SystemInfo sysInfo;
    Security security;
    baseApi->setApiName("account");
    QJsonObject json
    {
        {"identifier", identifier},
        {"password", security.hashPass(password)},
        {"os_name", sysInfo.getOsName()},
        {"app_name", sysInfo.getAppName()},
        {"cpu_arch", sysInfo.getCpuArch()},
        {"os_version", sysInfo.getOsVersion()},
        {"app_version", sysInfo.getAppVersion()},
        {"kernel_version", sysInfo.getKernelVersion()},
        {"machine_unique_id", sysInfo.getMachineUniqueId()}
    };

    QJsonDocument doc(json);

    QNetworkRequest postReq = baseApi->createRequest("signin");
    baseApi->sendRequest(QNetworkAccessManager::PostOperation,postReq,&doc);
}

void UsersController::validateOTP(QString identifier, QString otp)
{
    SystemInfo sysInfo;
    baseApi->setApiName("account");
    QJsonObject json
    {
        {"identifier", identifier},
        {"otp", otp},
        {"machine_unique_id", sysInfo.getMachineUniqueId()}
    };

    QJsonDocument doc(json);

    QNetworkRequest postReq = baseApi->createRequest("validate-otp");
    baseApi->sendRequest(QNetworkAccessManager::PostOperation,postReq,&doc);
}

void UsersController::forgetPass(QString identifier)
{
    SystemInfo sysInfo;
    Security security;
    baseApi->setApiName("password");
    QJsonObject json
    {
        {"identifier", identifier},
        {"os_name", sysInfo.getOsName()},
        {"app_name", sysInfo.getAppName()},
        {"cpu_arch", sysInfo.getCpuArch()},
        {"os_version", sysInfo.getOsVersion()},
        {"app_version", sysInfo.getAppVersion()},
        {"kernel_version", sysInfo.getKernelVersion()},
        {"machine_unique_id", sysInfo.getMachineUniqueId()}
    };

    QJsonDocument doc(json);

    QNetworkRequest postReq = baseApi->createRequest("forget-pass");
    baseApi->sendRequest(QNetworkAccessManager::PostOperation,postReq,&doc);
}

void UsersController::resetPass(QString identifier, QString otp, QString password)
{
    SystemInfo sysInfo;
    Security security;
    baseApi->setApiName("password");
    QJsonObject json
    {
        {"otp", otp},
        {"identifier", identifier},
        {"password", security.hashPass(password)},
        {"machine_unique_id", sysInfo.getMachineUniqueId()}
    };
    QJsonDocument doc(json);
    QNetworkRequest postReq = baseApi->createRequest("reset-pass");
    baseApi->sendRequest(QNetworkAccessManager::PostOperation,postReq,&doc);
}

void UsersController::resendOTP(QString identifier)
{
    SystemInfo sysInfo;
    baseApi->setApiName("password");
    QJsonObject json
    {
        {"identifier", identifier},
        {"machine_unique_id", sysInfo.getMachineUniqueId()}
    };

    QJsonDocument doc(json);

    QNetworkRequest postReq = baseApi->createRequest("resend-otp");
    baseApi->sendRequest(QNetworkAccessManager::PostOperation,postReq,&doc);
}

void UsersController::validateToken()
{
    baseApi->setApiName("account");
    QString authToken = userModel->getUserAuthToken();

    SystemInfo sysInfo;
    QJsonObject json
    {
        {"auth_token", authToken},
        {"machine_unique_id", sysInfo.getMachineUniqueId()}
    };

    QJsonDocument doc(json);

    QNetworkRequest postReq = baseApi->createRequest("validate-token");
    baseApi->sendRequest(QNetworkAccessManager::PostOperation,postReq,&doc,false);
}

void UsersController::deleteAccount(int userId, QString password)
{
    baseApi->setApiName("account");

    Security security;
    QJsonObject json
    {
        {"password", security.hashPass(password)},
    };

    QJsonDocument doc(json);

    QNetworkRequest delReq = baseApi->createRequest(QString("delete-account/%1").arg(userId));
    baseApi->sendRequest(QNetworkAccessManager::DeleteOperation, delReq, &doc);
}

void UsersController::getUser(int userId)
{
    baseApi->setApiName("users");
    SystemInfo sysInfo;

    QUrlQuery query;
    query.addQueryItem("machine_unique_id",sysInfo.getMachineUniqueId());

    QNetworkRequest getReq = baseApi->createRequest(QString::number(userId),&query);
    baseApi->sendRequest(QNetworkAccessManager::GetOperation, getReq);
}

void UsersController::editUser(int userId, QString rawjson)
{
    baseApi->setApiName("users");
    QJsonDocument doc = QJsonDocument::fromJson(rawjson.toLatin1());

    QNetworkRequest patchReq = baseApi->createRequest(QString::number(userId));
    baseApi->sendRequest(QNetworkAccessManager::CustomOperation, patchReq,&doc);
}

void UsersController::onRequestError(int statusCode, QNetworkReply::NetworkError error, QByteArray rawData,QNetworkAccessManager::Operation method, QUrl url)
{
    Q_UNUSED(method)
    QString path = url.path().split("/").last().toLower();
    if(path == "signup")
    {
        if(error == QNetworkReply::ContentConflictError || statusCode == 409)
        {
            if(rawData.contains("username"))
            {
                emit logger->errorLog(tr("نام کاربری که انتخاب کردی، قبلا توسط یکنفر دیگه انتخاب شده، لطفا نام کاربری دیگه‌ای انتخاب کن."));
                emit this->wrongUsername();
            }
            else if(rawData.contains("email"))
            {
                emit logger->errorLog(tr("یک حساب با ایمیلی که وارد کردی وجود داره اگه مال خودته از بخش ورود به حساب، وارد حسابت شو."));
                emit this->wrongEmail();
            }

        }
    }
    else if(path == "signin" || path == "forget-pass" || path=="resend-otp" || path == "delete-account")
    {
        if(rawData.contains("username"))
        {
            emit logger->errorLog(tr("نام کاربری یا ایمیلی که وارد کردی اشتباهه."));
            emit this->wrongUsername();
        }
        else if(rawData.contains("password"))
        {
            emit logger->errorLog(tr("رمزعبوری که وارد کردی اشتباهه."));
            emit this->wrongPassword();
        }
    }

    else if(path == "reset-pass")
    {
        if(statusCode == 401)
        {
            emit logger->errorLog(tr("نام کاربری یا ایمیلی که وارد کردی اشتباهه."));
        }
        else if(statusCode == 403)
        {
            emit logger->errorLog(tr("کد تائیدی که ارسال کردی، اشتباهه دوباره تلاش کن."));
        }
    }
    else {
        QJsonDocument doc= QJsonDocument::fromJson(rawData);
        emit logger->log(doc["message"].toString(),Logger::Error);
    }


}

void UsersController::onRequestSuccess(int statusCode, QJsonObject data,QNetworkAccessManager::Operation method, QUrl url)
{
    Q_UNUSED(method)
    QString path=  url.path().split("/").last().toLower();
    if(path == "signup")
    {
        if(statusCode == 201)
        {
            QJsonValue result = data["result"];
            emit changePageToAuthentication(false,result["email"].toString());
        }
    }
    else if(path == "validate-otp")
    {
        emit logger->successLog(tr("به مموریتو خوش آمدی"));

        QJsonValue result = data["result"];
        userModel->addNewUser(result["username"].toString(),result["id"].toInt(),result["email"].toString(),
                result["auth_token"].toString(),result["avatar"].toString(),result["two_step"].toBool(),true,result["has_aes_key"].toBool());
        emit this->userAuthenticated();
    }
    else if(path == "signin")
    {
        QJsonValue result = data["result"];
        userModel->addNewUser(result["username"].toString(),result["id"].toInt(),result["email"].toString(),
                result["auth_token"].toString(),
                result["avatar"].toString(),result["two_step"].toBool(),true,result["has_aes_key"].toBool());
        emit this->userAuthenticated();

    }
    else if(path == "forget-pass")
    {
        QJsonValue result = data["result"];
        emit changePageToAuthentication(true,result["email"].toString());
    }
    else if(path == "reset-pass")
    {
        QJsonValue result = data["result"];
        userModel->addNewUser(result["username"].toString(),result["id"].toInt(),result["email"].toString(),
                result["auth_token"].toString(),
                result["avatar"].toString(),result["two_step"].toBool(),true,result["has_aes_key"].toBool());
        emit this->userAuthenticated();
    }
    else if(path == "resend-otp")
    {
        emit logger->infoLog(tr("کد تایید دوباره به ایمیلت ارسال شد."));
    }
    else if(path == "delete-account")
    {
        emit logger->infoLog(tr("حساب کاربریت با موفقیت حذف شد، ناراحت شدم که از پیشم رفتی :("));
        emit this->accountDeleted();
    }
    else if(path == "validate-token")
    {
        emit this->userAuthenticated();
    }
    else {
        emit logger->log(QString("Success: %1").arg(statusCode),Logger::Success);
    }

}
