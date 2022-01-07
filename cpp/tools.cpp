#include "tools.h"

Tools::Tools(QObject *parent)
    : QObject{parent}
{
    saveDir = (QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/Memorito Data/");

    QDir folder(this->saveDir);
    if(!folder.exists())
    {
        folder.mkdir(this->saveDir);
    }
}

void Tools::registerClassesToQML()
{
    qmlRegisterType<QDatePicker>("QDatePicker",1,0,"QDatePicker");
    qmlRegisterType<Tools>("Memorito.Tools",1,0,"MTools");
    qmlRegisterType<SystemInfo>("Memorito.SystemInfo",1,0,"MSysInfo");
    qmlRegisterType<Security>("Memorito.Security",1,0,"MSecurity");

    qmlRegisterType<UsersController>("Memorito.Users", 1, 0, "UsersController");
    qmlRegisterType<UsersModel>("Memorito.Users", 1, 0, "UsersModel");

    qmlRegisterType<ContextsController>("Memorito.Contexts", 1, 0, "ContextsController");
    qmlRegisterType<ContextsModel>("Memorito.Contexts", 1, 0, "ContextsModel");

    qmlRegisterType<FriendsController>("Memorito.Friends", 1, 0, "FriendsController");
    qmlRegisterType<FriendsModel>("Memorito.Friends", 1, 0, "FriendsModel");
}

void Tools::setContexts(QQmlContext *root)
{
    //**************** in Debug App ****************//
#ifdef QT_DEBUG
    QString domain = QGuiApplication::platformName() == "android" ? "http://192.168.0.117"
                                                                  : "http://memorito.local";
#else
    QString domain ="https://memorito.ir";
#endif
    root->setContextProperty("domain",domain);
    //*********************************************//

    Logger *logger = Logger::getInstance();
    root->setContextProperty("logger",logger);
}


QString Tools::saveBase64asFile(QString fileName, QString fileExtensions, QString base64data)
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

QString Tools::encodeToBase64(QString filePath)
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
    QFileInfo fileInfo(QUrl(getSaveDirectory()+"/"+fileName+"."+fileExtension).toString());
    return fileInfo.exists();
}

QString Tools::getSaveDirectory()
{
    return this->saveDir;
}

QString Tools::cropImageAndSave(QString imagePath,QString fileName,int x,int y , double width, double height,double widthRatio,double heightRatio)
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

QString Tools::getPictures(QString fileName)
{
    if(checkFileExist(fileName,"jpeg"))
    {
#ifdef Q_OS_WINDOWS
        return "file:\\" +getSaveDirectory()+fileName+".jpeg";
#else
        return "file://" +getSaveDirectory()+fileName+".jpeg";
#endif
    }
    else return "";
}

bool Tools::deleteSaveDir()
{
    QDir saveLocation(getSaveDirectory());
    if(saveLocation.exists())
    {
        return saveLocation.removeRecursively();
    }
    else
        return false;
}

bool Tools::deleteFile(QString fileName, QString fileExtension)
{
    QFile file(getSaveDirectory()+fileName+"."+fileExtension);
    if(file.exists())
    {
        return file.remove();
    }
    else
        return false;
}

QString Tools::checkOrientation(QString filePath)
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

QString Tools::readFile(QString filePath)
{
    QFile file(QUrl(filePath).path());
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return "";
    QString allText = file.readAll();
    file.close();
    return allText;
}

QVariantList Tools::getMountedDevices()
{
    QVariantList list;
    foreach (const QStorageInfo &storage, QStorageInfo::mountedVolumes()) {
        if (storage.isValid() && storage.isReady()) {
            if (!storage.isReadOnly()) {
                QRegularExpression rx;
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
