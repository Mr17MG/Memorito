import QtQuick 2.14

QtObject {
    function getUsers(){
        var response =[]
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("SELECT * FROM Users ORDER BY id DESC")
                            for(var i=0;i<result.rows.length;i++)
                            {
                                var row = {
                                    "localId":result.rows.item(i).local_id,
                                    "id":result.rows.item(i).id,
                                    "username":result.rows.item(i).username,
                                    "email":result.rows.item(i).email,
                                    "hashedPassword":result.rows.item(i).hashed_password,
                                    "authToken":result.rows.item(i).auth_token
                                }
                                response.push(row)
                            }
                        }
                        catch(e)
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
                        }
                    }
                    )
        return response;

    }

    function getUserByUserId(id){
        var response
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("SELECT * FROM Users WHERE id=?",[id])
                            if(result.rows.length>0){
                                var row = {
                                    "localId":result.rows.item(0).local_id,
                                    "id":result.rows.item(0).id,
                                    "username":result.rows.item(0).username,
                                    "email":result.rows.item(0).email,
                                    "hashedPassword":result.rows.item(0).hashed_password,
                                    "authToken":result.rows.item(0).auth_token
                                }
                                response = row
                            }
                        }
                        catch(e)
                        {
                            console.log(e)
                        }
                    }
                    )
        return response;
    }

    function addUser(user)
    {
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql(
                                        "INSERT INTO Users( id, username, email, hashed_password, auth_token)
                                                                    VALUES(?,?,?,?,?)",
                                        [user.id, user.username, user.email, user.hashed_password, user.auth_token]
                                        )
                        }
                        catch(e)
                        {
                            console.log(e)
                        }
                    }
                    )
    }

    function updateUser(user)
    {
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql(
                                        "UPATE Users SET id=?, username=?, email=?, hashed_password=?, auth_token=? WHERE local_id=?",
                                        [user.id, user.username, user.email, user.hashed_password, user.auth_token, user.localId]
                                        )
                        }
                        catch(e)
                        {
                            console.log(e)
                        }
                    }
                    )
    }

    function deleteUser(localId)
    {
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql( "DELETE FROM Users WHERE local_id=?", [localId] )
                        }
                        catch(e)
                        {
                            console.log(e)
                        }
                    }
                    )
    }


}
