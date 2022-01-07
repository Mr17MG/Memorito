#ifndef BASECONTROLLER_H
#define BASECONTROLLER_H

#include <QObject>
#include <QUrlQuery>
#include <QByteArray>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QNetworkAccessManager>

#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QJsonArray>

#include <QSettings>

#include "../logger.h"
#include "../Models/usersmodel.h"

class BaseController : public QObject
{
    Q_OBJECT

    QByteArray dataBuffer;
    QNetworkReply *netReply;
    QNetworkAccessManager *netManager;

    QString apiName;
    bool hasAuthentication;

    QString getUsername();
    QString getPassword();
    QString getDomain();
    QString getBaseUrl();

    QJsonObject parseToJsonObject(QByteArray rawData);

    void setAutheticationHeader(QNetworkRequest *request);
    void setRequestHeaders(QNetworkRequest *request);

public:
    BaseController();

    QNetworkRequest createRequest(QString path = "", QUrlQuery *query = nullptr);
    void sendRequest(QNetworkAccessManager::Operation method, QNetworkRequest request, QJsonDocument *data = nullptr);

    const QString &getApiName() const;
    void setApiName(const QString &newApiName);

    bool getHasAuthentication() const;
    void setHasAuthentication(bool newHasAuthentication);

private slots:
    void readData();
    void finishReading();

signals:
    void requestError(int, QNetworkReply::NetworkError, QByteArray,QNetworkAccessManager::Operation, QUrl);
    void requestSuccess(int, QJsonObject,QNetworkAccessManager::Operation, QUrl);
    void noNetworkError();
    void parseError(QString);

};

#endif // BASECONTROLLER_H
