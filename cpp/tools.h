#ifndef TOOLS_H
#define TOOLS_H

#include <QObject>
#include <QByteArray>
#include <QFile>
#include <QSaveFile>
#include <QDir>

class Tools : public QObject
{
    Q_OBJECT
public:
    explicit Tools(QObject *parent = nullptr);
    Q_INVOKABLE QString saveBase64asFile(QString fileName, QString fileExtensions, QString base64data);
    Q_INVOKABLE QString encodeToBase64(QString filePath);

signals:

};

#endif // TOOLS_H
