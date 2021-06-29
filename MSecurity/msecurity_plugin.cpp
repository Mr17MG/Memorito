#include "msecurity_plugin.h"

#include "msecurity.h"

#include <qqml.h>

void MSecurityPlugin::registerTypes(const char *uri)
{
    // @uri MSecurity
    qmlRegisterType<MSecurity>(uri, 1, 0, "MSecurity");
}

