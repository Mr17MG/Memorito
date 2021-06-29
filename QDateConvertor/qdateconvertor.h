#ifndef QDATECONVERTOR_H
#define QDATECONVERTOR_H

#include <QStringList>
#include <QDate>
#include <QMap>
#include <QQuickItem>

class QDateConvertor : public QQuickItem
{
    Q_OBJECT
    Q_DISABLE_COPY(QDateConvertor)

private:
    int div(int,int);
    void set_months();
    void set_days();
    QMap <int,QString> Month;
    QMap <QString,QString> Day;
    QDateTime today;//today =QDateTime::currentDateTime();// Miladi

public:
    explicit QDateConvertor(QQuickItem *parent = nullptr);
    ~QDateConvertor() override;

    Q_INVOKABLE bool is_leap(int year);//year is in Jalali system in range:[1244,1472]
    Q_INVOKABLE QStringList toJalali(QString year, QString month,QString day);//year,month and day in Miladi system
    Q_INVOKABLE QStringList toMiladi(QString year, QString month,QString day);//year,month and day in Jalali system
    Q_INVOKABLE QStringList Today();//return Jalali currentDateTime
    Q_INVOKABLE QStringList get_month();
};

#endif // QDATECONVERTOR_H
