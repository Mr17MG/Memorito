#include "filesmodel.h"

FilesModel::FilesModel()
{
    this->makeTable();
    this->setTableName("Files");
}

void FilesModel::makeTable()
{
    QSqlQuery sqlQuery(this->db);
    QString queryStr("CREATE TABLE IF NOT EXISTS 'Files' ("
                     "'local_id'	INTEGER NOT NULL UNIQUE,"
                     "'server_id'	INTEGER,"
                     "'user_id'	INTEGER,"
                     "'thing_id_local'	INTEGER NOT NULL,"
                     "'thing_id_server'	INTEGER,"
                     "'file'	TEXT NOT NULL,"
                     "'file_name'	TEXT NOT NULL,"
                     "'file_extension'	TEXT NOT NULL,"
                     "'register_date'	INTEGER NOT NULL DEFAULT CURRENT_TIMESTAMP,"
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
