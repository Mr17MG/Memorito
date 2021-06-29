#ifndef MSYSINFO_H
#define MSYSINFO_H

#include <QGuiApplication>
#include <QSettings>
#include <QUuid>
#include <QQuickItem>
#ifdef Q_OS_ANDROID
#include <QAndroidJniObject>
#include <QAndroidJniEnvironment>
#include <QtAndroid>
#endif

class MSysInfo : public QQuickItem
{
    Q_OBJECT
    Q_DISABLE_COPY(MSysInfo)

public:
    explicit MSysInfo(QQuickItem *parent = nullptr);
    ~MSysInfo() override;

    Q_INVOKABLE QSysInfo *sysInfo;
    Q_INVOKABLE QString getCpuArch();
    Q_INVOKABLE QString getKernelType();
    Q_INVOKABLE QString getKernelVersion();
    Q_INVOKABLE QString getMachineUniqueId();
    Q_INVOKABLE QString getPrettyOsName();
    Q_INVOKABLE QString getOsName();
    Q_INVOKABLE QString getOsVersion();
    Q_INVOKABLE QString getAppName();
    Q_INVOKABLE QString getAppVersion();

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

#endif // MSYSINFO_H
