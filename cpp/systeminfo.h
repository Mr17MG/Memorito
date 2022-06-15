#ifndef SYSTEMINFO_H
#define SYSTEMINFO_H

#include <QObject>
#include <QSettings>
#include <QUuid>
#include <QRegularExpression>
#include <QGuiApplication>

class SystemInfo
{
public:
    SystemInfo();

    QSysInfo *sysInfo;
    QString getCpuArch();
    QString getKernelVersion();
    QString getMachineUniqueId();
    QString getOsName();
    QString getOsVersion();
    QString getAppName();
    QString getAppVersion();
};

#endif // SYSTEMINFO_H
