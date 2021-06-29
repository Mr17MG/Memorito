TEMPLATE = lib
TARGET = MSecurity
QT += qml quick
CONFIG += plugin c++11
CONFIG -= android_install
TARGET = $$qtLibraryTarget($$TARGET)
uri = MSecurity

DESTDIR = $$PWD/../FinalExcutable/MSecurity
# Input
SOURCES += \
        msecurity_plugin.cpp \
        msecurity.cpp

HEADERS += \
        msecurity_plugin.h \
        msecurity.h

DISTFILES = qmldir

!equals(_PRO_FILE_PWD_, $$OUT_PWD) {
    copy_qmldir.target = $$OUT_PWD/qmldir
    copy_qmldir.depends = $$_PRO_FILE_PWD_/qmldir
    copy_qmldir.commands = $(COPY_FILE) "$$replace(copy_qmldir.depends, /, $$QMAKE_DIR_SEP)" "$$replace(copy_qmldir.target, /, $$QMAKE_DIR_SEP)"
    QMAKE_EXTRA_TARGETS += copy_qmldir
    PRE_TARGETDEPS += $$copy_qmldir.target
}

qmldir.files = qmldir
unix {
    installPath = $$[QT_INSTALL_QML]/$$replace(uri, \., /)
    qmldir.path = $$installPath
    target.path = $$installPath
    INSTALLS += target qmldir
}

cpqmldir.files = qmldir
cpqmldir.path = $$DESTDIR
COPIES += cpqmldir
