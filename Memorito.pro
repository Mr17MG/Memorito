QT += quick svg quickcontrols2

CONFIG += c++11

include(projects/openssl/openssl.pri)

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        cpp/main.cpp \
        cpp/translator.cpp

HEADERS += \
    cpp/translator.h


RESOURCES += \
    qml/qml.qrc \
    svg/svg.qrc \
    ttf/ttf.qrc \
    ts/ts.qrc

TRANSLATIONS += \
    ts/en.ts

DESTDIR = $$PWD/../FinalExcutable

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH += $$PWD/qml
QML_IMPORT_PATH += $$PWD/../FinalExcutable

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target


VERSION = 1.0.0
APP_VERSION = \\\"$$VERSION\\\"
APP_VERSION_CODE = 1
DEFINES += APP_VERSION APP_VERSION_CODE

android{
    QT += androidextras
    DISTFILES += \
        app/android/AndroidManifest.xml \
        app/android/build.gradle \
        app/android/gradle.properties \
        app/android/gradle/wrapper/gradle-wrapper.jar \
        app/android/gradle/wrapper/gradle-wrapper.properties \
        app/android/gradlew \
        app/android/gradlew.bat \
        app/android/res/values/libs.xml \
        app/android/res/drawable-hdpi/icon.png \
        app/android/res/drawable-ldpi/icon.png \
        app/android/res/drawable-mdpi/icon.png \
        app/android/res/drawable-xhdpi/icon.png \
        app/android/res/drawable-xxhdpi/icon.png \
        app/android/res/drawable-xxxhdpi/icon.png \
        app/android/res/values/styles.xml

    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/app/android
    ANDROID_ABIS = armeabi-v7a
    ANDROID_VERSION_NAME = $$(APP_VERSION)
    ANDROID_VERSION_CODE = $$(APP_VERSION_CODE)
}

ios{

DISTFILES += \
    app/ios/Assets.xcassets/AppIcon.appiconset/100.png \
    app/ios/Assets.xcassets/AppIcon.appiconset/1024.png \
    app/ios/Assets.xcassets/AppIcon.appiconset/114.png \
    app/ios/Assets.xcassets/AppIcon.appiconset/120.png \
    app/ios/Assets.xcassets/AppIcon.appiconset/128.png \
    app/ios/Assets.xcassets/AppIcon.appiconset/144.png \
    app/ios/Assets.xcassets/AppIcon.appiconset/152.png \
    app/ios/Assets.xcassets/AppIcon.appiconset/16.png \
    app/ios/Assets.xcassets/AppIcon.appiconset/167.png \
    app/ios/Assets.xcassets/AppIcon.appiconset/180.png \
    app/ios/Assets.xcassets/AppIcon.appiconset/20.png \
    app/ios/Assets.xcassets/AppIcon.appiconset/256.png \
    app/ios/Assets.xcassets/AppIcon.appiconset/29.png \
    app/ios/Assets.xcassets/AppIcon.appiconset/32.png \
    app/ios/Assets.xcassets/AppIcon.appiconset/40.png \
    app/ios/Assets.xcassets/AppIcon.appiconset/50.png \
    app/ios/Assets.xcassets/AppIcon.appiconset/512.png \
    app/ios/Assets.xcassets/AppIcon.appiconset/57.png \
    app/ios/Assets.xcassets/AppIcon.appiconset/58.png \
    app/ios/Assets.xcassets/AppIcon.appiconset/60.png \
    app/ios/Assets.xcassets/AppIcon.appiconset/64.png \
    app/ios/Assets.xcassets/AppIcon.appiconset/72.png \
    app/ios/Assets.xcassets/AppIcon.appiconset/76.png \
    app/ios/Assets.xcassets/AppIcon.appiconset/80.png \
    app/ios/Assets.xcassets/AppIcon.appiconset/87.png \
    app/ios/Assets.xcassets/AppIcon.appiconset/Contents.json

    QMAKE_BUNDLE_DATA += ios_icon
    QMAKE_INFO_PLIST = $$PWD/app/ios/Info.plist
    ios_icon.files = $$files($$PWD/app/ios/AppIcon*.png)
}

win32{

    DISTFILES += \
        app/windows/icon.ico

    RC_ICONS = app/windows/icon.ico

}

macx{
    CONFIG-=app_bundle
}

unix{
    ICON = $$PWD/app/linux/icon.png
}


