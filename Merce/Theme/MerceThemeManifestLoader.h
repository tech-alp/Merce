#pragma once

#include "MerceThemeManifest.h"
#include "MerceThemeRegistry.h"

#include <QString>
#include <QStringList>
#include <QVariantList>

struct MerceThemeRegistryLoadResult
{
    bool ok = false;
    MerceThemeRegistry registry;
    QStringList errors;
};

class MerceThemeManifestLoader
{
public:
    explicit MerceThemeManifestLoader(QString indexPath = QStringLiteral(":/merce/themes/index.json"));

    MerceThemeLoadResult loadDefault() const;
    MerceThemeLoadResult load(const QString &theme, const QString &variant = QString()) const;
    QVariantList availableThemes() const;

    static MerceThemeRegistryLoadResult loadRegistry(const QString &indexPath);
    static MerceThemeRegistryLoadResult loadMergedRegistry(const QStringList &indexPaths);
    static MerceThemeLoadResult loadDefaultFromRegistry(const MerceThemeRegistry &registry);
    static MerceThemeLoadResult loadFromRegistry(const MerceThemeRegistry &registry,
                                                 const QString &theme,
                                                 const QString &variant = QString());
    static QVariantList availableThemesForRegistry(const MerceThemeRegistry &registry);

private:
    QString m_indexPath;
};
