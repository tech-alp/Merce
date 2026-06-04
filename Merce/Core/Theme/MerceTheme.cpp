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
      m_palette(new MercePalette(this)),
      m_spacing(new MerceSpacing(this)),
      m_radius(new MerceRadius(this)),
      m_typography(new MerceTypography(this)),
      m_motion(new MerceMotion(this)),
      m_icons(new MerceIconography(this)),
      m_zIndex(new MerceZIndex(this)),
      m_breakpoints(new MerceBreakpoints(this)),
      m_shadows(new MerceShadows(this))
{
    const MerceThemeLoadResult theme = MerceThemeManifestLoader().loadDefault();
    if (!theme.ok) {
        for (const QString &error : theme.errors)
            qCWarning(merceThemeLog) << "default manifest load failed:" << error;
        return;
    }

    const QJsonObject manifest = theme.finalManifest;
    m_palette->applyManifestSection(manifest.value(QStringLiteral("palette")).toObject());
    m_spacing->applyManifestSection(manifest.value(QStringLiteral("spacing")).toObject());
    m_radius->applyManifestSection(manifest.value(QStringLiteral("radius")).toObject());
    m_typography->applyManifestSection(manifest.value(QStringLiteral("typography")).toObject());

    emit paletteChanged();
    emit spacingChanged();
    emit radiusChanged();
    emit typographyChanged();
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
    Q_UNUSED(brand)
    Q_UNUSED(mode)
    qCWarning(merceThemeLog) << "runtime theme switch failed: runtime switching is not initialized";
    return false;
}
