#ifndef TOOLS_H
#define TOOLS_H

#include <QObject>
#include <QQmlContext>
#include <QQmlApplicationEngine>

#include <QByteArray>
#include <QFile>
#include <QSaveFile>
#include <QDir>
#include <QUrl>
#include <QStandardPaths>
#include <QImage>
#include <QPixmap>
#include <QGuiApplication>
#include <QStorageInfo>
#include <QRegularExpression>

#ifdef Q_OS_ANDROID
#include <QtCore/private/qandroidextras_p.h>
#endif

#include "exif.h"
#include "qdatepicker.h"

#include "Controllers/userscontroller.h"
#include "Models/usersmodel.h"

#include "Controllers/contextscontroller.h"
#include "Models/contextsmodel.h"

#include "Controllers/friendscontroller.h"
#include "Models/friendsmodel.h"

#include "Controllers/thingscontroller.h"
#include "Models/thingsmodel.h"

#include "Controllers/logscontroller.h"
#include "Models/logsmodel.h"

#include "Controllers/filescontroller.h"
#include "Models/filesmodel.h"

class Tools : public QObject
{
    Q_OBJECT
    QString saveDir;

public:
    explicit Tools(QObject *parent = nullptr);

    void registerClassesToQML();
    void setContexts(QQmlContext *root);

    Q_INVOKABLE QString saveBase64asFile(QString fileName, QString fileExtensions, QString base64data);
    Q_INVOKABLE QString encodeToBase64(QString filePath);
    Q_INVOKABLE QVariantMap getFileInfo(QString filePath);
    Q_INVOKABLE bool checkFileExist(QString fileName,QString fileExtension);
    Q_INVOKABLE QString getSaveDirectory();
    Q_INVOKABLE QString cropImageAndSave(QString imagePath, QString fileName, int x, int y, double width, double height, double widthRatio, double heightRatio);
    Q_INVOKABLE QString getPictures(QString fileName);
    Q_INVOKABLE bool deleteSaveDir();
    Q_INVOKABLE bool deleteFile(QString fileName,QString fileExtension);
    Q_INVOKABLE QString checkOrientation(QString filePath);
    Q_INVOKABLE QString readFile(QString filePath);
    Q_INVOKABLE QVariantList getMountedDevices();


    // Method to request permissions
    Q_INVOKABLE int requestPermission(QString permissionName);

    // Method to get the permission granted state
    Q_INVOKABLE bool getPermissionResult(QString permissionName);

signals:

};

#endif // TOOLS_H
