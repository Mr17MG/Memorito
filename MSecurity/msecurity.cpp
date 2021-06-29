#include "msecurity.h"

MSecurity::MSecurity(QQuickItem *parent)
    : QQuickItem(parent)
{
    // By default, QQuickItem does not draw anything. If you subclass
    // QQuickItem to create a visual item, you will need to uncomment the
    // following line and re-implement updatePaintNode()

    // setFlag(ItemHasContents, true);
}

MSecurity::~MSecurity()
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
