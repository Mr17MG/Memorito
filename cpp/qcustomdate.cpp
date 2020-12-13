#include "qcustomdate.h"
#include "qdateconvertor.h"
#include <QDebug>
QCustomDate::QCustomDate(QDate date, QLocale l)
{
    _date = date;
    locale = l;
}
QCustomDate::QCustomDate(QObject *parent) : QObject(parent){
    _date = QDate::currentDate();
}
QDate QCustomDate::date() const{
    return _date;
}
QLocale QCustomDate::getLocale() const{
    return locale;
}
void QCustomDate::setLocale(QLocale locale){
    this->locale = locale;
}
void QCustomDate::setDate(QDate date){
    this->_date = date;
}
int QCustomDate::getDay() const{
    if(QLocale::Iran==locale.country()){
        // gregorian to jalali
        QDateConvertor mdate;
        QStringList shamsi=  mdate.toJalali(QString::number( _date.year()),QString::number( _date.month()),QString::number(_date.day()));
        QString JalailDate =shamsi.at(0)+"/"+shamsi.at(1)+"/"+shamsi.at(2)+ ":" +shamsi.at(3);
        //qDebug()<<JalailDate;
        return QString(shamsi.at(2)).toInt();
    }
    return _date.day();
}
int QCustomDate::month() const{
    if(QLocale::Iran==locale.country())
    {
        // gregorian to jalali
        QDateConvertor mdate;
        QStringList shamsi=  mdate.toJalali(QString::number( _date.year()),QString::number( _date.month()),QString::number(_date.day()));
        int shamsiDay = QString(shamsi.at(2)).toInt();
        QDate firstOfMonth= _date.addDays( - shamsiDay+1 );
        //        QString JalailDate =shamsi.at(0)+"/"+shamsi.at(1)+"/"+shamsi.at(2)+ ":" +shamsi.at(3);
        //        qDebug()<<JalailDate;
        //        qDebug() <<firstOfMonth<< firstOfMonth.month();
        return firstOfMonth.month();
    }
    return _date.month() ;
}
QString QCustomDate::monthName() const
{
    if(QLocale::Iran ==locale.country())
    {
        // gregorian to jalali
        QDateConvertor mdate;
        QStringList shamsi=  mdate.toJalali(QString::number( _date.year()),QString::number( _date.month()),QString::number(_date.day()));

        return shamsi.at(3);
    }
    return locale.monthName(_date.month(),QLocale::ShortFormat) ;
}
int QCustomDate::year() const{
    if(QLocale::Iran ==locale.country())
    {
        // gregorian to jalali
        QDateConvertor mdate;
        QStringList shamsi=  mdate.toJalali(QString::number( _date.year()),QString::number( _date.month()),QString::number(_date.day()));

        return QString(shamsi.at(0)).toInt();
    }
    return _date.year();
}
QDate QCustomDate::nextMonth() const
{
    if(QLocale::Iran==locale.country()){
        // gregorian to jalali
        QDateConvertor mdate;
        QStringList shamsi=  mdate.toJalali(QString::number( _date.year()),QString::number( _date.month()),QString::number(_date.day()));
        int year = shamsi.at(0).toInt();
        int month = shamsi.at(1).toInt();
        int day = shamsi.at(2).toInt();
        if(month==12){
            month=1;
            year++;
        }else month++;
        if(month==7  && day>30)
            day=30;
        else if(month==12){
            if(mdate.is_leap(year) && day>29){
                day=30;
            }else if( day>29)
                day=29;
        }
        QStringList miladi=mdate.toMiladi(QString::number(year),QString::number(month),QString::number(day));
        return QDate(miladi.at(0).toInt(),miladi.at(1).toInt(),miladi.at(2).toInt());
    }
    return _date.addMonths(1) ;
}
QDate QCustomDate::prevMonth() const
{
    if(QLocale::Iran==locale.country()){
        // gregorian to jalali
        QDateConvertor mdate;
        QStringList shamsi=  mdate.toJalali(QString::number( _date.year()),QString::number( _date.month()),QString::number(_date.day()));
        int year = shamsi.at(0).toInt();
        int month = shamsi.at(1).toInt();
        int day = shamsi.at(2).toInt();
        if(month==1){
            month=12;
            year--;
        }else month--;
        if(month==12){
            if(mdate.is_leap(year) && day>29){
                day=30;
            }else if( day>29)
                day=29;
        }
        QStringList miladi=mdate.toMiladi(QString::number(year),QString::number(month),QString::number(day));
        return QDate(miladi.at(0).toInt(),miladi.at(1).toInt(),miladi.at(2).toInt());
    }
    return _date.addMonths(-1) ;
}

QVariantList QCustomDate::monthDays(bool isShamsi) const
{
    QDateConvertor mdate;
    QDate today = QDate::currentDate();
    QStringList shamsi;

    if(isShamsi)
        shamsi =  mdate.toJalali(QString::number( _date.year()),QString::number( _date.month()),QString::number(_date.day()));
    else{
        shamsi << QString::number( _date.year())<< QString::number( _date.month())<<QString::number(_date.day());
    }
    int year = shamsi.at(0).toInt();
    int month = shamsi.at(1).toInt();
    int day = shamsi.at(2).toInt();
    QDate tmp  = _date.addDays(-day+1);
    int dow = (QLocale::Iran==locale.country()?tmp.dayOfWeek()+1:tmp.dayOfWeek())%7;
    QVariantList list;
    for(int i=0;i<dow;i++){
        QVariantMap map;
        map.insert("day",0);
        list.append(map);
    }
    int dayofmonth=0;
    if(isShamsi){
        if(month<=6)
            dayofmonth=31;
        else if(month<12)
            dayofmonth=30;
        else if(month==12 && mdate.is_leap(year))
            dayofmonth=30;
        else dayofmonth=29;
    }
    else{
        if( month == 1 ||month == 3 ||month == 5 ||month == 7 ||month == 8 || month == 10 ||month == 12)
        {
            dayofmonth = 31;
        }
        else if(month == 4 ||month == 6 ||month == 9 || month == 11 )
        {
            dayofmonth = 30;
        }
        if( month == 2)
        {
            if(QDate::isLeapYear(year)){
                dayofmonth = 29;
            }
            else dayofmonth = 28;
        }
    }
    for(int i=1;i<=dayofmonth;i++){
        QVariantMap map;
        map.insert("day",i);
        map.insert("date",tmp.addDays(i-1));
        if(tmp.addDays(i-1)==today)
            map.insert("today",true);
        list.append(map);
    }
    return list;
}
