#ifndef FILESMODEL_H
#define FILESMODEL_H

#include <QObject>
#include "basemodel.h"

class FilesModel : public QObject, private BaseModel
{
    Q_OBJECT
    void makeTable();
public:
    explicit FilesModel();
};

#endif // FILESMODEL_H
