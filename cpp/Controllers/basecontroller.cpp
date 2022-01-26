#include "basecontroller.h"


BaseController::BaseController()
{
    netManager = new QNetworkAccessManager();
}

void BaseController::setRequestHeaders(QNetworkRequest *request)
{
    request->setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
}

void BaseController::setAutheticationHeader(QNetworkRequest *request)
{
    QString credentialsString = QString("%1:%2").arg(this->getUsername(),this->getPassword());
    QByteArray credentialsArray = credentialsString.toLocal8Bit().toBase64();
    QString headerData = "Basic " + credentialsArray;
    request->setRawHeader("Authorization", headerData.toLocal8Bit());
}

QNetworkRequest BaseController::createRequest(QString path, QUrlQuery *query)
{
    QUrl url = QString("%1/%2/%3/%4").arg(this->getDomain(), this->getBaseUrl(), this->getApiName(), path);

    if(query != nullptr)
        url.setQuery(query->query());

    QNetworkRequest req(url);

    setRequestHeaders(&req);

    if(this->getHasAuthentication())
        setAutheticationHeader(&req);

    if(url.scheme() == "https")
    {
        QSslConfiguration conf = req.sslConfiguration();
        conf.setPeerVerifyMode(QSslSocket::VerifyNone);
        req.setSslConfiguration(conf);
    }

    return req;
}

const QString &BaseController::getApiName() const
{
    return apiName;
}

void BaseController::setApiName(const QString &newApiName)
{
    apiName = newApiName;
}

bool BaseController::getHasAuthentication() const
{
    return hasAuthentication;
}

void BaseController::setHasAuthentication(bool newHasAuthentication)
{
    hasAuthentication = newHasAuthentication;
}

QString BaseController::getUsername()
{
    UsersModel userModel;
    QString email = userModel.getUserEmail();
    return email;
}

QString BaseController::getPassword()
{
    UsersModel userModel;
    QString auth = userModel.getUserAuthToken();
    return auth;
}

QString BaseController::getDomain()
{
#ifdef QT_DEBUG
    return "https://memorito.local";
#else
    return "https://memorito.ir";
#endif
}

QString BaseController::getBaseUrl()
{
    return "api/v1";
}

QJsonObject BaseController::parseToJsonObject(QByteArray rawData)
{
    QJsonDocument doc;
    QJsonParseError jsonError;
    QJsonObject jsonObj = doc.fromJson(rawData, &jsonError).object();

    if(jsonError.error != QJsonParseError::NoError)
    {
        QString dataString(rawData);
        if(dataString.indexOf("{")!= -1 && dataString.lastIndexOf("}")!= -1)
        {
            dataString = dataString.remove(0,dataString.indexOf("{"));
            jsonObj = doc.fromJson(dataString.toLatin1(), &jsonError).object();
            if(jsonError.error != QJsonParseError::NoError)
                emit parseError(jsonError.errorString());
        }
    }

    return jsonObj;
}

void BaseController::sendRequest(QNetworkAccessManager::Operation method, QNetworkRequest request, QJsonDocument *data, bool hasBusyLoaderInGui)
{
    if(hasBusyLoaderInGui)
    {
        Logger *logger = Logger::getInstance();
        emit logger->loading("");
    }

    switch (method)
    {
    case QNetworkAccessManager::GetOperation:
        netReply = netManager->get(request);
        break;
    case QNetworkAccessManager::PostOperation:
        netReply = netManager->post(request,(data==nullptr)?"":data->toJson(QJsonDocument::Compact));
        break;
    case QNetworkAccessManager::CustomOperation:
        netReply = netManager->sendCustomRequest(request,"PATCH",(data==nullptr)?"":data->toJson(QJsonDocument::Compact));
        break;
    case QNetworkAccessManager::DeleteOperation:
        netReply = netManager->deleteResource(request);
        break;
    default:
        break;
    }
    netReply->setProperty("method",method);

    QObject::connect(netReply, SIGNAL(readyRead()),
                     this, SLOT(readData()));

    QObject::connect(netReply, SIGNAL(finished()),
                     this, SLOT(finishReading()));
}


void BaseController::readData()
{
    dataBuffer.append(netReply->readAll());
}

void BaseController::finishReading()
{
    Logger *logger = Logger::getInstance();
    emit logger->loaded();

    int statusCode = netReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

    int methodInt = netReply->property("method").toInt();
    QNetworkAccessManager::Operation method;

    switch (methodInt)
    {
    case QNetworkAccessManager::GetOperation:
        method = QNetworkAccessManager::GetOperation;
        break;
    case QNetworkAccessManager::PostOperation:
        method = QNetworkAccessManager::PostOperation;
        break;
    case QNetworkAccessManager::CustomOperation:
        method = QNetworkAccessManager::CustomOperation;
        break;
    case QNetworkAccessManager::DeleteOperation:
        method = QNetworkAccessManager::DeleteOperation;
        break;
    default:
        method = QNetworkAccessManager::GetOperation;
        break;
    }

    if(netReply->error() != QNetworkReply::NoError)
    {
        if(netReply->error() == QNetworkReply::ConnectionRefusedError)
            emit noNetworkError();
        else {

            emit requestError(statusCode, netReply->error(),dataBuffer,method,netReply->url());
        }
    }
    else {
        //HTTPS code of reply
        if(statusCode != 204) // 204 means response is not content
        {
            QJsonObject result = this->parseToJsonObject(dataBuffer);
            emit requestSuccess(statusCode,result,method,netReply->url());
        }
        else
            emit requestSuccess(statusCode,QJsonObject{},method,netReply->url());

    }
    dataBuffer.clear();
}

