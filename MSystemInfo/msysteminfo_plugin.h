#ifndef MSYSTEMINFO_PLUGIN_H
#define MSYSTEMINFO_PLUGIN_H

#include <QQmlExtensionPlugin>

class MSystemInfoPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)

public:
    void registerTypes(const char *uri) override;
};

#endif // MSYSTEMINFO_PLUGIN_H
