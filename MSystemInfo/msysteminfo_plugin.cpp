#include "msysteminfo_plugin.h"

#include "msysinfo.h"

#include <qqml.h>

void MSystemInfoPlugin::registerTypes(const char *uri)
{
    // @uri MSysInfo
    qmlRegisterType<MSysInfo>(uri, 1, 0, "MSysInfo");
}

