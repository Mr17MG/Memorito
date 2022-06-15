QT += quick svg quickcontrols2 sql core

CONFIG += c++17

android{
    include(platform/android/android.pri)
}

ios{
    include(platform/ios/ios.pri)
}

win32{
    include(platform/windows/windows.pri)
}

macx{
    include(platform/mac/mac.pri)
}

unix{
    include(platform/linux/linux.pri)
}

DESTDIR = $$PWD/bin
message($$PWD)

VERSION=0.93
DEFINES += APP_VERSION=$$VERSION
DEFINES += APP_VERSION_CODE=1

RESOURCES += \
    qml/qml.qrc \
    svg/svg.qrc \
    ttf/ttf.qrc \
    ts/ts.qrc

TRANSLATIONS += \
    ts/en.ts

SOURCES += \
        cpp/Controllers/basecontroller.cpp \
        cpp/Controllers/calendarcontroller.cpp \
        cpp/Controllers/changescontroller.cpp \
        cpp/Controllers/contextscontroller.cpp \
        cpp/Controllers/coopcontroller.cpp \
        cpp/Controllers/filescontroller.cpp \
        cpp/Controllers/friendscontroller.cpp \
        cpp/Controllers/logscontroller.cpp \
        cpp/Controllers/thingscontroller.cpp \
        cpp/Controllers/userscontroller.cpp \
        cpp/Models/basemodel.cpp \
        cpp/Models/calendarmodel.cpp \
        cpp/Models/changesmodel.cpp \
        cpp/Models/contextsmodel.cpp \
        cpp/Models/coopmodel.cpp \
        cpp/Models/filesmodel.cpp \
        cpp/Models/friendsmodel.cpp \
        cpp/Models/logsmodel.cpp \
        cpp/Models/thingsmodel.cpp \
        cpp/Models/usersmodel.cpp \
        cpp/logger.cpp \
        cpp/qdatepicker.cpp \
        cpp/exif.cpp \
        cpp/main.cpp \
        cpp/security.cpp \
        cpp/systeminfo.cpp \
        cpp/tools.cpp \
        cpp/translator.cpp

HEADERS += \
    cpp/Controllers/basecontroller.h \
    cpp/Controllers/calendarcontroller.h \
    cpp/Controllers/changescontroller.h \
    cpp/Controllers/contextscontroller.h \
    cpp/Controllers/coopcontroller.h \
    cpp/Controllers/filescontroller.h \
    cpp/Controllers/friendscontroller.h \
    cpp/Controllers/logscontroller.h \
    cpp/Controllers/thingscontroller.h \
    cpp/Controllers/userscontroller.h \
    cpp/Models/basemodel.h \
    cpp/Models/calendarmodel.h \
    cpp/Models/changesmodel.h \
    cpp/Models/contextsmodel.h \
    cpp/Models/coopmodel.h \
    cpp/Models/filesmodel.h \
    cpp/Models/friendsmodel.h \
    cpp/Models/logsmodel.h \
    cpp/Models/thingsmodel.h \
    cpp/Models/usersmodel.h \
    cpp/logger.h \
    cpp/qdatepicker.h \
    cpp/exif.h \
    cpp/security.h \
    cpp/systeminfo.h \
    cpp/tools.h \
    cpp/translator.h


# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH += $$PWD/qml

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =



