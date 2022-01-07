#ifndef CALENDARMODEL_H
#define CALENDARMODEL_H

#include <QObject>
#include "basemodel.h"

class CalendarModel : public QObject, private BaseModel
{
    Q_OBJECT
    void makeTable();
public:
    explicit CalendarModel();
};

#endif // CALENDARMODEL_H
