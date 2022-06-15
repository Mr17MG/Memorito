import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import Memorito.Global
import Memorito.Components

import Memorito.Things

Page {

    property int listId: -1
    property string pageTitle: ""

    property int parentId: -1

    property var queryList: {
        "context_id" : [],
        "priority_id" : [],
        "energy_id" : [],
        "display_type": [],
        "has_files" : 2,
        "estimate_type":"<", // timeCompbo.model.get(timeCompbo.currentIndex).query
        "estimate_time" : "", //Number(timeInput.text.trim()),
        "parent_id": "",
        "friend_id": "",
        "due_date" : {
            "fromDate": "",
            "toDate" : ""
        },
        "searchText" : "",
        "orderBy":"title",
        "orderType":"ASC"
    }

    function makeQuery()
    {
        let query= []

        if (queryList.context_id.length)
            query.push("context_id_local IN("+(queryList.context_id)+")")

        if (queryList.priority_id.length)
            query.push("priority_id IN("+(queryList.priority_id)+")")

        if (queryList.energy_id.length)
            query.push("energy_id IN("+(queryList.energy_id)+")")

        if (queryList.has_files !== 2)
            query.push("has_files"+"="+queryList.has_files)

        if (queryList.estimate_time !== "")
            query.push("estimate_time"+queryList.estimate_type + queryList.estimate_time)

        if( parentId !== -1)
            query.push("parent_id_local"+"="+parentId)
        else
            query.push("parent_id_local IS NULL")

        if(listId===Memorito.Calendar)
        {
            query.push("datetime(due_date) BETWEEN datetime('" + queryList.due_date.fromDate + "') AND datetime('" + queryList.due_date.toDate + "')")
        }

        if( queryList.searchText !=="" )
        {
            query.push("(lower(title) LIKE '%"+ queryList.searchText.toLowerCase() +"%' OR "+"lower(detail) LIKE '%"+ queryList.searchText.toLowerCase() +"%')")
        }

        if(listId === Memorito.Process)
            query.push("status=1")
        else if(listId === Memorito.NextAction)
            query.push("status=2")
        else if(listId === Memorito.Done)
            query.push("status=3")
        else if(listId === Memorito.Refrence)
            query.push("status=4")
        else if(listId === Memorito.Someday)
            query.push("status=5")

        if(listId !== Memorito.Calendar && listId !== Memorito.Coop)
        {
            query.push("T1.local_id NOT IN (SELECT thing_id_local FROM Calendar)")
            query.push("T1.local_id NOT IN (SELECT thing_id_local FROM Coop)")
        }

        var conditions = query.length?"WHERE "+query.join(" AND "):""
        var order = ("ORDER BY lower(" + queryList.orderBy + ") " + queryList.orderType)

        return conditions + " " + order
    }

    function cameInToPage(object) {
        internalModel.clear()
        let query = "SELECT T1.*,CASE WHEN (SELECT COUNT(*) FROM Files WHERE  thing_id_local = T1.local_id) > 0 THEN 1 ELSE 0 END AS has_files,
CASE WHEN (parent_id_local IS NOT NULL) THEN (SELECT title FROM Things WHERE local_id=parent_id_local) ELSE '' END AS parent_title"

        if(listId === Memorito.Coop)
        {
            query += ",CASE WHEN T1.user_id=T3.friend2 THEN T3.friend1_nickname ELSE T3.friend2_nickname END AS assignee
FROM Things as T1 JOIN Coop As T2 ON thing_id_local=T1.local_id JOIN Friends AS T3 ON T2.friend_id_local=T3.local_id"
        }
        else if(listId === Memorito.Calendar)
        {
            query += ",T2.due_date FROM Things as T1 JOIN Calendar As T2 ON thing_id_local=T1.local_id"
        }
        else query +=" FROM Things as T1"

        console.log("%1 %2".arg(query).arg(makeQuery()))
        internalModel.append(thingsModel.getThingsByQuery("%1 %2".arg(query).arg(makeQuery())))
        addBtn.text = qsTr("افزودن چیز جدید به") +" "+ (object.pageTitle??"")
    }

    ThingsController { id: thingsController }

    ThingsModel { id: thingsModel }

    ListModel {
        id: internalModel;
        dynamicRoles: true
    }

    header: ThingsHeader{}

    Loader {
        id: thingsLoader

        active: internalModel.count > 0
        width: parent.width
        clip: true

        anchors {
            top: parent.top
            topMargin: 20*AppStyle.size1H
            right: parent.right
            rightMargin: 5*AppStyle.size1W
            bottom: parent.bottom
            bottomMargin: 15*AppStyle.size1H
            left: parent.left
            leftMargin: 30*AppStyle.size1W
        }

        sourceComponent: GridView {
            id: gridView

            property real lastContentY: 0

            layoutDirection: Qt.RightToLeft
            cellHeight: listId === Memorito.Process? 240*AppStyle.size1W:400*AppStyle.size1W
            cellWidth: width / (parseInt(width / parseInt(600*AppStyle.size1W))===0?1:(parseInt(width / parseInt(600*AppStyle.size1W))))

            onContentYChanged: {
                if(contentY<0 || contentHeight < gridView.height)
                    contentY = 0

                else if(contentY > (contentHeight - gridView.height))
                {
                    contentY = (contentHeight - gridView.height)
                    gridView.lastContentY = contentY-1
                }

                /************* Move Add Button to Down or Up *******************/
                if(contentY > gridView.lastContentY)
                    addBtn.anchors.bottomMargin = -60*AppStyle.size1H
                else addBtn.anchors.bottomMargin = 20*AppStyle.size1H

                gridView.lastContentY = contentY
            }

            onContentXChanged: {
                if(contentX<0 || contentWidth < gridView.width)
                    contentX = 0
                else if(contentX > (contentWidth-gridView.width))
                    contentX = (contentWidth-gridView.width)
            }

            model: internalModel

            delegate: ThingsListDelegate {
                width:  gridView.cellWidth  - 20*AppStyle.size1W
                height: gridView.cellHeight - 10*AppStyle.size1H
            }
        }

    }

    Item {
        height: width
        width:  600*AppStyle.size1W
        visible: internalModel.count <= 0

        anchors {
            centerIn: parent
        }
        Image {
            width:  600*AppStyle.size1W
            height: width*0.781962339
            source: "qrc:/empties/empty-list-"+AppStyle.primaryInt+".svg"
            sourceSize.width: width*2
            sourceSize.height: height*2
            anchors{
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: -30*AppStyle.size1H
            }
        }
        Text{
            text: qsTr("تو این لیست که چیزی نیست")
            font{family: AppStyle.appFont;pixelSize:  40*AppStyle.size1F;bold:true}
            color: AppStyle.textColor
            anchors{
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
        }
    }

    AppButton{
        id: addBtn

        radius: 20*AppStyle.size1W
        leftPadding: 35*AppStyle.size1W
        rightPadding: 35*AppStyle.size1W

        icon {
            width: 30*AppStyle.size1W
            source:"qrc:/plus.svg"
        }

        anchors {
            left: parent.left
            leftMargin: 20*AppStyle.size1W
            bottom: parent.bottom
            bottomMargin: 20*AppStyle.size1W
        }

        Behavior on anchors.bottomMargin {
            NumberAnimation{
                duration: 200
            }
        }

        onClicked: {
            if(listId === Memorito.Friends)
                UsefulFunc.mainStackPush("qrc:/Things/AddEditThing.qml",text,{listId:Memorito.Coop,parentId:parentId})
            else if(listId === Memorito.Contexts)
                UsefulFunc.mainStackPush("qrc:/Things/AddEditThing.qml",text,{listId:Memorito.NextAction,parentId:parentId})
            else
                UsefulFunc.mainStackPush("qrc:/Things/AddEditThing.qml",text,{listId:listId,parentId:parentId})
        }
    }

}
