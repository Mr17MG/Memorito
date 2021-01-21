import QtQuick 2.14

QtObject {
    function getFilesChanges()
    {
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            let list=[]
                            let result = tx.executeSql("SELECT record_id FROM ServerChanges WHERE table_id = 5 AND changes_type !=3 AND user_id = ? GROUP BY record_id",currentUser.id)
                            if(result.rows.length > 0)
                            {
                                for(let i=0;i<result.rows.length;i++)
                                {
                                    list.push(result.rows.item(i).record_id)
                                }
                                getMultipleFilesChanges(list.join(','))
                            }

                            list = []
                            let ids =[]

                            result = tx.executeSql("    SELECT record_id,id FROM ServerChanges WHERE table_id = 5 AND changes_type = 3 AND user_id = ? GROUP BY record_id",currentUser.id)
                            if(result.rows.length > 0)
                            {
                                for(let j=0;j<result.rows.length;j++)
                                {
                                    list.push(result.rows.item(j).record_id)
                                    ids.push(result.rows.item(j).id)
                                }
                                deleteFilesLocalDatabase(list.join(','))
                                localDB.deleteFromServerChanges(ids.join(','))
                            }
                        }
                        catch(e)
                        {
                            console.error(e)
                        }
                    })
    }

    function syncFilesChanges()
    {
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            let list=[]
                            let result = tx.executeSql("SELECT T1.record_id ,T1.changes_type,T1.id AS change_id ,T2.* FROM LocalChanges AS T1
JOIN Files AS T2 ON record_id =T2.local_id  WHERE table_id = 5 AND T2.user_id = ?",currentUser.id)
                            if(result.rows.length > 0)
                            {
                                for(let i=0;i<result.rows.length;i++)
                                {
                                    let item = result.rows.item(i)
                                    if(item.changes_type === 1)
                                    {
                                        addFiles(item.file_name,item.file_detail,item.list_id,null,null,null,null,item.local_id ,item.change_id)
                                    }
                                    else if(item.changes_type === 2)
                                    {
                                        editFile(item.id,item.file_name,item.file_detail,item.list_id,null,null,item.local_id ,item.change_id)
                                    }
                                    else if(item.changes_type === 3)
                                    {
                                        deleteFile( item.id,null,null,item.local_id ,item.change_id )
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

    function getMultipleFilesChanges(changesList)
    {
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + currentUser.id + "&file_id_list="+changesList
        xhr.open("GET", domain+"/api/v1/files"+"?"+query,true);
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
                                        updateFiles(item)
                                    }
                                    nChangeId.push(item.change_id)
                                }
                                if(insertArray.length > 0)
                                    insertFiles(insertArray)
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


    function getFiles(model,thingId)
    {
        if(model.count>0 )
            return model

        let valuesCategories = getFilesLocalDatabase(thingId) // get Categories from local database
        if(valuesCategories.length >0){
            model.append(valuesCategories)
            return model
        }


        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + currentUser.id + "&things_id="+thingId
        xhr.open("GET", domain+"/api/v1/files"+"?"+query,true);
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
                            insertFiles(response.result)
                            for(let i=0;i<response.result.length;i++)
                            {
                                let file=response.result[i]
                                if(myTools.checkFileExist(file["file_name"],file["file_extension"]))
                                    file["file_source"] = "file://"+myTools.getSaveDirectory()+file["file_name"]+"."+file["file_extension"]
                                else file["file_source"] = "";
                                model.append(file)
                            }
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

    function addFiles(fileModel,filesCount,thingId)
    {
        let fileList= [];
        for(let i = 0; i < filesCount; i++)
        {
            let file = fileModel.get(i)
            let base64 = myTools.encodeToBase64(String(file.file_source.replace("file://","")))
            fileList[i] = {"base64_file" : base64 , "file_extension": file.file_extension ,"file_name" :file.file_name}
        }

        let json = JSON.stringify(
                {
                    things_id: thingId,
                    user_id: currentUser.id,
                    file_list: fileList
                }, null, 1);

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("POST", domain+"/api/v1/files",true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(json);
        var busyDialog = usefulFunc.showBusy("در حال ارسال فایل ها");
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
                            usefulFunc.showLog(qsTr("فایل‌ها با موفقیت افزوده شد"),false,null,700*size1W, ltr)
                            insertFiles(response.result)
                            localDB.insertDeviceChanges([{"table_id":5,   "record_id":response.result.id,    "changes_type":1,  "user_id":currentUser.id}])
                            fileModel.clear()
                        }
                    }
                    else {
                        if(response.code === 406)
                        {
                            usefulFunc.showLog(qsTr("خطا در ارتباط با سرور، لطفا مجدد تلاش نمایید"),true,null,400*size1W, ltr)
                        }
                        else
                            usefulFunc.showLog(response.message,true,mainPage,mainPage.width, ltr)
                    }

                }
                catch(e) {
                    let id = insertFiles(response.result)
                    localDB.insertLocalChanges([ {"table_id":5,   "record_id":id,    "changes_type":1,  "user_id":currentUser.id}] )
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,mainPage,mainPage.width, ltr)
                }
            }
        }
    }

    function deleteFiles(fileId,model,modelIndex,local_id = null,change_id = null)
    {
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + currentUser.id
        xhr.open("DELETE", domain+"/api/v1/files/"+fileId+"?"+query,true);
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
                                deleteFilesLocalDatabase(fileId)
                                localDB.insertDeviceChanges([{"table_id":5,   "record_id":fileId,    "changes_type":3,  "user_id":currentUser.id}])
                            }
                            else{
                                localDB.deleteFromLocalChanges(change_id)
                            }
                        }
                    }
                    else {
                        if(response.code === 406)
                        {
                            usefulFunc.showLog(qsTr("خطا در ارتباط با سرور، لطفا مجدد تلاش نمایید"),true,null,400*size1W, ltr)
                        }
                        else
                            usefulFunc.showLog(response.message,true,mainPage,mainPage.width, ltr)
                    }

                }
                catch(e) {
                    deleteFilesLocalDatabase(fileId)
                    localDB.insertLocalChanges([ {"table_id":5,   "record_id":fileId,    "changes_type":3,  "user_id":currentUser.id}] )
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,mainPage,mainPage.width, ltr)
                }
            }
        }
    }


    /****************** Local Database Function Table:Files  **************************/

    function getFilesLocalDatabase(thingId)
    {
        let valuesFiles=[]
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("SELECT * FROM Files WHERE thing_id = ? ORDER By id ASC",listId)
                            for(var i=0;i<result.rows.length;i++)
                            {
                                valuesFiles.push(result.rows.item(i))
                            }
                        }
                        catch(e)
                        {

                        }
                    })
        return valuesFiles
    }


    function insertFiles(values)
    {
        let mapValues = values.map(item => [ item.id, item.user_id, item.things_id, item.file, String(item.file_name), item.file_extension, item.register_date??"" ] )
        let finalString = ""
        for(let i=0;i<mapValues.length;i++)
        {
            for(let j=0;j<mapValues[i].length;j++)
            {
                mapValues[i][j] = typeof mapValues[i][j] === "string"?'"'+ (mapValues[i][j]==="null"?"":mapValues[i][j]) + '"':mapValues[i][j]
            }
            let check = 0;
            dataBase.transaction(function(tx){try{
                    var result = tx.executeSql("SELECT * FROM Files WHERE id=?",mapValues[i][0])
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
                                tx.executeSql("INSERT INTO Files( id, user_id,things_id,file, file_name, file_extension, register_date ) VALUES "+ finalString)
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


    function updateFiles(values,local_id = null)
    {
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            let result
                            if(local_id)
                                result = tx.executeSql(
                                            "UPDATE Files SET id=? , user_id=? , things_id=? , file=? , file_name =? , file_extension=? , register_date=?  WHERE local_id=?",
                                            [values.id, values.user_id ,values.things_id ,values.file, values.file_name, values.file_extension, values.register_date??"", local_id]
                                            )
                            else result = tx.executeSql(
                                     "UPDATE Files SET user_id=? , things_id=? , file=? , file_name =? , file_extension=? , register_date=?  WHERE id=?",
                                     [values.user_id, values.things_id ,values.file, values.file_name, values.file_extension, values.register_date??"",values.id]
                                     )
                        }
                        catch(e)
                        {
                            console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
    } // end of update function


    function deleteFilesLocalDatabase(ids)
    {
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("DELETE FROM Files WHERE id IN (?)",ids)
                        }
                        catch(e)
                        {
                            console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
    }// end of delete function


}
