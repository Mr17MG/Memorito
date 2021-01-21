#include "tools.h"

Tools::Tools(QObject *parent) : QObject(parent)
{
    saveDir = (QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+QDir::separator()+"Memorito Data"+QDir::separator());
}


QString Tools::saveBase64asFile(QString fileName, QString fileExtensions, QString base64data)
{
    QString saveFile(this->saveDir+fileName+"."+fileExtensions);
    QDir folder(this->saveDir);

    if(!folder.exists())
    {
        folder.mkdir(this->saveDir);
    }

    QFile checkExist(saveFile);
    if(checkExist.exists())
    {
        return saveFile;
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

QVariantMap Tools::getFileInfo(QString filePath)
{
    filePath.remove("file://");

    QFileInfo fileInfo(QUrl(filePath).toString());

    QVariantMap map;

    if(fileInfo.exists())
    {
        map.insert("file_size", fileInfo.size());
        map.insert("file_extension",fileInfo.suffix());
        map.insert("file_source",fileInfo.filePath());
        map.insert("file_name",fileInfo.baseName());
    }
    return map;
}

bool Tools::checkFileExist(QString fileName, QString fileExtension)
{
    QFileInfo fileInfo(QUrl(this->saveDir+QDir::separator()+fileName+"."+fileExtension).toString());
    return fileInfo.exists();
}

QString Tools::getSaveDirectory()
{
    return this->saveDir;
}
