#ifndef MTOOLS_H
#define MTOOLS_H

#include <QQuickItem>
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

#include "exif.h"

class MTools : public QQuickItem
{
    Q_OBJECT
    Q_DISABLE_COPY(MTools)
private:
    QString saveDir;

public:
    explicit MTools(QQuickItem *parent = nullptr);
    ~MTools() override;
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


};

#endif // MTOOLS_H
