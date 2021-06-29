#ifndef QCUSTOMDATE_PLUGIN_H
#define QCUSTOMDATE_PLUGIN_H

#include <QQmlExtensionPlugin>

class QCustomDatePlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)

public:
    void registerTypes(const char *uri) override;
};

#endif // QCUSTOMDATE_PLUGIN_H
