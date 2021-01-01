#ifndef TOOLS_H
#define TOOLS_H

#include <QObject>
#include <QByteArray>
#include <QFile>
#include <QSaveFile>
#include <QDir>
#include <QVariantMap>
#include <QUrl>
#include <QStandardPaths>

class Tools : public QObject
{
    Q_OBJECT
    QString saveDir;
public:
    explicit Tools(QObject *parent = nullptr);
    Q_INVOKABLE QString saveBase64asFile(QString fileName, QString fileExtensions, QString base64data);
    Q_INVOKABLE QString encodeToBase64(QString filePath);
    Q_INVOKABLE QVariantMap getFileInfo(QString filePath);
    Q_INVOKABLE bool checkFileExist(QString fileName,QString fileExtension);
    Q_INVOKABLE QString getSaveDirectory();
signals:

};

#endif // TOOLS_H
