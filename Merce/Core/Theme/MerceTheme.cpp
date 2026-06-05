#include "MerceTheme.h"

#include "MerceThemeManifestLoader.h"

#include <QJsonObject>
#include <QJsonValue>
#include <QLoggingCategory>

Q_LOGGING_CATEGORY(merceThemeLog, "merce.theme")

MerceTheme::MerceTheme(QObject *parent)
    : MerceTheme(QStringLiteral(":/merce/themes/index.json"), parent)
{
}

MerceTheme::MerceTheme(const QString &manifestIndexPath, QObject *parent)
    : QObject(parent),
      m_manifestIndexPath(manifestIndexPath),
      m_colors(new MerceColors(this)),
      m_spacing(new MerceSpacing(this)),
      m_radius(new MerceRadius(this)),
      m_typography(new MerceTypography(this)),
      m_motion(new MerceMotion(this)),
      m_icons(new MerceIconography(this)),
      m_zIndex(new MerceZIndex(this)),
      m_breakpoints(new MerceBreakpoints(this)),
      m_shadows(new MerceShadows(this))
{
    const MerceThemeManifestLoader loader(m_manifestIndexPath);
    m_availableThemes = loader.availableThemes();

    const MerceThemeLoadResult theme = loader.loadDefault();
    if (!theme.ok) {
        for (const QString &error : theme.errors)
            qCWarning(merceThemeLog) << "default manifest load failed:" << error;
        return;
    }

    applyLoadedTheme(theme);
}

QString MerceTheme::activeBrand() const
{
    return m_activeBrand;
}

QString MerceTheme::activeMode() const
{
    return m_activeMode;
}

bool MerceTheme::setTheme(const QString &brand, const QString &mode)
{
    const MerceThemeLoadResult theme = MerceThemeManifestLoader(m_manifestIndexPath).load(brand, mode);
    if (!theme.ok) {
        for (const QString &error : theme.errors)
            qCWarning(merceThemeLog) << "runtime theme switch failed:" << error;
        return false;
    }

    return applyLoadedTheme(theme);
}

bool MerceTheme::applyLoadedTheme(const MerceThemeLoadResult &result)
{
    if (!result.ok)
        return false;

    const QJsonObject manifest = result.finalManifest;
    m_colors->applyManifestSection(manifest.value(QStringLiteral("colors")).toObject());
    m_spacing->applyManifestSection(manifest.value(QStringLiteral("spacing")).toObject());
    m_radius->applyManifestSection(manifest.value(QStringLiteral("radius")).toObject());
    m_typography->applyManifestSection(manifest.value(QStringLiteral("typography")).toObject());
    setActiveThemeState(result.theme, result.variant);
    return true;
}

void MerceTheme::setActiveThemeState(const QString &brand, const QString &mode)
{
    if (m_activeBrand == brand && m_activeMode == mode)
        return;

    m_activeBrand = brand;
    m_activeMode = mode;
    emit activeThemeChanged();
}
