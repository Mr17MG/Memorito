pragma Singleton
import QtQuick 2.14
import Global 1.0

QtObject {
    function getThingsChanges()
    {
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            let list=[]
                            let result = tx.executeSql("SELECT record_id FROM ServerChanges WHERE table_id = ? AND changes_type !=3 AND user_id = ? GROUP BY record_id",[Memorito.CHThings ,User.id])
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

                            result = tx.executeSql("    SELECT record_id,id FROM ServerChanges WHERE table_id = ? AND changes_type  =3 AND user_id = ? GROUP BY record_id",[Memorito.CHThings ,User.id])
                            if(result.rows.length > 0)
                            {
                                for(let j=0;j<result.rows.length;j++)
                                {
                                    list.push(result.rows.item(j).record_id)
                                    ids.push(result.rows.item(j).id)
                                }
                                deleteThingLocalDatabase(list.join(','))
                                LocalDatabase.deleteFromServerChanges(ids.join(','))
                            }
                        }
                        catch(e)
                        {
                            console.trace();console.error(e)
                        }
                    })
    }

    function syncThingsChanges()
    {
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            let list=[]
                            let result = tx.executeSql("SELECT T1.record_id ,T1.changes_type,T1.id AS change_id ,T2.* FROM LocalChanges AS T1
JOIN Things AS T2 ON record_id =T2.local_id  WHERE table_id = 4 AND T2.user_id = ?",User.id)
                            if(result.rows.length > 0)
                            {
                                for(let i=0;i<result.rows.length;i++)
                                {
                                    let item = result.rows.item(i)
                                    if(item.changes_type === 1)
                                    {
                                        let json = JSON.stringify(
                                                {
                                                    title           : item.title                                                ,
                                                    user_id         : User.id                                                   ,
                                                    detail          : item.detail                                               ,
                                                    list_id         : item.list_id                                              ,
                                                    has_files       : parseInt(item.has_files)                                  ,
                                                    energy_id       : item.energy_id        === 0 ? null :  item.energy_id      ,
                                                    context_id      : item.context_id       === 0 ? null :  item.context_id     ,
                                                    priority_id     : item.priority_id      === 0 ? null :  item.priority_id    ,
                                                    estimate_time   : item.estimate_time    === 0 ? null :  item.estimate_time  ,
                                                    due_date        : item.due_date         === ""? null :  item.due_date       ,
                                                    friend_id       : item.friend_id        === 0 ? null :  item.friend_id      ,
                                                    category_id     : item.category_id      === 0 ? null :  item.category_id    ,
                                                    is_done         : item.is_done ?? 0
                                                }, null, 1);

                                        addThing(json,null,item.local_id,item.change_id)
                                    }
                                    else if(item.changes_type === 2)
                                    {
                                        let json = JSON.stringify(
                                                {
                                                    title           : item.title                                                ,
                                                    user_id         : User.id                                                   ,
                                                    detail          : item.detail                                               ,
                                                    list_id         : item.list_id                                              ,
                                                    has_files       : parseInt(item.has_files)                                  ,
                                                    energy_id       : item.energy_id        === 0 ? null :  item.energy_id      ,
                                                    context_id      : item.context_id       === 0 ? null :  item.context_id     ,
                                                    priority_id     : item.priority_id      === 0 ? null :  item.priority_id    ,
                                                    estimate_time   : item.estimate_time    === 0 ? null :  item.estimate_time  ,
                                                    due_date        : item.due_date         === ""? null :  item.due_date       ,
                                                    friend_id       : item.friend_id        === 0 ? null :  item.friend_id      ,
                                                    category_id     : item.category_id      === 0 ? null :  item.category_id    ,
                                                    is_done         : item.is_done ?? 0
                                                }, null, 1);

                                        editThing(item.id,json,null,item.local_id,item.change_id)
                                    }
                                    else if(item.changes_type === 3)
                                    {
                                        deleteThing(item.id,item.local_id,item.change_id)
                                    }
                                }
                            }
                        }
                        catch(e)
                        {
                            console.trace();console.error(e)
                        }
                    })
    }

    function getMultipleThingsChanges(changesList)
    {
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + User.id + "&thing_id_list="+changesList
        xhr.open("GET", domain+"/api/v1/things"+"?"+query,true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Authorization", "Basic " +Qt.btoa(unescape(encodeURIComponent( User.email + ':' + User.authToken))) );
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
                                    LocalDatabase.deleteFromServerChanges(nChangeId.join(','))
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
        let valuesThings;
        if(categoryId === -1)
            valuesThings = getThingsByListId(listId) // get Things from local database
        else
            valuesThings = getThingsByListIdAndCategoryId(listId,categoryId)

        if(valuesThings.length >0){
            if(model[0] !== "__")
                model.append(valuesThings)
            return model
        }

        if(listId === Memorito.Done)
            return

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + User.id + "&list_id="+listId + (categoryId === -1 ?"":"&category_id="+categoryId)
        xhr.open("GET", domain+"/api/v1/things"+"?"+query,true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Authorization", "Basic " +Qt.btoa(unescape(encodeURIComponent( User.email + ':' + User.authToken))) );
        xhr.send(null);
        var busyDialog = UsefulFunc.showBusy("",
                                             function()
                                             {
                                                 UsefulFunc.showConfirm(
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
                            insertThings(response.result)
                            let ids = response.result.map(item =>[item.id]).join(",")

                            let valuesThings = getThingById(ids)
                            if(valuesThings.length >0){
                                if(model[0] !== "__")
                                    model.append(valuesThings)
                                return model
                            }
                        }
                    }
                    else {
                        if(response.code === 401)
                        {
                            console.trace();UsefulFunc.showUnauthorizedError()
                        }
                        else
                            UsefulFunc.showLog(response.message,true)
                        return null
                    }
                }
                catch(e) {
                    UsefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true)
                    return null
                }
            }
        }
    }


    function addThing(json,filesModel,local_id = null,change_id = null)
    {
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("POST", domain+"/api/v1/things",true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Authorization", "Basic " +Qt.btoa(unescape(encodeURIComponent( User.email + ':' + User.authToken))) );
        xhr.send(json);
        if(local_id === null)
            var busyDialog = UsefulFunc.showBusy("");
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
                                let ids;
                                if(typeof response.result === "array")
                                {
                                    insertThings(response.result)
                                }
                                else
                                {
                                    insertThings(Array(response.result))
                                }

                                UsefulFunc.showLog(" <b>'"+ response.result.title+" '</b>" +qsTr("با موفقیت افزوده شد"),false)

                                if(filesModel)
                                    if(filesModel.count > 0)
                                        FilesApi.addFiles(filesModel,filesModel.count,response.result.id)

                                UsefulFunc.mainStackPop({"thingId":response.result.id,"changeType":Memorito.Insert})
                            }
                            else{
                                updateThings(response.result,local_id)
                                LocalDatabase.deleteFromLocalChanges(change_id)
                            }

                        }
                    }
                    else if(local_id === null) {
                        if(response.code === 401)
                        {
                            console.trace();UsefulFunc.showUnauthorizedError()
                        }
                        else
                            UsefulFunc.showLog(response.message,true)
                    }

                }
                catch(e) {
                    json = JSON.parse(json)
                    let id = insertThings([{"id":-1, "title":json.title??"", "detail":json.detail??"", "list_id":json.list_id??0, "is_done":0, "has_files":json.has_files,
                                               "context_id":json.context_id??0, "priority_id":json.priorityId??0, "energy_id":json.energy_id??0, "estimate_time":json.estimate_time??0,
                                               "category_id":json.category_id??0,"due_date":json.due_date??"","friend_id":json.friend_id??0,  "user_id": User.id, "register_date":"","modified_date":""}])
                    if(filesModel)
                        if(filesModel.count > 0)
                            FilesApi.addFiles(filesModel,filesModel.count,-1)

                    LocalDatabase.insertLocalChanges([ {"table_id":4,   "record_id":id,    "changes_type":1,  "user_id":User.id}] )
                    UsefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true)
                    UsefulFunc.mainStackPop({"localThingId":id,"changeType":Memorito.Insert})

                }

            }
        }
    }

    function editThing(thingId,json,filesModel,local_id = null,change_id = null)
    {

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("PATCH", domain+"/api/v1/things/"+thingId,true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Authorization", "Basic " +Qt.btoa(unescape(encodeURIComponent( User.email + ':' + User.authToken))) );
        xhr.send(json);
        if(local_id === null)
            var busyDialog = UsefulFunc.showBusy("");
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
                                updateThings(response.result)

                                UsefulFunc.showLog(" <b>'"+ response.result.title+" '</b>" +qsTr("با موفقیت بروزرسانی شد"),false)
                                if(filesModel)
                                    if(filesModel.count > 0)
                                        FilesApi.addFiles(filesModel,filesModel.count,response.result.id)

                            }
                            else {
                                updateThings(response.result,local_id)
                                LocalDatabase.deleteFromLocalChanges(change_id)
                            }
                        }
                    }
                    else if(local_id === null){
                        if(response.code === 401)
                        {
                            console.trace();UsefulFunc.showUnauthorizedError()
                        }
                        else
                            UsefulFunc.showLog(response.message,true)
                    }

                }
                catch(e) {
                    json = JSON.parse(json)
                    updateThings( {"id":thingId, "title":json.title??"", "detail":json.detail??"", "list_id":json.list_id??0, "is_done":0, "has_files":json.has_files,
                                     "context_id":json.context_id??0, "priority_id":json.priorityId??0, "energy_id":json.energy_id??0, "estimate_time":json.estimate_time??0,
                                     "category_id":json.category_id??0,"due_date":json.due_date??"","friend_id":json.friend_id??0,  "user_id": User.id, "register_date":"","modified_date":""},local_id)
                    if(filesModel)
                        if(filesModel.count > 0)
                            FilesApi.addFiles(filesModel,filesModel.count,thingId)

                    LocalDatabase.insertLocalChanges([ {"table_id":4,   "record_id":thingId,    "changes_type":2,  "user_id":User.id}] )
                    UsefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true)
                }
                if(local_id === null)
                    UsefulFunc.mainStackPop({"thingId":thingId,"chnageType":Memorito.Update})
            }
        }
    }

    function deleteThing(thingId,local_id = null,change_id = null)
    {
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + User.id
        xhr.open("DELETE", domain+"/api/v1/things/"+thingId+"?"+query,true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Authorization", "Basic " +Qt.btoa(unescape(encodeURIComponent( User.email + ':' + User.authToken))) );
        xhr.send(null);
        if(local_id === null)
            var busyDialog = UsefulFunc.showBusy("");
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
                                deleteThingLocalDatabase(thingId)

                            }
                            else{
                                LocalDatabase.deleteFromLocalChanges(change_id)
                            }
                        }
                    }
                    else if(local_id === null){
                        if(response.code === 401)
                        {
                            console.trace();UsefulFunc.showUnauthorizedError()
                        }
                        else
                            UsefulFunc.showLog(response.message,true)
                    }

                }
                catch(e) {
                    deleteThingLocalDatabase(thingId)
                    LocalDatabase.insertLocalChanges([ {"table_id":4,   "record_id":thingId,    "changes_type":3,  "user_id":User.id}] )
                    UsefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true)
                }
                if(local_id === null)
                    UsefulFunc.mainStackPop({"thingId":thingId,"changeType":Memorito.Delete})
            }
        }
    }

    /****************** Local Database Function Table:Things  **************************/

    function getThingsByListId(listId)
    {
        let valuesThings=[]
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            let result
                            if( listId === Memorito.Done )
                                result = tx.executeSql("SELECT * FROM Things WHERE is_done = 1 ORDER By id ASC")
                            else if( listId === Memorito.NextAction ){
                                var fromDate = new Date()
                                var toDate = new Date()

                                fromDate.setHours(0)
                                fromDate.setMinutes(0)
                                fromDate.setSeconds(0)

                                toDate.setHours(23)
                                toDate.setMinutes(59)
                                toDate.setSeconds(59)
                                result = tx.executeSql("SELECT * FROM Things WHERE ( list_id IN (?,?) OR ( list_id = ? AND datetime(due_date) BETWEEN datetime(?) AND datetime(?) ) )
 AND is_done != 1 ORDER By id ASC"
                                                       ,[Memorito.NextAction,Memorito.Project,Memorito.Calendar,fromDate,toDate])
                            }
                            else
                                result = tx.executeSql("SELECT * FROM Things WHERE list_id = ? AND is_done != 1 ORDER By id ASC",listId)
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

    function getThingsByListIdAndCategoryId(listId,categoryId)
    {
        let valuesThings=[]
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("SELECT * FROM Things WHERE list_id = ? AND category_id = ? ORDER By id ASC",[listId,categoryId])
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

    function getThingsByQuery(query)
    {
        let valuesThings=[]
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("SELECT * FROM Things " + query)
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

    function getThingById(ids)
    {
        let valuesThings = []
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("SELECT * FROM Things WHERE id IN ("+ids+")")
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

    function getThingByFriendId(ids)
    {
        let valuesThings = []
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("SELECT * FROM Things WHERE list_id != ? AND friend_id IN ("+ids+")",Memorito.Trash)
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

    function getThingByContextId(ids)
    {
        let valuesThings = []
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("SELECT * FROM Things WHERE list_id != ? AND context_id IN ("+ids+")",Memorito.Trash)
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

    function getThingByLocalId(LocalId)
    {
        let valuesLogs = {}
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("SELECT * FROM Things WHERE local_id=?",LocalId)
                            if(result.rows.length)
                                valuesLogs = result.rows.item(0)
                        }
                        catch(e)
                        {

                        }
                    })
        return valuesLogs
    }

    function getThingByDate(fromDate,toDate)
    {
        let valuesThings = []

        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("SELECT * FROM Things WHERE list_id = ? AND datetime(due_date) BETWEEN datetime(?) AND datetime(?) ",[Memorito.Calendar,fromDate,toDate])
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

    function insertThings(values,local_id = null)
    {
        let mapValues = values.map(item => [ item.id, item.title, item.detail??"", item.list_id ?? 0, item.is_done??0, item.has_files??0,item.context_id??0,
                                            item.priority_id??0, item.user_id??0, item.energy_id??0, item.estimate_time??0, item.category_id??0, item.due_date??"",
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
            Database.connection.transaction(function(tx){try{
                    var result = tx.executeSql("SELECT * FROM Things WHERE id=?",mapValues[i][0])
                    check = result.rows.length}catch(e){}
            })

            if(!check)
                finalString += "(" + mapValues[i] + ")" + (i!==mapValues.length-1?",":"")
        }
        let insertId = -1
        Database.connection.transaction(
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
                            console.trace();console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
        return insertId
    } // end of insert function


    function updateThings(values,local_id = null)
    {
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            let result
                            if(local_id)
                                result = tx.executeSql("UPDATE Things SET title = ?, detail = ?, list_id=?, is_done=?, has_files=?,context_id=?, priority_id=?, user_id= ?,
energy_id=?, estimate_time=?, category_id=?, due_date=?, friend_id=?, register_date = ?, modified_date = ?, id=? WHERE local_id=? ",
                                                       [
                                                           values.title??"",
                                                           values.detail??"",
                                                           values.list_id??0 ,
                                                           values.is_done??0 ,
                                                           values.has_files??0 ,
                                                           values.context_id??0 ,
                                                           values.priority_id??0,
                                                           values.user_id??0 ,
                                                           values.energy_id??0 ,
                                                           values.estimate_time??0 ,
                                                           values.category_id??0,
                                                           values.due_date??"",
                                                           values.friend_id??0,
                                                           values.register_date??"",
                                                           values.modified_date??"",
                                                           values.id??0,
                                                           local_id
                                                       ])

                            else result = tx.executeSql("UPDATE Things SET title = ?, detail = ?, list_id=?, is_done=?, has_files=?, context_id=?, priority_id=?, user_id= ?,
energy_id=?, estimate_time=?, category_id=?, due_date=?, friend_id=?, register_date = ?, modified_date = ?  WHERE id=?",
                                                        [
                                                            values.title??"",
                                                            values.detail??"",
                                                            values.list_id??0 ,
                                                            values.is_done??0 ,
                                                            values.has_files??0 ,
                                                            values.context_id??0 ,
                                                            values.priority_id??0,
                                                            values.user_id??0 ,
                                                            values.energy_id??0 ,
                                                            values.estimate_time??0 ,
                                                            values.category_id??0,
                                                            values.due_date??"",
                                                            values.friend_id??0,
                                                            values.register_date??"",
                                                            values.modified_date??"",
                                                            values.id
                                                        ])
                        }
                        catch(e)
                        {
                            console.trace();console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
    } // end of update function


    function deleteThingLocalDatabase(ids)
    {
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("DELETE FROM Things WHERE id IN (?)",ids)
                        }
                        catch(e)
                        {
                            console.trace();console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
    }// end of delete function

}
