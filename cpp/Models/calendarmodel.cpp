#include "calendarmodel.h"

CalendarModel::CalendarModel()
{
    this->makeTable();
    this->setTableName("Calendar");
}

void CalendarModel::makeTable()
{
    QSqlQuery sqlQuery(this->db);
    QString queryStr("CREATE TABLE IF NOT EXISTS 'Calendar' ("
                     "'local_id'	INTEGER NOT NULL UNIQUE,"
                     "'server_id'	INTEGER,"
                     "'user_id'	INTEGER,"
                     "'thing_id_local'	INTEGER NOT NULL,"
                     "'thing_id_server'	INTEGER,"
                     "'due_date'	TEXT,"
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
