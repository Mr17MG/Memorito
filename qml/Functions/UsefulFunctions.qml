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
}
