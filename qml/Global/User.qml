pragma Singleton
import QtQuick 2.14
import MTools 1.0

QtObject{
    property ListModel users: ListModel{}
    property var myTools: MTools{}

    property int id : 0
    property int localId :0
    property int twoStep: 0

    property string email : ""
    property string username : ""
    property string authToken : ""
    property string hashedPassword : ""
    property string avatar: ""
    property string profile: ""

    property bool isSet: false
    function set(data,deleteProfile = false)
    {
        this.isSet           = false;
        this.id              = data.id??0;
        this.email           = data.email??"";
        this.localId         = data.local_id??0;
        this.username        = data.username??"";
        this.authToken       = data.auth_token??"";
        this.hashedPassword  = data.hashed_password??"";
        this.avatar          = data.avatar??"";
        this.twoStep         = data.two_step??0;
        this.isSet           = true;

        if(deleteProfile)
        {
            myTools.deleteFile("profile-"+User.id,"jpeg")
        }

        if(myTools.getPictures("profile-"+User.id))
        {
             profile = myTools.getPictures("profile-"+User.id)
        }

        else if(User.avatar.length>10)
        {
            profile= "file://" + myTools.saveBase64asFile("profile-"+User.id,"jpeg",User.avatar)
        }
        else{
            profile= "qrc:/user.svg"
        }
    }

    function clear()
    {
        this.id              = 0;
        this.email           = 0;
        this.twoStep         = 0;
        this.localId         = "";
        this.username        = "";
        this.authToken       = "";
        this.hashedPassword  = "";
        this.avatar          = "";
        this.isSet           = false;
    }
}
