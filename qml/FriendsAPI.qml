import QtQuick 2.14
import MEnum 1.0

QtObject {

    function getFriendsChanges()
    {
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            let list=[]
                            let result = tx.executeSql("SELECT record_id FROM ServerChanges WHERE table_id = ? AND changes_type !=3 AND user_id = ? GROUP BY record_id",[Memorito.CHFriends ,currentUser.id])
                            if(result.rows.length > 0)
                            {
                                for(let i=0;i<result.rows.length;i++)
                                {
                                    list.push(result.rows.item(i).record_id)
                                }
                                getMultipleFriendsChanges(list.join(','))
                            }

                            list = []
                            let ids =[]

                            result = tx.executeSql("    SELECT record_id,id FROM ServerChanges WHERE table_id = ? AND changes_type  =3 AND user_id = ? GROUP BY record_id",[Memorito.CHFriends ,currentUser.id])
                            if(result.rows.length > 0)
                            {
                                for(let j=0;j<result.rows.length;j++)
                                {
                                    list.push(result.rows.item(j).record_id)
                                    ids.push(result.rows.item(j).id)
                                }
                                deleteFriendLocalDatabase(list.join(','))
                                localDB.deleteFromServerChanges(ids.join(','))
                            }
                        }
                        catch(e)
                        {
                            console.error(e)
                        }
                    })
    }

    function syncFriendsChanges()
    {
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            let list=[]
                            let result = tx.executeSql("SELECT T1.record_id ,T1.changes_type,T1.id AS change_id ,T2.* FROM LocalChanges AS T1
JOIN Friends AS T2 ON record_id =T2.local_id  WHERE table_id = 3 AND T2.user_id = ?",currentUser.id)
                            if(result.rows.length > 0)
                            {
                                for(let i=0;i<result.rows.length;i++)
                                {
                                    let item = result.rows.item(i)
                                    if(item.changes_type === 1)
                                    {
                                        addFriend(item.friend_name,null,item.local_id,item.change_id)
                                    }
                                    else if(item.changes_type === 2)
                                    {
                                        editFriend(item.id,friendName,null,-1,item.local_id,item.change_id)
                                    }
                                    else if(item.changes_type === 3)
                                    {
                                        deleteFriend(item.id,null,-1,item.local_id,item.change_id)
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

    function getMultipleFriendsChanges(changesList)
    {
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + currentUser.id + "&friend_id_list="+changesList
        xhr.open("GET", domain+"/api/v1/friends"+"?"+query,true);
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
                                        if(!getFriendById(item.id))
                                            insertArray.push(item)
                                        else
                                            updateFriends(item)
                                    }
                                    nChangeId.push(item.change_id)
                                }
                                if(insertArray.length > 0)
                                    insertFriends(insertArray)
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

    function getFriends(model)
    {
        if(model.count>0 )
            return model

        let valuesFriends = getFriendsLocalDatabase() // get Friends from local database
        if(valuesFriends.length >0){
            model.append(valuesFriends)
            return model
        }

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + currentUser.id
        xhr.open("GET", domain+"/api/v1/friends"+"?"+query,true);
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
                            insertFriends(response.result)
                        }
                        return model
                    }
                    else {
                        if(response.code === 401)
                        {
                            usefulFunc.showUnauthorizedError()
                        }
                        else
                            usefulFunc.showLog(response.message,true,mainPage,mainPage.width)
                        return null
                    }
                }
                catch(e) {
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,mainPage,mainPage.width)
                    return null
                }
            }
        }
    }

    function addFriend(friendName,model,local_id = null,change_id = null)
    {
        let json = JSON.stringify(
                {
                    user_id: currentUser.id,
                    friend_name: friendName
                }, null, 1);

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("POST", domain+"/api/v1/friends",true);
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
                            if(local_id !== null)
                            {
                                updateFriends(response.result,local_id)
                                localDB.deleteFromLocalChanges(change_id)
                            }
                            else
                            {
                                model.append(response.result)
                                
                                insertFriends(Array(response.result))
                            }
                        }
                    }
                    else if(local_id === null)
                    {
                        if(response.code === 401)
                        {
                            usefulFunc.showUnauthorizedError()
                        }
                        else
                            usefulFunc.showLog(response.message,true,mainPage,mainPage.width)
                    }
                }
                catch(e) {
                    let id = insertFriends([{"id":-1, "friend_name":friendName, "user_id":currentUser.id,"register_date" : "", "modified_date":"" }])
                    localDB.insertLocalChanges([ {"table_id":3,   "record_id":id,    "changes_type":1,  "user_id":currentUser.id}] )
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,mainPage,mainPage.width)
                }
            }
        }
    }

    function editFriend(friendId,friendName,model,modelIndex,local_id = null,change_id = null)
    {
        let json = JSON.stringify(
                {
                    user_id: currentUser.id,
                    friend_name: friendName
                }, null, 1);

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("PATCH", domain+"/api/v1/friends/"+friendId,true);
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
                                model.set(modelIndex,{"friend_name":response.result.friend_name})
                                updateFriends(response.result)
                                
                            }
                            else {
                                updateFriends(response.result,local_id)
                                localDB.deleteFromLocalChanges(change_id)
                            }
                        }
                    }
                    else if(local_id === null) {
                        if(response.code === 401)
                        {
                            usefulFunc.showUnauthorizedError()
                        }
                        else
                            usefulFunc.showLog(response.message,true,mainPage,mainPage.width)
                    }
                }
                catch(e) {
                    model.set(modelIndex,{"friend_name":friendName})
                    updateFriends( {"id":friendId,"friend_name":friendName,"user_id": currentUser.id, "register_date":"","modified_date":""},local_id)
                    localDB.insertLocalChanges([ {"table_id":3,   "record_id":friendId,    "changes_type":2,  "user_id":currentUser.id}] )
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,mainPage,mainPage.width)
                }
            }
        }
    }

    function deleteFriend(friendId,model,modelIndex,local_id = null,change_id = null)
    {
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + currentUser.id
        xhr.open("DELETE", domain+"/api/v1/friends/"+friendId+"?"+query,true);
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
                                model.remove(modelIndex)
                                deleteFriendLocalDatabase(friendId)
                                
                            }
                            else{
                                localDB.deleteFromLocalChanges(change_id)
                            }
                        }
                    }
                    else if(local_id === null) {
                        if(response.code === 401)
                        {
                            usefulFunc.showUnauthorizedError()
                        }
                        else
                            usefulFunc.showLog(response.message,true,mainPage,mainPage.width)
                    }

                }
                catch(e) {
                    deleteFriendLocalDatabase(friendId)
                    localDB.insertLocalChanges([ {"table_id":3,   "record_id":friendId,    "changes_type":3,  "user_id":currentUser.id}] )
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,mainPage,mainPage.width)
                }
            }
        }
    }

    /****************** Local Database Function Table:Friends  **************************/

    function getFriendsLocalDatabase()
    {
        let valuesFriends=[]
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("SELECT * FROM Friends ORDER By id ASC")
                            for(var i=0;i<result.rows.length;i++)
                            {
                                valuesFriends.push(result.rows.item(i))
                            }
                        }
                        catch(e)
                        {

                        }
                    })
        return valuesFriends
    }

    function getFriendById(id)
    {
        let valuesLogs = {}
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("SELECT * FROM Friends WHERE id=?",id)
                            if(result.rows.length)
                                valuesLogs = result.rows.item(0)
                        }
                        catch(e)
                        {

                        }
                    })
        return valuesLogs
    }


    function insertFriends(values)
    {
        let mapValues = values.map(item => [ item.id, String(item.friend_name),   item.user_id,   String(item.register_date), String(item.modified_date) ] )
        let finalString = ""
        for(let i=0;i<mapValues.length;i++)
        {
            for(let j=0;j<mapValues[i].length;j++)
            {
                mapValues[i][j] = typeof mapValues[i][j] === "string"?'"'+ (mapValues[i][j]==="null"?"":mapValues[i][j]) + '"':mapValues[i][j]
            }
            let check = 0;
            dataBase.transaction(function(tx){try{
                    var result = tx.executeSql("SELECT * FROM Friends WHERE id=?",mapValues[i][0])
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
                                tx.executeSql("INSERT INTO Friends( id, friend_name, user_id, register_date, modified_date ) VALUES "+ finalString)
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


    function updateFriends(values,local_id = null)
    {
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            let result
                            if(local_id)
                                result = tx.executeSql(
                                            "UPDATE Friends SET friend_name = ?,user_id= ? ,register_date = ?,modified_date = ?, id=?  WHERE local_id=?",
                                            [values.friend_name??"", values.user_id??0, values.register_date??"", values.modified_date??"",values.id??0, local_id]
                                            )
                            else result = tx.executeSql(
                                     "UPDATE Friends SET friend_name = ?,user_id= ? ,register_date = ?,modified_date = ?  WHERE id=?",
                                     [values.friend_name??"", values.user_id??0, values.register_date??"", values.modified_date??"",values.id??0]
                                     )
                        }
                        catch(e)
                        {
                            console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
    } // end of update function


    function deleteFriendLocalDatabase(ids)
    {
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("DELETE FROM Friends WHERE id IN (?)",ids)
                        }
                        catch(e)
                        {
                            console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
    }// end of delete function
}
