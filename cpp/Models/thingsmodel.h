#ifndef THINGSMODEL_H
#define THINGSMODEL_H

#include <QObject>
#include "basemodel.h"

class ThingsModel : public QObject, private BaseModel
{
    Q_OBJECT
    void makeTable();
public:
    explicit ThingsModel();
};

#endif // THINGSMODEL_H
