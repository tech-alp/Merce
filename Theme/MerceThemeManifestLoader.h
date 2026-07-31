#pragma once

#include "MerceThemeManifest.h"
#include "MerceThemeRegistry.h"

#include <QString>
#include <QStringList>
#include <QVariantList>

struct MerceThemeRegistryLoadResult
{
    bool ok = false;
    MerceThemeRegistry colorRegistry;
    MerceProfileRegistry profileRegistry;
    QStringList errors;
};

class MerceThemeManifestLoader
{
public:
    explicit MerceThemeManifestLoader(
        QString indexPath = QStringLiteral(":/merce/themes/index.json"));

    MerceThemeLoadResult loadDefault() const;
    MerceThemeLoadResult load(const QString &brandId,
                              const QString &mode = QString(),
                              const QString &profile = QString()) const;
    QVariantList availableThemes() const;
    QVariantList availableProfiles() const;

    static MerceThemeRegistryLoadResult loadRegistry(const QString &sourcePath);
    static MerceThemeRegistryLoadResult loadMergedRegistry(const QStringList &sourcePaths);
    static MerceThemeLoadResult loadDefaultFromRegistries(
        const MerceThemeRegistry &colorRegistry,
        const MerceProfileRegistry &profileRegistry);
    static MerceThemeLoadResult loadFromRegistries(
        const MerceThemeRegistry &colorRegistry,
        const MerceProfileRegistry &profileRegistry,
        const QString &brandId,
        const QString &mode = QString(),
        const QString &profile = QString());
    static QVariantList availableThemesForRegistry(const MerceThemeRegistry &registry);
    static QVariantList availableProfilesForRegistry(const MerceProfileRegistry &registry);

private:
    QString m_indexPath;
};
