#include "msysinfo.h"

MSysInfo::MSysInfo(QQuickItem *parent)
    : QQuickItem(parent)
{
    // By default, QQuickItem does not draw anything. If you subclass
    // QQuickItem to create a visual item, you will need to uncomment the
    // following line and re-implement updatePaintNode()

    // setFlag(ItemHasContents, true);
    sysInfo = new QSysInfo();
}

MSysInfo::~MSysInfo() { }


QString MSysInfo::getCpuArch()
{
    return sysInfo->currentCpuArchitecture();
}

QString MSysInfo::getKernelType()
{
    return sysInfo->kernelType();
}

QString MSysInfo::getKernelVersion()
{
    return sysInfo->kernelVersion();
}

QString MSysInfo::getMachineUniqueId()
{
    QSettings *setting = new QSettings();
    QString returnVal = "";
    if(setting->value("machineId","").toString()=="")
    {
        if(sysInfo->machineUniqueId().toStdString() == "")
            returnVal = QUuid::createUuid().toString().replace(QRegExp("[{}-]"),"");
        else
            returnVal = sysInfo->machineUniqueId();
        setting->setValue("machineId",returnVal);
        return returnVal;

    }
    else
        return setting->value("machineId","").toString();
}

QString MSysInfo::getPrettyOsName()
{
    return sysInfo->prettyProductName();
}

QString MSysInfo::getOsName()
{
    return sysInfo->productType();
}

QString MSysInfo::getOsVersion()
{
    return sysInfo->productVersion();
}

QString MSysInfo::getAppName()
{
    return QGuiApplication::applicationName();
}

QString MSysInfo::getAppVersion()
{
    return QGuiApplication::applicationVersion();
}

int MSysInfo::requestPermission(QString permissionName)
{
#if defined(Q_OS_ANDROID)

    QtAndroid::PermissionResult request = QtAndroid::checkPermission(permissionName);
    if (request == QtAndroid::PermissionResult::Denied )
    {
        QtAndroid::requestPermissionsSync(QStringList() <<  permissionName);
        request = QtAndroid::checkPermission(permissionName);

        if (request == QtAndroid::PermissionResult::Denied)
        {

            if (QtAndroid::shouldShowRequestPermissionRationale(permissionName))
            {
                return 0;
            }
            else return -1;
        }
        else return 1;
    }
    else
        return 1;
#endif
    return 1;
}

bool MSysInfo::getPermissionResult(QString permissionName)
{
#if defined(Q_OS_ANDROID)
    return (QtAndroid::checkPermission(permissionName) == QtAndroid::PermissionResult::Granted);
#else
    return true;
#endif
}
