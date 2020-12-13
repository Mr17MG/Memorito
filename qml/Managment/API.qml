import QtQuick 2.14

QtObject {
    function getFriends(model)
    {
        if(model.count > 0)
        {
            return model
        }

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + currentUser.userId
        xhr.open("GET", domain+"/api/v1/friends"+"?"+query,true);
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
                            model.append(response.result)
                        }
                        return model
                    }
                    else {
                        if(response.code === 406)
                        {
                            usefulFunc.showLog(qsTr("خطا در ارتباط با سرور، لطفا مجدد تلاش نمایید"),true,null,400*size1W, ltr)
                        }
                        else
                            usefulFunc.showLog(response.message,true,mainColumn,mainColumn.width, ltr)
                        return null
                    }
                }
                catch(e) {
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,mainColumn,mainColumn.width, ltr)
                    return null
                }
            }
        }
    }

    function addFriend(friendName,model)
    {
        let json = JSON.stringify(
                {
                    user_id: currentUser.userId,
                    friend_name: friendName
                }, null, 1);

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("POST", domain+"/api/v1/friends",true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(json);
        var busyDialog = usefulFunc.showBusy("");
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
                            console.log(JSON.stringify(response.result))
                            model.append(response.result)
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
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,mainColumn,mainColumn.width, ltr)
                }
            }
        }
    }

    function editFriend(friendId,friendName,model,modelIndex)
    {
        let json = JSON.stringify(
                {
                    user_id: currentUser.userId,
                    friend_name: friendName
                }, null, 1);

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("PATCH", domain+"/api/v1/friends/"+friendId,true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(json);
        var busyDialog = usefulFunc.showBusy("");
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
                            model.set(modelIndex,{"friend_name":friendName})
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
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,mainColumn,mainColumn.width, ltr)
                }
            }
        }
    }

    function deleteFriend(friendId,model,modelIndex)
    {
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + currentUser.userId
        xhr.open("DELETE", domain+"/api/v1/friends/"+friendId+"?"+query,true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(null);
        var busyDialog = usefulFunc.showBusy("");
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
                            model.remove(modelIndex)
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
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,mainColumn,mainColumn.width, ltr)
                }
            }
        }
    }

    ///////////////////////////// Contexts /////////////////////////////////////
    function getContexts(model)
    {
        if(model.count > 0)
        {
            return model
        }

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + currentUser.userId
        xhr.open("GET", domain+"/api/v1/contexts"+"?"+query,true);
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
                            model.append(response.result)
                        }
                        return model
                    }
                    else {
                        if(response.code === 406)
                        {
                            usefulFunc.showLog(qsTr("خطا در ارتباط با سرور، لطفا مجدد تلاش نمایید"),true,null,400*size1W, ltr)
                        }
                        else
                            usefulFunc.showLog(response.message,true,mainColumn,mainColumn.width, ltr)
                        return null
                    }
                }
                catch(e) {
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,mainColumn,mainColumn.width, ltr)
                    return null
                }
            }
        }
    }

    function addContext(contextName,model)
    {
        let json = JSON.stringify(
                {
                    user_id: currentUser.userId,
                    context_name: contextName
                }, null, 1);

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("POST", domain+"/api/v1/contexts",true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(json);
        var busyDialog = usefulFunc.showBusy("");
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
                            console.log(JSON.stringify(response.result))
                            model.append(response.result)
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
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,mainColumn,mainColumn.width, ltr)
                }
            }
        }
    }

    function editContext(contextId,contextName,model,modelIndex)
    {
        let json = JSON.stringify(
                {
                    user_id: currentUser.userId,
                    context_name: contextName
                }, null, 1);

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("PATCH", domain+"/api/v1/contexts/"+contextId,true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(json);
        var busyDialog = usefulFunc.showBusy("");
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
                            model.set(modelIndex,{"context_name":contextName})
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
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,mainColumn,mainColumn.width, ltr)
                }
            }
        }
    }

    function deleteContext(contextId,model,modelIndex)
    {
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + currentUser.userId
        xhr.open("DELETE", domain+"/api/v1/contexts/"+contextId+"?"+query,true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(null);
        var busyDialog = usefulFunc.showBusy("");
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
                            model.remove(modelIndex)
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
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,mainColumn,mainColumn.width, ltr)
                }
            }
        }
    }
}
