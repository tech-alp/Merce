#include "MerceThemeRegistry.h"

#include <QDir>
#include <QFileInfo>
#include <QJsonValue>

namespace {

constexpr qsizetype kMaxRegistryEntries = 256;

bool isSafeFileName(const QString &fileName)
{
    return !fileName.isEmpty()
        && !QDir::isAbsolutePath(fileName)
        && !fileName.startsWith(QLatin1Char(':'))
        && !fileName.contains(QLatin1Char('/'))
        && !fileName.contains(QLatin1Char('\\'))
        && !fileName.contains(QStringLiteral(".."));
}

QString resolvedThemePath(const QString &indexPath, const QString &fileName)
{
    return QDir::cleanPath(QFileInfo(indexPath).path() + QLatin1Char('/') + fileName);
}

QString resolvedProfilePath(const QString &indexPath, const QString &fileName)
{
    return QDir::cleanPath(QFileInfo(indexPath).path()
                           + QStringLiteral("/../profiles/") + fileName);
}

bool hasThemeEntry(const QList<MerceThemeRegistryEntry> &entries,
                   const QString &brandId,
                   const QString &mode)
{
    for (const auto &entry : entries) {
        if (entry.brandId == brandId && entry.mode == mode)
            return true;
    }
    return false;
}

bool hasProfileEntry(const QList<MerceProfileRegistryEntry> &entries,
                     const QString &profileId)
{
    for (const auto &entry : entries) {
        if (entry.profileId == profileId)
            return true;
    }
    return false;
}

} // namespace

MerceThemeRegistryResult MerceThemeRegistry::fromJson(const QJsonObject &index,
                                                      const QString &indexPath)
{
    MerceThemeRegistryResult result;

    const QJsonValue defaultBrandValue = index.value(QStringLiteral("defaultBrand"));
    if (defaultBrandValue.isString())
        result.registry.m_defaultBrand = defaultBrandValue.toString();

    const QJsonValue brandsValue = index.value(QStringLiteral("brands"));
    if (brandsValue.isUndefined()) {
        result.ok = true;
        return result;
    }
    if (!brandsValue.isObject() || brandsValue.toObject().isEmpty()) {
        result.errors.append(QStringLiteral("theme index brands must be a non-empty object"));
        return result;
    }

    const QJsonObject brands = brandsValue.toObject();
    for (const QString &brandId : brands.keys()) {
        const QJsonValue brandValue = brands.value(brandId);
        if (brandId.isEmpty() || !brandValue.isObject()) {
            result.errors.append(QStringLiteral("brand entries require a non-empty id and object value"));
            continue;
        }

        const QJsonObject brand = brandValue.toObject();
        const QString displayName = brand.value(QStringLiteral("displayName")).toString(brandId);
        const QString defaultMode = brand.value(QStringLiteral("defaultMode")).toString();
        const QJsonValue modesValue = brand.value(QStringLiteral("modes"));
        if (defaultMode.isEmpty() || !modesValue.isObject() || modesValue.toObject().isEmpty()) {
            result.errors.append(QStringLiteral("brand '%1' requires defaultMode and modes").arg(brandId));
            continue;
        }

        const QJsonObject modes = modesValue.toObject();
        if (!modes.contains(defaultMode)) {
            result.errors.append(QStringLiteral("brand '%1' defaultMode '%2' is not registered")
                                     .arg(brandId, defaultMode));
        }
        result.registry.m_defaultModesByBrand.insert(brandId, defaultMode);
        if (brandId == result.registry.m_defaultBrand)
            result.registry.m_defaultMode = defaultMode;

        for (const QString &mode : modes.keys()) {
            if (result.registry.m_entries.size() >= kMaxRegistryEntries) {
                result.errors.append(QStringLiteral("theme index exceeds 256 brand/mode entries"));
                break;
            }
            const QJsonValue pathValue = modes.value(mode);
            if (mode.isEmpty() || !pathValue.isString()
                || !isSafeFileName(pathValue.toString())) {
                result.errors.append(QStringLiteral("brand '%1' mode '%2' has an unsafe manifest path")
                                         .arg(brandId, mode));
                continue;
            }
            result.registry.m_entries.push_back({
                brandId,
                displayName,
                mode,
                resolvedThemePath(indexPath, pathValue.toString()),
                MerceThemeSourceKind::ResolvedTheme,
            });
        }
    }

    if (!result.registry.m_defaultBrand.isEmpty()
        && !result.registry.lookup(result.registry.m_defaultBrand).ok) {
        result.errors.append(QStringLiteral("defaultBrand '%1' is not registered")
                                 .arg(result.registry.m_defaultBrand));
    }

    result.ok = result.errors.isEmpty();
    return result;
}

