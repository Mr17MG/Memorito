#include "qcustomdate_plugin.h"

#include "qcustomdate.h"

#include <qqml.h>

void QCustomDatePlugin::registerTypes(const char *uri)
{
    // @uri QCustomDate
    qmlRegisterType<QCustomDate>(uri, 1, 0, "QCustomDate");
}

