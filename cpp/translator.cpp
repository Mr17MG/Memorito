#include "translator.h"

Translator::Translator(QGuiApplication *app,QQmlApplicationEngine *engine, int lang)
{
    mApp=app;
    mEngine = engine;
    updateLanguage(lang);
    languageList.insert("ENG",QLocale::English);
    languageList.insert("FA",QLocale::Persian);

}

void Translator::updateLanguage(int lang)
{
    switch (lang) {
    case QLocale::English:
        mTranslator.load("en",":/");
        mApp->installTranslator(&mTranslator);
        break;
    default:
        mApp->removeTranslator(&mTranslator);
        break;
    }
    currentLang = lang;
    mEngine->retranslate();
}

QVariantMap Translator::getLanguages()
{
    return languageList;
}

int Translator::getCurrentLanguage()
{
    return currentLang;
}
