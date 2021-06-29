#ifndef MSECURITY_PLUGIN_H
#define MSECURITY_PLUGIN_H

#include <QQmlExtensionPlugin>

class MSecurityPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)

public:
    void registerTypes(const char *uri) override;
};

#endif // MSECURITY_PLUGIN_H
