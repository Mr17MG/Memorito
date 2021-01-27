pragma Singleton
import QtQuick 2.14

QtObject{
    property ListModel users: ListModel{}
    property int id : 0
    property int localId :0

    property string email : ""
    property string username : ""
    property string authToken : ""
    property string hashedPassword : ""

    property bool isSet: false
    function set(data)
    {
        this.id              = data.id
        this.email           = data.email
        this.localId         = data.localId
        this.username        = data.username
        this.authToken       = data.authToken
        this.hashedPassword  = data.hashedPassword
        this.isSet           = true
    }
    function clear()
    {
        this.id              = 0
        this.email           = 0
        this.localId         = ""
        this.username        = ""
        this.authToken       = ""
        this.hashedPassword  = ""
        this.isSet           = false
    }
}
