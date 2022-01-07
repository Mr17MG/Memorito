#include <QIcon>                 // Require For icon
#include <QLocale>               // Require For AppLanguage
#include <QSettings>             // Require For settings
#include <QQuickStyle>           // Require For setStyle()
#include <QQmlContext>           // Require For setContextProperty()
#include <QGuiApplication>       // Require For app
#include <QCommandLineParser>    // Require For parser
#include <QQmlApplicationEngine> // Require For engine

#include "tools.h"      // Require For tools
#include "translator.h" // Require For Translator

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setOrganizationName("MrMG");
    app.setApplicationVersion(QString::number(APP_VERSION));

#ifdef QT_DEBUG
    app.setApplicationName("Memorito-debug");
    app.setDesktopFileName("Memorito-debug");
    app.setOrganizationDomain("Memorito-debug");
    app.setApplicationDisplayName("Memorito-debug");
#else
    app.setApplicationName("Memorito");
    app.setDesktopFileName("Memorito");
    app.setOrganizationDomain("Memorito");
    app.setApplicationDisplayName("Memorito");
#endif

    QQmlApplicationEngine engine;
    Tools tools;
    tools.registerClassesToQML();
    tools.setContexts(engine.rootContext());

    //**************** App Style ****************//
    QQuickStyle::setStyle("Material");
    app.setWindowIcon(QIcon(":/icon2.png"));
    //*******************************************//

    //**************** Command Line Options ****************//
    QCommandLineParser parser;
    parser.addHelpOption();
    parser.addVersionOption();
    parser.process(app);
    //*****************************************************//

    //**************** Load Language of App ****************//
    QSettings settings;
    Translator mTrans(&app,&engine,settings.value("AppLanguage",QLocale::Persian).toInt());
    engine.rootContext()->setContextProperty("translator",&mTrans);
    //******************************************************//

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
