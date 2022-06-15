#include "security.h"

Security::Security()
{

}

QString Security::hashPass(QString password)
{
    QString salt = "evPtvtFGjVCGNak3";
    password+=salt;
    QByteArray bytePassword(password.toUtf8());
    QString hashedPass = QString(QCryptographicHash::hash(bytePassword,QCryptographicHash::Sha3_512).toHex());
    return hashedPass;
}
