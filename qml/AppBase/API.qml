import QtQuick 2.14

QtObject{
    function makeLocalTables()
    {
        makeLocalThingsTable()
        makeLocalCategoriesTable()
        makeLocalContextsTable()
        makeLocalFriendsTable()
        makeLocalFilesTable()
        makeServerChangesTable()
        makeLocalChangesTable()
    }

    function makeLocalThingsTable()
    {

        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            let query = '
    CREATE TABLE IF NOT EXISTS "Things" (
    "local_id"	INTEGER NOT NULL UNIQUE,
    "id"	INTEGER UNIQUE,
    "user_id"   INTEGER,
    "title"	TEXT,
    "detail"	TEXT,
    "list_id"	INTEGER,
    "is_done"	INTEGER,
    "register_date"	TEXT,
    "modified_date"	TEXT,
    "has_files"	INTEGER,
    "context_id"	INTEGER,
    "priority_id"	INTEGER,
    "energy_id"	INTEGER,
    "estimate_id"	INTEGER,
    "category_id"	INTEGER,
    "due_date"	TEXT,
    "friend_id"	INTEGER,
    PRIMARY KEY("local_id" AUTOINCREMENT)
)'
                            var result = tx.executeSql(query)
                        } // end of try
                        catch(e)
                        {
                            console.log(e)
                        }
                    }// end of function
                    )// end of transaction
    }//end of function


    function makeLocalCategoriesTable()
    {

        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            let query = '
    CREATE TABLE IF NOT EXISTS "Categories"(
    "local_id"	INTEGER NOT NULL UNIQUE,
    "id"	INTEGER UNIQUE,
    "category_name"	TEXT,
    "categoty_detail"	TEXT,
    "user_id"	INTEGER,
    "list_id"	INTEGER,
    "register_date"	TEXT,
    "modified_date"	TEXT,
    PRIMARY KEY("local_id" AUTOINCREMENT)
)'
                            var result = tx.executeSql(query)
                        } // end of try
                        catch(e)
                        {
                            console.log(e)
                        }
                    }// end of function
                    )// end of transaction
    }//end of function

    function makeLocalContextsTable()
    {

        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            let query ='
    CREATE TABLE IF NOT EXISTS "Contexts" (
    "local_id"	INTEGER NOT NULL UNIQUE,
    "id"	INTEGER UNIQUE,
    "context_name"	TEXT,
    "user_id"	INTEGER,
    "register_date"	TEXT,
    "modified_date"	TEXT,
    PRIMARY KEY("local_id" AUTOINCREMENT)
);'
                            var result = tx.executeSql(query)
                        } // end of try
                        catch(e)
                        {
                            console.log(e)
                        }
                    }// end of function
                    )// end of transaction
    }//end of function


    function makeLocalFriendsTable()
    {

        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            let query ='
    CREATE TABLE IF NOT EXISTS "Friends" (
    "local_id"	INTEGER NOT NULL UNIQUE,
    "id"	INTEGER UNIQUE,
    "friend_name"	TEXT,
    "user_id"	INTEGER,
    "register_date"	TEXT,
    "modified_date"	TEXT,
    PRIMARY KEY("local_id" AUTOINCREMENT)
);'
                            var result = tx.executeSql(query)
                        } // end of try
                        catch(e)
                        {
                            console.log(e)
                        }
                    }// end of function
                    )// end of transaction
    }//end of function

    function makeLocalFilesTable()
    {

        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            let query ='
    CREATE TABLE IF NOT EXISTS "Files" (
    "local_id"	INTEGER NOT NULL UNIQUE,
    "id"	INTEGER UNIQUE,
    "user_id"	INTEGER,
    "things_id"	INTEGER,
    "file"	TEXT,
    "file_name"	TEXT,
    "file_extension"	TEXT,
    "register_date"	TEXT,
    PRIMARY KEY("local_id" AUTOINCREMENT)
);'
                            var result = tx.executeSql(query)
                        } // end of try
                        catch(e)
                        {
                            console.log(e)
                        }
                    }// end of function
                    )// end of transaction
    }//end of function

    function makeLocalChangesTable()
    {
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            let query ='
    CREATE TABLE IF NOT EXISTS "LocalChanges" (
    "id"	INTEGER NOT NULL UNIQUE,
    "table_id"	INTEGER,
    "record_id"	INTEGER,
    "changes_type"	INTEGER,
    "user_id"	INTEGER,
    "register_date"	TEXT,
    PRIMARY KEY("id" AUTOINCREMENT)
);'
                            var result = tx.executeSql(query)
                        } // end of try
                        catch(e)
                        {
                            console.log(e)
                        }
                    }// end of function
                    )// end of transaction
    }//end of function

    function makeServerChangesTable()
    {
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            let query ='
    CREATE TABLE IF NOT EXISTS "ServerChanges" (
    "id"	INTEGER NOT NULL UNIQUE,
    "table_id"	INTEGER,
    "record_id"	INTEGER,
    "changes_type"	INTEGER,
    "user_id"	INTEGER,
    "register_date"	TEXT,
    PRIMARY KEY("id" AUTOINCREMENT)
);'
                            var result = tx.executeSql(query)
                        } // end of try
                        catch(e)
                        {
                            console.log(e)
                        }
                    }// end of function
                    )// end of transaction
    }//end of function


    function getLastChanges()
    {
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + currentUser.id +"&last_date=" + decodeURIComponent(appSetting.value("last_date",""))
        xhr.open("GET", domain+"/api/v1/changes"+"?"+query,true);
        //http://memorito.local/api/v1/changes?user_id=108&last_date=2021-01-13 07:53:02
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
                        if(response.code === 200)
                        {
                            if(response.result.length > 0)
                            {
                                insertServerChanges(response.result)
                                appSetting.setValue("last_date",decodeURIComponent(response.result[0].register_date))
                            }
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
                    console.error(e)
                }
            }
        }
    }

    function insertServerChanges(values)
    {
        let mapValues = values.map(item => [ item.id,   item.table_id,   item.record_id,    item.changes_type,  item.user_id,   String(item.register_date)] )
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
                            var result = tx.executeSql("INSERT INTO ServerChanges(id,table_id,record_id,changes_type,user_id,register_date) VALUES "+ finalString)
                        }
                        catch(e)
                        {
                            console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
    } // end of insert function


    function insertLocalChanges(values)
    {
        let mapValues = values.map(item => [ item.id,   item.table_id,   item.record_id,    item.changes_type,  item.user_id,   String(item.register_date)] )
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
                            var result = tx.executeSql("INSERT INTO LocalChanges(id,table_id,record_id,changes_type,user_id,register_date) VALUES "+ finalString)
                        }
                        catch(e)
                        {
                            console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
    } // end of insert function


}
