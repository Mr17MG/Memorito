import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import Global 1.0
import Components 1.0

Item{
    Loader{

        id: thingsLoader

        clip: true
        active: true
        width: Math.min(parent.width-40*AppStyle.scaleW,1200*AppStyle.size1W)

        anchors{
            top: parent.top
            topMargin: 15*AppStyle.size1H
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 15*AppStyle.size1H
        }

        sourceComponent: GridView{
            id: control

            onContentYChanged: {
                if(contentY<0 || contentHeight < control.height)
                    contentY = 0

                else if(contentY > (contentHeight - control.height))
                {
                    contentY = (contentHeight - control.height)
                }
            }
            onContentXChanged: {
                if(contentX<0 || contentWidth < control.width)
                    contentX = 0
                else if(contentX > (contentWidth-control.width))
                    contentX = (contentWidth-control.width)
            }

            layoutDirection: Qt.RightToLeft
            cellHeight: 220*AppStyle.size1W
            cellWidth: width / (parseInt(width / parseInt(600*AppStyle.size1W))===0?1:(parseInt(width / parseInt(600*AppStyle.size1W))))

            delegate:Item{
                width: cellWidth
                height: cellHeight
                AppButton{
                    width:  parent.width - 20*AppStyle.size1W
                    height: parent.height- 20*AppStyle.size1H
                    anchors.centerIn: parent
                    radius: 30*AppStyle.size1W
                    Material.background: model.backColor

                    LayoutMirroring.enabled: index%2===1
                    LayoutMirroring.childrenInherit: true

                    Image{
                        id:img
                        width: height
                        height: parent.height-50*AppStyle.size1H
                        source: model.iconSrc
                        sourceSize: Qt.size(width*2,height*2)
                        anchors{
                            right: parent.right
                            rightMargin: 25*AppStyle.size1W
                            verticalCenter: parent.verticalCenter
                        }
                    }
                    Text{
                        id: titleText
                        text: model.title
                        color: model.textColor
                        horizontalAlignment: index%2 === Number(AppStyle.ltr) ? Qt.AlignRight : Qt.AlignLeft
                        font{
                            pixelSize: 30*AppStyle.size1F
                            family: AppStyle.appFont
                            bold: true
                        }
                        anchors{
                            right: img.left
                            rightMargin: 25*AppStyle.size1W
                            left: parent.left
                            leftMargin: 25*AppStyle.size1W
                            top: parent.top
                            topMargin: 25*AppStyle.size1H
                        }
                    }
                    Text{
                        text: model.detail
                        font{
                            pixelSize: 25*AppStyle.size1F
                            family: AppStyle.appFont
                        }
                        horizontalAlignment: index%2 === Number(AppStyle.ltr) ? Qt.AlignRight : Qt.AlignLeft
                        verticalAlignment: Qt.AlignTop
                        maximumLineCount: 2
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Qt.ElideRight
                        color: Qt.darker(model.textColor,0.7)
                        anchors{
                            right: img.left
                            rightMargin: 25*AppStyle.size1W
                            left: parent.left
                            leftMargin: 25*AppStyle.size1W
                            top: titleText.bottom
                            topMargin: 10*AppStyle.size1H
                            bottom: parent.bottom
                            bottomMargin: 10*AppStyle.size1H
                        }
                    }

                    onClicked: {
                        if(pageSource)
                        {
                            UsefulFunc.mainStackPush(model.pageSource,model.title,{listId:model.listId,pageTitle:model.title})
                        }
                    }

                }
            }
            model:ListModel{

                ListElement{
                    title: qsTr("خلاصه کتاب جی تی دی")
                    detail:qsTr("اگه با این روش آشنایی نداری یا بخشی ازش رو فراموش کردی حتما مطالعه کن تا بهت، تو انجام دادن چیزهات کمک کنه.")
                    iconSrc: "qrc:/homepage/book.svg"
                    backColor: "#9c27b0"
                    textColor: "#fcfcfc"
                    pageSource: "qrc:/About/AboutBook.qml"
                    listId: 0
                }
                ListElement{
                    title: qsTr("درباه‌ی مموریتو")
                    detail:qsTr("هرچیزی که لازمه درباره‌ی مموریتو بدونی")
                    iconSrc: "qrc:/homepage/memorito.svg"
                    backColor: "#e91e63"
                    textColor: "#fcfcfc"
                    pageSource: "qrc:/About/AboutApp.qml"
                    listId: 0
                }
                ListElement{
                    title: qsTr("جمع‌آوری")
                    detail:qsTr("هرچیزی که تو ذهنت داری رو اینجا خالی کن، ذهن تو فقط یک حافظه نیست پس بهتره بیشتر نقش یک پردازنده رو داشته باشه")
                    iconSrc: "qrc:/homepage/collect.svg"
                    backColor: "#7446c4"
                    textColor: "#ffffff"
                    pageSource: "qrc:/Things/AddEditThing.qml"
                    listId: Memorito.Collect
                }
                ListElement{
                    title:qsTr("پردازش نشده‌ها")
                    detail:qsTr("هرچیزی که ثبت کردی رو حالا پردازش کن ببین باید باهاشون چیکار کنی")
                    iconSrc: "qrc:/homepage/process.svg"
                    backColor: "#3f51b5"
                    textColor: "#fcfcfc"
                    pageSource: "qrc:/Things/ThingList.qml"
                    listId: Memorito.Process
                }
                ListElement{
                    title: qsTr("عملیات بعدی")
                    detail:qsTr("حالا وقت انجام دادن کارهاست")
                    iconSrc: "qrc:/homepage/nextAction.svg"
                    backColor: "#2196f3"
                    textColor: "#fcfcfc"
                    pageSource: "qrc:/Things/ThingList.qml"
                    listId: Memorito.NextAction
                }
                ListElement{
                    title:qsTr("لیست انتظار")
                    iconSrc: "qrc:/homepage/waiting.svg"
                    detail:qsTr("کاری رو به دوستت بسپار که انجام بده و بعد ازش پیگیری کن.")
                    backColor: "#03a9f4"
                    textColor: "#fcfcfc"
                    pageSource: "qrc:/Things/ThingList.qml"
                    listId: Memorito.Waiting
                }
                ListElement{
                    title:qsTr("تقویم")
                    detail:qsTr("اگه نیازه که کاری رو حتما در روز یا ساعت مشخصی انجام بدی")
                    iconSrc: "qrc:/homepage/calendar.svg"
                    backColor: "#009688"
                    textColor: "#fcfcfc"
                    pageSource: "qrc:/Things/ThingList.qml"
                    listId: Memorito.Calendar
                }
                ListElement{
                    title:qsTr("مرجع")
                    detail:qsTr("یادداشت‌های مهمی که نباید از دستشون بدی و بعدا نیازشون داری")
                    iconSrc: "qrc:/homepage/references.svg"
                    backColor: "#00bcd4"
                    textColor: "#fcfcfc"
                    pageSource: "qrc:/Categories/CategoriesList.qml"
                    listId: Memorito.Refrence
                }
                ListElement{
                    title:qsTr("شاید یک‌روزی")
                    iconSrc: "qrc:/homepage/someday.svg"
                    detail:qsTr("ایده‌ها و چیزهایی که شاید یک‌روزی رفتی سراغشون که انجام بدی")
                    backColor: "#4caf50"
                    textColor: "#fcfcfc"
                    pageSource: "qrc:/Categories/CategoriesList.qml"
                    listId: Memorito.Someday
                }
                ListElement{
                    title:qsTr("پروژه‌ها")
                    detail:qsTr("اون سری چیزهایی که نیازه چندتا چیز رو انجام بدی تا به نتیجه نهایی برسه")
                    backColor: "#8bc34a"
                    textColor: "#fcfcfc"
                    iconSrc: "qrc:/homepage/projects.svg"
                    pageSource: "qrc:/Categories/CategoriesList.qml"
                    listId: Memorito.Someday
                }
                ListElement{
                    title:qsTr("انجام شده‌ها")
                    detail:qsTr("اون چیزهایی که قبلا انجامشون دادی و تموم شده")
                    backColor: "#ffc107"
                    textColor: "#0C0C0C"
                    iconSrc: "qrc:/homepage/done.svg"
                    pageSource: "qrc:/Things/ThingList.qml"
                    listId: Memorito.Done
                }
                ListElement{
                    title:qsTr("سطل زباله")
                    detail:qsTr("چیزهایی که قبلا جمع کردی ولی دیگه بهشون احتیاج نداری")
                    backColor: "#ffd34e"
                    textColor: "#0C0C0C"
                    pageSource: "qrc:/Things/ThingList.qml"
                    iconSrc: "qrc:/homepage/trash.svg"
                    listId: Memorito.Trash
                }
                ListElement{
                    title:qsTr("محل‌های انجام")
                    detail:qsTr("وقتی باید یک چیز رو در مکان یا زمان مشخصی انجام بدی مثل وقتی که تو فروشگاهی و ...")
                    backColor: "#ffd862"
                    textColor: "#0C0C0C"
                    iconSrc: "qrc:/homepage/contexts.svg"
                    pageSource: "qrc:/Contexts/Contexts.qml"
                    listId: Memorito.Contexts
                }
                ListElement{
                    title:qsTr("دوستان")
                    detail:qsTr("لیستی از اون دوستات که باهاشون درارتباطی و بهشون چیزی رو دادی که انجام بدن")
                    backColor: "#fff389"
                    textColor: "#0C0C0C"
                    iconSrc: "qrc:/homepage/friends.svg"
                    pageSource: "qrc:/Friends/Friends.qml"
                    listId: Memorito.Friends
                }
                ListElement{
                    title: qsTr("پروفایل")
                    detail:qsTr("اطلاعات حساب کاربریت مثل نام‌کاربری، ایمیل، تغییر رمز ورود و ... ")
                    backColor: "#fff7b0"
                    textColor: "#0C0C0C"
                    iconSrc: "qrc:/homepage/profile.svg"
                    pageSource : "qrc:/Account/Profile.qml"
                }
                ListElement{
                    title: qsTr("تنظیمات")
                    detail:qsTr("هربخش از مموریتو رو با سلیقه‌ی خودت تنظیم کن ...")
                    backColor: "#fffbd6"
                    textColor: "#0C0C0C"
                    iconSrc: "qrc:/homepage/settings.svg"
                    pageSource : "qrc:/AppBase/AppSettings.qml"
                }
            }
        }
    }
}
