pragma Singleton
import QtQuick 2.15
import Qt.labs.settings 1.1

QtObject{
    function makeLocalTables()
    {
        makeLocalUsersTable()

        makeLocalThingsTable()
        makeLocalCategoriesTable()
        makeLocalContextsTable()
        makeLocalFriendsTable()
        makeLocalFilesTable()
        makeLocalLogsTable()

        makeServerChangesTable()
        makeLocalChangesTable()
        makeChangesOnThisDeviceTable()
    }

    function makeLocalUsersTable()
    {        Database.connection.transaction(
                 function(tx)
                 {
                     try
                     {
                         tx.executeSql("CREATE TABLE IF NOT EXISTS Users(
                                                        local_id INTEGER PRIMARY KEY AUTOINCREMENT ,
                                                        id INTEGER DEFAULT -1 ,
                                                        username TEXT DEFAULT '' ,
                                                        email TEXT DEFAULT '' ,
                                                        hashed_password TEXT DEFAULT '' ,
                                                        auth_token TEXT DEFAULT '' ,
                                                        avatar TEXT DEFAULT '',
                                                        register_date TEXT DEFAULT '',
                                                        modified_date TEXT DEFAULT '',
                                                        two_step INTEGER DEFAULT 0
                                                       )"
                                       );

                         let query = 'CREATE TRIGGER IF NOT EXISTS updateUserChanges
 AFTER UPDATE ON Users
 BEGIN
     INSERT INTO ChangesOnThisDevice(table_id,record_id,changes_type,user_id)
     VALUES ( 6,NEW.id,2,NEW.id );
 END;'
                         tx.executeSql(query) // create trigerr on users after update
                     } // end of try
                     catch(e)
                     {
                         console.trace();console.error(e)
                     }
                 }// end of function
                 )// end of transaction
    }

    function dropAallLocalTables()
    {
        //DROP TABLE IF EXISTS table1;
        Database.connection.transaction(
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
                            console.trace();console.error(e)
                        }
                    }// end of function
                    )// end of transaction
    }

    function makeLocalThingsTable()
    {

        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            let query = '
    CREATE TABLE IF NOT EXISTS "Things" (
    "local_id"	INTEGER NOT NULL UNIQUE,
    "id"	INTEGER ,
    "user_id"   INTEGER,
    "title"	TEXT DEFAULT "",
    "detail"	TEXT DEFAULT "",
    "list_id"	INTEGER,
    "is_done"	INTEGER DEFAULT 0,
    "register_date"	TEXT DEFAULT "",
    "modified_date"	TEXT DEFAULT "",
    "has_files"	INTEGER DEFAULT 0,
    "context_id"	INTEGER DEFAULT 0,
    "priority_id"	INTEGER DEFAULT 0,
    "energy_id"	INTEGER DEFAULT 0,
    "estimate_time"	INTEGER DEFAULT 0,
    "category_id"	INTEGER DEFAULT 0,
    "due_date"	TEXT DEFAULT "",
    "friend_id"	INTEGER DEFAULT 0,
    PRIMARY KEY("local_id" AUTOINCREMENT)
)'
                            tx.executeSql(query) // create things table
                            query = 'CREATE TRIGGER IF NOT EXISTS insertThingsChanges
    AFTER INSERT ON Things
    FOR EACH ROW
    WHEN NEW.id != -1
    BEGIN
        INSERT INTO ChangesOnThisDevice(table_id,record_id,changes_type,user_id)
        VALUES (4,NEW.id,1,NEW.user_id );
    END;'
                            tx.executeSql(query) // create trigerr on things after insert
                            query = 'CREATE TRIGGER IF NOT EXISTS updateThingsChanges
    AFTER UPDATE ON Things
    FOR EACH ROW
    WHEN NEW.id != -1
    BEGIN
        INSERT INTO ChangesOnThisDevice(table_id,record_id,changes_type,user_id)
        VALUES (4,NEW.id,2,NEW.user_id );
    END;'
                            tx.executeSql(query) // create trigerr on things after update
                            query = 'CREATE TRIGGER IF NOT EXISTS deleteThingsChanges
    AFTER DELETE ON Things
    FOR EACH ROW
    WHEN OLD.id != -1
    BEGIN
        INSERT INTO ChangesOnThisDevice(table_id,record_id,changes_type,user_id)
        VALUES (4,OLD.id,3,OLD.user_id );
    END;'
                            tx.executeSql(query) // create trigerr on things after delete
                        } // end of try
                        catch(e)
                        {
                            console.trace();console.error(e)
                        }
                    }// end of function
                    )// end of transaction
    }//end of function


    function makeLocalCategoriesTable()
    {

        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            let query = '
    CREATE TABLE IF NOT EXISTS "Categories"(
    "local_id"	INTEGER NOT NULL UNIQUE,
    "id"	INTEGER UNIQUE,
    "category_name"	TEXT DEFAULT "",
    "category_detail"	TEXT DEFAULT "",
    "user_id"	INTEGER,
    "list_id"	INTEGER,
    "register_date"	TEXT DEFAULT "",
    "modified_date"	TEXT DEFAULT "",
    PRIMARY KEY("local_id" AUTOINCREMENT)
)'
                            tx.executeSql(query)// create Categories table

                            query = 'CREATE TRIGGER IF NOT EXISTS insertCategoriesChanges
    AFTER INSERT ON Categories
    FOR EACH ROW
    WHEN NEW.id != -1
    BEGIN
        INSERT INTO ChangesOnThisDevice(table_id,record_id,changes_type,user_id)
        VALUES (1,NEW.id,1,NEW.user_id );
    END;'
                            tx.executeSql(query)// create trigerr on Categories after insert

                            query = 'CREATE TRIGGER IF NOT EXISTS updateCategoriesChanges
    AFTER UPDATE ON Categories
    FOR EACH ROW
    WHEN NEW.id != -1
    BEGIN
        INSERT INTO ChangesOnThisDevice(table_id,record_id,changes_type,user_id)
        VALUES (1,NEW.id,2,NEW.user_id );
    END;'
                            tx.executeSql(query)// create trigerr on Categories after update

                            query = 'CREATE TRIGGER IF NOT EXISTS deleteCategoriesChanges
    AFTER DELETE ON Categories
    FOR EACH ROW
    WHEN OLD.id != -1
    BEGIN
        INSERT INTO ChangesOnThisDevice(table_id,record_id,changes_type,user_id)
        VALUES (1,OLD.id,3,OLD.user_id );
    END;'
                            tx.executeSql(query)// create trigerr on Categories after delete

                        } // end of try
                        catch(e)
                        {
                            console.trace();console.error(e)
                        }
                    }// end of function
                    )// end of transaction
    }//end of function

    function makeLocalContextsTable()
    {

        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            let query ='
    CREATE TABLE IF NOT EXISTS "Contexts" (
    "local_id"	INTEGER NOT NULL UNIQUE,
    "id"	INTEGER,
    "context_name"	TEXT DEFAULT "",
    "user_id"	INTEGER,
    "register_date"	TEXT DEFAULT "",
    "modified_date"	TEXT DEFAULT "",
    PRIMARY KEY("local_id" AUTOINCREMENT)
);'
                            tx.executeSql(query)

                            query = 'CREATE TRIGGER IF NOT EXISTS insertContextsChanges
    AFTER INSERT ON Contexts
    FOR EACH ROW
    WHEN NEW.id != -1
    BEGIN
        INSERT INTO ChangesOnThisDevice(table_id,record_id,changes_type,user_id)
        VALUES (2,NEW.id,1,NEW.user_id );
    END;'
                            tx.executeSql(query)

                            query = 'CREATE TRIGGER IF NOT EXISTS updateContextsChanges
    AFTER UPDATE ON Contexts
    FOR EACH ROW
    WHEN NEW.id != -1
    BEGIN
        INSERT INTO ChangesOnThisDevice(table_id,record_id,changes_type,user_id)
        VALUES (2,NEW.id,2,NEW.user_id );
    END;'
                            tx.executeSql(query)

                            query = 'CREATE TRIGGER IF NOT EXISTS deleteContextsChanges
    AFTER DELETE ON Contexts
    FOR EACH ROW
    WHEN OLD.id != -1
    BEGIN
        INSERT INTO ChangesOnThisDevice(table_id,record_id,changes_type,user_id)
        VALUES (2,OLD.id,3,OLD.user_id );
    END;'
                            tx.executeSql(query)

                        } // end of try
                        catch(e)
                        {
                            console.trace();console.error(e)
                        }
                    }// end of function
                    )// end of transaction
    }//end of function


    function makeLocalFriendsTable()
    {

        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            let query ='
    CREATE TABLE IF NOT EXISTS "Friends" (
    "local_id"	INTEGER NOT NULL UNIQUE,
    "id"	INTEGER,
    "friend_name"	TEXT DEFAULT "",
    "user_id"	INTEGER,
    "register_date"	TEXT DEFAULT "",
    "modified_date"	TEXT DEFAULT "",
    PRIMARY KEY("local_id" AUTOINCREMENT)
);'
                            tx.executeSql(query)
                            query = 'CREATE TRIGGER IF NOT EXISTS insertFriendsChanges
    AFTER INSERT ON Friends
    FOR EACH ROW
    WHEN NEW.id != -1
    BEGIN
        INSERT INTO ChangesOnThisDevice(table_id,record_id,changes_type,user_id)
        VALUES (3,NEW.id,1,NEW.user_id );
    END;'
                            tx.executeSql(query)
                            query = 'CREATE TRIGGER IF NOT EXISTS updateFriendsChanges
    AFTER UPDATE ON Friends
    FOR EACH ROW
    WHEN NEW.id != -1
    BEGIN
        INSERT INTO ChangesOnThisDevice(table_id,record_id,changes_type,user_id)
        VALUES (3,NEW.id,2,NEW.user_id );
    END;'
                            tx.executeSql(query)
                            query = 'CREATE TRIGGER IF NOT EXISTS deleteFriendsChanges
    AFTER DELETE ON Friends
    FOR EACH ROW
    WHEN OLD.id != -1
    BEGIN
        INSERT INTO ChangesOnThisDevice(table_id,record_id,changes_type,user_id)
        VALUES (3,OLD.id,3,OLD.user_id );
    END;'
                            tx.executeSql(query)
                        } // end of try
                        catch(e)
                        {
                            console.trace();console.error(e)
                        }
                    }// end of function
                    )// end of transaction
    }//end of function

    function makeLocalFilesTable()
    {

        Database.connection.transaction(
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
    "file"	TEXT DEFAULT "",
    "file_name"	TEXT DEFAULT "",
    "file_extension"	TEXT DEFAULT "",
    "register_date"	TEXT DEFAULT "",
    PRIMARY KEY("local_id" AUTOINCREMENT)
);'
                            tx.executeSql(query)
                            query = 'CREATE TRIGGER IF NOT EXISTS insertFilesChanges
    AFTER INSERT ON Files
    FOR EACH ROW
    WHEN NEW.id != -1
    BEGIN
        INSERT INTO ChangesOnThisDevice(table_id,record_id,changes_type,user_id)
        VALUES (5,NEW.id,1,NEW.user_id );
    END;'
                            tx.executeSql(query)
                            query = 'CREATE TRIGGER IF NOT EXISTS updateFilesChanges
    AFTER UPDATE ON Files
    FOR EACH ROW
    WHEN NEW.id != -1
    BEGIN
        INSERT INTO ChangesOnThisDevice(table_id,record_id,changes_type,user_id)
        VALUES (5,NEW.id,2,NEW.user_id );
    END;'
                            tx.executeSql(query)
                            query = 'CREATE TRIGGER IF NOT EXISTS deleteFilesChanges
    AFTER DELETE ON Files
    FOR EACH ROW
    WHEN OLD.id != -1
    BEGIN
        INSERT INTO ChangesOnThisDevice(table_id,record_id,changes_type,user_id)
        VALUES (5,OLD.id,3,OLD.user_id );
    END;'
                            tx.executeSql(query)
                        } // end of try
                        catch(e)
                        {
                            console.trace();console.error(e)
                        }
                    }// end of function
                    )// end of transaction
    }//end of function

    function makeLocalLogsTable()
    {

        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            let query ='
    CREATE TABLE IF NOT EXISTS "Logs" (
    "local_id"	INTEGER NOT NULL UNIQUE,
    "id"	INTEGER,
    "log_text"	TEXT DEFAULT "",
    "register_date"	TEXT DEFAULT "",
    "modified_date"	TEXT DEFAULT "",
    "type_id"	INTEGER,
    "row_id"	INTEGER,
    "user_id"	INTEGER,
    PRIMARY KEY("local_id" AUTOINCREMENT)
);'
                            tx.executeSql(query)
                            query = 'CREATE TRIGGER IF NOT EXISTS insertLogsChanges
    AFTER INSERT ON Logs
    FOR EACH ROW
    WHEN NEW.id != -1
    BEGIN
        INSERT INTO ChangesOnThisDevice(table_id,record_id,changes_type,user_id)
        VALUES (7,NEW.id,1,NEW.user_id );
    END;'
                            tx.executeSql(query)
                            query = 'CREATE TRIGGER IF NOT EXISTS updateLogsChanges
    AFTER UPDATE ON Logs
    FOR EACH ROW
    WHEN NEW.id != -1
    BEGIN
        INSERT INTO ChangesOnThisDevice(table_id,record_id,changes_type,user_id)
        VALUES (7,NEW.id,2,NEW.user_id );
    END;'
                            tx.executeSql(query)
                            query = 'CREATE TRIGGER IF NOT EXISTS deleteLogsChanges
    AFTER DELETE ON Logs
    FOR EACH ROW
    WHEN OLD.id != -1
    BEGIN
        INSERT INTO ChangesOnThisDevice(table_id,record_id,changes_type,user_id)
        VALUES (7,OLD.id,3,OLD.user_id );
    END;'
                            tx.executeSql(query)
                        } // end of try
                        catch(e)
                        {
                            console.trace();console.error(e)
                        }
                    }// end of function
                    )// end of transaction
    }//end of function


    function makeLocalChangesTable()
    {
        Database.connection.transaction(
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
                            console.trace();console.error(e)
                        }
                    }// end of function
                    )// end of transaction
    }//end of function

    function makeChangesOnThisDeviceTable()
    {

        Database.connection.transaction(
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
                            console.trace();console.error(e)
                        }
                    }// end of function
                    )// end of transaction
    }//end of function

    function makeServerChangesTable()
    {
        Database.connection.transaction(
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
    "register_date"	TEXT DEFAULT "",
    PRIMARY KEY("id" AUTOINCREMENT)
);'
                            var result = tx.executeSql(query)
                        } // end of try
                        catch(e)
                        {
                            console.trace();console.error(e)
                        }
                    }// end of function
                    )// end of transaction
    }//end of function


    function getLastChanges(callback)
    {
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + User.id +"&last_date=" + decodeURIComponent(SettingDriver.value("last_date",""))
        xhr.open( "GET", domain+"/api/v1/changes"+"?"+query,true);
        xhr.setRequestHeader("Content-Type" , "application/json");
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
                        if(response.code === 200)
                        {
                            if(response.result.length > 0)
                            {
                                insertServerChanges(response.result)

                                SettingDriver.setValue("last_date",decodeURIComponent(response.result[0].register_date))
                            }
              }
                    }
                    else
                    {
                        if(response.code === 401)
                        {
                            UsefulFunc.showUnauthorizedError()
                            return
                        }
                        else{
                            UsefulFunc.showLog(response.message,true)
                            return
                        }
                    }
                }
                catch(e) {
                    console.trace();
                    console.error(e);
                    console.log(xhr.responseText)
                }
                callback()
            }
        }
    }

    function insertServerChanges(values)
    {
        let mapValues = values.map(item => [ item.id,   item.table_id,   item.record_id,    item.changes_type,  item.user_id,   item.register_date] )
        let finalString = ""
        for(let i=0;i<mapValues.length;i++)
        {
            for(let j=0;j<mapValues[i].length;j++)
            {
                mapValues[i][j] = typeof mapValues[i][j] === "string"?'"'+ (mapValues[i][j]==="null"?"":mapValues[i][j]) + '"':mapValues[i][j]
            }
            finalString += "(" + mapValues[i] + ")" + (i!==mapValues.length-1?",":"")
        }
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            tx.executeSql("INSERT INTO ServerChanges(id,table_id,record_id,changes_type,user_id,register_date) VALUES "+ finalString)
                        }
                        catch(e)
                        {
                            console.trace();console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            var ids = tx.executeSql("SELECT a.id as ChangeId,b.id as ServerId FROM ChangesOnThisDevice a JOIN ServerChanges b on a.table_id = b.table_id AND a.record_id = b.record_id AND a.changes_type = b.changes_type AND a.user_id = b.user_id");
                            var sIds = ""
                            var cIds = ""

                            for(var i=0; i < ids.rows.length ; i++)
                            {
                                sIds += ids.rows.item(i).ServerId;
                                cIds += ids.rows.item(i).ChangeId;
                                if(i !==ids.rows.length -1)
                                {
                                    cIds+=",";
                                    sIds+=','
                                }
                            }
                            if(sIds)
                                deleteFromServerChanges(sIds)
                            if(cIds)
                                deleteFromDeviceChanges(cIds)
                        }
                        catch(e){}
                    })


    } // end of insert function

    function deleteFromServerChanges(ids)
    {
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("DELETE FROM ServerChanges WHERE id IN ("+ids+")")
                        }
                        catch(e)
                        {
                            console.trace();console.error(e)
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

        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("INSERT INTO LocalChanges( table_id, record_id, changes_type, user_id) VALUES "+ finalString)
                        }
                        catch(e)
                        {
                            console.trace();console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
    } // end of insert function


    function deleteFromLocalChanges(ids)
    {
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("DELETE FROM LocalChanges WHERE id IN ("+ids+")")
                        }
                        catch(e)
                        {
                            console.trace();console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
    } // end of insert function

    function deleteFromDeviceChanges(ids)
    {
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("DELETE FROM ChangesOnThisDevice WHERE id IN ("+ids+")")
                        }
                        catch(e)
                        {
                            console.trace();console.error(e)
                        }
                    }//end of  function
                    ) // end of transaction
    } // end of insert function

}
