#ifndef MSECURITY_H
#define MSECURITY_H

#include <QQuickItem>
#include <QCryptographicHash> // Require for QCryptographicHash::hash

class MSecurity : public QQuickItem
{
    Q_OBJECT
    Q_DISABLE_COPY(MSecurity)

public:
    explicit MSecurity(QQuickItem *parent = nullptr);
    ~MSecurity() override;
    Q_INVOKABLE QString hashPass(QString password);
};

#endif // MSECURITY_H
