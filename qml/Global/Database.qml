pragma Singleton
import QtQuick 2.14
import QtQuick.LocalStorage 2.14

QtObject {
    readonly property var connection: LocalStorage.openDatabaseSync("Memorito_database","1.0","a GTD based Project",10000)
}
