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
