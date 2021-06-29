#ifndef MTOOLS_PLUGIN_H
#define MTOOLS_PLUGIN_H

#include <QQmlExtensionPlugin>

class MToolsPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)

public:
    void registerTypes(const char *uri) override;
};

#endif // MTOOLS_PLUGIN_H
