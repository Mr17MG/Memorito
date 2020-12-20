#include <QGuiApplication>// Require For app
#include <QQmlApplicationEngine>// Require For engine
#include "translator.h" // Require For Translator
#include <QQmlContext> // Require For setContextProperty()
#include <QQuickStyle> // Require For setStyle()
#include <QIcon> // Require For icon
#include <QSettings> // Require For settings
#include "cpp/msysinfo.h" // Require For MSysInfo
#include "cpp/msecurity.h" // Require For MSecurity
#include "cpp/qcustomdate.h"// Require For QCustomDate
#include "cpp/qdateconvertor.h"// Require For QDateConvertor
#include "tools.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setOrganizationName("MrMG");
    app.setApplicationName("Memorito");
    app.setApplicationVersion("1.0.0");
    app.setApplicationDisplayName("Memorito");
    app.setDesktopFileName("Memorito");
    app.setOrganizationDomain("Memorito.ir");

    //**************** App Style ****************//
    QQuickStyle::setStyle("Material");
    app.setWindowIcon(QIcon(":/icon.png"));
    //*******************************************//

    QQmlApplicationEngine engine;

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

    //**************** Registry C++ To QML ****************//
    qmlRegisterType<MSysInfo>("MSysInfo", 1, 0, "SystemInfo");
    qmlRegisterType<MSecurity>("MSecurity", 1, 0, "MSecurity");
    qmlRegisterType<QCustomDate>("MDate", 1 ,0, "CustomDate");
    qmlRegisterType<QDateConvertor>("MDate", 1, 0, "DateConvertor");
    qmlRegisterType<Tools>("MTools", 1, 0, "MTools");
    //******************************************************//

    //////////////
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
