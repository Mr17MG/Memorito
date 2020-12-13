#ifndef QDATECONVERTOR_H
#define QDATECONVERTOR_H
/****************************************************
*QDateConvertor library for Qt developers 
*this library can convert Jalali dates to Miladi and Miladi(AD) to Jalali(shamsi/khorshidi)
*
*    Copyright (C) 2012  vahid kharazi <vahid@kharazi.net>
*
*    This program is free software: you can redistribute it and/or modify
*
*    it under the terms of the GNU General Public License as published by
*
*    the Free Software Foundation, either version 3 of the License, or
*
*    (at your option) any later version.
*    This program is distributed in the hope that it will be useful,
*
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*
*    GNU General Public License for more details.
*
*
*
*    You should have received a copy of the GNU General Public License
*
*    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*********************************************************
*******************The instructions**********************
*********************************************************
*- add qdateconvertor class to your project
*- include qdataconvertor where you want to use qdataconvertor
*- use from QDateConvertor::toJalali(year,month,day)[return QStringList] function to convert Miladi date to Jalali and
*  use from QDateConvertor::toMiladi(year,month,day)[return QStringList] function to convert Jalali date to Miladi

for Example:
       include <QDebug>
       include "qdateconvertor.h"

       //leap year[sale kabise] in Jalali Calender
       QDateConvertor mdate;
       qDebug()<<"is leap year? "<<mdate.is_leap(1391);

       //current time in Jalali Calender
       QStringList today= mdate.Today();
       qDebug()<<today.at(0)<<"/"<<today.at(1)<<"/"<<today.at(2)<<"/"<<today.at(3)<<"/"<<today.at(4);

       //current time in Miladi Calender
       qDebug()<<" current time: ";
       qDebug()<<mdate.today.toString("yyyy")<<mdate.today.toString("MM")<<mdate.today.toString("dd");

       //cuurent time
       qDebug()<<"time is:"<<mdate.today.toString("hh:mm");

       //convert miladi to Jalali
       QStringList shamsi=  mdate.toJalali( "2001","9","11");
       QString JalailDate =shamsi.at(0)+"/"+shamsi.at(1)+"/"+shamsi.at(2)+ ":" +shamsi.at(3);
       qDebug()<<JalailDate;

       //convert Miladi to jalali
       QStringList m= mdate.toMiladi("1372","3","6");

       QString miladiDate= m.at(0)+"/"+ m.at(1)+"/"+m.at(2);
       qDebug()<<"VAHID BIRTHDAY: "<<miladiDate;

******************************************************
***************QDateConvertor Class*******************
***Copyright 2012 Vahid Kharazi <vahid@kharazi.net>***
***Licensed for distribution under the GPL version3***
******************************************************
******************************************************/

#include <QStringList>
#include <QDate>
#include <QMap>
#include <QObject>

class QDateConvertor : public QObject
{
private:
    Q_OBJECT
    int div(int,int);
    void set_months();
    void set_days();
    QMap<int,QString> Month;
    QMap<QString,QString> Day;
public:
//    QDateConvertor();
    explicit QDateConvertor(QObject *parent = nullptr);
    Q_INVOKABLE bool is_leap(int year);//year is in Jalali system in range:[1244,1472]
    Q_INVOKABLE QStringList toJalali(QString year, QString month,QString day);//year,month and day in Miladi system
    Q_INVOKABLE QStringList toMiladi(QString year, QString month,QString day);//year,month and day in Jalali system
    Q_INVOKABLE QStringList Today();//return Jalali currentDateTime
    QDateTime today;//today =QDateTime::currentDateTime();// Miladi
};
#endif // QDATECONVERTOR_H
