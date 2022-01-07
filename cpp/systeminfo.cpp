#include "systeminfo.h"

SystemInfo::SystemInfo()
{
    sysInfo = new QSysInfo();
}

QString SystemInfo::getCpuArch()
{
    return sysInfo->currentCpuArchitecture();
}

QString SystemInfo::getKernelVersion()
{
    return sysInfo->kernelVersion();
}

QString SystemInfo::getMachineUniqueId()
{
    QSettings *setting = new QSettings();
    QString returnVal = "";
    if(setting->value("machineId","").toString()=="")
    {
        if(sysInfo->machineUniqueId().toStdString() == "")
            returnVal = QUuid::createUuid().toString().replace(QRegularExpression("[{}-]"),"");
        else
            returnVal = sysInfo->machineUniqueId();
        setting->setValue("machineId",returnVal);
        return returnVal;

    }
    else
        return setting->value("machineId","").toString();
}

QString SystemInfo::getOsName()
{
    return sysInfo->productType();
}

QString SystemInfo::getOsVersion()
{
    return sysInfo->productVersion();
}

QString SystemInfo::getAppName()
{
    return QGuiApplication::applicationName();
}

QString SystemInfo::getAppVersion()
{
    return QGuiApplication::applicationVersion();
}

int SystemInfo::requestPermission(QString permissionName)
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
#else
    Q_UNUSED(permissionName)
#endif
    return 1;
}

bool SystemInfo::getPermissionResult(QString permissionName)
{
#if defined(Q_OS_ANDROID)
    return (QtAndroid::checkPermission(permissionName) == QtAndroid::PermissionResult::Granted);
#else
    Q_UNUSED(permissionName)
    return true;
#endif
}
