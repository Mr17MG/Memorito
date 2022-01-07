DISTFILES += \
    $$PWD/Assets.xcassets/AppIcon.appiconset/AppIcon-20@2x.png \
    $$PWD/Assets.xcassets/AppIcon.appiconset/AppIcon-20@2x~ipad.png \
    $$PWD/Assets.xcassets/AppIcon.appiconset/AppIcon-20@3x.png \
    $$PWD/Assets.xcassets/AppIcon.appiconset/AppIcon-20~ipad.png \
    $$PWD/Assets.xcassets/AppIcon.appiconset/AppIcon-29.png \
    $$PWD/Assets.xcassets/AppIcon.appiconset/AppIcon-29@2x.png \
    $$PWD/Assets.xcassets/AppIcon.appiconset/AppIcon-29@2x~ipad.png \
    $$PWD/Assets.xcassets/AppIcon.appiconset/AppIcon-29@3x.png \
    $$PWD/Assets.xcassets/AppIcon.appiconset/AppIcon-29~ipad.png \
    $$PWD/Assets.xcassets/AppIcon.appiconset/AppIcon-40@2x.png \
    $$PWD/Assets.xcassets/AppIcon.appiconset/AppIcon-40@2x~ipad.png \
    $$PWD/Assets.xcassets/AppIcon.appiconset/AppIcon-40@3x.png \
    $$PWD/Assets.xcassets/AppIcon.appiconset/AppIcon-40~ipad.png \
    $$PWD/Assets.xcassets/AppIcon.appiconset/AppIcon-60@2x~car.png \
    $$PWD/Assets.xcassets/AppIcon.appiconset/AppIcon-60@3x~car.png \
    $$PWD/Assets.xcassets/AppIcon.appiconset/AppIcon-83.5@2x~ipad.png \
    $$PWD/Assets.xcassets/AppIcon.appiconset/AppIcon@2x.png \
    $$PWD/Assets.xcassets/AppIcon.appiconset/AppIcon@2x~ipad.png \
    $$PWD/Assets.xcassets/AppIcon.appiconset/AppIcon@3x.png \
    $$PWD/Assets.xcassets/AppIcon.appiconset/AppIcon~ios-marketing.png \
    $$PWD/Assets.xcassets/AppIcon.appiconset/AppIcon~ipad.png \


QMAKE_BUNDLE_DATA += ios_icon
QMAKE_INFO_PLIST = $$PWD/Info.plist
ios_icon.files = $$files($$PWD/Assets.xcassets/AppIcon.appiconset//AppIcon*.png)
