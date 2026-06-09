#include "MercePlatformCapabilities.h"

#include <QCoreApplication>
#include <QGuiApplication>
#include <QScreen>

MercePlatformCapabilities::MercePlatformCapabilities(QObject *parent)
    : QObject(parent)
{
    if (auto *app = qobject_cast<QGuiApplication *>(QCoreApplication::instance())) {
        connect(app, &QGuiApplication::primaryScreenChanged,
                this, &MercePlatformCapabilities::changed);
    }
}

QString MercePlatformCapabilities::name() const
{
    return QGuiApplication::platformName();
}

bool MercePlatformCapabilities::offscreen() const
{
    return name() == QStringLiteral("offscreen");
}

bool MercePlatformCapabilities::hasPrimaryScreen() const
{
    return QGuiApplication::primaryScreen() != nullptr;
}

qreal MercePlatformCapabilities::devicePixelRatio() const
{
    const QScreen *screen = QGuiApplication::primaryScreen();
    return screen ? screen->devicePixelRatio() : 1.0;
}
