pragma Singleton
import QtQuick 2.14
import Global 1.0

QtObject {

    function getCategoriesChanges()
    {
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            let list=[]
                            let result = tx.executeSql("SELECT record_id FROM ServerChanges WHERE table_id = ? AND changes_type !=3 AND user_id = ? GROUP BY record_id",[Memorito.CHCategories ,User.id])
                            if(result.rows.length > 0)
                            {
                                for(let i=0;i<result.rows.length;i++)
                                {
                                    list.push(result.rows.item(i).record_id)
                                }
                                getMultipleCategoriesChanges(list.join(','))
                            }

                            list = []
                            let ids =[]

                            result = tx.executeSql("    SELECT record_id,id FROM ServerChanges WHERE table_id = ? AND changes_type = 3 AND user_id = ? GROUP BY record_id",[Memorito.CHCategories ,User.id])
                            if(result.rows.length > 0)
                            {
                                for(let j=0;j<result.rows.length;j++)
                                {
                                    list.push(result.rows.item(j).record_id)
                                    ids.push(result.rows.item(j).id)
                                }
                                deleteCategoryLocalDatabase(list.join(','))
                                LocalDatabase.deleteFromServerChanges(ids.join(','))
                            }
                        }
                        catch(e)
                        {
                            console.error(e)
                        }
                    })
    }

    function syncCategoriesChanges()
    {
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            let list=[]
                            let result = tx.executeSql("SELECT T1.record_id ,T1.changes_type,T1.id AS change_id ,T2.* FROM LocalChanges AS T1
JOIN Categories AS T2 ON record_id =T2.local_id  WHERE table_id = 1 AND T2.user_id = ?",User.id)
                            if(result.rows.length > 0)
                            {
                                for(let i=0;i<result.rows.length;i++)
                                {
                                    let item = result.rows.item(i)
                                    if(item.changes_type === 1)
                                    {
                                        addCategory(item.category_name,item.category_detail,item.list_id,null,null,null,null,item.local_id ,item.change_id)
                                    }
                                    else if(item.changes_type === 2)
                                    {
                                        editCategory(item.id,item.category_name,item.category_detail,item.list_id,null,null,item.local_id ,item.change_id)
                                    }
                                    else if(item.changes_type === 3)
                                    {
                                        deleteCategory( item.id,null,null,item.local_id ,item.change_id )
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

    function getMultipleCategoriesChanges(changesList)
    {
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + User.id + "&category_id_list="+changesList
        xhr.open("GET", domain+"/api/v1/categories"+"?"+query,true);
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
                                        if(!getCategoryById(item.id))
                                            insertArray.push(item)
                                        else
                                            updateCategories(item)
                                    }
                                    nChangeId.push(item.change_id)
                                }
                                if(insertArray.length > 0)
                                    insertCategories(insertArray)
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

    function getCategories(model,listId)
    {
        if(model.count>0 )
            return model

        let valuesCategories = getCategoriesLocalDatabase(listId) // get Categories from local database
        if(valuesCategories.length >0){
            model.append(valuesCategories)
            return model
        }

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + User.id + "&list_id=" + listId
        xhr.open("GET", domain+"/api/v1/categories"+"?"+query,true);
        xhr.setRequestHeader("Content-Type", "application/json");
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
                            model.append(response.result)
                            insertCategories(response.result)
                        }
                    }
                    else {
                        if(response.code === 401)
                            UsefulFunc.showUnauthorizedError()
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

    function addCategory(categoryName,categoryDetail,listId,model,fromCollect=0,oldModel=null,modelIndex=null,local_id = null,change_id = null)
    {
        let json = JSON.stringify(
                {
                    user_id: User.id,
                    list_id : listId,
                    category_name: categoryName,
                    category_detail: categoryDetail
                }, null, 1);

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("POST", domain+"/api/v1/categories",true);
        xhr.setRequestHeader("Content-Type", "application/json");
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
                            UsefulFunc.showLog(" <b>'"+qsTr("پروژه جدید با نام")+ " "+ categoryName+" '</b>" +qsTr("با موفقیت افزوده شد"),false,700*AppStyle.size1W)
                            if(local_id !== null)
                            {
                                updateCategories(response.result,local_id)
                                LocalDatabase.deleteFromLocalChanges(change_id)
                            }
                            else{
                                model.append(response.result)
                                insertCategories(Array(response.result))

                                if(fromCollect === 1)
                                {
                                    flickTextArea.detailInput.clear()
                                    titleInput.clear()
                                    attachModel.clear()
                                    processBtn.checked = false
                                }
                                else if(fromCollect === 2)
                                {
                                    ThingsApi.deleteThing(oldModel.get(modelIndex).id, oldModel, modelIndex)
                                    UsefulFunc.mainStackPop()
                                }

                            }
                        }
                    }
                    else if(local_id === null) {
                        if(response.code === 401)
                        {
                            UsefulFunc.showUnauthorizedError()
                        }
                        else
                            UsefulFunc.showLog(response.message,true,1700*AppStyle.size1W)
                    }

                }
                catch(e) {
                    let id = insertCategories([{"id":-1, "category_name":categoryName, "category_detail":categoryDetail,"list_id":listId,"user_id":User.id,"register_date" : "", "modified_date":"" }])
                    LocalDatabase.insertLocalChanges([ {"table_id":1,   "record_id":id,    "changes_type":1,  "user_id":User.id}] )
                    UsefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,1700*AppStyle.size1W)
                }
            }
        }
    }

    function editCategory(categoryId,categoryName,categoryDetail,listId,model,modelIndex,local_id = null,change_id = null)
    {
        let json = JSON.stringify(
                {
                    user_id: User.id,
                    list_id : listId,
                    category_name: categoryName,
                    category_detail: categoryDetail
                }, null, 1);

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("PATCH", domain+"/api/v1/categories/"+categoryId,true);
        xhr.setRequestHeader("Content-Type", "application/json");
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
                                model.set(modelIndex,response.result)
                                updateCategories(response.result)

                            }
                            else {
                                updateCategories(response.result,local_id)
                            }
                        }
                    }
                    else if(local_id === null) {
                        if(response.code === 401)
                        {
                            UsefulFunc.showUnauthorizedError()
                        }
                        else
                            UsefulFunc.showLog(response.message,true,1700*AppStyle.size1W)
                    }

                }
                catch(e) {
                    model.set(modelIndex,{"category_name":categoryName})
                    updateCategories( {"id":categoryId,"category_name":categoryName, "category_detail":categoryDetail,"list_id":listId,"user_id": User.id, "register_date":"","modified_date":""},local_id)
                    LocalDatabase.insertLocalChanges([ {"table_id":1,   "record_id":categoryId,    "changes_type":2,  "user_id":User.id}] )
                    UsefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,1700*AppStyle.size1W)
                }
            }
        }
    }

    function deleteCategory(categoryId,model,modelIndex,local_id = null,change_id = null)
    {
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + User.id
        xhr.open("DELETE", domain+"/api/v1/categories/"+categoryId+"?"+query,true);
        xhr.setRequestHeader("Content-Type", "application/json");
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

                            }
                            deleteCategoryLocalDatabase(categoryId)
                        }
                    }
                    else if(local_id === null){
                        if(response.code === 401)
                        {
                            UsefulFunc.showUnauthorizedError()
                        }
                        else
                            UsefulFunc.showLog(response.message,true,1700*AppStyle.size1W)
                    }

                }
                catch(e) {
                    deleteCategoryLocalDatabase(categoryId)
                    LocalDatabase.insertLocalChanges([ {"table_id":3,   "record_id":categoryId,    "changes_type":3,  "user_id":User.id}] )
                    UsefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,1700*AppStyle.size1W)
                }
            }
        }
    }


    /****************** Local Database Function Table:Categories  **************************/

    function getCategoriesLocalDatabase(listId)
    {
        let valuesCategories=[]
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("SELECT * FROM Categories WHERE list_id = ? ORDER By id ASC",listId)
                            for(var i=0;i<result.rows.length;i++)
                            {
                                valuesCategories.push(result.rows.item(i))
                            }
                        }
                        catch(e)
                        {

                        }
                    })
        return valuesCategories
    }

    function getCategoryById(id)
    {
        let valuesLogs = {}
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("SELECT * FROM Categories WHERE id=?",id)
                            if(result.rows.length)
                                valuesLogs = result.rows.item(0)
                        }
                        catch(e)
                        {

                        }
                    })
        return valuesLogs
    }


    function insertCategories(values)
    {
        let mapValues = values.map(item => [ item.id??0, String(item.category_name)??"", String(item.category_detail)??"" ,item.list_id??0, item.user_id??0,   String(item.register_date)??"", String(item.modified_date)??"" ] )
        let finalString = ""
        for(let i=0;i<mapValues.length;i++)
        {
            for(let j=0;j<mapValues[i].length;j++)
            {
                mapValues[i][j] = typeof mapValues[i][j] === "string"?'"'+ (mapValues[i][j]==="null"?"":mapValues[i][j]) + '"':mapValues[i][j]
            }
            let check = 0;
            Database.connection.transaction(function(tx){try{
                    var result = tx.executeSql("SELECT * FROM Categories WHERE id=?",mapValues[i][0])
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
                                tx.executeSql("INSERT INTO Categories( id, category_name,category_detail,list_id, user_id, register_date, modified_date ) VALUES "+ finalString)
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


    function updateCategories(values,local_id = null)
    {
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            let result
                            if(local_id)
                                result = tx.executeSql(
                                            "UPDATE Categories SET category_name = ?,category_detail = ? , list_id=? ,user_id= ? ,register_date = ?,modified_date = ?, id=?  WHERE local_id=?",
                                            [values.category_name??"", values.category_detail??"" ,values.list_id??0 ,values.user_id, values.register_date??"", values.modified_date??"",values.id??0, local_id]
                                            )
                            else result = tx.executeSql(
                                     "UPDATE Categories SET category_name = ?,category_detail = ? , list_id=?,user_id= ? ,register_date = ?,modified_date = ?  WHERE id=?",
                                     [values.category_name??"", values.category_detail??"" ,values.list_id??0, values.user_id??0, String(values.register_date)??"", String(values.modified_date)??"",values.id]
                                     )
                        }
                        catch(e)
                        {
                            console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
    } // end of update function


    function deleteCategoryLocalDatabase(ids)
    {
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("DELETE FROM Categories WHERE id IN (?)",ids)
                        }
                        catch(e)
                        {
                            console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
    }// end of delete function

}