MerceThemeRegistryResult MerceThemeRegistry::fromTenantBrand(const QJsonObject &document,
                                                             const QString &documentPath)
{
    MerceThemeRegistryResult result;
    const QString brandId = document.value(QStringLiteral("brandId")).toString();
    if (brandId.isEmpty()) {
        result.errors.append(QStringLiteral("tenant brand requires a non-empty brandId"));
        return result;
    }

    result.registry.m_defaultBrand = brandId;
    result.registry.m_defaultMode = QStringLiteral("light");
    result.registry.m_defaultModesByBrand.insert(brandId, QStringLiteral("light"));
    result.registry.m_entries = {
        {brandId,
         brandId,
         QStringLiteral("light"),
         documentPath,
         MerceThemeSourceKind::TenantBrand},
        {brandId,
         brandId,
         QStringLiteral("dark"),
         documentPath,
         MerceThemeSourceKind::TenantBrand},
    };
    result.ok = true;
    return result;
}

MerceThemeRegistryLookupResult MerceThemeRegistry::lookup(const QString &brandId,
                                                          const QString &mode) const
{
    MerceThemeRegistryLookupResult result;
    const QString effectiveMode = mode.isEmpty() ? defaultModeForBrand(brandId) : mode;

    for (const auto &entry : m_entries) {
        if (entry.brandId == brandId && entry.mode == effectiveMode) {
            result.ok = true;
            result.entry = entry;
            return result;
        }
    }

    bool foundBrand = false;
    for (const auto &entry : m_entries)
        foundBrand = foundBrand || entry.brandId == brandId;

    if (!foundBrand) {
        result.errors.append(QStringLiteral("brand '%1' is not registered").arg(brandId));
        return result;
    }

    // A brand that ships only one mode is normal — most tenant brands do — so
    // asking a light-only brand for dark is a request the registry can honour
    // rather than refuse. Refusing costs more than the wrong mode does: the
    // caller loads theme and device profile together, so a rejected lookup
    // takes the touch-target sizes down with the colours. The resolved mode is
    // reported back in the entry, which is how a caller notices the fallback.
    const QString brandDefault = defaultModeForBrand(brandId);
    for (const auto &entry : m_entries) {
        if (entry.brandId == brandId && entry.mode == brandDefault) {
            result.ok = true;
            result.entry = entry;
            return result;
        }
    }

    result.errors.append(QStringLiteral("mode '%1' is not registered for brand '%2'")
                             .arg(effectiveMode, brandId));
    return result;
}

MerceThemeRegistryLookupResult MerceThemeRegistry::defaultEntry() const
{
    return lookup(m_defaultBrand, m_defaultMode);
}

bool MerceThemeRegistry::appendRegistry(const MerceThemeRegistry &registry,
                                        QStringList *errors)
{
    bool ok = true;
    for (const auto &entry : registry.m_entries) {
        if (!hasThemeEntry(m_entries, entry.brandId, entry.mode))
            continue;
        if (errors) {
            errors->append(QStringLiteral("duplicate brand/mode '%1/%2'")
                               .arg(entry.brandId, entry.mode));
        }
        ok = false;
    }
    if (!ok)
        return false;

    if (m_entries.size() + registry.m_entries.size() > kMaxRegistryEntries) {
        if (errors)
            errors->append(QStringLiteral("theme registry exceeds 256 brand/mode entries"));
        return false;
    }
    m_entries += registry.m_entries;
    for (auto it = registry.m_defaultModesByBrand.cbegin();
         it != registry.m_defaultModesByBrand.cend();
         ++it) {
        if (!m_defaultModesByBrand.contains(it.key()))
            m_defaultModesByBrand.insert(it.key(), it.value());
    }
    return true;
}

