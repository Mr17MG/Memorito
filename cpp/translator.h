#ifndef TRANSLATOR_H
#define TRANSLATOR_H

#include <QObject> // Require For Q_OBJECT and Class
#include <QGuiApplication> // Require for QGuiApplication
#include <QTranslator> // Require for mTranslator
#include <QQmlApplicationEngine> // Require For mEngine
#include <QLocale> // Require For Qlocal::English and Qlocale::Persian

class Translator : public QObject
{

public:
    Translator(QGuiApplication *app,QQmlApplicationEngine *engine,int lang);

public slots:
    Q_INVOKABLE void updateLanguage(int lang);
    Q_INVOKABLE QVariantMap getLanguages();
    Q_INVOKABLE int getCurrentLanguage();

private:
    Q_OBJECT

    QVariantMap languageList;
    QQmlApplicationEngine * mEngine;
    QGuiApplication * mApp;
    QTranslator mTranslator;
    int currentLang;

signals:
    void languageChanged();

};

#endif // TRANSLATOR_H
