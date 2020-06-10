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
}
