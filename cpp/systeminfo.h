#ifndef SYSTEMINFO_H
#define SYSTEMINFO_H

#include <QObject>
#include <QSettings>
#include <QUuid>
#include <QRegularExpression>
#include <QGuiApplication>

#ifdef Q_OS_ANDROID
#include <QAndroidJniObject>
#include <QAndroidJniEnvironment>
#include <QtAndroid>
#endif

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

    // Method to request permissions
    Q_INVOKABLE int requestPermission(QString permissionName);

    // Method to get the permission granted state
    Q_INVOKABLE bool getPermissionResult(QString permissionName);

public slots:

private:

    // Variable indicating if the permission to read / write has been granted
    bool permissionResult;  //  true - "Granted", false - "Denied"

#if defined(Q_OS_ANDROID)
    // Object used to obtain permissions on Android Marshmallow
    QAndroidJniObject ShowPermissionRationale;
#endif

};

#endif // SYSTEMINFO_H
