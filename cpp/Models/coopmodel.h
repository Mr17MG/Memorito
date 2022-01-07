#ifndef COOPMODEL_H
#define COOPMODEL_H

#include <QObject>
#include "basemodel.h"

class CoopModel : public QObject, private BaseModel
{
    Q_OBJECT
    void makeTable();
public:
    explicit CoopModel();
};

#endif // COOPMODEL_H
