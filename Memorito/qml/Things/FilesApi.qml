pragma Singleton
import QtQuick 2.15
import Global 1.0
import MTools 1.0 // Require For myTools

QtObject {
    property var myTools: MTools{}

    function getFilesChanges()
    {
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            let list=[]
                            let result = tx.executeSql("SELECT record_id FROM ServerChanges WHERE table_id = ? AND changes_type !=3 AND user_id = ? GROUP BY record_id",[Memorito.CHFiles ,User.id])
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

                            result = tx.executeSql("    SELECT record_id,id FROM ServerChanges WHERE table_id = ? AND changes_type = 3 AND user_id = ? GROUP BY record_id",[Memorito.CHFiles ,User.id])
                            if(result.rows.length > 0)
                            {
                                for(let j=0;j<result.rows.length;j++)
                                {
                                    list.push(result.rows.item(j).record_id)
                                    ids.push(result.rows.item(j).id)
                                }
                                deleteFilesLocalDatabase(list.join(','))
                                LocalDatabase.deleteFromServerChanges(ids.join(','))
                            }
                        }
                        catch(e)
                        {
                            console.trace();console.error(e)
                        }
                    })
    }

    function syncFilesChanges()
    {
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            let list=[]
                            let result = tx.executeSql("SELECT T1.record_id ,T1.changes_type,T1.id AS change_id ,T2.* FROM LocalChanges AS T1
JOIN Files AS T2 ON record_id =T2.local_id  WHERE table_id = 5 AND T2.user_id = ?",User.id)
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
                            console.trace();console.error(e)
                        }
                    })
    }

    function getMultipleFilesChanges(changesList)
    {
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + User.id + "&file_id_list="+changesList
        xhr.open("GET", domain+"/api/v1/files"+"?"+query,true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Authorization", "Basic " +Qt.btoa(unescape(encodeURIComponent( User.email + ':' + User.authToken))) );
        xhr.send(null);
        xhr.timeout = 3000;
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
                                        if(!getFileById(item.id))
                                            insertArray.push(item)
                                        else
                                            updateFiles(item)
                                    }
                                    nChangeId.push(item.change_id)
                                }
                                if(insertArray.length > 0)
                                    insertFiles(insertArray)
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
        let query = "user_id=" + User.id + "&things_id="+thingId
        xhr.open("GET", domain+"/api/v1/files"+"?"+query,true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Authorization", "Basic " +Qt.btoa(unescape(encodeURIComponent( User.email + ':' + User.authToken))) );
        xhr.send(null);
        var busyDialog = UsefulFunc.showBusy("",
                                             function()
                                             {
                                                 UsefulFunc.showConfirm(
                                                             qsTr("لغو"),
                                                             qsTr("میخوای درخواستت لغو بشه؟"),
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
        xhr.timeout = 3000;
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
                                let ids = response.result.map(item =>[item.id]).join(",")
                                file["file_name"] = String(file["file_name"])
                                model.append(file)
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
                    UsefulFunc.showConnectionError()

                    return null
                }
            }
        }
    }

    function addFiles(fileModel,filesCount,thingId)
    {
        let fileList= [];
        let deletedFile = [];

        for(let i = 0; i < filesCount; i++)
        {
            let file = fileModel.get(i)
            if(file.change_type === 1) {
                let base64 = myTools.encodeToBase64(String(file.file_source.replace("file://","")))
                fileList.push({"base64_file" : base64 , "file_extension": file.file_extension ,"file_name" :file.file_name})
            }
            else if( file.change_type === 3)
            {
                deletedFile.push(file.id)
            }
        }

        for(let j = 0; j < deletedFile.length; j++)
        {
            deleteFiles(deletedFile[j])
        }

        if(fileList.length <= 0)
            return

        let json = JSON.stringify(
                {
                    things_id: thingId,
                    user_id: User.id,
                    file_list: fileList
                }, null, 1);

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("POST", domain+"/api/v1/files",true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Authorization", "Basic " +Qt.btoa(unescape(encodeURIComponent( User.email + ':' + User.authToken))) );
        xhr.send(json);
        var busyDialog = UsefulFunc.showBusy("در حال ارسال فایل ها");
        xhr.timeout = 3000;
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
                            UsefulFunc.showLog(qsTr("فایل‌ها با موفقیت اضافه شد"),false)
                            insertFiles(response.result)
                        }
                    }
                    else {
                        if(response.code === 401)
                        {
                            console.trace();UsefulFunc.showUnauthorizedError()
                        }
                        else
                            UsefulFunc.showLog(response.message,true)
                    }

                }
                catch(e) {
                    let id = insertFiles(response.result)
                    LocalDatabase.insertLocalChanges([ {"table_id":5,   "record_id":id,    "changes_type":1,  "user_id":User.id}] )
                    UsefulFunc.showConnectionError()

                }
            }
        }
    }

    function deleteFiles(fileId,local_id = null,change_id = null)
    {
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + User.id
        xhr.open("DELETE", domain+"/api/v1/files/"+fileId+"?"+query,true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Authorization", "Basic " +Qt.btoa(unescape(encodeURIComponent( User.email + ':' + User.authToken))) );
        xhr.send(null);
        if(local_id === null)
            var busyDialog = UsefulFunc.showBusy("");
        xhr.timeout = 3000;
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
                                deleteFilesLocalDatabase(String(fileId))
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
                            UsefulFunc.showLog(response.message,true)
                    }

                }
                catch(e) {
                    deleteFilesLocalDatabase(fileId)
                    LocalDatabase.insertLocalChanges([ {"table_id":5,   "record_id":fileId,    "changes_type":3,  "user_id":User.id}] )
                    UsefulFunc.showConnectionError()

                }
            }
        }
    }


    /****************** Local Database Function Table:Files  **************************/

    function getFilesLocalDatabase(thingId)
    {
        let valuesFiles=[]
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("SELECT * FROM Files WHERE things_id = ? ORDER By id ASC",thingId)
                            for(var i=0;i<result.rows.length;i++)
                            {
                                result.rows.item(i).file_name = String(result.rows.item(i).file_name)
                                valuesFiles.push(result.rows.item(i))
                            }
                        }
                        catch(e)
                        {

                        }
                    })
        return valuesFiles
    }

    function getFilseByIds(ids)
    {
        let valuesLogs = {}
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("SELECT * FROM Files WHERE id IN(?))",idsS)
                            if(result.rows.length)
                            {
                                valuesLogs = result.rows.item(0)
                            }
                        }
                        catch(e)
                        {

                        }
                    })
        return valuesLogs
    }

    function getFileById(id)
    {
        let valuesLogs = {}
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("SELECT * FROM Files WHERE id=?",id)
                            if(result.rows.length)
                            {
                                valuesLogs = result.rows.item(0)
                            }
                        }
                        catch(e)
                        {

                        }
                    })
        return valuesLogs
    }


    function insertFiles(values)
    {
        let mapValues = values.map(item => [ item.id, item.user_id, item.things_id, String(item.file), String(item.file_name), item.file_extension, item.register_date??"" ] )
        let finalString = ""
        for(let i=0;i<mapValues.length;i++)
        {
            for(let j=0;j<mapValues[i].length;j++)
            {
                mapValues[i][j] = typeof mapValues[i][j] === "string"?'"'+ (mapValues[i][j]==="null"?"":mapValues[i][j]) + '"':mapValues[i][j]
            }

            let check = 0;
            Database.connection.transaction(function(tx){try{
                    var result = tx.executeSql("SELECT * FROM Files WHERE id=?",mapValues[i][0])
                    check = result.rows.length}catch(e){}
            })

            if(!check)
                finalString += "(" + mapValues[i] + ")" + (i !== mapValues.length-1?",":"")
        }
        if(finalString[finalString.length - 1] === ',')
            finalString = finalString.slice(0,-1)

        let insertId = -1
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            if(finalString!== "")
                            {
                                tx.executeSql("INSERT INTO Files( id, user_id, things_id, file, file_name, file_extension, register_date ) VALUES "+ finalString)
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


    function updateFiles(values,local_id = null)
    {
        Database.connection.transaction(
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
                            console.trace();console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
    } // end of update function


    function deleteFilesLocalDatabase(ids)
    {
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("DELETE FROM Files WHERE id IN (?)",ids)
                        }
                        catch(e)
                        {
                            console.trace();console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
    }// end of delete function


}
