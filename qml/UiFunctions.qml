import QtQuick 2.14 // Require For QtObject

QtObject {
    function getHeightMargin(window)
    {
        var heightRatio = 1366/window.height;
        var widthRatio = 768/window.width;
        if(heightRatio<widthRatio)
            return (window.height - 1366 / widthRatio) /2;
        return 0;
    }

    function getWidthMargin(window)
    {
        var heightRatio = 1366/window.height;
        var widthRatio = 768/window.width;
        if(heightRatio>widthRatio)
            return (window.width - 768 / heightRatio) /2;
        return 0;
    }

    function getHeightSize(size,window)
    {
        return (size / (1366 / (window.height-getHeightMargin(window)*2)));
    }

    function getWidthSize(size,window)
    {
        return (size / (768 / (window.width-getWidthMargin(window)*2)));
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
