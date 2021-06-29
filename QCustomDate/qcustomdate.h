#ifndef QCUSTOMDATE_H
#define QCUSTOMDATE_H
#include <QObject>
#include <QDate>
#include <QLocale>
#include <QQmlListProperty>

class QCustomDate : public QObject
{
    Q_OBJECT
public:
    explicit QCustomDate(QObject *parent = nullptr);
    Q_PROPERTY(int day READ getDay NOTIFY dayChanged)
    Q_PROPERTY(int month READ month NOTIFY monthChanged)
    Q_PROPERTY(int year READ year NOTIFY yearChanged)
    Q_PROPERTY(QDate date READ date WRITE setDate NOTIFY dateChanged)
    Q_PROPERTY(QLocale locale READ getLocale WRITE setLocale NOTIFY localeChanged)
public:

    Q_INVOKABLE int getDay() const;
    Q_INVOKABLE int month() const;
    Q_INVOKABLE QString monthName() const;
    Q_INVOKABLE int year() const;
    Q_INVOKABLE QDate date() const;
    Q_INVOKABLE QDate nextMonth() const;
    Q_INVOKABLE QDate prevMonth() const;
    Q_INVOKABLE QVariantList monthDays(bool isShamsi) const;
    void setDate(QDate date);
    Q_INVOKABLE QLocale getLocale() const;
    void setLocale(QLocale locale);
    QCustomDate(QDate date,QLocale l);
signals:
    void dateChanged();
    void localeChanged();
    void dayChanged();
    void monthChanged();
    void yearChanged();
private:
    QDate _date;
    QLocale locale;
signals:

};

#endif // QCUSTOMDATE_H

