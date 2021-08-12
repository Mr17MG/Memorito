#include <QGuiApplication>// Require For app
#include <QQmlApplicationEngine>// Require For engine
#include <QQmlContext> // Require For setContextProperty()
#include <QQuickStyle> // Require For setStyle()
#include <QIcon> // Require For icon
#include <QSettings> // Require For settings
#include "translator.h" // Require For Translator

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setOrganizationName("MrMG");
    app.setApplicationName("Memorito");
    app.setApplicationVersion(QString::number(APP_VERSION));
    app.setApplicationDisplayName("Memorito");
    app.setDesktopFileName("Memorito");
    app.setOrganizationDomain("Memorito.ir");

    QQmlApplicationEngine engine;

    //**************** App Style ****************//
    QQuickStyle::setStyle("Material");
    app.setWindowIcon(QIcon(":/icon2.png"));
    //*******************************************//


    //**************** Load Language of App ****************//
    QSettings settings;
    Translator mTrans(&app,&engine,settings.value("AppLanguage",89).toInt()); // QLocale::Persian  == 89
    engine.rootContext()->setContextProperty("translator",(QObject *)&mTrans);
    //******************************************************//

    //**************** in Debug App ****************//
#ifdef QT_DEBUG
    bool isDebug = true;
#else
    bool isDebug = false;
#endif
    engine.rootContext()->setContextProperty("isDebug",isDebug);

    //******************************************************//
    QString domain = isDebug?app.platformName() == "android"?"http://192.168.0.117"
                                                            :"http://memorito.local"
                            :"https://memorito.ir";
    engine.rootContext()->setContextProperty("domain",domain);

    engine.addImportPath("qrc:/");

    //******************************************************//

    const QUrl url(QStringLiteral("qrc:/StartPage.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
