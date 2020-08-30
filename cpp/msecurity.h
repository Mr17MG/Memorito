#ifndef MSECURITY_H
#define MSECURITY_H

#include <QObject>
#include <QCryptographicHash> // Require for QCryptographicHash::hash

class MSecurity : public QObject
{
    Q_OBJECT
public:
    explicit MSecurity(QObject *parent = nullptr);
    Q_INVOKABLE QString hashPass(QString password);

signals:

};

#endif // MSECURITY_H