MerceProfileRegistryResult MerceProfileRegistry::fromJson(const QJsonObject &index,
                                                          const QString &indexPath)
{
    MerceProfileRegistryResult result;
    const QJsonValue defaultProfileValue = index.value(QStringLiteral("defaultProfile"));
    if (defaultProfileValue.isString())
        result.registry.m_defaultProfile = defaultProfileValue.toString();

    const QJsonValue profilesValue = index.value(QStringLiteral("profiles"));
    if (profilesValue.isUndefined()) {
        result.ok = true;
        return result;
    }
    if (!profilesValue.isObject() || profilesValue.toObject().isEmpty()) {
        result.errors.append(QStringLiteral("theme index profiles must be a non-empty object"));
        return result;
    }

    const QJsonObject profiles = profilesValue.toObject();
    for (const QString &profileId : profiles.keys()) {
        if (result.registry.m_entries.size() >= kMaxRegistryEntries) {
            result.errors.append(QStringLiteral("theme index exceeds 256 profile entries"));
            break;
        }
        const QJsonValue profileValue = profiles.value(profileId);
        if (profileId.isEmpty() || !profileValue.isObject()) {
            result.errors.append(QStringLiteral("profile entries require a non-empty id and object value"));
            continue;
        }

        const QJsonObject profile = profileValue.toObject();
        const QJsonValue pathValue = profile.value(QStringLiteral("path"));
        if (!pathValue.isString() || !isSafeFileName(pathValue.toString())) {
            result.errors.append(QStringLiteral("profile '%1' has an unsafe manifest path")
                                     .arg(profileId));
            continue;
        }
        result.registry.m_entries.push_back({
            profileId,
            profile.value(QStringLiteral("displayName")).toString(profileId),
            resolvedProfilePath(indexPath, pathValue.toString()),
        });
    }

    if (!result.registry.m_defaultProfile.isEmpty()
        && !hasProfileEntry(result.registry.m_entries, result.registry.m_defaultProfile)) {
        result.errors.append(QStringLiteral("defaultProfile '%1' is not registered")
                                 .arg(result.registry.m_defaultProfile));
    }

    result.ok = result.errors.isEmpty();
    return result;
}

MerceProfileRegistryLookupResult MerceProfileRegistry::lookup(const QString &profileId) const
{
    MerceProfileRegistryLookupResult result;
    for (const auto &entry : m_entries) {
        if (entry.profileId == profileId) {
            result.ok = true;
            result.entry = entry;
            return result;
        }
    }
    result.errors.append(QStringLiteral("profile '%1' is not registered").arg(profileId));
    return result;
}

MerceProfileRegistryLookupResult MerceProfileRegistry::defaultEntry() const
{
    return lookup(m_defaultProfile);
}

bool MerceProfileRegistry::appendRegistry(const MerceProfileRegistry &registry,
                                          QStringList *errors)
{
    bool ok = true;
    for (const auto &entry : registry.m_entries) {
        if (!hasProfileEntry(m_entries, entry.profileId))
            continue;
        if (errors)
            errors->append(QStringLiteral("duplicate profile '%1'").arg(entry.profileId));
        ok = false;
    }
    if (!ok)
        return false;

    if (m_entries.size() + registry.m_entries.size() > kMaxRegistryEntries) {
        if (errors)
            errors->append(QStringLiteral("profile registry exceeds 256 entries"));
        return false;
    }
    m_entries += registry.m_entries;
    return true;
}
