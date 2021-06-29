#include "qdateconvertor_plugin.h"

#include "qdateconvertor.h"

#include <qqml.h>

void QDateConvertorPlugin::registerTypes(const char *uri)
{
    // @uri QDateConvertor
    qmlRegisterType<QDateConvertor>(uri, 1, 0, "QDateConvertor");
}

