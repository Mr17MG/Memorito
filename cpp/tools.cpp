#include "tools.h"

Tools::Tools(QObject *parent) : QObject(parent)
{

}

QString Tools::saveBase64asFile(QString fileName, QString fileExtensions, QString base64data)
{
    QString saveDir(QDir::homePath()+"/Memorito Data");
    QString saveFile(saveDir+"/"+fileName+"."+fileExtensions);
    QDir folder(saveDir);

    if(!folder.exists())
    {
        folder.mkdir(saveDir);
    }

    QFile checkExist(saveFile);
    if(checkExist.exists())
    {
        return saveFile+"Mohammad";
    }

    QSaveFile file(saveFile);
    file.open(QIODevice::WriteOnly);
    file.write(QByteArray::fromBase64(base64data.toLatin1()));
    file.commit();

    return saveFile;
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
