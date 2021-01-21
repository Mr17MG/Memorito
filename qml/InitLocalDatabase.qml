import QtQuick 2.14

QtObject{
    function makeLocalTables()
    {
        makeLocalUsersTable()
        makeLocalThingsTable()
        makeLocalCategoriesTable()
        makeLocalContextsTable()
        makeLocalFriendsTable()
        makeLocalFilesTable()
        makeServerChangesTable()
        makeLocalChangesTable()
        makeChangesOnThisDeviceTable()
    }

    function makeLocalUsersTable()
    {        dataBase.transaction(
                 function(tx)
                 {
                     try
                     {
                         tx.executeSql("CREATE TABLE IF NOT EXISTS Users(
                                                        local_id INTEGER PRIMARY KEY AUTOINCREMENT ,
                                                        id INTEGER DEFAULT -1 ,
                                                        username TEXT ,
                                                        email TEXT ,
                                                        hashed_password TEXT ,
                                                        auth_token TEXT
                                                       )"
                                       );
                     } // end of try
                     catch(e)
                     {
                         console.error(e)
                     }
                 }// end of function
                 )// end of transaction
    }

    function dropAallLocalTables()
    {
        //DROP TABLE IF EXISTS table1;
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            tx.executeSql('DROP TABLE IF EXISTS Things;')
                            tx.executeSql('DROP TABLE IF EXISTS Categories;')
                            tx.executeSql('DROP TABLE IF EXISTS Contexts;')
                            tx.executeSql('DROP TABLE IF EXISTS Friends;')
                            tx.executeSql('DROP TABLE IF EXISTS Files;')
                            tx.executeSql('DROP TABLE IF EXISTS ServerChanges;')
                            tx.executeSql('DROP TABLE IF EXISTS LocalChanges;')
                            tx.executeSql('DROP TABLE IF EXISTS ChangesOnThisDevice;')
                            tx.executeSql('DROP TABLE IF EXISTS Users;')
                        } // end of try
                        catch(e)
                        {
                            console.error(e)
                        }
                    }// end of function
                    )// end of transaction
    }

    function makeChangesOnThisDeviceTable()
    {

        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            let query = '
        CREATE TABLE IF NOT EXISTS "ChangesOnThisDevice" (
            "id"        INTEGER NOT NULL UNIQUE,
            "table_id"	INTEGER,
            "record_id"	INTEGER,
            "changes_type" INTEGER,
            "user_id"	INTEGER,
            PRIMARY KEY("id" AUTOINCREMENT)
        );'
                            var result = tx.executeSql(query)
                        } // end of try
                        catch(e)
                        {
                            console.error(e)
                        }
                    }// end of function
                    )// end of transaction
    }//end of function

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
    "id"	INTEGER ,
    "user_id"   INTEGER,
    "title"	TEXT,
    "detail"	TEXT,
    "list_id"	INTEGER,
    "is_done"	INTEGER DEFAULT 0,
    "register_date"	TEXT,
    "modified_date"	TEXT,
    "has_files"	INTEGER DEFAULT 0,
    "context_id"	INTEGER DEFAULT 0,
    "priority_id"	INTEGER DEFAULT 0,
    "energy_id"	INTEGER DEFAULT 0,
    "estimate_time"	INTEGER DEFAULT 0,
    "category_id"	INTEGER DEFAULT 0,
    "due_date"	TEXT,
    "friend_id"	INTEGER DEFAULT 0,
    PRIMARY KEY("local_id" AUTOINCREMENT)
)'
                            var result = tx.executeSql(query)
                        } // end of try
                        catch(e)
                        {
                            console.error(e)
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
    "category_detail"	TEXT,
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
                            console.error(e)
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
    "id"	INTEGER,
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
                            console.error(e)
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
    "id"	INTEGER,
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
                            console.error(e)
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
    "id"	INTEGER,
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
                            console.error(e)
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
    "id"	INTEGER NOT NULL ,
    "table_id"	INTEGER,
    "record_id"	INTEGER,
    "changes_type"	INTEGER,
    "user_id"	INTEGER,
    PRIMARY KEY("id" AUTOINCREMENT)
);'
                            var result = tx.executeSql(query)
                        } // end of try
                        catch(e)
                        {
                            console.error(e)
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
                            console.error(e)
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
                        if(response.code === 200)
                        {
                            if(response.result.length > 0)
                            {
                                insertServerChanges(response.result)
                                appSetting.setValue("last_date",decodeURIComponent(response.result[0].register_date))
                            }
                        }
                    }
                    else
                    {
                        if(response.code === 406)
                        {
                            usefulFunc.showLog(qsTr("خطا در ارتباط با سرور، لطفا مجدد تلاش نمایید"),true,null,400*size1W, ltr)
                            return
                        }
                        else{
                            usefulFunc.showLog(response.message,true,mainPage,mainPage.width, ltr)
                            return
                        }
                    }
                }
                catch(e) {
                    console.error(e);
                    console.log(xhr.responseText)
                }
                friendsApi.getFriendsChanges()
                friendsApi.syncFriendsChanges()
                contextApi.getContextsChanges()
                contextApi.syncContextsChanges()
                categoryApi.getCategoriesChanges()
                categoryApi.syncCategoriesChanges()
                thingsApi.getThingsChanges()
                thingsApi.syncThingsChanges()
                filesApi.getFilesChanges()
                filesApi.syncFilesChanges()
                userApi.getUsersChanges()
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
                            tx.executeSql("INSERT INTO ServerChanges(id,table_id,record_id,changes_type,user_id,register_date) VALUES "+ finalString)
                        }
                        catch(e)
                        {
                            console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            var ids = tx.executeSql("SELECT a.id as ChangeId,b.id as ServerId FROM ChangesOnThisDevice a JOIN ServerChanges b on a.table_id = b.table_id AND a.record_id = b.record_id AND a.changes_type = b.changes_type AND a.user_id = b.user_id");
                            var sIds = ""
                            var cIds = ""
                            for(let i=0;i<ids.rows.length;i++){
                                sIds += ids.rows.item(i).ServerId;cIds += ids.rows.item(i).ChangeId
                                if(i !==ids.rows.length -1){ cIds+=",";sIds+=',' }
                            }

                            deleteFromServerChanges(sIds)
                            deleteFromDeviceChanges(cIds)
                        }
                        catch(e){}
                    })


    } // end of insert function

    function deleteFromServerChanges(ids)
    {
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("DELETE FROM ServerChanges WHERE id IN (?)",ids)
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
        let mapValues = values.map(item => [ item.table_id,   item.record_id,    item.changes_type,  item.user_id] )
        let finalString = ""
        for(let i=0;i<mapValues.length;i++)
        {
            finalString += "(" + mapValues[i] + ")" + (i!==mapValues.length-1?",":"")
        }

        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("INSERT INTO LocalChanges( table_id, record_id, changes_type, user_id) VALUES "+ finalString)
                        }
                        catch(e)
                        {
                            console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
    } // end of insert function


    function deleteFromLocalChanges(ids)
    {
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("DELETE FROM LocalChanges WHERE id IN (?)",ids)
                        }
                        catch(e)
                        {
                            console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
    } // end of insert function

    function insertDeviceChanges(values)
    {
        let mapValues = values.map(item => [ item.table_id,   item.record_id,    item.changes_type,  item.user_id] )
        let finalString = ""
        for(let i=0;i<mapValues.length;i++)
        {
            finalString += "(" + mapValues[i] + ")" + (i!==mapValues.length-1?",":"")
        }

        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("INSERT INTO ChangesOnThisDevice (table_id, record_id, changes_type, user_id) VALUES "+ finalString)
                        }
                        catch(e)
                        {
                            console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
    } // end of insert function


    function deleteFromDeviceChanges(ids)
    {
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("DELETE FROM ChangesOnThisDevice WHERE id IN (?)",ids)
                        }
                        catch(e)
                        {
                            console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
    } // end of insert function

}
