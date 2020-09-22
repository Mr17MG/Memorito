#include "msysinfo.h"

MSysInfo::MSysInfo(QObject *parent) : QObject(parent)
{
    sysInfo = new QSysInfo();
}

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

