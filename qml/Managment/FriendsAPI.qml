import QtQuick 2.14

QtObject {

    function getFriendsChanges()
    {

    }

    function getFriends(model)
    {
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
                        if(response.code === 406)
                        {
                            usefulFunc.showLog(qsTr("خطا در ارتباط با سرور، لطفا مجدد تلاش نمایید"),true,null,400*size1W, ltr)
                        }
                        else
                            usefulFunc.showLog(response.message,true,mainColumn,mainColumn.width, ltr)
                        return null
                    }
                }
                catch(e) {
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,mainColumn,mainColumn.width, ltr)
                    return null
                }
            }
        }
    }

    function addFriend(friendName,model)
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
        var busyDialog = usefulFunc.showBusy("");
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
                        if(response.code === 201){
                            model.append(response.result)
                            insertFriends(Array(response.result))
                        }
                    }
                    else {
                        if(response.code === 406)
                        {
                            usefulFunc.showLog(qsTr("خطا در ارتباط با سرور، لطفا مجدد تلاش نمایید"),true,null,400*size1W, ltr)
                        }
                        else
                            usefulFunc.showLog(response.message,true,mainColumn,mainColumn.width, ltr)
                    }

                }
                catch(e) {
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,mainColumn,mainColumn.width, ltr)
                }
            }
        }
    }

    function editFriend(friendId,friendName,model,modelIndex)
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
        var busyDialog = usefulFunc.showBusy("");
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
                            model.set(modelIndex,{"friend_name":response.result.friend_name})
                            updateFriends(response.result)
                        }
                    }
                    else {
                        if(response.code === 406)
                        {
                            usefulFunc.showLog(qsTr("خطا در ارتباط با سرور، لطفا مجدد تلاش نمایید"),true,null,400*size1W, ltr)
                        }
                        else
                            usefulFunc.showLog(response.message,true,mainColumn,mainColumn.width, ltr)
                    }

                }
                catch(e) {
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,mainColumn,mainColumn.width, ltr)
                }
            }
        }
    }

    function deleteFriend(friendId,model,modelIndex)
    {
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + currentUser.id
        xhr.open("DELETE", domain+"/api/v1/friends/"+friendId+"?"+query,true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(null);
        var busyDialog = usefulFunc.showBusy("");
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
                            model.remove(modelIndex)
                            deleteFriendLocalDatabase(friendId)
                        }
                    }
                    else {
                        if(response.code === 406)
                        {
                            usefulFunc.showLog(qsTr("خطا در ارتباط با سرور، لطفا مجدد تلاش نمایید"),true,null,400*size1W, ltr)
                        }
                        else
                            usefulFunc.showLog(response.message,true,mainColumn,mainColumn.width, ltr)
                    }

                }
                catch(e) {
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,mainColumn,mainColumn.width, ltr)
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


    function insertFriends(values)
    {
        let mapValues = values.map(item => [ item.id,   String(item.friend_name),   item.user_id,   String(item.register_date), String(item.modified_date) ] )
        let finalString = ""
        for(let i=0;i<mapValues.length;i++)
        {
            for(let j=0;j<mapValues[i].length;j++)
            {
                mapValues[i][j] = typeof mapValues[i][j] === "string"?'"'+ (mapValues[i][j]==="null"?"":mapValues[i][j]) + '"':mapValues[i][j]
            }
            finalString += "(" + mapValues[i] + ")" + (i!==mapValues.length-1?",":"")
        }

        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("INSERT INTO Friends(id,friend_name,user_id,register_date,modified_date) VALUES "+ finalString)
                        }
                        catch(e)
                        {
                            console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
    } // end of insert function


    function updateFriends(values)
    {
        let array = []
        array[0]= values.friend_name
        array[1]= values.user_id
        array[2]= values.register_date
        array[3]= values.modified_date
        array[4]= values.id

        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("UPDATE Friends SET friend_name = ?,user_id= ? ,register_date = ?,modified_date = ?  WHERE id=?",array)
                        }
                        catch(e)
                        {
                            console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
    } // end of update function


    function deleteFriendLocalDatabase(id)
    {
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("DELETE FROM Friends WHERE id = ?",id)
                        }
                        catch(e)
                        {
                            console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
    }// end of delete function
}
