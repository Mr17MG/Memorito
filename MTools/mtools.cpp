#include "mtools.h"

MTools::MTools(QQuickItem *parent)
    : QQuickItem(parent)
{
    // By default, QQuickItem does not draw anything. If you subclass
    // QQuickItem to create a visual item, you will need to uncomment the
    // following line and re-implement updatePaintNode()

    // setFlag(ItemHasContents, true);
    saveDir = (QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+QDir::separator()+"Memorito Data"+QDir::separator());

    QDir folder(this->saveDir);
    if(!folder.exists())
    {
        folder.mkdir(this->saveDir);
    }
}

MTools::~MTools()
{
}

QString MTools::saveBase64asFile(QString fileName, QString fileExtensions, QString base64data)
{
    QString saveFile(getSaveDirectory()+fileName+"."+fileExtensions);
    QDir folder(getSaveDirectory());

    if(!folder.exists())
    {
        folder.mkdir(getSaveDirectory());
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

QString MTools::encodeToBase64(QString filePath)
{
    filePath.remove("file://");
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

QVariantMap MTools::getFileInfo(QString filePath)
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

bool MTools::checkFileExist(QString fileName, QString fileExtension)
{
    QFileInfo fileInfo(QUrl(getSaveDirectory()+QDir::separator()+fileName+"."+fileExtension).toString());
    return fileInfo.exists();
}

QString MTools::getSaveDirectory()
{
    return this->saveDir;
}

QString MTools::cropImageAndSave(QString imagePath,QString fileName,int x,int y , double width, double height,double widthRatio,double heightRatio)
{
    imagePath.remove("file://");
    QImage image(imagePath);
    width = (width*image.width())/widthRatio;
    height = (height*image.height())/heightRatio;
    x = (x*image.width())/widthRatio;
    y = (y*image.height())/heightRatio;

    QImage copy ;
    copy = image.copy( x, y, width, height);
    QString savePath = getSaveDirectory()+fileName+".jpeg";
    copy.save(savePath,"jpeg");
    return savePath;
}

QString MTools::getPictures(QString fileName)
{
    if(checkFileExist(fileName,"jpeg"))
    {
        return "file://" +getSaveDirectory()+fileName+".jpeg";
    }
    else return "";
}

bool MTools::deleteSaveDir()
{
    QDir saveLocation(getSaveDirectory());
    if(saveLocation.exists())
    {
        return saveLocation.removeRecursively();
    }
    else
        return false;
}

bool MTools::deleteFile(QString fileName, QString fileExtension)
{
    QFile file(getSaveDirectory()+fileName+"."+fileExtension);
    if(file.exists())
    {
        return file.remove();
    }
    else
        return false;
}

QString MTools::checkOrientation(QString filePath)
{
    QUrl url(filePath);
    QImage image( url.path() );
    QPixmap pixmap;
    int width = image.width();
    int height = image.height();

    int Oriention = easyexif::EXIFInfo::getRotation(url.path().toStdString());

    if(Oriention!=0){
        QTransform transform;
        QTransform trans = transform.rotate(Oriention);
        pixmap = pixmap.fromImage(image.scaled(width,height,Qt::KeepAspectRatio,Qt::SmoothTransformation)).transformed(trans);
    }
    else {
        return "";
    }

    QImage final=pixmap.toImage();
    QString savePath = getSaveDirectory()+"tempSelection"+".jpeg";
    final.save(savePath,"jpeg");
    return savePath;
}

QString MTools::readFile(QString filePath)
{
    QFile file(QUrl(filePath).path());
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return "";
    QString allText = file.readAll();
    file.close();
    return allText;
}

QVariantList MTools::getMountedDevices()
{
    QVariantList list;
    foreach (const QStorageInfo &storage, QStorageInfo::mountedVolumes()) {
        if (storage.isValid() && storage.isReady()) {
            if (!storage.isReadOnly()) {
                QRegExp rx;
                if(QGuiApplication::platformName() == "windows")
                {
                    rx.setPattern("+:/");
                }
                else {
                    rx.setPattern("/^|/home|/mnt/+|/media*|/storage/+");
                    if( storage.rootPath() == "/storage/emulated" )
                    {
                        list << "/storage/emulated/0";
                    }
                }

                QDir storagePath(storage.rootPath());

                if(storagePath.path().contains(rx) && storagePath.isReadable())
                {
                    if( storage.rootPath() != "/storage/emulated" )
                        list << storage.rootPath();
                }
            }
        }
    }
    return list;

}
