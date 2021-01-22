import QtQuick 2.14

QtObject {

    function getThingsChanges()
    {
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            let list=[]
                            let result = tx.executeSql("SELECT record_id FROM ServerChanges WHERE table_id = 4 AND changes_type !=3 AND user_id = ? GROUP BY record_id",currentUser.id)
                            if(result.rows.length > 0)
                            {
                                for(let i=0;i<result.rows.length;i++)
                                {
                                    list.push(result.rows.item(i).record_id)
                                }
                                getMultipleThingsChanges(list.join(','))
                            }

                            list = []
                            let ids =[]

                            result = tx.executeSql("    SELECT record_id,id FROM ServerChanges WHERE table_id = 4 AND changes_type  =3 AND user_id = ? GROUP BY record_id",currentUser.id)
                            if(result.rows.length > 0)
                            {
                                for(let j=0;j<result.rows.length;j++)
                                {
                                    list.push(result.rows.item(j).record_id)
                                    ids.push(result.rows.item(j).id)
                                }
                                deleteThingLocalDatabase(list.join(','))
                                localDB.deleteFromServerChanges(ids.join(','))
                            }
                        }
                        catch(e)
                        {
                            console.error(e)
                        }
                    })
    }

    function syncThingsChanges()
    {
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            let list=[]
                            let result = tx.executeSql("SELECT T1.record_id ,T1.changes_type,T1.id AS change_id ,T2.* FROM LocalChanges AS T1
JOIN Things AS T2 ON record_id =T2.local_id  WHERE table_id = 4 AND T2.user_id = ?",currentUser.id)
                            if(result.rows.length > 0)
                            {
                                for(let i=0;i<result.rows.length;i++)
                                {
                                    let item = result.rows.item(i)
                                    if(item.changes_type === 1)
                                    {
                                        addThing(null,item.title,item.detail,item.list_id,item.has_files,item.context_id,item.priority_id,item.energy_id,item.estimate_time,item.category_id,
                                                 item.due_date,item.friend_id,item.local_id,item.change_id)
                                    }
                                    else if(item.changes_type === 2)
                                    {
                                        editThing(item.id,-1,null,null,item.title,item.detail,item.list_id,item.has_files,item.context_id,item.priority_id,item.energy_id,item.estimate_time,
                                                  item.category_id,decodeURIComponent(item.due_date)??"",item.friend_id,item.local_id,item.change_id)
                                    }
                                    else if(item.changes_type === 3)
                                    {
                                        deleteThing(item.id,null,-1,item.local_id,item.change_id)
                                    }
                                }
                            }
                        }
                        catch(e)
                        {
                            console.error(e)
                        }
                    })
    }

    function getMultipleThingsChanges(changesList)
    {
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + currentUser.id + "&thing_id_list="+changesList
        xhr.open("GET", domain+"/api/v1/things"+"?"+query,true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(null);
        xhr.timeout = 10000;
        xhr.onreadystatechange = function ()
        {
            if (xhr.readyState === XMLHttpRequest.DONE)
            {
                try
                {
                    let response = xhr.response
                    if(response.ok)
                    {
                        if(response.code === 200){
                            if(response.result.length)
                            {
                                let insertArray = []
                                let nChangeId = []
                                for(let i =0; i<response.result.length; i++)
                                {
                                    let item = response.result[i]
                                    if( item.changes_type === 1 )
                                    {
                                        insertArray.push(item)
                                    }
                                    else if( item.changes_type === 2 )
                                    {
                                        if(!getThingById(item.id))
                                            insertArray.push(item)
                                        else
                                            updateThings(item)
                                    }
                                    nChangeId.push(item.change_id)
                                }
                                if(insertArray.length > 0)
                                    insertThings(insertArray)
                                if(nChangeId.length > 0)
                                {
                                    localDB.deleteFromServerChanges(nChangeId.join(','))
                                }
                            }
                        }
                        return true
                    }
                    else {
                        return null
                    }
                }
                catch(e) {
                    return null
                }
            }
        }
    }


    function getThings(model,listId,categoryId)
    {
        if(model.count>0 )
            return model

        let valuesThings = getThingsLocalDatabase(listId,categoryId) // get Things from local database
        if(valuesThings.length >0){
            model.append(valuesThings)
            return model
        }

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + currentUser.id + "&list_id="+listId + (categoryId === -1 ?"":"&category_id="+categoryId)
        xhr.open("GET", domain+"/api/v1/things"+"?"+query,true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(null);
        var busyDialog = usefulFunc.showBusy("",
                                             function()
                                             {
                                                 usefulFunc.showConfirm(
                                                             qsTr("لغو"),
                                                             qsTr("آیا مایلید که درخواست شما لغو گردد؟"),
                                                             function()
                                                             {
                                                                 xhr.abort()
                                                             }
                                                             )
                                             }
                                             );
        xhr.onabort =function(){
            busyDialog.close()
        }
        xhr.timeout = 10000;
        xhr.onreadystatechange = function ()
        {
            if (xhr.readyState === XMLHttpRequest.DONE)
            {
                busyDialog.close()
                try
                {
                    let response = xhr.response
                    if(response.ok)
                    {
                        if(response.code === 200){
                            model.append(response.result)
                            insertThings(response.result)
                        }
                    }
                    else {
                        if(response.code === 406)
                        {
                            usefulFunc.showLog(qsTr("خطا در ارتباط با سرور، لطفا مجدد تلاش نمایید"),true,null,400*size1W, ltr)
                        }
                        else
                            usefulFunc.showLog(response.message,true,mainPage,mainPage.width, ltr)
                        return null
                    }
                }
                catch(e) {
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,mainPage,mainPage.width, ltr)
                    return null
                }
            }
        }
    }
    function prepareForAdd(model,options,listId,hasFiles,categoryId=null,dueDate=null,friendId=null)
    {
        if(titleInput.text.trim() === "")
        {
            usefulFunc.showLog(qsTr("لطفا قسمت 'چی تو دهنته؟' رو پر کن"),true,null,600*size1W, ltr)
            titleMoveAnimation.start()
            return
        }

        let title = titleInput.text.trim()
        let detail = flickTextArea.text.trim()

        if(dueDate !==null)
            dueDate = encodeURIComponent(dueDate)

        addThing(model,title,detail,listId,hasFiles,options["contextId"],options["priorityId"],options["energyId"],options["estimateTime"],categoryId,dueDate,friendId)
    }

    function addThing(model,title,detail,listId=null,hasFiles,contextId=null,priorityId=null,energyId=null,estimateTime=null,categoryId=null,dueDate=null,friendId=null,local_id = null,change_id = null)
    {
        let json = JSON.stringify(
                {
                    title : title,
                    user_id: currentUser.id,
                    detail : detail,
                    list_id : listId,
                    has_files: parseInt(hasFiles),
                    priority_id : priorityId,
                    estimate_time : estimateTime,
                    context_id : contextId,
                    energy_id : energyId,
                    due_date : dueDate,
                    friend_id : friendId,
                    category_id : categoryId
                }, null, 1);

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("POST", domain+"/api/v1/things",true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(json);
        if(local_id === null)
            var busyDialog = usefulFunc.showBusy("");
        xhr.timeout = 10000;
        xhr.onreadystatechange = function ()
        {
            if (xhr.readyState === XMLHttpRequest.DONE)
            {
                if(local_id === null)
                    busyDialog.close()
                try
                {
                    let response = xhr.response
                    if(response.ok)
                    {
                        if(response.code === 201){
                            if(local_id === null)
                            {
                                model.append(response.result)

                                if(typeof response.result === "array")
                                    insertThings(response.result)
                                else
                                    insertThings(Array(response.result))

                                flickTextArea.detailInput.clear()
                                titleInput.clear()
                                isDual = false

                                usefulFunc.showLog(" <b>'"+ title+" '</b>" +qsTr("با موفقیت افزوده شد"),false,null,700*size1W, ltr)

                                localDB.insertDeviceChanges([{"table_id":4,   "record_id":response.result.id,    "changes_type":1,  "user_id":currentUser.id}])

                                if(hasFiles)
                                    filesApi.addFiles(attachModel,attachModel.count,response.result.id)
                            }
                            else{
                                updateThings(response.result,local_id)
                                localDB.deleteFromLocalChanges(change_id)
                            }

                        }
                    }
                    else if(local_id === null) {
                        if(response.code === 406)
                        {
                            usefulFunc.showLog(qsTr("خطا در ارتباط با سرور، لطفا مجدد تلاش نمایید"),true,null,400*size1W, ltr)
                        }
                        else
                            usefulFunc.showLog(response.message,true,mainPage,mainPage.width, ltr)
                    }

                }
                catch(e) {
                    console.error(e)
                    let id = insertThings([{"id":-1, "title":title, "detail":detail, "list_id":listId, "is_done":0, "has_files":hasFiles,
                                               "context_id":contextId, "priority_id":priorityId, "energy_id":energyId, "estimate_time":estimateTime,
                                                "category_id":categoryId,"due_date":dueDate,"friend_id":friendId,  "user_id": currentUser.id, "register_date":"","modified_date":""}])

                    localDB.insertLocalChanges([ {"table_id":4,   "record_id":id,    "changes_type":1,  "user_id":currentUser.id}] )
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,mainPage,mainPage.width, ltr)
                }
            }
        }
    }

    function prepareForEdit(model,newModel,thingId,options,listId,hasFiles,categoryId=null,dueDate=null,friendId=null)
    {
        if(titleInput.text.trim() === "")
        {
            usefulFunc.showLog(qsTr("لطفا قسمت 'چی تو دهنته؟' رو پر کن"),true,null,600*size1W, ltr)
            return
        }
        let title = titleInput.text.trim()
        let detail = flickTextArea.text.trim()

        if(dueDate !==null)
            dueDate = encodeURIComponent(dueDate)

        editThing(thingId,modelIndex,model,newModel,title,detail,listId,hasFiles,options["contextId"],options["priorityId"],options["energyId"],options["estimateTime"],categoryId,dueDate,friendId)
    }

    function editThing(thingId,modelIndex,model,newModel,title,detail,listId=null,hasFiles,contextId=null,priorityId=null,energyId=null,estimateTime=null,categoryId=null,dueDate=null,friendId=null,local_id = null,change_id = null)
    {
        let json = JSON.stringify(
                {
                    title : title,
                    user_id: currentUser.id,
                    detail : detail,
                    has_files: parseInt(hasFiles),
                    priority_id : priorityId,
                    estimate_time : estimateTime,
                    context_id : contextId,
                    energy_id : energyId,
                    due_date : dueDate,
                    friend_id : friendId,
                    category_id : categoryId,
                    list_id : listId
                }, null, 1);
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("PATCH", domain+"/api/v1/things/"+thingId,true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(json);
        if(local_id === null)
            var busyDialog = usefulFunc.showBusy("");
        xhr.timeout = 10000;
        xhr.onreadystatechange = function ()
        {
            if (xhr.readyState === XMLHttpRequest.DONE)
            {
                if(local_id === null)
                    busyDialog.close()
                try
                {
                    let response = xhr.response
                    if(response.ok)
                    {
                        if(response.code === 200){
                            if(local_id === null)
                            {
                                if(model){
                                    model.remove(modelIndex,1)
                                    newModel.append(response.result)
                                }
                                else newModel.set(modelIndex,response.result)
                                updateThings(response.result)
                                usefulFunc.showLog(" <b>'"+ title+" '</b>" +qsTr("با موفقیت بروزرسانی شد"),false,null,700*size1W, ltr)
                                localDB.insertDeviceChanges([{"table_id":4,   "record_id":response.result.id,    "changes_type":2,  "user_id":currentUser.id}])
                                if(hasFiles)
                                    filesApi.addFiles(attachModel,attachModel.count,response.result.id)
                                usefulFunc.mainStackPop()
                                usefulFunc.mainStackPop()
                            }
                            else {
                                updateThings(response.result,local_id)
                                localDB.deleteFromLocalChanges(change_id)
                            }
                        }
                    }
                    else if(local_id === null){
                        if(response.code === 406)
                        {
                            usefulFunc.showLog(qsTr("خطا در ارتباط با سرور، لطفا مجدد تلاش نمایید"),true,null,400*size1W, ltr)
                        }
                        else
                            usefulFunc.showLog(response.message,true,mainPage,mainPage.width, ltr)
                    }

                }
                catch(e) {
                    updateThings( {"id":thingId, "title":title, "detail":detail, "list_id":listId, "is_done":0, "has_files":hasFiles,
                                    "context_id":contextId, "priority_id":priorityId, "energy_id":energyId, "estimate_time":estimateTime,
                                     "category_id":categoryId,"due_date":dueDate,"friend_id":friendId,  "user_id": currentUser.id, "register_date":"","modified_date":""},local_id)

                    localDB.insertLocalChanges([ {"table_id":4,   "record_id":thingId,    "changes_type":2,  "user_id":currentUser.id}] )
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,mainPage,mainPage.width, ltr)
                }
            }
        }
    }

    function deleteThing(thingId,model,modelIndex,local_id = null,change_id = null)
    {
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + currentUser.id
        xhr.open("DELETE", domain+"/api/v1/things/"+thingId+"?"+query,true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(null);
        if(local_id === null)
            var busyDialog = usefulFunc.showBusy("");
        xhr.timeout = 10000;
        xhr.onreadystatechange = function ()
        {
            if (xhr.readyState === XMLHttpRequest.DONE)
            {
                if(local_id === null)
                    busyDialog.close()
                try
                {
                    let response = xhr.response
                    if(response.ok)
                    {
                        if(response.code === 200){
                            if(local_id === null)
                            {
//                                model.remove(modelIndex)
                                deleteThingLocalDatabase(thingId)
                                localDB.insertDeviceChanges([{"table_id":4,   "record_id":thingId,    "changes_type":3,  "user_id":currentUser.id}])
                                usefulFunc.mainStackPop()
                            }
                            else{
                                localDB.deleteFromLocalChanges(change_id)
                            }
                        }
                    }
                    else if(local_id === null){
                        if(response.code === 406)
                        {
                            usefulFunc.showLog(qsTr("خطا در ارتباط با سرور، لطفا مجدد تلاش نمایید"),true,null,400*size1W, ltr)
                        }
                        else
                            usefulFunc.showLog(response.message,true,mainPage,mainPage.width, ltr)
                    }

                }
                catch(e) {
                    deleteThingLocalDatabase(thingId)
                    localDB.insertLocalChanges([ {"table_id":4,   "record_id":thingId,    "changes_type":3,  "user_id":currentUser.id}] )
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,mainPage,mainPage.width, ltr)
                }
            }
        }
    }

    /****************** Local Database Function Table:Things  **************************/

    function getThingsLocalDatabase(listId,categoryId)
    {
        let valuesThings=[]
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("SELECT * FROM Things WHERE list_id=? OR (list_id=? AND category_id=?) ORDER By id ASC",[listId,listId,categoryId])
                            for(var i=0;i<result.rows.length;i++)
                            {
                                valuesThings.push(result.rows.item(i))
                            }
                        }
                        catch(e)
                        {

                        }
                    })
        return valuesThings
    }

    function getThingById(id)
    {
        let valuesLogs = {}
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("SELECT * FROM Things WHERE id=?",id)
                            if(result.rows.length)
                                valuesLogs = result.rows.item(0)
                        }
                        catch(e)
                        {

                        }
                    })
        return valuesLogs
    }
    function insertThings(values,local_id = null)
    {
        let mapValues = values.map(item => [ item.id, String(item.title), String(item.detail)??"", item.list_id ?? 0, item.is_done??0, item.has_files??0,item.context_id??0,
                                             item.priority_id??0, item.user_id??0, item.energy_id??0, item.estimate_time??0, item.category_id??0, String(item.due_date)??"",
                                             item.friend_id??0, item.register_date??"",item.modified_date??"" ] )
        // todo decode dates
        let finalString = ""
        for(let i=0;i<mapValues.length;i++)
        {
            for(let j=0;j<mapValues[i].length;j++)
            {
                mapValues[i][j] = typeof mapValues[i][j] === "string"?'"'+ (mapValues[i][j]==="null"?"":mapValues[i][j]) + '"':mapValues[i][j]
            }
            let check = 0;
            dataBase.transaction(function(tx){try{
                    var result = tx.executeSql("SELECT * FROM Things WHERE id=?",mapValues[i][0])
                    check = result.rows.length}catch(e){}
            })

            if(!check)
                finalString += "(" + mapValues[i] + ")" + (i!==mapValues.length-1?",":"")
        }
        let insertId = -1
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            if(finalString!== "")
                            {
                                tx.executeSql("INSERT INTO Things( id, title, detail, list_id, is_done, has_files, context_id, priority_id, user_id, energy_id,
estimate_time, category_id, due_date, friend_id, register_date, modified_date ) VALUES "+ finalString)
                                var result = tx.executeSql("SELECT last_insert_rowid() as id")
                                insertId= parseInt(result.insertId);
                            }
                        }
                        catch(e)
                        {
                            console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
        return insertId
    } // end of insert function


    function updateThings(values,local_id = null)
    {
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            let result
                            if(local_id)
                                result = tx.executeSql("UPDATE Things SET title = ?, detail = ?, list_id=?, is_done=?, has_files=?,context_id=?, priority_id=?, user_id= ?,
energy_id=?, estimate_time=?, category_id=?, due_date=?, friend_id=?, register_date = ?, modified_date = ?, id=? WHERE local_id=? ",
                                            [
                                                values.title,values.detail ,values.list_id ,values.is_done??0 ,values.has_files??0 ,values.context_id??0 ,values.priority_id??0,
                                                values.user_id??0 ,values.energy_id??0 ,values.estimate_time??0 , values.category_id??0, values.due_date??"", values.friend_id??0,
                                                values.register_date??"", values.modified_date??"", values.id??0, local_id
                                            ])

                            else result = tx.executeSql("UPDATE Things SET title = ?, detail = ?, list_id=?, is_done=?, has_files=?, context_id=?, priority_id=?, user_id= ?,
energy_id=?, estimate_time=?, category_id=?, due_date=?, friend_id=?, register_date = ?, modified_date = ?  WHERE id=?",
                                     [
                                         values.title,values.detail ,values.list_id??0 ,values.is_done??0 ,values.has_files??0 ,values.context_id??0 ,values.priority_id??0,
                                         values.user_id??0 ,values.energy_id??0 ,values.estimate_time??0 , values.category_id??0, values.due_date??"", values.friend_id??0,
                                         values.register_date??"", values.modified_date??"", values.id
                                     ])
                        }
                        catch(e)
                        {
                            console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
    } // end of update function


    function deleteThingLocalDatabase(ids)
    {
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("DELETE FROM Things WHERE id IN (?)",ids)
                        }
                        catch(e)
                        {
                            console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
    }// end of delete function

}
