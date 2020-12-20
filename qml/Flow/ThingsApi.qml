import QtQuick 2.14

QtObject {
    function prepareForAdd(options,listId,categoryId=null,dueDate=null,friendId=null,projectId=null)
    {
        if(titleInput.text.trim() === "")
        {
            usefulFunc.showLog(qsTr("لطفا قسمت 'چی تو دهنته؟' رو پر کن"),true,null,600*size1W, ltr)
            return
        }

        let title = titleInput.text.trim()
        let detail = detailInput.text.trim()

        if(dueDate !==null)
            dueDate = encodeURIComponent(dueDate)

        addThing(thingModel,title,detail,listId,options["contextId"],options["priorityId"],options["energyId"],options["estimateTime"],categoryId,dueDate,friendId,projectId)
    }

    function getThings(model,listId)
    {
        if(model.count>0)
        {
            return model
        }

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + currentUser.userId + "&list_id="+listId
        xhr.open("GET", domain+"/api/v1/things"+"?"+query,true);
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

    function addThing(model,title,detail,listId=null,contextId=null,priorityId=null,energyId=null,estimateTime=null,categoryId=null,dueDate=null,friendId=null,projectId=null)
    {
        let json = JSON.stringify(
                {
                    title : title,
                    user_id: currentUser.userId,
                    detail : detail,
                    priority_id : priorityId,
                    estimate_time : estimateTime,
                    context_id : contextId,
                    energy_id : energyId,
                    due_date : dueDate,
                    friend_id : friendId,
                    category_id : categoryId,
                    project_id : projectId,
                    list_id : listId

                }, null, 1);

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("POST", domain+"/api/v1/things",true);
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
                            usefulFunc.showLog(" <b>'"+ title+" '</b>" +qsTr("با موفقیت افزوده شد"),false,null,700*size1W, ltr)
                            model.append(response.result)
                            detailInput.clear()
                            titleInput.clear()
                            attachModel.clear()
                            processBtn.checked = false

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
                    console.log(e)
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,mainColumn,mainColumn.width, ltr)
                }
            }
        }
    }

    function editThing(title,detail,priorityId,estimateTime,contextId,energyId,dueDate,friendId,categoryId,projectId,listId,model,modelIndex)
    {
        let json = JSON.stringify(
                {
                    title : title,
                    user_id: currentUser.userId,
                    detail : detail,
                    priority_id : priorityId,
                    estimate_time : estimateTime,
                    context_id : contextId,
                    energy_id : energyId,
                    due_date : dueDate,
                    friend_id : friendId,
                    category_id : categoryId,
                    project_id : projectId,
                    list_id : listId
                }, null, 1);

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("PATCH", domain+"/api/v1/things/"+thingId,true);
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
//                            model.set(modelIndex,{"thing_name":thingName,"thing_goal":thingGoal})
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

    function deleteThing(thingId,model,modelIndex)
    {
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + currentUser.userId
        xhr.open("DELETE", domain+"/api/v1/things/"+thingId+"?"+query,true);
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


    function addFiles(fileModel,filesCount,thingId)
    {
        let fileList= [];
        for(let i = 0; i < filesCount; i++)
        {
            let base64 = myTools.encodeToBase64(String(fileModel.get(i).fileSource.replace("file://","")))
            fileList[i] = {"base64_file" : base64 , "file_extension": fileModel.get(i).fileExtension ,"file_name" :fileModel.get(i).fileName}
        }

        let json = JSON.stringify(
                {
                    things_id: thingId,
                    user_id: currentUser.userId,
                    file_list: fileList
                }, null, 1);

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        xhr.open("POST", domain+"/api/v1/files",true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(json);
        var busyDialog = usefulFunc.showBusy("در حال ارسال فایل ها");
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
                            usefulFunc.showLog(qsTr("فایل‌ها با موفقیت افزوده شد"),false,null,700*size1W, ltr)
//                            let result = response.result
//                            console.log(myTools.saveBase64asFile(result[0].file_name,result[0].file_extension,result[0].file))
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
                    console.log(e)
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,mainColumn,mainColumn.width, ltr)
                }
            }
        }
    }

}
