#ifndef TRANSLATOR_H
#define TRANSLATOR_H

#include <QObject> // Require For Q_OBJECT and Class
#include <QGuiApplication> // Require for QGuiApplication
#include <QTranslator> // Require for mTranslator
#include <QQmlApplicationEngine> // Require For mEngine
#include <QLocale> // Require For Qlocal::English

class Translator : public QObject
{
    Q_OBJECT

public:
    QVariantMap languageList;
    Translator(QGuiApplication *app,QQmlApplicationEngine *engine,int lang);

public slots:
    Q_INVOKABLE void updateLanguage(int lang);
    Q_INVOKABLE QVariantMap getLanguages();
    Q_INVOKABLE int getCurrentLanguage();

private:
    QQmlApplicationEngine * mEngine;
    QGuiApplication * mApp;
    QTranslator mTranslator;
    int currentLang;

};

#endif // TRANSLATOR_H
