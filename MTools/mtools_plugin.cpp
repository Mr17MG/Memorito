#include "mtools_plugin.h"

#include "mtools.h"

#include <qqml.h>

void MToolsPlugin::registerTypes(const char *uri)
{
    // @uri MTools
    qmlRegisterType<MTools>(uri, 1, 0, "MTools");
}

