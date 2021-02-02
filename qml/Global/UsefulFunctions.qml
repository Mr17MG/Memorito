pragma Singleton
import QtQuick 2.14 // Require For QtObject

QtObject {
    property ListModel stackPages: ListModel{}

    property var rootWindow: null
    function setRootWindowVar(rootWindow)
    {
        this.rootWindow = rootWindow;
    }

    property var mainPage :null
    function setMainPageVar(mainPage)
    {
        this.mainPage = mainPage;
    }

    property var mainLoader :null
    function setMainLoaderVar(mainLoader)
    {
        this.mainLoader = mainLoader;
    }
    property var authLoader :null
    function setAuthLoaderVar(authLoader)
    {
        this.authLoader = authLoader;
    }

    function faToEnNumber(num)
    {
        num = num.replace(/۰/ig,'0')
        num = num.replace(/۱/ig,'1')
        num = num.replace(/۲/ig,'2')
        num = num.replace(/۳/ig,'3')
        num = num.replace(/۴/ig,'4')
        num = num.replace(/۵/ig,'5')
        num = num.replace(/۶/ig,'6')
        num = num.replace(/۷/ig,'7')
        num = num.replace(/۸/ig,'8')
        num = num.replace(/۹/ig,'9')
        return num
    }

    function findListModel(model, criteria,isData)
    {
        for(var i = 0; i < model.count; ++i)
        {
            if (criteria(model.get(i)))
            {
                if(isData)
                    return model.get(i);
                else return i;
            }
        }
        return null
    }

    function formatDate(date,timestamp)
    {
        let d = date,
        month = '' + (d.getMonth() + 1),
        day = '' + d.getDate(),
        year = d.getFullYear();

        if (month.toString().length < 2) month = '0' + month;
        if (day.toString().length < 2) day = '0' + day;
        let hour = d.getHours(),
        minute = d.getMinutes(),
        second = d.getSeconds()
        if (hour.toString().length < 2) hour = '0' + hour;
        if (minute.toString().length < 2) minute = '0' + minute;
        if (second.toString().length < 2) second = '0' + second;
        let timezone = d.toString().substr(-5);
        let resualt = [year, month, day].join('-')+"T"+[hour, minute, second].join(':');
        resualt += timestamp?".000":"";
        resualt += timezone.substr(0,3)+":"+timezone.substr(3);
        return resualt;
    }

    function findInModel(key,searchField,listModel)
    {
        var index = findListModel(listModel,function(model){return key===model[searchField]},false)
        return {index: index,value:listModel.get(index)};
    }

    property var logDetail:[]

    function showLog(message,isError,width)
    {
        var component = Qt.createComponent("qrc:/Components/Log.qml")
        if(component.status === Component.Ready)
        {
            var logObj = component.createObject(rootWindow)
            logObj.text = message
            logObj.isError = isError
            logObj.width = width?(Math.min(width,rootWindow.width))
                               :360*AppStyle.size1W
            let y = 0
            for(let i=0;i<logDetail.length;i++)
                y += logDetail[i].height
            logObj.y =y
            logObj.open()
            logDetail.push({"index":logObj.index = (logDetail.length>0?logDetail[logDetail.length-1].index+1:0),"index2":logObj.index2 = (logDetail.length>0?logDetail[logDetail.length-1].index2+1:0),"height":logObj.height,"dialog":logObj})
            logObj.endTime = logObj.index?(logObj.index+1)*logObj.endTime:logObj.endTime
            logObj.callAfterClose = function(){
                for(let i = logObj.index; i< logDetail.length;i++)
                {
                    if(i !== logObj.index)
                    {
                        logDetail[i].dialog.endTime -= logObj.now
                        logDetail[i].dialog.now -= logObj.now
                        logDetail[i].dialog.index -= 1
                        logDetail[i].index -= 1
                        logDetail[i].dialog.y -= logDetail[logObj.index].height
                    }
                }
                logDetail.splice(logObj.index, 1);
            }
        }
        else
            console.error(component.errorString())
    }

    function showUnauthorizedError()
    {
        showLog(qsTr("نام کاربری شما مجاز شناخته نشد، ممکن حساب شما پاک شده باشد."),true,400*AppStyle.size1W)
    }

    function showBusy(text,callback)
    {
        var component = Qt.createComponent("qrc:/Components/BusyDialog.qml")
        if(component.status === Component.Ready)
        {
            var busy = component.createObject(rootWindow)
            busy.message = text
            busy.callback = callback
            busy.open()
        }
        else
            console.error(component.errorString())

        return busy
    }

    function showConfirm(title, text, callback)
    {
        var component = Qt.createComponent("qrc:/Components/ConfirmDialog.qml")
        if(component.status === Component.Ready)
        {
            var confirm = component.createObject(rootWindow)
            confirm.dialogTitle= title
            confirm.dialogText = text
            confirm.accepted = callback
            confirm.open()
        }
        else
            console.error(component.errorString())

        return confirm
    }

    function emailValidation(inputtext)
    {
        var emailExp = /(?!.*\.{2})^([a-z\d!#$%&'*+\-\/=?^_`{|}~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+(\.[a-z\d!#$%&'*+\-\/=?^_`{|}~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+)*|"((([ \t]*\r\n)?[ \t]+)?([\x01-\x08\x0b\x0c\x0e-\x1f\x7f\x21\x23-\x5b\x5d-\x7e\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|\\[\x01-\x09\x0b\x0c\x0d-\x7f\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))*(([ \t]*\r\n)?[ \t]+)?")@(([a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|[a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF][a-z\d\-._~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]*[a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])\.)+([a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|[a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF][a-z\d\-._~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]*[a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])\.?$/i;
        if(inputtext.match(emailExp))
            return true;
        return false
    }

    function mainStackPush(page,title,data)
    {
        if(page !== stackPages.get(stackPages.count-1).page || title !== stackPages.get(stackPages.count-1).title)
        {
            let result = findListModel(stackPages,function(model){return page===model["page"] && title===model["title"]},false)
            if(result)
            {
                stackPages.append({"page":page,"title":title})
                stackPages.remove(result,stackPages.count-result-1)
                mainPage.item.mainStackView.pop(mainPage.item.mainStackView.get(result))
            }
            else{
                stackPages.append({"page":page,"title":title})
                mainPage.item.mainStackView.push(page,data)
            }
            mainPage.item.mainStackView.callWhenPush(data)
        }
    }

    function mainStackPop(object)
    {
        let prevPage = stackPages.get(stackPages.count-2)
        stackPages.remove(stackPages.count-1)
        if(!object)
          object =  mainPage.item.mainStackView.callForGetDataBeforePop()
        mainPage.item.mainStackView.pop()
        mainPage.item.mainStackView.callWhenPop(object)
    }

}
