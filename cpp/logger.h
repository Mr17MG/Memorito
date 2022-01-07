#ifndef LOGGER_H
#define LOGGER_H

#include <QObject>
#include <QDebug>

class Logger : public QObject
{
    Q_OBJECT
    explicit Logger(QObject *parent = nullptr);
    static Logger *instance;

public:
    enum Types{
        Success,
        Error,
        Warning,
        Info
    };
    static Logger *getInstance() {
        if (!instance)
            instance = new Logger;
        return instance;
    }
public slots:
    void setLog(QString message, Logger::Types type);

signals:
    void log(QString message, Logger::Types Type);
    void successLog(QString message);
    void errorLog(QString message);
    void warningLog(QString message);
    void infoLog(QString message);

    void loading(QString);
    void loaded();
};

#endif // LOGGER_H
