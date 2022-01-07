#ifndef CONTEXTSCONTROLLER_H
#define CONTEXTSCONTROLLER_H

#include <QObject>
#include "basecontroller.h"
#include "../logger.h"
#include "../Models/contextsmodel.h"

class ContextsController : public QObject
{
    Q_OBJECT
    BaseController *baseApi;
    Logger *logger;
    ContextsModel *contextsModel;

public:
    explicit ContextsController(QObject *parent = nullptr);

    Q_INVOKABLE void getContexts(QString idList="");
    Q_INVOKABLE void getContextById(int contextId);
    Q_INVOKABLE void addNewContext(QString contextName);
    Q_INVOKABLE void editContext(int contextId, QString contextName);
    Q_INVOKABLE void deleteContext(int id);

public slots:
    void onRequestError(int statusCode, QNetworkReply::NetworkError error, QByteArray rawData,QNetworkAccessManager::Operation method, QUrl url);
    void onRequestSuccess(int statusCode, QJsonObject data,QNetworkAccessManager::Operation method, QUrl url);

signals:
    void newContextAdded(int);
    void contextUpdated(int,QString);
    void contextDeleted(int);
};

#endif // CONTEXTSCONTROLLER_H
