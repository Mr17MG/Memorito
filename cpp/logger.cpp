#include "logger.h"

Logger *Logger::instance = nullptr;

Logger::Logger(QObject *parent) : QObject(parent)
{
    QObject::connect(this,SIGNAL(log(QString,Logger::Types)),
                     this,SLOT(setLog(QString,Logger::Types)));
}

void Logger::setLog(QString message, Types type)
{
    switch (type) {
    case Types::Success:
        qDebug()<< "\033[1;32m" << message << "\033[0m";
        emit successLog(message);
        break;
    case Types::Error:
        qDebug()<< "\033[1;31m" << message << "\033[0m";
        emit errorLog(message);
        break;
    case Types::Warning:
        qDebug()<< "\033[1;33m" << message << "\033[0m";
        emit warningLog(message);
        break;
    case Types::Info:
        qDebug()<< "\033[1;36m" << message << "\033[0m";
        emit infoLog(message);
        break;
    default:
        qDebug()<< "\033[1;36m" << message << "\033[0m";
        emit infoLog(message);
        break;
    }

}
