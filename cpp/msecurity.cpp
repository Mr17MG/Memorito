#include "msecurity.h"

MSecurity::MSecurity(QObject *parent) : QObject(parent)
{

}

QString MSecurity::hashPass(QString password)
{
    QString salt = "I need to immigrate to Europe";
    password+=salt;
    QByteArray bytePassword(password.toLatin1());
    QString hashedPass = QString(QCryptographicHash::hash(bytePassword,QCryptographicHash::Sha3_512).toHex());
    return hashedPass;
}
