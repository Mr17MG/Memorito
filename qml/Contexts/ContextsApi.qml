pragma Singleton
import QtQuick 2.14
import Global 1.0

QtObject {
    function getContextsChanges()
    {
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            let list=[]
                            let result = tx.executeSql("SELECT record_id FROM ServerChanges WHERE table_id = ? AND changes_type !=3 AND user_id = ? GROUP BY record_id",[Memorito.CHContexts ,User.id])
                            if(result.rows.length > 0)
                            {
                                for(let i=0;i<result.rows.length;i++)
                                {
                                    list.push(result.rows.item(i).record_id)
                                }
                                getMultipleContextsChanges(list.join(','))
                            }

                            list = []
                            let ids =[]

                            result = tx.executeSql("    SELECT record_id,id FROM ServerChanges WHERE table_id = ? AND changes_type  =3 AND user_id = ? GROUP BY record_id",[Memorito.CHContexts ,User.id])
                            if(result.rows.length > 0)
                            {
                                for(let j=0;j<result.rows.length;j++)
                                {
                                    list.push(result.rows.item(j).record_id)
                                    ids.push(result.rows.item(j).id)
                                }
                                deleteContextLocalDatabase(list.join(','))
                                LocalDatabase.deleteFromServerChanges(ids.join(','))
                            }
                        }
                        catch(e)
                        {
                            console.trace()
                            console.error(e)
                        }
                    })
    }

    function syncContextsChanges()
    {
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            let list=[]
                            let result = tx.executeSql("SELECT T1.record_id ,T1.changes_type,T1.id AS change_id ,T2.* FROM LocalChanges AS T1
JOIN Contexts AS T2 ON record_id =T2.local_id  WHERE table_id = 2 AND T2.user_id = ?",User.id)
                            if(result.rows.length > 0)
                            {
                                for(let i=0;i<result.rows.length;i++)
                                {
                                    let item = result.rows.item(i)
                                    if(item.changes_type === 1)
                                    {
                                        addContext(item.context_name,null,item.local_id,item.change_id)
                                    }
                                    else if(item.changes_type === 2)
                                    {
                                        editContext(item.id,contextName,null,-1,item.local_id,item.change_id)
                                    }
                                    else if(item.changes_type === 3)
                                    {
                                        deleteContext(item.id,null,-1,item.local_id,item.change_id)
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

    function getMultipleContextsChanges(changesList)
    {
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + User.id + "&context_id_list="+changesList
        xhr.open("GET", domain+"/api/v1/contexts"+"?"+query,true);
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
                                        if(!getContextById(item.id))
                                            insertArray.push(item)
                                        else
                                            updateContexts(item)
                                    }
                                    nChangeId.push(item.change_id)
                                }
                                if(insertArray.length > 0)
                                    insertContexts(insertArray)
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


    function getContexts(model)
    {
        if(model.count>0 )
            return model

        let valuesContexts = getContextsLocalDatabase() // get Contexts from local database
        if(valuesContexts.length >0){
            model.append(valuesContexts)
            return model
        }

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + User.id
        xhr.open("GET", domain+"/api/v1/contexts"+"?"+query,true);
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
                            insertContexts(response.result)
                            let ids = response.result.map(item =>[item.id]).join(",")

                            let valuesThings = getContextById(ids)
                            if(valuesThings.length >0){
                                model.append(valuesThings)
                                return model
                            }
                        }
                        return model
                    }
                    else {
                        if(response.code === 401)
                        {
                            console.trace();UsefulFunc.showUnauthorizedError()
                        }
                        else
                            UsefulFunc.showLog(response.message,true,1700*AppStyle.size1W)
                        return null
                    }
                }
                catch(e) {
                    UsefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,1700*AppStyle.size1W)
                    return null
                }
            }
        }
    }

    function addContext(contextName,model,local_id = null,change_id = null)
    {
        let json = JSON.stringify(
                {
                    user_id: User.id,
                    context_name: contextName
                }, null, 1);

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("POST", domain+"/api/v1/contexts",true);
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
                                model.append(response.result)
                                insertContexts(Array(response.result))
                                
                            }
                            else{
                                updateContexts(response.result,local_id)
                                LocalDatabase.deleteFromLocalChanges(change_id)
                            }
                        }
                    }
                    else if(local_id === null)
                    {
                        if(response.code === 401)
                        {
                            console.trace();UsefulFunc.showUnauthorizedError()
                        }
                        else
                            UsefulFunc.showLog(response.message,true,1700*AppStyle.size1W)
                    }

                }
                catch(e) {
                    let id = insertContexts([{"id":-1, "context_name":contextName, "user_id":User.id,"register_date" : "", "modified_date":"" }])
                    LocalDatabase.insertLocalChanges([ {"table_id":2,   "record_id":id,    "changes_type":1,  "user_id":User.id}] )
                    UsefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,1700*AppStyle.size1W)
                }
            }
        }
    }

    function editContext(contextId,contextName,model,modelIndex,local_id = null,change_id = null)
    {
        let json = JSON.stringify(
                {
                    user_id: User.id,
                    context_name: contextName
                }, null, 1);

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("PATCH", domain+"/api/v1/contexts/"+contextId,true);
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
                            if(local_id === null)        {
                                model.set(modelIndex,{"context_name":contextName})
                                
                                updateContexts(response.result)
                            }
                            else {
                                updateContexts(response.result,local_id)
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
                            UsefulFunc.showLog(response.message,true,1700*AppStyle.size1W)
                    }

                }
                catch(e) {
                    model.set(modelIndex,{"context_name":contextName})
                    updateContexts( {"id":contextId,"context_name":contextName, "user_id": User.id ,"register_date":"", "modified_date":"" },local_id)
                    LocalDatabase.insertLocalChanges([ {"table_id":2,   "record_id":contextId,    "changes_type":2,  "user_id":User.id}] )
                    UsefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,1700*AppStyle.size1W)
                }
            }
        }
    }

    function deleteContext(contextId,model,modelIndex,local_id = null,change_id = null)
    {
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + User.id
        xhr.open("DELETE", domain+"/api/v1/contexts/"+contextId+"?"+query,true);
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
                                model.remove(modelIndex)
                                deleteContextLocalDatabase(contextId)
                                
                            }
                            else{
                                LocalDatabase.deleteFromLocalChanges(change_id)
                            }
                        }
                    }
                    else {
                        if(response.code === 401)
                        {
                            console.trace();UsefulFunc.showUnauthorizedError()
                        }
                        else
                            UsefulFunc.showLog(response.message,true,1700*AppStyle.size1W)
                    }

                }
                catch(e) {
                    deleteContextLocalDatabase(contextId)
                    LocalDatabase.insertLocalChanges([ {"table_id":2,   "record_id":contextId,    "changes_type":3,  "user_id":User.id}] )
                    UsefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,1700*AppStyle.size1W)
                }
            }
        }
    }

    /****************** Local Database Function Table:Contexts  **************************/

    function getContextsLocalDatabase()
    {
        let valuesContexts=[]
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("SELECT * FROM Contexts ORDER By id ASC")
                            for(var i=0;i<result.rows.length;i++)
                            {
                                valuesContexts.push(result.rows.item(i))
                            }
                        }
                        catch(e)
                        {

                        }
                    })
        return valuesContexts
    }

    function getContextById(id)
    {
        let valuesLogs = {}
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("SELECT * FROM Contexts WHERE id IN (?)",id)
                            if(result.rows.length)
                                valuesLogs = result.rows.item(0)
                        }
                        catch(e)
                        {

                        }
                    })
        return valuesLogs
    }


    function insertContexts(values)
    {
        let mapValues = values.map(item => [ item.id??0, item.context_name??"",   item.user_id??0,   item.register_date??"", item.modified_date??"" ] )
        let finalString = ""
        for(let i=0;i<mapValues.length;i++)
        {
            for(let j=0;j<mapValues[i].length;j++)
            {
                mapValues[i][j] = typeof mapValues[i][j] === "string"?'"'+ (mapValues[i][j]==="null"?"":mapValues[i][j]) + '"':mapValues[i][j]
            }
            let check = 0;
            Database.connection.transaction(function(tx){try{
                    var result = tx.executeSql("SELECT * FROM Contexts WHERE id=?",mapValues[i][0])
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
                                tx.executeSql("INSERT INTO Contexts( id, context_name, user_id, register_date, modified_date ) VALUES "+ finalString)
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


    function updateContexts(values,local_id = null)
    {
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            let result
                            if(local_id)
                                result = tx.executeSql(
                                            "UPDATE Contexts SET context_name = ?,user_id= ? ,register_date = ?,modified_date = ?, id=?  WHERE local_id=?",
                                            [values.context_name??"", values.user_id??0, values.register_date??"", values.modified_date??"",values.id??0, local_id]
                                            )
                            else result = tx.executeSql(
                                     "UPDATE Contexts SET context_name = ?,user_id= ? ,register_date = ?,modified_date = ?  WHERE id=?",
                                     [values.context_name??"", values.user_id??0, values.register_date??"", values.modified_date??"",values.id??0]
                                     )
                        }
                        catch(e)
                        {
                            console.trace();console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
    } // end of update function


    function deleteContextLocalDatabase(ids)
    {
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("DELETE FROM Contexts WHERE id IN (?)",ids)
                        }
                        catch(e)
                        {
                            console.trace();console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
    }// end of delete function
}
