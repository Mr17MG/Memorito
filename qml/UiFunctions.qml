import QtQuick 2.14 // Require For QtObject

QtObject {
    function getHeightMargin(window)
    {
        var heightRatio = 667/window.height;
        var widthRatio = 375/window.width;
        if(heightRatio<widthRatio)
            return (window.height - 667 / widthRatio) /2;
        return 0;
    }

    function getWidthMargin(window)
    {
        var heightRatio = 667/window.height;
        var widthRatio = 375/window.width;
        if(heightRatio>widthRatio)
            return (window.width - 375 / heightRatio) /2;
        return 0;
    }

    function getHeightSize(size,window)
    {
        return (size / (667 / (window.height-getHeightMargin(window)*2)));
    }

    function getWidthSize(size,window)
    {
        return (size / (375 / (window.width-getWidthMargin(window)*2)));
    }

    function getFontSize(a,window)
    {
        return getWidthSize(a,window);
    }

    function checkDisplayForNumberofRows(window)
    {
        if(Qt.platform.os === "android" || Qt.platform.os === "ios")
        {
            if(window.width>window.height)
                return 2;
            else
                return 1;
        }
        else {
            if(rootWindow.width>window.width/1.75)
                return 3;
            else if(rootWindow.width>window.width/3)
                return 2;
            else
                return 1;
        }
    }
}
