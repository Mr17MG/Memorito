#ifndef SECURITY_H
#define SECURITY_H

#include <QObject>
#include <QCryptographicHash> // Require for QCryptographicHash::hash

class Security
{
public:
    Security();
    QString hashPass(QString password);
};

#endif // SECURITY_H
