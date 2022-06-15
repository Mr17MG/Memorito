#ifndef FILESCONTROLLER_H
#define FILESCONTROLLER_H

#include "basecontroller.h"
#include "../Models/filesmodel.h"

class FilesController : public QObject
{
    Q_OBJECT
    BaseController *baseApi;
    Logger *logger;
    FilesModel *filesModel;

public:
    FilesController(QObject *parent = nullptr);

    Q_INVOKABLE void getAllFiles();
    Q_INVOKABLE void getFilesByListOfId(QString list);
    Q_INVOKABLE void getFileById(int id);

    Q_INVOKABLE void addNewFiles(QString rawJson);
    Q_INVOKABLE void deleteFile(int id);

public slots:
    void onRequestError(int statusCode, QNetworkReply::NetworkError error, QByteArray rawData,QNetworkAccessManager::Operation method, QUrl url);
    void onRequestSuccess(int statusCode, QJsonObject data,QNetworkAccessManager::Operation method, QUrl url);

signals:
    void newFilesAdded(QList<int>);
    void fileDeleted(int);

};

#endif // FILESCONTROLLER_H
