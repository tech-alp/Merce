#include "MerceBuildInfo.h"

#include <QtGlobal>

#ifndef MERCE_VERSION
#define MERCE_VERSION "0.0.0"
#endif

#ifndef MERCE_BUILD_TYPE
#define MERCE_BUILD_TYPE "unknown"
#endif

MerceBuildInfo::MerceBuildInfo(QObject *parent)
    : QObject(parent)
{
}

QString MerceBuildInfo::version() const
{
    return QStringLiteral(MERCE_VERSION);
}

QString MerceBuildInfo::qtVersion() const
{
    return QString::fromLatin1(qVersion());
}

QString MerceBuildInfo::buildType() const
{
    return QStringLiteral(MERCE_BUILD_TYPE);
}
