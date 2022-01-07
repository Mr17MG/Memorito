#ifndef CALENDARCONTROLLER_H
#define CALENDARCONTROLLER_H

#include "basecontroller.h"
#include "../Models/calendarmodel.h"

class CalendarController : public QObject
{
    Q_OBJECT
    BaseController *baseApi;
    Logger *logger;
    CalendarModel *calendarModel;

public:
    CalendarController(QObject *parent = nullptr);

public slots:
    void onRequestError(int statusCode, QNetworkReply::NetworkError error, QByteArray rawData,QNetworkAccessManager::Operation method, QUrl url);
    void onRequestSuccess(int statusCode, QJsonObject data,QNetworkAccessManager::Operation method, QUrl url);
};

#endif // CALENDARCONTROLLER_H
