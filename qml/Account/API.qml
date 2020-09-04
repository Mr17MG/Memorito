import QtQuick 2.14

QtObject {
    //    property var xhr: new XMLHttpRequest()
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
        var busyDialog = usefulFunc.showBusy("",function(){ xhr.abort() });

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
        var busyDialog = usefulFunc.showBusy("",function(){ xhr.abort() });

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
                            mainLoader.source = "qrc:/Memorito.qml"
                            //TODO insert to Database
                            userDbFunc.addUser(response.result)
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
        var busyDialog = usefulFunc.showBusy("",function(){ xhr.abort() });
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
                            mainLoader.source = "qrc:/Memorito.qml"
                            //TODO insert to Database
                            userDbFunc.addUser(response.result)
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
        var busyDialog = usefulFunc.showBusy("",function(){ xhr.abort() });
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
        var busyDialog = usefulFunc.showBusy("",function(){ xhr.abort() });
        xhr.timeout = 10000;
        console.log(json)
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
                            mainLoader.source = "qrc:/Memorito.qml"
                            //TODO insert to Database
                            userDbFunc.addUser(response.result)
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
        var busyDialog = usefulFunc.showBusy("",function(){ xhr.abort() });
        xhr.timeout = 10000;
        console.log(json)
        xhr.onreadystatechange = function ()
        {
            if (xhr.readyState === XMLHttpRequest.DONE)
            {
                busyDialog.close()
                try
                {
                    console.log(xhr.responseText)
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
        var busyDialog = usefulFunc.showBusy("",function(){ xhr.abort() });

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
                            mainLoader.source = "qrc:/Memorito.qml"
                        }
                    }
                    else {
                        if(response.code === 403)
                        {
                            mainLoader.source = "qrc:/Account/AccountMain.qml"
                            userDbFunc.deleteUser(userId)
                        }

                        else
                            usefulFunc.showLog(response.message,true,rootWindow,rootWindow, true)
                    }

                }
                catch(e) {
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,authLoader,authLoader.width, true)
                    mainLoader.source = currentUser?"qrc:/Memorito.qml":"qrc:/Account/AccountMain.qml"
                }
            }
        }
    }
}
