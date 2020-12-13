#include "tools.h"

Tools::Tools(QObject *parent) : QObject(parent)
{

}

QString Tools::saveBase64asFile(QString fileName, QString fileExtensions, QString base64data)
{
    QSaveFile file(QDir::homePath()+"/"+fileName+"."+fileExtensions);
    file.open(QIODevice::WriteOnly);
    file.write(QByteArray::fromBase64(base64data.toLatin1()));
    file.commit();
    return (QDir::homePath()+"/"+fileName+"."+fileExtensions);
}

QString Tools::encodeToBase64(QString filePath)
{
    QFile f(filePath);
    QString base64;
    QByteArray data;
    if(f.open(QFile::ReadOnly))
    {
        data = f.readAll();
        base64 = data.toBase64();
        f.close();
        return base64;
    }
    else return "";

}
