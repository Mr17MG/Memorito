import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtGraphicalEffects 1.14
import QtQuick.Layouts 1.15
import "qrc:/Components/" as App
import "qrc:/Managment/" as Managment
import MEnum 1.0

Item{

    ListModel{id:attachModel}

    ThingsApi{ id: thingsApi}

    property bool isDual: prevPageModel?true:false
    property var prevPageModel
    property int modelIndex: -1
    property var options: []
    property int listId: -1
    property int categoryId: -1

    onPrevPageModelChanged: {
        if(prevPageModel)
            if(prevPageModel.has_files === 1)
            {
                thingsApi.getFiles(attachModel,prevPageModel.id)
            }
    }

    Flickable{
        id: mainFlick
        height: parent.height
        width: nRow==3 && (listId === Memorito.Process || listId === Memorito.Collect) &&  isDual?parent.width/2 : parent.width
        clip:true
        contentHeight: item1.height
        anchors{
            right: parent.right
            top: parent.top
        }
        flickableDirection: Flickable.VerticalFlick
        onContentYChanged: {
            if(contentY<0 || contentHeight < mainFlick.height)
                contentY = 0
            else if(contentY > (contentHeight-mainFlick.height))
                contentY = contentHeight-mainFlick.height
        }
        onContentXChanged: {
            if(contentX<0 || contentWidth < mainFlick.width)
                contentX = 0
            else if(contentX > (contentWidth-mainFlick.width))
                contentX = (contentWidth-mainFlick.width)
        }
        ScrollBar.vertical: ScrollBar {
            hoverEnabled: true
            active: hovered || pressed
            orientation: Qt.Vertical
            anchors.right: mainFlick.right
            height: parent.height
            width: hovered || pressed?18*size1W:8*size1W
        }
        Item{
            id:item1
            width: parent.width
            height: mainFlow.height + (listId === Memorito.Process?50*size1H:100*size1H)
            Flow{
                id: mainFlow
                spacing: 25*size1H
                anchors{
                    top: parent.top
                    topMargin: 15*size1H
                    right: parent.right
                    rightMargin: 25*size1W
                    left: parent.left
                    leftMargin: 25*size1W
                }

                Item{
                    id: titleItem
                    width: parent.width
                    height: 100*size1H
                    App.TextInput{
                        id:titleInput
                        placeholderText: qsTr("چی تو ذهنته؟")
                        text: prevPageModel?prevPageModel.title:""
                        width: parent.width
                        height: parent.height
                        inputMethodHints: Qt.ImhPreferLowercase
                        font.bold:false
                        maximumLength: 50
                        anchors{
                            horizontalCenter: parent.horizontalCenter
                        }
                    }
                    SequentialAnimation {
                        id:titleMoveAnimation
                        running: false
                        loops: 3
                        NumberAnimation { target: titleInput; property: "anchors.horizontalCenterOffset"; to: -10   ; duration: 50  }
                        NumberAnimation { target: titleInput; property: "anchors.horizontalCenterOffset"; to: 10    ; duration: 100 }
                        NumberAnimation { target: titleInput; property: "anchors.horizontalCenterOffset"; to: 0     ; duration: 50  }
                    }
                }

                App.FlickTextArea{
                    id:flickTextArea
                    placeholderText : qsTr("توضیحاتی از چیزی که تو ذهنته رو بنویس") + " (" + qsTr("اختیاری") + ")"
                    text: prevPageModel?prevPageModel.detail?prevPageModel.detail:"":""
                }

                App.FilesSelection{
                    id: fileRect
                    width: flickTextArea.width
                    height:
                        listId === Memorito.Process?
                            (mainFlick.height-titleItem.height-flickTextArea.height-125*size1H < 450*size1H ? 450*size1H
                                                                                                            :(mainFlick.height-titleItem.height-flickTextArea.height-125*size1H))
                          :450*size1W

                    model: attachModel
                }

                Loader{
                    id: optionLoader
                    width: flickTextArea.width
                    active: listId !== Memorito.Collect && listId !== Memorito.Process
                    height: active?600*size1H:0
                    sourceComponent: optionsComponent
                }

                Loader{
                    id:collectLoader
                    width: flickTextArea.width
                    active: listId !== Memorito.Process
                    height: active?(
                                        (
                                            listId === Memorito.Project  ||
                                            listId === Memorito.Someday  ||
                                            listId === Memorito.Waiting  ||
                                            listId === Memorito.Calendar ||
                                            listId === Memorito.Refrence
                                            )
                                        ?220*size1H
                                        :110*size1H
                                        )
                                  :0
                    sourceComponent:listId === Memorito.NextAction?
                                        nextComponent :listId === Memorito.Someday?
                                            somedayComponent :listId === Memorito.Refrence?
                                                refrenceComponent : listId === Memorito.Waiting?
                                                    friendComponent : listId === Memorito.Calendar?
                                                        calendarComponent : listId === Memorito.Trash?
                                                            trashComponent : listId === Memorito.Done?
                                                                doComponent : listId === Memorito.Project?
                                                                    projectCategoryComponent : collectComponent
                }

                Loader{
                    id: processLoader
                    width: flickTextArea.width
                    height: active?1900*size1W:0
                    active: nRow <= 2 && (listId === Memorito.Process || listId === Memorito.Collect) && isDual
                    sourceComponent: processComponent
                    visible: active
                }
            } // end of Flow

        }// end of item1
    }//end of Flickable

    Loader{
        active: nRow === 3 && (listId === Memorito.Process || listId === Memorito.Collect) && isDual
        width: parent.width/2
        height: active?mainFlick.height:0
        asynchronous: true
        anchors{
            top: parent.top
            topMargin: 15*size1H
            left: parent.left
            leftMargin: 25*size1W
        }
        sourceComponent: Flickable{
            id: secondFlick
            contentHeight: processLoader2.height
            flickableDirection: Flickable.VerticalFlick
            onContentYChanged: {
                if(contentY<0 || contentHeight < secondFlick.height)
                    contentY = 0
                else if(contentY > (contentHeight-secondFlick.height))
                    contentY = contentHeight-secondFlick.height
            }
            onContentXChanged: {
                if(contentX<0 || contentWidth < secondFlick.width)
                    contentX = 0
                else if(contentX > (contentWidth-secondFlick.width))
                    contentX = (contentWidth-secondFlick.width)
            }

            ScrollBar.vertical: ScrollBar {
                hoverEnabled: true
                active: hovered || pressed
                orientation: Qt.Vertical
                anchors.right: secondFlick.right
                height: parent.height
                width: hovered || pressed?18*size1W:8*size1W
            }

            Loader{
                id: processLoader2
                width: parent.width
                height: 2000*size1H
                active: true
                asynchronous: true
                sourceComponent: processComponent
            }
        }//end of Flickable
    }//end of Loader

    Component{
        id:processComponent
        Item{
            Flow{
                anchors{
                    top: parent.top
                    right: parent.right
                    rightMargin: 15*size1W
                    bottom: parent.bottom
                    bottomMargin: 20*size1H
                    left: parent.left
                    leftMargin: 15*size1W
                }
                spacing: 10*size1H

                Loader{
                    id: optionsLoader
                    width: parent.width
                    height: 620*size1H
                    sourceComponent: optionsComponent
                }
                /*********** انجام نشدنی‌ها*****************/
                Text {
                    id: actionText
                    text: "⏺ "+qsTr("این چیز انجام شدنی نیست") +":"
                    width: parent.width
                    color: appStyle.textColor
                    font { family: appStyle.appFont; pixelSize: size1F*30;bold:true}
                }

                App.RadioButton{
                    id: somedayRadio
                    text: qsTr("شاید یک روزی این را انجام دادم")
                    width: parent.width
                    rightPadding: 50*size1W
                }
                Loader{
                    id: somedayLoader
                    width: parent.width
                    height: somedayRadio.checked?240*size1W:0
                    active: height!==0
                    Behavior on height { NumberAnimation{    duration: 200   } }
                    clip:true
                    sourceComponent: somedayComponent
                }
                /*********************************/

                App.RadioButton{
                    id: refrenceRadio
                    text: qsTr("اطلاعات مفیدی است میخواهم بعدا به آن مراجعه کنم")
                    width: parent.width
                    rightPadding: 50*size1W
                }
                Loader{
                    id: refrenceLoader
                    width: parent.width
                    height: refrenceRadio.checked?240*size1W:0
                    active: height!==0
                    Behavior on height { NumberAnimation{    duration: 200   } }
                    clip:true
                    sourceComponent: refrenceComponent
                }
                /*********************************/

                App.RadioButton{
                    id: trashRadio
                    text: qsTr("اطلاعات به درد نخوری است میخواهم به سطل آشغال بیاندازم")
                    width: parent.width
                    rightPadding: 50*size1W
                }
                Loader{
                    id: trashLoader
                    width: parent.width
                    height: trashRadio.checked?120*size1W:0
                    active: height!==0
                    Behavior on height { NumberAnimation{    duration: 200   } }
                    clip:true
                    sourceComponent: trashComponent
                }
                /*********************************/
                /*********** انجام نشدنی‌ها*****************/


                /*********** انجام شدنی‌ها*****************/
                /*********************************/
                Text {
                    id: action2Text
                    text: "⏺ "+qsTr("این چیز انجام شدنی است") +":"
                    width: parent.width
                    color: appStyle.textColor
                    font { family: appStyle.appFont; pixelSize: size1F*30;bold:true}
                }
                /*********************************/

                Text {
                    id: action3Text
                    text: "⏺ "+qsTr("این چیز با یک انجام یک عمل به پایان نمی‌رسد") +":"
                    width: parent.width
                    color: appStyle.textColor
                    height: 50*size1H
                    verticalAlignment: Text.AlignBottom
                    font { family: appStyle.appFont; pixelSize: size1F*24;bold:true}
                    rightPadding: 50*size1W
                }
                App.RadioButton{
                    id: projectRadio
                    text: qsTr("می‌خواهم یک پروژه جدید بسازم")
                    width: parent.width
                    rightPadding: 80*size1W
                }
                Loader{
                    id: projectLoader
                    active: height!==0
                    width: parent.width
                    height: projectRadio.checked?120*size1W:0
                    Behavior on height { NumberAnimation{    duration: 200   } }
                    clip:true
                    sourceComponent: projectComponent
                }
                /*********************************/

                App.RadioButton{
                    id: projectCategoryRadio
                    text: qsTr("می‌خواهم این عمل را به پروژه های قدیمی اضافه کنم")
                    width: parent.width
                    rightPadding: 80*size1W
                }
                Loader{
                    id: projectCategoryLoader
                    active: height!==0
                    width: parent.width
                    height: projectCategoryRadio.checked?240*size1W:0
                    Behavior on height { NumberAnimation{    duration: 200   } }
                    clip:true
                    sourceComponent: projectCategoryComponent
                }
                /*********************************/

                Text {
                    id: action4Text
                    text: "⏺ "+qsTr("این عمل بیشتر از ۵ دقیقه زمان نیاز دارد") +":"
                    width: parent.width
                    color: appStyle.textColor
                    height: 50*size1H
                    verticalAlignment: Text.AlignBottom
                    font { family: appStyle.appFont; pixelSize: size1F*24;bold:true}
                    rightPadding: 50*size1W
                }
                App.RadioButton{
                    id: friendRadio
                    text: qsTr("می‌خواهم این را شخص دیگری انجام دهد")
                    width: parent.width
                    rightPadding: 80*size1W
                }
                Loader{
                    id: friendLoader
                    active: height!==0
                    width: parent.width
                    height: friendRadio.checked?240*size1W:0
                    Behavior on height { NumberAnimation{    duration: 200   } }
                    clip: true
                    sourceComponent: friendComponent
                }
                /*********************************/

                App.RadioButton{
                    id: calendarRadio
                    text: qsTr("می‌خواهم این عمل را در زمان مشخصی انجام دهم")
                    width: parent.width
                    rightPadding: 80*size1W
                }
                Loader{
                    id: calendarLoader
                    active: height!==0
                    width: parent.width
                    height: calendarRadio.checked?220*size1W:0
                    Behavior on height { NumberAnimation{    duration: 200   } }
                    clip: true
                    sourceComponent: calendarComponent
                }
                /*********************************/

                App.RadioButton{
                    id: nextRadio
                    text: qsTr("می‌خواهم این عمل را در بعدا انجام دهم")
                    width: parent.width
                    rightPadding: 80*size1W
                }

                Loader{
                    id: nextLoader
                    active: height!==0
                    width: parent.width
                    height: nextRadio.checked?120*size1W:0
                    Behavior on height { NumberAnimation{    duration: 200   } }
                    clip: true
                    sourceComponent: nextComponent
                }
                /*********************************/

                Text {
                    id: action5Text
                    text: "⏺ "+qsTr("این عمل کمتر از ۵ دقیقه انجام می‌شود") +":"
                    width: parent.width
                    color: appStyle.textColor
                    height: 50*size1H
                    verticalAlignment: Text.AlignBottom
                    font { family: appStyle.appFont; pixelSize: size1F*24;bold:true}
                    rightPadding: 50*size1W
                }

                App.RadioButton{
                    id: doRadio
                    text: qsTr("می‌خواهم این عمل را در الان انجام دهم")
                    width: parent.width
                    rightPadding: 80*size1W
                }
                Loader{
                    id: doLoader
                    active: height!==0
                    width: parent.width
                    height: doRadio.checked?120*size1W:0
                    Behavior on height { NumberAnimation{    duration: 200   } }
                    clip: true
                    sourceComponent: doComponent
                }
                /*********************************/
                /*********** انجام شدنی‌ها*****************/
            }
        }
    }

    Component{
        id: collectComponent
        Rectangle{
            radius: 15*size1W
            border.width: 2*size1W
            border.color: appStyle.borderColor
            color: "transparent"
            RowLayout{
                anchors.fill: parent
                layoutDirection: RowLayout.RightToLeft
                App.Button{
                    id:submitBtn
                    text: qsTr("بفرست به پردازش نشده ها")

                    Layout.fillWidth: true
                    Layout.rightMargin: 25*size1W
                    Layout.leftMargin: 25*size1W
                    Layout.minimumWidth: processBtn.checked?170*size1W:370*size1W
                    Layout.preferredWidth: 390*size1W
                    Layout.maximumWidth: 400*size1W
                    Layout.minimumHeight: 70*size1H
                    Layout.maximumHeight: 70*size1H

                    radius: 15*size1W
                    leftPadding: 35*size1W
                    enabled: !processBtn.checked
                    icon.source: "qrc:/check.svg"
                    icon.width: 20*size1W
                    onClicked: {
                        options["contextId"] = null
                        options["priorityId"] = null
                        options["energyId"] =null
                        options["estimateTime"] = null
                        thingsApi.prepareForAdd(thingModel,options,Memorito.Process,(attachModel.count>0?1:0));
                    }
                }// 2 is proccess list id

                Item { Layout.fillWidth: true }

                App.Button{
                    id: processBtn
                    text: qsTr("پردازش")

                    Layout.leftMargin: 25*size1W
                    Layout.rightMargin: 25*size1W
                    Layout.fillWidth: true
                    Layout.minimumWidth: 170*size1W
                    Layout.maximumWidth: 210*size1W
                    Layout.preferredWidth: 210*size1W
                    Layout.minimumHeight: 70*size1H
                    Layout.maximumHeight: 70*size1H

                    checkable: true
                    Material.accent: "transparent"
                    Material.primary: "transparent"
                    Material.background: checked ? appStyle.primaryInt :"transparent"
                    Material.foreground: checked ? "white" : appStyle.primaryInt

                    checked: isDual
                    onCheckedChanged: {
                        isDual = checked
                    }

                    radius: 10*size1W
                    leftPadding: ltr?0:35*size1W
                    rightPadding:ltr?35*size1W:0
                    Image {
                        id: processIcon
                        width: 20*size1W
                        height: width
                        source: "qrc:/arrow.svg"
                        anchors{
                            left: parent.left
                            leftMargin: 30*size1W
                            verticalCenter: parent.verticalCenter
                        }
                        sourceSize{width:width*2;height:height*2}
                        visible: false
                    }
                    ColorOverlay{
                        rotation: processBtn.checked ?(nRow===3?90
                                                               :180)
                                                     :(nRow===3?270:0)
                        anchors.fill: processIcon
                        source: processIcon
                        color: processBtn.checked ? "white" : appStyle.primaryColor
                    }
                }
            }

        }
    } //end of collectComponent

    Component{
        id:optionsComponent
        Flow{
            width: parent.width
            property alias energyInput  :   energyInput
            property alias contextInput :   contextInput
            property alias priorityInput:   priorityInput
            property alias estimateInput:   estimateInput
            Managment.ContextsApi{id: contextsApi}
            spacing: 25*size1H
            Rectangle{
                width: parent.width
                height: 130*size1H
                radius: 15*size1W
                border.width: 2*size1W
                border.color: appStyle.borderColor
                color: "transparent"
                Text {
                    id: contextText
                    text: qsTr("محل انجام") +":"
                    width: 250*size1W
                    anchors{
                        right: parent.right
                        rightMargin: 15*size1W
                        verticalCenter: parent.verticalCenter
                    }
                    color: appStyle.textColor
                    font { family: appStyle.appFont; pixelSize: size1F*30;bold:true}
                }
                App.ComboBox{
                    id: contextInput
                    anchors{
                        right: contextText.left
                        rightMargin: 15*size1W
                        left: parent.left
                        leftMargin: 15*size1W
                        bottom: contextText.bottom
                        bottomMargin: -20*size1W
                    }
                    font.pixelSize: size1F*28
                    textRole: "context_name"
                    placeholderText: qsTr("محل انجام") + " (" + qsTr("اختیاری") + ")"
                    currentIndex: prevPageModel?contextModel.count>0?prevPageModel.context_id?usefulFunc.findInModel(prevPageModel.context_id,"id",contextModel).index:-1:-1:-1
                    model: contextModel
                    onCurrentIndexChanged: {
                        options["contextId"]      = contextInput.currentIndex  === -1? null : contextModel.get (   contextInput.currentIndex    ).id
                    }

                    Component.onCompleted: {
                        contextsApi.getContexts(contextModel)
                    }
                }
            }
            Rectangle{
                width: parent.width
                height: 130*size1H
                radius: 15*size1W
                border.width: 2*size1W
                border.color: appStyle.borderColor
                color: "transparent"
                Text {
                    id: priorityText
                    text: qsTr("اولویت‌ها") +":"
                    width: 250*size1W
                    anchors{
                        right: parent.right
                        rightMargin: 15*size1W
                        verticalCenter: parent.verticalCenter
                    }
                    color: appStyle.textColor
                    font { family: appStyle.appFont; pixelSize: size1F*30;bold:true}
                }
                App.ComboBox{
                    id:priorityInput
                    anchors{
                        right: priorityText.left
                        rightMargin: 15*size1W
                        left: parent.left
                        leftMargin: 15*size1W
                        bottom: priorityText.bottom
                        bottomMargin: -20*size1W
                    }
                    textRole: "Text"
                    iconRole: "iconSource"
                    font.pixelSize: size1F*28
                    placeholderText: qsTr("اولویت") + " (" + qsTr("اختیاری") + ")"
                    currentIndex: prevPageModel?prevPageModel.priority_id?usefulFunc.findInModel(prevPageModel.priority_id,"Id",priorityModel).index:-1:-1
                    model: priorityModel
                    onCurrentIndexChanged: {
                        options["priorityId"] = priorityInput.currentIndex === -1? null : priorityModel.get( priorityInput.currentIndex ).Id
                    }
                }
            }
            Rectangle{
                width: parent.width
                height: 130*size1H
                radius: 15*size1W
                border.width: 2*size1W
                border.color: appStyle.borderColor
                color: "transparent"
                Text {
                    id: energyText
                    text: qsTr("سطح انرژی") +":"
                    width: 250*size1W
                    anchors{
                        right: parent.right
                        rightMargin: 15*size1W
                        verticalCenter: parent.verticalCenter
                    }
                    color: appStyle.textColor
                    font { family: appStyle.appFont; pixelSize: size1F*30;bold:true}
                }
                App.ComboBox{
                    id: energyInput
                    anchors{
                        right: energyText.left
                        rightMargin: 15*size1W
                        left: parent.left
                        leftMargin: 15*size1W
                        bottom: energyText.bottom
                        bottomMargin: -20*size1W
                    }
                    textRole: "Text"
                    iconRole: "iconSource"
                    font.pixelSize: size1F*28
                    placeholderText: qsTr("سطح انرژی") + " (" + qsTr("اختیاری") + ")"
                    model: energyModel
                    currentIndex: prevPageModel?prevPageModel.energy_id?usefulFunc.findInModel(prevPageModel.energy_id,"Id",energyModel).index:-1:-1
                    onCurrentIndexChanged: {
                        options["energyId"] = energyInput.currentIndex === -1? null : energyModel.get( energyInput.currentIndex ).Id
                    }
                }
            }
            Rectangle{
                width: parent.width
                height: 130*size1H
                radius: 15*size1W
                border.width: 2*size1W
                border.color: appStyle.borderColor
                color: "transparent"
                Text {
                    id: estimateText
                    text: qsTr("تخمین زمان انجام") +":"
                    anchors{
                        right: parent.right
                        rightMargin: 15*size1W
                        verticalCenter: parent.verticalCenter
                    }
                    width: 250*size1W
                    color: appStyle.textColor
                    font { family: appStyle.appFont; pixelSize: size1F*30;bold:true}
                }
                TextField{
                    id: estimateInput
                    text: prevPageModel?prevPageModel.estimate_time?prevPageModel.estimate_time:"":""
                    font{family: appStyle.appFont;pixelSize: 28*size1F}
                    selectByMouse: true
                    renderType:Text.NativeRendering
                    placeholderTextColor: appStyle.textColor
                    verticalAlignment: Text.AlignBottom
                    Material.accent: appStyle.primaryColor
                    placeholderText: qsTr("تخمین به دقیقه")  + " (" + qsTr("اختیاری") + ")"
                    horizontalAlignment: Text.AlignHCenter
                    validator: RegExpValidator{regExp: /[0123456789۰۱۲۳۴۵۶۷۸۹]{3}/ig;}
                    anchors{
                        right: estimateText.left
                        rightMargin: 15*size1W
                        left: parent.left
                        bottom: estimateText.bottom
                        leftMargin: 15*size1W
                        bottomMargin: -20*size1W
                    }
                    onTextChanged: {
                        if(text.match(/[۰۱۲۳۴۵۶۷۸۹]/ig))
                            text = usefulFunc.faToEnNumber(text)

                        options["estimateTime"] = estimateInput.text.trim() === ""? null : parseInt(   estimateInput.text.trim()    )
                    }
                }
            }

        }
    } // end of optionsComponent


    Component{
        id:projectComponent
        Rectangle {
            id: projectItem
            CategoryApi{ id: categoryApi}
            anchors{
                fill: parent
            }
            radius: 10*size1W
            color: "transparent"
            border.width: 3*size1W
            border.color: Material.hintTextColor

            App.Button{
                id: projectBtn
                width: 410*size1W
                height: 70*size1H
                checkable: true
                Material.accent: "transparent"
                Material.primary: "transparent"
                Material.background: appStyle.primaryInt

                anchors{
                    centerIn: parent
                }
                text: qsTr("ساخت پروژه جدید")
                radius: 10*size1W
                leftPadding: 35*size1W
                onClicked: {
                    if(listId === Memorito.Process)
                        categoryApi.addCategory(titleInput.text.trim(),flickTextArea.text.trim(),Memorito.Project,projectCategoryModel,2,thingModel,modelIndex)
                    else
                        categoryApi.addCategory(titleInput.text.trim(),flickTextArea.text.trim(),Memorito.Project,projectCategoryModel,1)
                }
            }
        }
    }


    Component{
        id:nextComponent
        Rectangle {
            id: nextItem
            anchors{
                fill: parent
            }
            radius: 10*size1W
            color: "transparent"
            border.width: 3*size1W
            border.color: Material.hintTextColor
            App.Button{
                id: nextBtn
                width: 410*size1W
                height: 70*size1H
                checkable: true
                Material.accent: "transparent"
                Material.primary: "transparent"
                Material.background: appStyle.primaryInt

                anchors{
                    centerIn: parent
                }
                text: prevPageModel && listId != Memorito.Process?qsTr("بروزرسانی"):qsTr("بفرست به عملیات بعدی")
                radius: 10*size1W
                leftPadding: 35*size1W
                rightPadding: 35*size1W
                onClicked: {
                    if(prevPageModel)
                        thingsApi.prepareForEdit(thingModel,nextActionModel,prevPageModel.id,options,Memorito.NextAction,(attachModel.count>0?1:0),null,null,null,null)
                    else
                        thingsApi.prepareForAdd(options,Memorito.NextAction,(attachModel.count>0?1:0),null,null,null,null);
                }
            }
        }
    }// 3 is next action list id

    Component{
        id:refrenceComponent
        Rectangle {
            id: refrenceItem
            CategoryApi{ id: categoryApi}
            width: parent.width
            anchors{
                fill: parent
            }
            radius: 10*size1W
            color: "transparent"
            border.width: 3*size1W
            border.color: Material.hintTextColor
            Text {
                id: refrenceCategoryText
                text: qsTr("دسته بندی") + ":"
                anchors{
                    right: parent.right
                    rightMargin: 20*size1W
                    top: parent.top
                    topMargin: 50*size1W
                }
                font { family: appStyle.appFont; pixelSize: size1F*30;bold:true}
                color: appStyle.textColor
            }
            App.ComboBox{
                id: refrenceCategoryCombo
                textRole: "category_name"
                font.pixelSize: size1F*28
                placeholderText: qsTr("دسته بندی")
                currentIndex: prevPageModel?
                                  refrenceCategoryModel.count>0
                                  ?prevPageModel.category_id
                                    ?usefulFunc.findInModel(prevPageModel.category_id,"id",refrenceCategoryModel).index
                                    :-1
                :-1
                :-1
                anchors{
                    top: parent.top
                    topMargin: 10*size1W
                    right: refrenceCategoryText.left
                    rightMargin: currentIndex === -1?20*size1W:50*size1W
                    left: parent.left
                    leftMargin: 20*size1W
                }
                model: refrenceCategoryModel
                Component.onCompleted: {
                    categoryApi.getCategories(refrenceCategoryModel,Memorito.Refrence) // 4= مرجع
                }
            }

            App.Button{
                id: refrenceBtn
                width: 410*size1W
                height: 70*size1H
                checkable: true
                Material.accent: "transparent"
                Material.primary: "transparent"
                Material.background: appStyle.primaryInt

                anchors{
                    top: refrenceCategoryCombo?refrenceCategoryCombo.visible?refrenceCategoryCombo.bottom:parent.top:undefined
                    topMargin: 25*size1W
                    horizontalCenter: parent.horizontalCenter
                }
                text: prevPageModel && listId != Memorito.Process?qsTr("بروزرسانی"):qsTr("بفرست به مرجع")
                radius: 10*size1W
                leftPadding: 35*size1W
                rightPadding: 35*size1W
                onClicked: {

                    let categoryId = refrenceCategoryCombo.currentIndex !== -1 ? refrenceCategoryModel.get(refrenceCategoryCombo.currentIndex).id : null
                    if(prevPageModel)
                        thingsApi.prepareForEdit(thingModel,refrenceModel,prevPageModel.id,options,Memorito.Refrence,(attachModel.count>0?1:0),categoryId);
                    else
                        thingsApi.prepareForAdd(refrenceModel,options,Memorito.Refrence,(attachModel.count>0?1:0),categoryId);
                }
            }
        }
    }// 4 is refrence list id

    Component{
        id:friendComponent
        Rectangle {
            id: friendItem
            anchors{
                fill: parent
            }
            Managment.FriendsAPI{id: friendsApi}
            radius: 10*size1W
            color: "transparent"
            border.width: 3*size1W
            border.color: Material.hintTextColor
            Text {
                id: friendCategoryText
                text: qsTr("انتخاب دوست") + ":"
                visible: friendModel.count!==0
                anchors{
                    right: parent.right
                    rightMargin: 20*size1W
                    top: parent.top
                    topMargin: 50*size1W
                }
                font { family: appStyle.appFont; pixelSize: size1F*30;bold:true}
                color: appStyle.textColor
            }
            App.ComboBox{
                id: friendCombo
                textRole: "friend_name"
                font.pixelSize: size1F*28
                placeholderText: qsTr("دوست موردنظر را انتخاب کنید")
                currentIndex: prevPageModel
                              ?friendModel.count>0
                                ?prevPageModel.friend_id
                                  ?usefulFunc.findInModel(prevPageModel.friend_id,"id",friendModel).index
                                  :-1
                :-1
                :-1
                anchors{
                    top: parent.top
                    topMargin: 10*size1W
                    right: friendCategoryText.left
                    rightMargin: currentIndex === -1?20*size1W:50*size1W
                    left: parent.left
                    leftMargin: 20*size1W
                }
                model: friendModel
                Component.onCompleted: {
                    friendsApi.getFriends(friendModel)
                }
            }

            App.Button{
                id: friendBtn
                width: 410*size1W
                height: 70*size1H
                checkable: true
                Material.accent: "transparent"
                Material.primary: "transparent"
                Material.background: appStyle.primaryInt

                anchors{
                    top: friendCombo?friendCombo.visible?friendCombo.bottom:parent.top:undefined
                    topMargin: 25*size1W
                    horizontalCenter: parent.horizontalCenter
                }
                text: prevPageModel && listId != Memorito.Process?qsTr("بروزرسانی"):qsTr("بفرست به لیست انتظار")
                radius: 10*size1W
                leftPadding: 35*size1W
                rightPadding: 35*size1W
                onClicked: {

                    if(friendCombo.currentIndex === -1)
                    {
                        if(friendModel.count >0)
                            usefulFunc.showLog(qsTr("لطفا دوست خودتو انتخاب کن"),true,null,600*size1W, ltr)
                        else
                            usefulFunc.showLog(qsTr("لطفااول دوستاتو اضافه کن بعد دوست خودتو انتخاب کن"),true,null,700*size1W, ltr)
                        return
                    }

                    let friendId = friendModel.get(friendCombo.currentIndex).id
                    if(prevPageModel)
                        thingsApi.prepareForEdit(thingModel,waitingModel,prevPageModel.id,options,Memorito.Waiting,(attachModel.count>0?1:0),null,null,friendId,null); // 5 is waiting list id
                    else
                        thingsApi.prepareForAdd(waitingModel,options,Memorito.Waiting,(attachModel.count>0?1:0),null,null,friendId,null);
                }
            }
        }
    }// 5 is waiting list id

    Component{
        id:calendarComponent
        Rectangle {
            id: calendarItem
            anchors{
                fill: parent
            }
            radius: 10*size1W
            color: "transparent"
            border.width: 3*size1W
            border.color: Material.hintTextColor
            Behavior on height {
                NumberAnimation{
                    duration: 200
                }
            }
            clip:true
            property date dueDate: prevPageModel?prevPageModel.due_date?new Date(prevPageModel.due_date):"":""
            App.CheckBox{
                id:clockCheck
                anchors{
                    left: parent.left
                    leftMargin: 20*size1W
                    top: parent.top
                    topMargin: 20*size1W
                }
                text: qsTr("تعیین ساعت")
                checked: prevPageModel?prevPageModel.due_date?!(calendarItem.dueDate.getHours() === 5 && calendarItem.dueDate.getMinutes() === 17 && calendarItem.dueDate.getSeconds() === 17):false:false
            }
            App.DateInput{
                id: dateInput
                placeholderText: qsTr("زمان مورد نظر را انتخاب نمایید")
                hasTime: clockCheck.checked
                minSelectedDate: new Date()
                selectedDate: calendarItem.dueDate
                anchors{
                    top: parent.top
                    right: clockCheck.left
                    rightMargin: 30*size1W
                    left: parent.left
                    leftMargin: 20*size1W
                }
            }

            App.Button{
                id: calendarBtn
                width: 410*size1W
                height: 70*size1H
                checkable: true
                Material.accent: "transparent"
                Material.primary: "transparent"
                Material.background: appStyle.primaryInt

                anchors{
                    top: dateInput.bottom
                    topMargin: 20*size1W
                    horizontalCenter: parent.horizontalCenter
                }
                text: prevPageModel && listId != Memorito.Process?qsTr("بروزرسانی"):qsTr("بفرست به تقویم")

                radius: 10*size1W
                leftPadding: 35*size1W
                onClicked: {

                    if( dateInput.selectedDate.toString() === "Invalid Date")
                    {
                        usefulFunc.showLog(qsTr("لطفا زمانی که میخوای این کار رو بکنی مشخص کن"),true,null,700*size1W, ltr)
                        return
                    }
                    if(!clockCheck.checked)
                    {
                        dateInput.selectedDate = new Date(dateInput.selectedDate.setHours(5));
                        dateInput.selectedDate = new Date(dateInput.selectedDate.setMinutes(17))
                        dateInput.selectedDate = new Date(dateInput.selectedDate.setSeconds(17))
                    }

                    let dueDate = usefulFunc.formatDate(dateInput.selectedDate,false)
                    if(prevPageModel)
                        thingsApi.prepareForEdit(thingModel,calendarModel,prevPageModel.id,options,Memorito.Calendar,(attachModel.count>0?1:0),null,dueDate,null,null)
                    else
                        thingsApi.prepareForAdd(calendarModel,options,Memorito.Calendar,(attachModel.count>0?1:0),null,dueDate,null,null);
                }
            }
        }
    }// 6 is calendar list id

    Component{
        id:trashComponent
        Rectangle {
            id: trashItem
            anchors{
                fill: parent
            }
            radius: 10*size1W
            color: "transparent"
            border.width: 3*size1W
            border.color: Material.hintTextColor
            App.Button{
                id: trashBtn
                width: 410*size1W
                height: 70*size1H
                checkable: true
                Material.accent: "transparent"
                Material.primary: "transparent"
                Material.background: appStyle.primaryInt

                anchors{
                    centerIn: parent
                }
                text: prevPageModel && listId != Memorito.Process?qsTr("بروزرسانی"):qsTr("بفرست به سطل آشغال")
                radius: 10*size1W
                leftPadding: 35*size1W
                rightPadding: 35*size1W
                onClicked: {
                    if(prevPageModel)
                        thingsApi.prepareForEdit(thingModel,trashModel,dprevPageModel.id,options,Memorito.Trash,(attachModel.count>0?1:0));
                    else
                        thingsApi.prepareForAdd(trashModel,options,Memorito.Trash,(attachModel.count>0?1:0));
                }
            }
        }
    }// 7 is trash list id

    Component{
        id: doComponent
        Rectangle {
            id: doItem
            anchors{
                fill: parent
            }
            radius: 10*size1W
            color: "transparent"
            border.width: 3*size1W
            border.color: Material.hintTextColor
            App.Button{
                id: doBtn
                width: 410*size1W
                height: 70*size1H
                checkable: true
                Material.accent: "transparent"
                Material.primary: "transparent"
                Material.background: appStyle.primaryInt

                anchors{
                    centerIn: parent
                }
                text: prevPageModel && listId != Memorito.Process?qsTr("بروزرسانی"):qsTr("بفرست به انجام شده ها")
                radius: 10*size1W
                leftPadding: 35*size1W
                rightPadding: 35*size1W
                onClicked: {
                    if(prevPageModel)
                        thingsApi.prepareForEdit(thingModel,doneModel,prevPageModel.id,options,Memorito.Done,(attachModel.count>0?1:0),null,null,null,null)
                    else
                        thingsApi.prepareForAdd(doneModel,options,Memorito.Done,(attachModel.count>0?1:0),null,null,null,null);
                }
            }
        }
    }// 8 is Done list id

    Component{
        id:somedayComponent
        Rectangle {
            id: somedayItem
            CategoryApi{ id: categoryApi}
            anchors{
                fill: parent
            }
            radius: 10*size1W
            color: "transparent"
            border.width: 3*size1W
            border.color: Material.hintTextColor
            Text {
                id: somedayCategoryText
                text: qsTr("دسته بندی") + ":"
                anchors{
                    right: parent.right
                    rightMargin: 20*size1W
                    top: parent.top
                    topMargin: 50*size1W
                }
                font { family: appStyle.appFont; pixelSize: size1F*30;bold:true}
                color: appStyle.textColor
            }
            App.ComboBox{
                id: somedayCategoryCombo
                textRole: "category_name"
                font.pixelSize: size1F*28
                placeholderText: qsTr("دسته بندی") + " (" + qsTr("اختیاری") + ")"
                currentIndex: prevPageModel
                              ?somedayCategoryModel.count>0
                                ?prevPageModel.category_id
                                  ?usefulFunc.findInModel(prevPageModel.category_id,"id",somedayCategoryModel).index
                                  :-1
                :-1:-1
                anchors{
                    top: parent.top
                    topMargin: 10*size1W
                    right: somedayCategoryText.left
                    rightMargin: currentIndex === -1?20*size1W:50*size1W
                    left: parent.left
                    leftMargin: 20*size1W
                }
                model: somedayCategoryModel
                Component.onCompleted: {
                    categoryApi.getCategories(somedayCategoryModel,Memorito.Someday) // 9 = شاید یک روزی
                }
            }

            App.Button{
                id: somedayBtn
                width: 410*size1W
                height: 70*size1H
                checkable: true
                Material.accent: "transparent"
                Material.primary: "transparent"
                Material.background: appStyle.primaryInt

                anchors{
                    top: somedayCategoryCombo?somedayCategoryCombo.visible?somedayCategoryCombo.bottom:parent.top:undefined
                    topMargin: 25*size1W
                    horizontalCenter: parent.horizontalCenter
                }
                text: prevPageModel && listId != Memorito.Process?qsTr("بروزرسانی"):qsTr("بفرست به شاید یک روزی")
                radius: 10*size1W
                leftPadding: 35*size1W
                rightPadding: 35*size1W
                onClicked: {
                    let categoryId = somedayCategoryCombo.currentIndex !== -1 ? somedayCategoryModel.get(somedayCategoryCombo.currentIndex).id : null
                    if(prevPageModel)
                        thingsApi.prepareForEdit(thingModel,somedayModel,prevPageModel.id,options,Memorito.Someday,(attachModel.count>0?1:0),categoryId); // 9 is someday list id
                    else
                        thingsApi.prepareForAdd(somedayModel,options,Memorito.Someday,(attachModel.count>0?1:0),categoryId);
                }
            }
        }
    }// 9 is someday list id

    Component{
        id: projectCategoryComponent
        Rectangle {
            id: projectCategoryItem
            CategoryApi{ id: categoryApi}
            anchors{
                fill: parent
            }
            radius: 10*size1W
            color: "transparent"
            border.width: 3*size1W
            border.color: Material.hintTextColor
            Text {
                id: projectCategoryText
                text: qsTr("انتخاب پروژه") + ":"
                anchors{
                    right: parent.right
                    rightMargin: 20*size1W
                    top: parent.top
                    topMargin: 50*size1W
                }
                font { family: appStyle.appFont; pixelSize: size1F*30;bold:true}
                color: appStyle.textColor
            }
            App.ComboBox{
                id: projectCategoryCombo
                textRole: "category_name"
                font.pixelSize: size1F*28
                placeholderText: qsTr("پروژه موردنظر را انتخاب کنید")
                currentIndex: prevPageModel?
                                  projectCategoryModel.count>0?prevPageModel.category_id?usefulFunc.findInModel(prevPageModel.category_id,"id",projectCategoryModel).index:-1:-1
                :categoryId !== -1?usefulFunc.findInModel(categoryId,"id",projectCategoryModel).index:-1
                anchors{
                    top: parent.top
                    topMargin: 10*size1W
                    right: projectCategoryText.left
                    rightMargin: currentIndex === -1?20*size1W:50*size1W
                    left: parent.left
                    leftMargin: 20*size1W
                }
                model: projectCategoryModel
                Component.onCompleted: {
                    categoryApi.getCategories(projectCategoryModel,Memorito.Project)
                }
            }
            App.Button{
                id: projectCategoryBtn
                width: 410*size1W
                height: 70*size1H
                checkable: true
                Material.accent: "transparent"
                Material.primary: "transparent"
                Material.background: appStyle.primaryInt

                anchors{
                    top: projectCategoryCombo.visible?projectCategoryCombo.bottom:parent.top
                    topMargin: 25*size1W
                    horizontalCenter: parent.horizontalCenter
                }
                text: prevPageModel && listId != Memorito.Process?qsTr("بروزرسانی"):qsTr("بفرست به پروژه")
                radius: 10*size1W
                leftPadding: 35*size1W
                rightPadding: 35*size1W
                onClicked: {
                    if(projectCategoryCombo.currentIndex === -1)
                    {
                        usefulFunc.showLog(qsTr("لطفا پروژه موردنظر را انتخاب کن"),true,null,600*size1W, ltr)
                        return
                    }
                    let projectId = projectCategoryCombo.currentIndex !== -1 ? projectCategoryModel.get(projectCategoryCombo.currentIndex).id : null
                    if(prevPageModel)
                        thingsApi.prepareForEdit(thingModel,projectModel,prevPageModel.id,options,Memorito.Project,(attachModel.count>0?1:0),projectId,null,null)
                    else
                        thingsApi.prepareForAdd(projectModel,options,Memorito.Project,(attachModel.count>0?1:0),projectId);
                }
            }
        }
    }// 10 is project list id

}
