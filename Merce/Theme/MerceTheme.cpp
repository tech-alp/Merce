#include "MerceTheme.h"

#include "MerceThemeManifestLoader.h"

#include <QFileInfo>
#include <QJsonObject>
#include <QJsonValue>
#include <QLoggingCategory>

Q_LOGGING_CATEGORY(merceThemeLog, "merce.theme")

namespace {

bool isLocalThemeSourcePath(const QString &path)
{
    const QString trimmed = path.trimmed();
    const QString lower = trimmed.toLower();
    return !trimmed.isEmpty()
        && !trimmed.startsWith(QLatin1Char(':'))
        && !lower.startsWith(QStringLiteral("qrc:"))
        && !lower.startsWith(QStringLiteral("http://"))
        && !lower.startsWith(QStringLiteral("https://"));
}

QString normalizedLocalThemeSourcePath(const QString &path)
{
    return QFileInfo(path.trimmed()).absoluteFilePath();
}

void logThemeErrors(const QString &prefix, const QStringList &errors)
{
    for (const QString &error : errors)
        qCWarning(merceThemeLog) << prefix << error;
}

} // namespace

MerceTheme::MerceTheme(QObject *parent)
    : MerceTheme(QStringLiteral(":/merce/themes/index.json"), parent)
{
}

MerceTheme::MerceTheme(const QString &manifestIndexPath, QObject *parent)
    : QObject(parent),
      m_builtinManifestIndexPath(manifestIndexPath),
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
    if (!reloadThemesInternal(false))
        return;

    const MerceThemeLoadResult theme = MerceThemeManifestLoader::loadDefaultFromRegistry(m_registry);
    if (!theme.ok) {
        logThemeErrors(QStringLiteral("default manifest load failed:"), theme.errors);
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
    const MerceThemeLoadResult theme = MerceThemeManifestLoader::loadFromRegistry(m_registry, brand, mode);
    if (!theme.ok) {
        logThemeErrors(QStringLiteral("runtime theme switch failed:"), theme.errors);
        return false;
    }

    return applyLoadedTheme(theme);
}

bool MerceTheme::addThemeSource(const QString &indexPath)
{
    if (!isLocalThemeSourcePath(indexPath)) {
        qCWarning(merceThemeLog) << "external theme source path must be a local filesystem path:" << indexPath;
        return false;
    }

    const QString normalizedPath = normalizedLocalThemeSourcePath(indexPath);
    if (!m_externalThemeSourcePaths.contains(normalizedPath))
        m_externalThemeSourcePaths.append(normalizedPath);
    return true;
}

void MerceTheme::clearThemeSources()
{
    if (m_externalThemeSourcePaths.isEmpty())
        return;

    m_externalThemeSourcePaths.clear();
    if (!reloadThemesInternal(true))
        qCWarning(merceThemeLog) << "failed to reload built-in theme registry after clearing external sources";
}

bool MerceTheme::reloadThemes()
{
    return reloadThemesInternal(true);
}

bool MerceTheme::reloadThemesInternal(bool emitAvailableThemesChanged)
{
    QStringList indexPaths;
    indexPaths.append(m_builtinManifestIndexPath);
    indexPaths.append(m_externalThemeSourcePaths);

    const MerceThemeRegistryLoadResult registry = m_externalThemeSourcePaths.isEmpty()
        ? MerceThemeManifestLoader::loadRegistry(m_builtinManifestIndexPath)
        : MerceThemeManifestLoader::loadMergedRegistry(indexPaths);
    if (!registry.ok) {
        logThemeErrors(QStringLiteral("theme source reload failed:"), registry.errors);
        return false;
    }

    MerceThemeLoadResult nextActiveTheme;
    const bool hasActiveTheme = !m_activeBrand.isEmpty();
    if (hasActiveTheme) {
        if (registry.registry.lookup(m_activeBrand, m_activeMode).ok) {
            nextActiveTheme = MerceThemeManifestLoader::loadFromRegistry(registry.registry,
                                                                         m_activeBrand,
                                                                         m_activeMode);
        } else {
            nextActiveTheme = MerceThemeManifestLoader::loadDefaultFromRegistry(registry.registry);
        }

        if (!nextActiveTheme.ok) {
            logThemeErrors(QStringLiteral("active theme reload failed:"), nextActiveTheme.errors);
            return false;
        }
    }

    const QVariantList nextAvailableThemes =
        MerceThemeManifestLoader::availableThemesForRegistry(registry.registry);
    const bool availableThemesDidChange = m_availableThemes != nextAvailableThemes;

    m_registry = registry.registry;
    m_availableThemes = nextAvailableThemes;

    if (availableThemesDidChange && emitAvailableThemesChanged)
        emit availableThemesChanged();

    if (hasActiveTheme)
        applyLoadedTheme(nextActiveTheme);

    return true;
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
