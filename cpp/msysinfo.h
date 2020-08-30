#ifndef MSYSINFO_H
#define MSYSINFO_H
#include <QObject>
#include <QGuiApplication>
class MSysInfo : public QObject
{
    Q_OBJECT
public:
    explicit MSysInfo(QObject *parent = nullptr);

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

signals:

};

#endif // MSYSINFO_H
