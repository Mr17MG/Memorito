QT += androidextras
DISTFILES += \
    $$PWD/AndroidManifest.xml \
    $$PWD/res/values/libs.xml \
    $$PWD/res/drawable-hdpi/icon.png \
    $$PWD/res/drawable-ldpi/icon.png \
    $$PWD/res/drawable-mdpi/icon.png \
    $$PWD/res/drawable-xhdpi/icon.png \
    $$PWD/res/drawable-xxhdpi/icon.png \
    $$PWD/res/drawable-xxxhdpi/icon.png \
    $$PWD/res/values/styles.xml

ANDROID_PACKAGE_SOURCE_DIR = $$PWD
ANDROID_VERSION_NAME = $$APP_VERSION
ANDROID_VERSION_CODE = $$APP_VERSION_CODE
