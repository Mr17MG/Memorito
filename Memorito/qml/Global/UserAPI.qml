pragma Singleton
import QtQuick 2.15
import QtQuick.LocalStorage 2.15
import MSysInfo 1.0
import MSecurity 1.0
import MTools 1.0

QtObject {
    property var sysInfo : MSysInfo{}
    property var security: MSecurity{}
    property var myTools: MTools{}

    function getUsersChanges()
    {
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            let list=[]
                            let result = tx.executeSql("SELECT record_id FROM ServerChanges WHERE table_id = ? AND changes_type =2 AND user_id = ? GROUP BY record_id",[Memorito.CHUsers ,User.id])
                            if(result.rows.length > 0)
                            {
                                getUser(result.rows.item(0).record_id)
                            }
                        }
                        catch(e)
                        {
                            console.trace();console.error(e)
                        }
                    })
    }

    function getUser(userId)
    {
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "machine_unique_id= "+ sysInfo.getMachineUniqueId()
        xhr.open("GET", domain+"/api/v1/users/"+userId+"?"+query,true);
        xhr.setRequestHeader("Content-Type", "application/json");
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
                            updateUser(response.result)
                            Database.connection.transaction(
                                        function(tx)
                                        {
                                            try
                                            {
                                                var result = tx.executeSql("DELETE FROM ServerChanges WHERE table_id = ?",Memorito.CHUsers)
                                            }
                                            catch(e)
                                            {
                                                console.trace();console.error(e)
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

    function editUser(userId,json)
    {
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("PATCH", domain+"/api/v1/users/"+userId,true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(json);
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
                            updateUser(response.result)
                            UsefulFunc.showLog(qsTr("پروفایل شما با موفقیت بروزرسانی شد."),false)
                        }
                        return true
                    }
                    else {
                        if(response.code === 401)
                        {
                            UsefulFunc.showUnauthorizedError()
                        }
                        else
                            UsefulFunc.showLog(response.message,true)
                    }
                }
                catch(e) {
                    console.trace();
                    console.log(xhr.responseText);
                    console.log(e)
                    UsefulFunc.showConnectionError()
                    return false
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
        var busyDialog = UsefulFunc.showBusy("");


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
                        if(response.code === 201){
                            UsefulFunc.authLoader.item.push("qrc:/Account/Authentication.qml",{isReset:false,email:email})
                        }
                    }
                    else {
                        if(response.code === 409)
                        {
                            if(response.message.includes("username"))
                            {
                                UsefulFunc.showLog(qsTr("نام کاربری که انتخاب کرده اید، توسط شخص دیگری استفاده شده است. لطفا نام کاربری دیگری انتخاب نمایید."),true)
                            }
                            else if(response.message.includes("email"))
                            {
                                UsefulFunc.showLog(qsTr("حسابی با ایمیلی که وارد کرده‌اید، وجود دارید در صورتی که از ایمیل خود مطمئن هستید از بخش ورود به حساب، وارد حساب خود شوید."),true)
                            }
                        }
                        else
                            UsefulFunc.showLog(response.message,true)
                    }

                }
                catch(e) {
                    console.trace();console.error(e);console.log(xhr.responseText)
                    UsefulFunc.showConnectionError()

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
        var busyDialog = UsefulFunc.showBusy("");


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
                            console.log(JSON.stringify(response.result))
                            console.log(JSON.stringify(JSON.parse(getUsers())))
                            User.users.append(getUsers())
                            UsefulFunc.mainLoader.source = "qrc:/StartMemorito.qml"
                            User.set(getUserByUserId(User.users.get(0).id))
                        }
                    }
                    else {
                        if(response.code === 401)
                        {
                            UsefulFunc.showLog(qsTr("ایمیل شما توسط شخص دیگری ثبت گردید لطفا مجدد امتحان نمایید."),true)
                        }
                        else if(response.code === 403)
                        {
                            UsefulFunc.showLog(qsTr("کد تائیدی که ارسال کرده اید، اشتباه است لطفا مجدد ارسال نمایید"),true)
                        }

                        else
                            UsefulFunc.showLog(response.message,true)
                    }

                }
                catch(e) {
                    console.trace();console.error(e);console.log(xhr.responseText)
                    UsefulFunc.showConnectionError()

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
        var busyDialog = UsefulFunc.showBusy("");


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
                        if(response.code === 202){
                            addUser(response.result)
                            User.users.append(getUsers())
                            UsefulFunc.mainLoader.source = "qrc:/StartMemorito.qml"
                            User.set(getUserByUserId(User.users.get(0).id))
                        }
                        else if(response.code === 200)
                        {
                            UsefulFunc.authLoader.item.push("qrc:/Account/Authentication.qml",{isReset:false,email:response.result.email})
                        }
                    }
                    else {
                        if(response.code === 401)
                        {
                            if(response.message.includes("username"))
                            {
                                UsefulFunc.showLog(qsTr("نام کاربری یا ایمیل وارد شده اشتباه می‌باشد."),true)
                            }
                            else if (response.message.includes("password"))
                            {
                                UsefulFunc.showLog(qsTr("رمزعبور وارد شده اشتباه می‌باشد."),true)
                            }
                        }
                        else
                            UsefulFunc.showLog(response.message,true)
                    }

                }
                catch(e) {
                    console.trace();console.error(e);console.log(xhr.responseText)
                    UsefulFunc.showConnectionError()

                }
            }
        }
    }

    function forgetPass(identifier,fromProfile)
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
        var busyDialog = UsefulFunc.showBusy("");


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
                        if(response.code === 200)
                        {
                            if(fromProfile)
                            {
                                UsefulFunc.mainStackPush("qrc:/Account/Authentication.qml",qsTr("تغییر رمز ورود"),{isReset:true,email:response.result.email,fromProfile:true})
                            }
                            else UsefulFunc.authLoader.item.push("qrc:/Account/Authentication.qml",{isReset:true,email:response.result.email})
                        }
                    }
                    else {
                        if(response.code === 401)
                        {
                            if(response.message.includes("username"))
                            {
                                UsefulFunc.showLog(qsTr("نام کاربری یا ایمیل وارد شده اشتباه می‌باشد."),true)
                            }
                        }
                        else
                            UsefulFunc.showLog(response.message,true)
                    }

                }
                catch(e) {
                    console.trace();console.error(e);console.log(xhr.responseText)
                    UsefulFunc.showConnectionError()

                }
            }
        }
    }

    function resetPass(identifier, otp, password,fromProfile)
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
        var busyDialog = UsefulFunc.showBusy("");


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
                        if(response.code === 200)
                        {
                            if(fromProfile)
                            {
                                updateUser(response.result)
                                User.users.append(getUsers())
                                User.set(getUserByUserId(User.users.get(0).id))
                                UsefulFunc.mainStackPop()
                            }
                            else{
                                addUser(response.result)
                                User.users.append(getUsers())
                                UsefulFunc.mainLoader.source = "qrc:/StartMemorito.qml"
                                User.set(getUserByUserId(User.users.get(0).id))
                            }
                        }
                    }
                    else {
                        if(response.code === 401)
                        {
                            if(response.message.includes("username"))
                            {
                                UsefulFunc.showLog(qsTr("نام کاربری یا ایمیل وارد شده اشتباه می‌باشد."),true)
                            }
                        }
                        else if(response.code === 403)
                        {
                            if(response.message.includes("OTP"))
                            {
                                UsefulFunc.showLog(qsTr("کد تائید وارد شده اشتباه می‌باشد."),true)
                            }
                        }

                        else
                            UsefulFunc.showLog(response.message,true)
                    }

                }
                catch(e) {
                    console.trace();console.error(e);console.log(xhr.responseText)
                    UsefulFunc.showConnectionError()

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
        var busyDialog = UsefulFunc.showBusy("");


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
                        if(response.code === 200)
                        {
                            UsefulFunc.showLog(qsTr("کد تایید مجدد به ایمیل شما ارسال شد."),false)
                        }
                    }
                    else {
                        if(response.code === 401)
                        {
                            if(response.message.includes("username"))
                            {
                                UsefulFunc.showLog(qsTr("نام کاربری یا ایمیل وارد شده اشتباه می‌باشد."),true)
                            }
                        }
                        else
                            UsefulFunc.showLog(response.message,true)
                    }

                }
                catch(e) {
                    console.trace();console.error(e);console.log(xhr.responseText)
                    UsefulFunc.showConnectionError()

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
                            UsefulFunc.mainLoader.source = "qrc:/StartMemorito.qml"
                            UsefulFunc.connectionType = 1
                        }
                    }
                    else {
                        if(response.code === 403)
                        {
                            deleteUser(userId)
                            LocalDatabase.dropAallLocalTables()
                            UsefulFunc.mainLoader.source = "qrc:/Account/AccountMain.qml"
                        }

                        else{
                            UsefulFunc.showLog(response.message,true)
                        }
                    }

                }
                catch(e) {
                    console.trace();console.error(e);console.log(xhr.responseText)
                    UsefulFunc.showConnectionError()
                    UsefulFunc.mainLoader.source = User.isSet?"qrc:/StartMemorito.qml":"qrc:/Account/AccountMain.qml"
                }
            }
        }
    }

    function deleteAccount(password)
    {
        let json = JSON.stringify(
                {
                    hashed_password : security.hashPass(password),
                }, null, 1);

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("POST", domain+"/api/v1/account/delete-account/"+User.id,true);
        console.log(domain+"/api/v1/account/delete-account/"+User.id)
        xhr.setRequestHeader("Authorization", "Basic " +Qt.btoa(unescape(encodeURIComponent( User.email + ':' + User.authToken))) );
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(json);
        xhr.onreadystatechange = function ()
        {
            if (xhr.readyState === XMLHttpRequest.DONE)
            {
                console.log(xhr.responseText)
                try
                {
                    let response = xhr.response
                    console.log(xhr.responseText)
                    if(response.ok)
                    {
                        UsefulFunc.showLog(qsTr("حساب کاربری شما با موفقیت حذف شد، ناراحت شدم که از پیشم رفتی :("),false)
                        myTools.deleteSaveDir();
                        UsefulFunc.mainLoader.source = "qrc:/Account/AccountMain.qml"
                        SettingDriver.setValue("last_date","")
                        User.clear()
                        UsefulFunc.stackPages.clear()
                    }
                    else {
                        if(response.code === 403)
                        {
                            deleteUser(userId)
                            LocalDatabase.dropAallLocalTables()
                            UsefulFunc.mainLoader.source = "qrc:/Account/AccountMain.qml"
                        }
                        else if(response.code === 401)
                        {
                            UsefulFunc.showLog(qsTr("رمز عبور وارد شده صحبح نمی‌باشد."),true)

                        }
                        else{
                            UsefulFunc.showLog(response.message,true)
                        }
                    }
                }
                catch(e) {
                    UsefulFunc.showConnectionError()
                }
            }
        }
    }


    function getUsers(){
        var response =[]
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("SELECT * FROM Users ORDER BY id DESC")
                            for(var i=0;i<result.rows.length;i++)
                            {
                                var row = result.rows.item(i)
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
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql("SELECT * FROM Users WHERE id=?",[id])
                            if(result.rows.length>0){
                                response = result.rows.item(0)
                            }
                        }
                        catch(e)
                        {
                            console.trace();console.error(e)
                        }
                    }
                    )
        return response;
    }

    function addUser(user)
    {
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql(
                                        "INSERT INTO Users( id, username, email, hashed_password, auth_token,
 avatar, register_date, modified_date, two_step)
                                                                    VALUES(?,?,?,?,?,?,?,?,?)",
                                        [
                                            user.id??0, user.username??"", user.email??"", user.hashed_password??"", user.auth_token??"",
                                            user.avatar??"", user.register_date??"", user.modified_date??"", user.two_step??0
                                        ]
                                        )
                        }
                        catch(e)
                        {
                            console.trace();console.error(e)
                        }
                    }
                    )
    }

    function updateUser(user)
    {
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            tx.executeSql(
                                        "UPDATE Users SET username=?, email=?, hashed_password=?, auth_token=?, avatar=?, register_date=?, modified_date=?, two_step=? WHERE id=?"
                                        ,[user.username??"", user.email??"", user.hashed_password??"",user.auth_token??"",user.avatar??"", user.register_date??"", user.modified_date??"", user.two_step??0, user.id]
                                        )

                            User.set(getUserByUserId(user.id),true)
                        }
                        catch(e)
                        {
                            console.trace();console.error(e)
                        }
                    }
                    )
    }

    function deleteUser(localId)
    {
        Database.connection.transaction(
                    function(tx)
                    {
                        try
                        {
                            var result = tx.executeSql( "DELETE FROM Users WHERE local_id=?", [localId] )
                        }
                        catch(e)
                        {
                            console.trace();console.error(e)
                        }
                    }
                    )
    }


}
