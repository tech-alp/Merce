#include "MerceModuleRegistry.h"

#include <QVariantMap>

MerceModuleRegistry::MerceModuleRegistry(QObject *parent)
    : QObject(parent)
{
    registerModule(QStringLiteral("Merce.Core"));
}

QVariantList MerceModuleRegistry::modules() const
{
    QVariantList result;
    result.reserve(m_modules.size());

    for (const ModuleEntry &module : m_modules) {
        QVariantMap item;
        item.insert(QStringLiteral("uri"), module.uri);
        item.insert(QStringLiteral("version"), module.version);
        result.append(item);
    }

    return result;
}

bool MerceModuleRegistry::hasModule(const QString &uri) const
{
    const QString normalizedUri = uri.trimmed();
    for (const ModuleEntry &module : m_modules) {
        if (module.uri == normalizedUri)
            return true;
    }
    return false;
}

bool MerceModuleRegistry::registerModule(const QString &uri, const QString &version)
{
    const QString normalizedUri = uri.trimmed();
    if (normalizedUri.isEmpty())
        return false;

    for (ModuleEntry &module : m_modules) {
        if (module.uri == normalizedUri) {
            const QString normalizedVersion = version.trimmed();
            if (module.version == normalizedVersion)
                return true;

            module.version = normalizedVersion;
            emit modulesChanged();
            return true;
        }
    }

    m_modules.append({ normalizedUri, version.trimmed() });
    emit modulesChanged();
    return true;
}
