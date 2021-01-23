import QtQuick 2.14
import MEnum 1.0

QtObject {
    function getUsersChanges()
    {
        dataBase.transaction(
                    function(tx)
                    {
                        try
                        {
                            let list=[]
                            let result = tx.executeSql("SELECT record_id FROM ServerChanges WHERE table_id = ? AND changes_type =2 AND user_id = ? GROUP BY record_id",[Memorito.CHUsers ,currentUser.id])
                            if(result.rows.length > 0)
                            {
                                getUser(result.rows.item(0).record_id)
                            }
                        }
                        catch(e)
                        {
                            console.error(e)
                        }
                    })
    }

    function getUser(userId)
    {
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("GET", domain+"/api/v1/users/"+userId,true);
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
                            response.result.localId = currentUser.localId
                            updateUser(response.result)
                            dataBase.transaction(
                                        function(tx)
                                        {
                                            try
                                            {
                                                var result = tx.executeSql("DELETE FROM ServerChanges WHERE table_id = ?")
                                            }
                                            catch(e)
                                            {
                                                console.error(e)
                                            }
                                        }
                                        )
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

    function signUp(username,email,password)
    {
        let json = JSON.stringify(
                {
                    app_name: sysInfo.getAppName(),
                    app_version: sysInfo.getAppVersion(),
                    cpu_arch : sysInfo.getCpuArch(),
                    email : email,
                    hashed_password : security.hashPass(password),
                    kernel_type: sysInfo.getKernelType(),
                    kernel_version : sysInfo.getKernelVersion(),
                    machine_unique_id : sysInfo.getMachineUniqueId(),
                    os_name: sysInfo.getOsName() ,
                    os_version : sysInfo.getOsVersion(),
                    pretty_os_name : sysInfo.getPrettyOsName(),
                    username : username
                }, null, 1);

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("POST", domain+"/api/v1/account/signup",true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(json);
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
                        if(response.code === 201){
                            authLoader.item.push("qrc:/Account/Authentication.qml",{isReset:false,email:email})
                        }
                    }
                    else {
                        if(response.code === 409)
                        {
                            if(response.message.includes("username"))
                            {
                                usefulFunc.showLog(qsTr("نام کاربری که انتخاب کرده اید، توسط شخص دیگری استفاده شده است. لطفا نام کاربری دیگری انتخاب نمایید."),true,authLoader,authLoader.width, true)
                            }
                            else if(response.message.includes("email"))
                            {
                                usefulFunc.showLog(qsTr("حسابی با ایمیلی که وارد کرده‌اید، وجود دارید در صورتی که از ایمیل خود مطمئن هستید از بخش ورود به حساب، وارد حساب خود شوید."),true,authLoader,authLoader.width, true)
                            }
                        }
                        else
                            usefulFunc.showLog(response.message,true,authLoader,authLoader.width, true)
                    }

                }
                catch(e) {
                    console.error(e);console.log(xhr.responseText)
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,authLoader,authLoader.width, true)
                }
            }
        }
    }

    function validateOTP(email, otp)
    {
        let json = JSON.stringify(
                {
                    identifier : email,
                    machine_unique_id : sysInfo.getMachineUniqueId(),
                    otp : otp
                }, null, 1);

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("POST", domain+"/api/v1/account/validate-otp",true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(json);
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
                        if(response.code === 202){                           
                            addUser(response.result)
                            users.append(getUsers())
                            mainLoader.source = "qrc:/StartMemorito.qml"
                            currentUser = getUserByUserId(users.get(0).id)
                        }
                    }
                    else {
                        if(response.code === 401)
                        {
                            usefulFunc.showLog(qsTr("ایمیل شما توسط شخص دیگری ثبت گردید لطفا مجدد امتحان نمایید."),true,authLoader,authLoader.width, true)
                        }
                        else if(response.code === 403)
                        {
                            usefulFunc.showLog(qsTr("کد تائیدی که ارسال کرده اید، اشتباه است لطفا مجدد ارسال نمایید"),true,authLoader,authLoader.width, true)
                        }

                        else
                            usefulFunc.showLog(response.message,true,authLoader,authLoader.width, true)
                    }

                }
                catch(e) {
                    console.error(e);console.log(xhr.responseText)
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,authLoader,authLoader.width, true)
                }
            }
        }
    }

    function signIn(identifier,password)
    {
        let json = JSON.stringify(
                {
                    app_name: sysInfo.getAppName(),
                    app_version: sysInfo.getAppVersion(),
                    cpu_arch : sysInfo.getCpuArch(),
                    hashed_password : security.hashPass(password),
                    kernel_type: sysInfo.getKernelType(),
                    kernel_version : sysInfo.getKernelVersion(),
                    machine_unique_id : sysInfo.getMachineUniqueId(),
                    identifier : identifier ,
                    os_name: sysInfo.getOsName() ,
                    os_version : sysInfo.getOsVersion(),
                    pretty_os_name : sysInfo.getPrettyOsName(),
                }, null, 1);

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("POST", domain+"/api/v1/account/signin",true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(json);
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
                        if(response.code === 202){
                            addUser(response.result)
                            users.append(getUsers())
                            mainLoader.source = "qrc:/StartMemorito.qml"
                            currentUser = getUserByUserId(users.get(0).id)
                        }
                        else if(response.code === 200)
                        {
                            authLoader.item.push("qrc:/Account/Authentication.qml",{isReset:false,email:response.result.email})
                        }
                    }
                    else {
                        if(response.code === 401)
                        {
                            if(response.message.includes("username"))
                            {
                                usefulFunc.showLog(qsTr("نام کاربری یا ایمیل وارد شده اشتباه می‌باشد."),true,authLoader,authLoader.width, false)
                            }
                            else if (response.message.includes("password"))
                            {
                                usefulFunc.showLog(qsTr("رمزعبور وارد شده اشتباه می‌باشد."),true,authLoader,authLoader.width, false)
                            }
                        }
                        else
                            usefulFunc.showLog(response.message,true,authLoader,authLoader.width, false)
                    }

                }
                catch(e) {
                    console.error(e);console.log(xhr.responseText)
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,authLoader,authLoader.width, false)
                }
            }
        }
    }

    function forgetPass(identifier)
    {
        let json = JSON.stringify(
                {
                    app_name: sysInfo.getAppName(),
                    app_version: sysInfo.getAppVersion(),
                    cpu_arch : sysInfo.getCpuArch(),
                    kernel_type: sysInfo.getKernelType(),
                    kernel_version : sysInfo.getKernelVersion(),
                    machine_unique_id : sysInfo.getMachineUniqueId(),
                    identifier : identifier ,
                    os_name: sysInfo.getOsName() ,
                    os_version : sysInfo.getOsVersion(),
                    pretty_os_name : sysInfo.getPrettyOsName(),
                }, null, 1);

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("POST", domain+"/api/v1/password/forget-pass",true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(json);
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
                            authLoader.item.push("qrc:/Account/Authentication.qml",{isReset:true,email:response.result.email})
                        }
                    }
                    else {
                        if(response.code === 401)
                        {
                            if(response.message.includes("username"))
                            {
                                usefulFunc.showLog(qsTr("نام کاربری یا ایمیل وارد شده اشتباه می‌باشد."),true,authLoader,authLoader.width, false)
                            }
                        }
                        else
                            usefulFunc.showLog(response.message,true,authLoader,authLoader.width, false)
                    }

                }
                catch(e) {
                    console.error(e);console.log(xhr.responseText)
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,authLoader,authLoader.width, false)
                }
            }
        }
    }

    function resetPass(identifier, otp, password)
    {
        let json = JSON.stringify(
                {
                    identifier : identifier,
                    machine_unique_id : sysInfo.getMachineUniqueId(),
                    hashed_password : security.hashPass(password),
                    otp : otp
                }, null, 1);

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("POST", domain+"/api/v1/password/reset-pass",true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(json);
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
                            addUser(response.result)
                            users.append(getUsers())
                            mainLoader.source = "qrc:/StartMemorito.qml"
                            currentUser = getUserByUserId(users.get(0).id)
                        }
                    }
                    else {
                        if(response.code === 401)
                        {
                            if(response.message.includes("username"))
                            {
                                usefulFunc.showLog(qsTr("نام کاربری یا ایمیل وارد شده اشتباه می‌باشد."),true,authLoader,authLoader.width, false)
                            }
                        }
                        else if(response.code === 403)
                        {
                            if(response.message.includes("OTP"))
                            {
                                usefulFunc.showLog(qsTr("کد تائید وارد شده اشتباه می‌باشد."),true,authLoader,authLoader.width, false)
                            }
                        }

                        else
                            usefulFunc.showLog(response.message,true,authLoader,authLoader.width, false)
                    }

                }
                catch(e) {
                    console.error(e);console.log(xhr.responseText)
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,authLoader,authLoader.width, false)
                }
            }
        }
    }

    function resendOTP(identifier)
    {
        let json = JSON.stringify(
                {
                    identifier : identifier,
                    machine_unique_id : sysInfo.getMachineUniqueId(),
                }, null, 1);

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("POST", domain+"/api/v1/password/resend-otp",true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(json);
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
                            usefulFunc.showLog(qsTr("کد تایید مجدد به ایمیل شما ارسال شد."),false,authLoader,authLoader.width, false)
                        }
                    }
                    else {
                        if(response.code === 401)
                        {
                            if(response.message.includes("username"))
                            {
                                usefulFunc.showLog(qsTr("نام کاربری یا ایمیل وارد شده اشتباه می‌باشد."),true,authLoader,authLoader.width, false)
                            }
                        }
                        else
                            usefulFunc.showLog(response.message,true,authLoader,authLoader.width, false)
                    }

                }
                catch(e) {
                    console.error(e);console.log(xhr.responseText)
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,authLoader,authLoader.width, false)
                }
            }
        }
    }

    function validateToken(authToken,userId)
    {
        let json = JSON.stringify(
                {
                    auth_token : authToken,
                    machine_unique_id : sysInfo.getMachineUniqueId(),
                }, null, 1);

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("POST", domain+"/api/v1/account/validate-token",true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(json);
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
                            mainLoader.source = "qrc:/StartMemorito.qml"
                        }
                    }
                    else {
                        if(response.code === 403)
                        {
                            deleteUser(userId)
                            localDB.dropAallLocalTables()
                            mainLoader.source = "qrc:/Account/AccountMain.qml"
                        }

                        else
                            usefulFunc.showLog(response.message,true,rootWindow,rootWindow, true)
                    }

                }
                catch(e) {
                    console.error(e);console.log(xhr.responseText)
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,mainLoader,mainLoader.width, true)
                    mainLoader.source = currentUser?"qrc:/StartMemorito.qml":"qrc:/Account/AccountMain.qml"
                }
            }
        }
    }




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
                        catch(e){}
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
                            console.error(e)
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
                                        [user.id??0, user.username??"", user.email??"", user.hashed_password??"", user.auth_token??""]
                                        )
                        }
                        catch(e)
                        {
                            console.error(e)
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
                                        "UPDATE Users SET id=?, username=?, email=?, hashed_password=? WHERE local_id=?",
                                        [user.id??0, user.username??"", user.email??"", user.hashed_password??"", user.localId??0]
                                        )
                            currentUser = getUserByUserId(user.id)
                        }
                        catch(e)
                        {
                            console.error(e)
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
                            console.error(e)
                        }
                    }
                    )
    }


}
