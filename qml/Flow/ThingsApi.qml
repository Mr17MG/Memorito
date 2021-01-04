import QtQuick 2.14

QtObject {
    function prepareForAdd(model,options,listId,hasFiles,categoryId=null,dueDate=null,friendId=null)
    {
        if(titleInput.text.trim() === "")
        {
            usefulFunc.showLog(qsTr("لطفا قسمت 'چی تو دهنته؟' رو پر کن"),true,null,600*size1W, ltr)
            titleMoveAnimation.start()
            return
        }

        let title = titleInput.text.trim()
        let detail = flickTextArea.text.trim()

        if(dueDate !==null)
            dueDate = encodeURIComponent(dueDate)

        addThing(model,title,detail,listId,hasFiles,options["contextId"],options["priorityId"],options["energyId"],options["estimateTime"],categoryId,dueDate,friendId)
    }

    function prepareForEdit(model,newModel,thingId,options,listId,hasFiles,categoryId=null,dueDate=null,friendId=null)
    {
        if(titleInput.text.trim() === "")
        {
            usefulFunc.showLog(qsTr("لطفا قسمت 'چی تو دهنته؟' رو پر کن"),true,null,600*size1W, ltr)
            return
        }
        let title = titleInput.text.trim()
        let detail = flickTextArea.text.trim()

        if(dueDate !==null)
            dueDate = encodeURIComponent(dueDate)

        editThing(thingId,modelIndex,model,newModel,title,detail,listId,hasFiles,options["contextId"],options["priorityId"],options["energyId"],options["estimateTime"],categoryId,dueDate,friendId)
    }

    function getThings(model,listId,categoryId)
    {
        if(model.count>0)
        {
            return model
        }

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + currentUser.id + "&list_id="+listId + (categoryId === -1 ?"":"&category_id="+categoryId)
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

    function addThing(model,title,detail,listId=null,hasFiles,contextId=null,priorityId=null,energyId=null,estimateTime=null,categoryId=null,dueDate=null,friendId=null)
    {
        let json = JSON.stringify(
                {
                    title : title,
                    user_id: currentUser.id,
                    detail : detail,
                    list_id : listId,
                    has_files: parseInt(hasFiles),
                    priority_id : priorityId,
                    estimate_time : estimateTime,
                    context_id : contextId,
                    energy_id : energyId,
                    due_date : dueDate,
                    friend_id : friendId,
                    category_id : categoryId
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
                            flickTextArea.detailInput.clear()
                            titleInput.clear()
                            if(hasFiles)
                                addFiles(attachModel,attachModel.count,response.result.id)
                            isDual = false

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

    function editThing(thingId,modelIndex,model,newModel,title,detail,listId=null,hasFiles,contextId=null,priorityId=null,energyId=null,estimateTime=null,categoryId=null,dueDate=null,friendId=null)
    {
        let json = JSON.stringify(
                {
                    title : title,
                    user_id: currentUser.id,
                    detail : detail,
                    has_files: parseInt(hasFiles),
                    priority_id : priorityId,
                    estimate_time : estimateTime,
                    context_id : contextId,
                    energy_id : energyId,
                    due_date : dueDate,
                    friend_id : friendId,
                    category_id : categoryId,
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
                            model.remove(modelIndex,1)
                            newModel.append(response.result)
                            usefulFunc.showLog(" <b>'"+ title+" '</b>" +qsTr("با موفقیت بروزرسانی شد"),false,null,700*size1W, ltr)
                            usefulFunc.mainStackPop()
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
        let query = "user_id=" + currentUser.id
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
            let file = fileModel.get(i)
            let base64 = myTools.encodeToBase64(String(file.file_source.replace("file://","")))
            fileList[i] = {"base64_file" : base64 , "file_extension": file.file_extension ,"file_name" :file.file_name}
        }

        let json = JSON.stringify(
                {
                    things_id: thingId,
                    user_id: currentUser.id,
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
                            fileModel.clear()
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
                    console.log(xhr.responseText)
                    console.error(e)
                    usefulFunc.showLog(qsTr("متاسفانه در ارتباط با سرور مشکلی پیش آمده است لطفا از اتصال اینترنت خود اطمینان حاصل فرمایید و مجدد تلاش نمایید"),true,mainColumn,mainColumn.width, ltr)
                }
            }
        }
    }

    function getFiles(model,thingId)
    {
        if(model.count>0)
        {
            return model
        }

        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.responseType = 'json';
        let query = "user_id=" + currentUser.id + "&things_id="+thingId
        xhr.open("GET", domain+"/api/v1/files"+"?"+query,true);
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
                            for(let i=0;i<response.result.length;i++)
                            {
                                let file=response.result[i]
                                if(myTools.checkFileExist(file["file_name"],file["file_extension"]))
                                    file["file_source"] = "file://"+myTools.getSaveDirectory()+file["file_name"]+"."+file["file_extension"]
                                else file["file_source"] = "";
                                model.append(file)
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

}
