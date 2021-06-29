#ifndef QDATECONVERTOR_PLUGIN_H
#define QDATECONVERTOR_PLUGIN_H

#include <QQmlExtensionPlugin>

class QDateConvertorPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)

public:
    void registerTypes(const char *uri) override;
};

#endif // QDATECONVERTOR_PLUGIN_H
