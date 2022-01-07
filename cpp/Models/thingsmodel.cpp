#include "thingsmodel.h"

ThingsModel::ThingsModel()
{
    this->makeTable();
    this->setTableName("Things");
}

void ThingsModel::makeTable()
{
    QSqlQuery sqlQuery(this->db);
    QString queryStr("CREATE TABLE IF NOT EXISTS 'Things'  ("
                     "'local_id'	INTEGER NOT NULL UNIQUE,"
                     "'server_id'	INTEGER UNIQUE,"
                     "'title'	TEXT NOT NULL,"
                     "'detail'	TEXT,"
                     "'user_id'	INTEGER NOT NULL,"
                     "'type_id'	INTEGER DEFAULT 1 CHECK(type_id IN (1,2)),"
                     "'parent_id_server'	INTEGER DEFAULT NULL,"
                     "'parent_id_local'	INTEGER DEFAULT NULL,"
                     "'status'	INTEGER DEFAULT 1 CHECK(status IN (1,2,3,4,5)),"
                     "'display_type'	INTEGER DEFAULT 0 CHECK(display_type IN (0,1,2)),"
                     "'context_id_local'	INTEGER DEFAULT NULL,"
                     "'context_id_server'	INTEGER DEFAULT NULL,"
                     "'priority_id'	INTEGER DEFAULT NULL CHECK(priority_id IN (1,2,3,4)),"
                     "'energy_id'	INTEGER DEFAULT NULL CHECK(energy_id IN (1,2,3,4)),"
                     "'estimated_time'	INTEGER DEFAULT NULL,"
                     "'register_date'	TEXT DEFAULT CURRENT_TIMESTAMP,"
                     "'modified_date'	TEXT,"
                     "PRIMARY KEY('local_id' AUTOINCREMENT)"
                     ");"
                     );

    sqlQuery.prepare(queryStr);
    if(sqlQuery.exec() != true)
    {
        QSqlError error = sqlQuery.lastError();
        emit logger->warningLog(error.text());
    }
}
