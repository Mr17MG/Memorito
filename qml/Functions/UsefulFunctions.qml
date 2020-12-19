import QtQuick 2.14

QtObject {
    function findListModel(model, criteria,isData) {
        for(var i = 0; i < model.count; ++i)
            if (criteria(model.get(i)))
            {
                if(isData)
                    return model.get(i);
                else return i;
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

    function findInModel(key,searchField,listModel){
        var personIndex = findListModel(listModel,function(model){return key===model[searchField]},false)
        return {index: personIndex,value:listModel.get(personIndex)};
    }
    function showLog(message,isError,parent,width,isLeftEdge) {
        var component = Qt.createComponent("qrc:/Components/Log.qml")
        if(component.status === Component.Ready) {
            var error = component.createObject(parent?parent:rootWindow)
            error.text = message
            error.isError = isError
            error.edge = isLeftEdge ? Qt.LeftEdge : Qt.RightEdge
            error.width = width?width:360*size1W
            error.open()
        } else
            console.error(component.errorString())
    }

    function showBusy(text,callback) {
        var component = Qt.createComponent("qrc:/Components/BusyDialog.qml")
        if(component.status === Component.Ready) {
            var busy = component.createObject(rootWindow)
            busy.message = text
            busy.callback = callback
            busy.open()
        } else
            console.error(component.errorString())

        return busy
    }

    function showConfirm(title, text, callback) {
        var component = Qt.createComponent("qrc:/Components/ConfirmDialog.qml")
        if(component.status === Component.Ready) {
            var confirm = component.createObject(rootWindow)
            confirm.dialogTitle= title
            confirm.dialogText = text
            confirm.accepted = callback
            confirm.open()
        } else
            console.error(component.errorString())

        return confirm
    }

    function emailValidation(inputtext){
        var emailExp = /(?!.*\.{2})^([a-z\d!#$%&'*+\-\/=?^_`{|}~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+(\.[a-z\d!#$%&'*+\-\/=?^_`{|}~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+)*|"((([ \t]*\r\n)?[ \t]+)?([\x01-\x08\x0b\x0c\x0e-\x1f\x7f\x21\x23-\x5b\x5d-\x7e\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|\\[\x01-\x09\x0b\x0c\x0d-\x7f\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))*(([ \t]*\r\n)?[ \t]+)?")@(([a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|[a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF][a-z\d\-._~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]*[a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])\.)+([a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|[a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF][a-z\d\-._~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]*[a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])\.?$/i;
        if(inputtext.match(emailExp))
            return true;
        return false
    }

    function mainStackPush(page,title)
    {
        if(page !== stackPages.get(stackPages.count-1).page)
        {
            mainHeaderTitle = title
            stackPages.append({"page":page,"title":title})
            mainColumn.item.mainStackView.push(page)
        }
    }

    function mainStackPop()
    {
        let prevPage = stackPages.get(stackPages.count-2)
        mainHeaderTitle = prevPage.title
        stackPages.remove(stackPages.count-1)
        mainColumn.item.mainStackView.pop()

    }
}
