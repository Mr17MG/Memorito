pragma Singleton
import QtQuick  // Require For QtObject
import QtQuick.Window // Require For Screen

QtObject {
    id:root
    property int screenWidth  : 768
    property int screenHeight : 1366

    property int  windowHeight : {
        if(["android","ios"].indexOf(Qt.platform.os) !== -1) return Screen.width
        else if (Screen.orientation === Qt.LandscapeOrientation) return screenHeight
        else return screenWidth
    }

    property int  windowWidth : {
        if(["android","ios"].indexOf(Qt.platform.os) !== -1) return Screen.height
        else if (Screen.orientation === Qt.LandscapeOrientation) return screenWidth
        else return screenHeight
    }


    function getHeightMargin(window)
    {
        let heightRatio = screenWidth  / windowHeight ;
        let widthRatio  = screenHeight / windowWidth  ;

        if(heightRatio<widthRatio)
            return (windowHeight - screenWidth / widthRatio) /2;

        return 0;
    }

    function getWidthMargin(window)
    {
        let heightRatio = screenWidth  / windowHeight ;
        let widthRatio  = screenHeight / windowWidth  ;

        if(heightRatio>widthRatio)
            return (windowWidth - screenHeight / heightRatio) /2;
        return 0;
    }

    function getHeightSize(size)
    {
        let height = (size / (screenWidth / (windowHeight-getHeightMargin(Screen)*2)));
        return height
    }

    function getWidthSize(size)
    {
        let width = (size / (screenHeight / (windowWidth-getWidthMargin(Screen)*2)));
        return width
    }

    function getFontSize(size)
    {
        let width = (size / (screenHeight / (windowWidth-getWidthMargin(Screen)*2)));
        return width
    }

    function checkDisplayForNumberofRows(window)
    {
        if(["android","ios"].indexOf(Qt.platform.os) !== -1)
        {
            if(Screen.width>Screen.height)
                return 2;
            else
                return 1;
        }
        else {
            if((UsefulFunc.rootWindow.width>screenHeight/1.75) || (UsefulFunc.rootWindow.width>900))
                return 3;
            else if(UsefulFunc.rootWindow.width>screenHeight/3 || (UsefulFunc.rootWindow.width>450))
                return 2;
            else
                return 1;
        }
    }
}
