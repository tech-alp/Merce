#include "MerceTheme.h"

#include "MerceThemeManifestLoader.h"

#include <QFileInfo>
#include <QJsonObject>
#include <QJsonValue>
#include <QLoggingCategory>
#include <QScopedValueRollback>

#include <stdexcept>

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
      m_size(new MerceSize(this)),
      m_state(new MerceState(this)),
      m_typography(new MerceTypography(this)),
      m_motion(new MerceMotion(this)),
      m_icons(new MerceIconography(this)),
      m_zIndex(new MerceZIndex(this)),
      m_breakpoints(new MerceBreakpoints(this)),
      m_shadows(new MerceShadows(this))
{
    if (!reloadThemesInternal(false))
        throw std::runtime_error("No valid bundled AlGit theme registry");

    const MerceThemeLoadResult theme =
        MerceThemeManifestLoader::loadDefaultFromRegistries(m_colorRegistry,
                                                            m_profileRegistry);
    if (!theme.ok) {
        logThemeErrors(QStringLiteral("default manifest load failed:"), theme.errors);
        throw std::runtime_error("No valid bundled AlGit theme");
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

QString MerceTheme::activeProfile() const
{
    return m_activeProfile;
}

bool MerceTheme::setContext(const QString &brand,
                            const QString &mode,
                            const QString &profile)
{
    if (m_contextMutationInProgress) {
        qCWarning(merceThemeLog) << "reentrant theme context mutation rejected";
        return false;
    }
    QScopedValueRollback mutationGuard(m_contextMutationInProgress, true);

    const MerceThemeLoadResult theme =
        MerceThemeManifestLoader::loadFromRegistries(m_colorRegistry,
                                                     m_profileRegistry,
                                                     brand,
                                                     mode,
                                                     profile);
    if (!theme.ok) {
        logThemeErrors(QStringLiteral("runtime theme switch failed:"), theme.errors);
        return false;
    }
    return applyLoadedTheme(theme);
}

bool MerceTheme::setTheme(const QString &brand, const QString &mode)
{
    const QString profile = m_activeProfile.isEmpty()
        ? m_profileRegistry.defaultProfile() : m_activeProfile;
    return setContext(brand, mode, profile);
}

bool MerceTheme::addThemeSource(const QString &indexPath)
{
    if (m_contextMutationInProgress) {
        qCWarning(merceThemeLog) << "reentrant theme source mutation rejected";
        return false;
    }
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
    if (m_contextMutationInProgress) {
        qCWarning(merceThemeLog) << "reentrant theme source mutation rejected";
        return;
    }

    const QStringList previousPaths = m_externalThemeSourcePaths;
    m_externalThemeSourcePaths.clear();
    if (!reloadThemesInternal(true)) {
        m_externalThemeSourcePaths = previousPaths;
        qCWarning(merceThemeLog) << "failed to reload built-in theme registry after clearing external sources";
    }
}

bool MerceTheme::reloadThemes()
{
    return reloadThemesInternal(true);
}

bool MerceTheme::reloadThemesInternal(bool emitAvailableThemesChanged)
{
    if (m_contextMutationInProgress) {
        qCWarning(merceThemeLog) << "reentrant theme registry reload rejected";
        return false;
    }
    QScopedValueRollback mutationGuard(m_contextMutationInProgress, true);

    QStringList indexPaths;
    indexPaths.append(m_builtinManifestIndexPath);
    indexPaths.append(m_externalThemeSourcePaths);

    const MerceThemeRegistryLoadResult registry =
        MerceThemeManifestLoader::loadMergedRegistry(indexPaths);
    if (!registry.ok) {
        logThemeErrors(QStringLiteral("theme source reload failed:"), registry.errors);
        return false;
    }

    MerceThemeLoadResult nextActiveTheme;
    const bool hasActiveTheme = !m_activeBrand.isEmpty();
    if (hasActiveTheme) {
        nextActiveTheme =
            MerceThemeManifestLoader::loadFromRegistries(registry.colorRegistry,
                                                         registry.profileRegistry,
                                                         m_activeBrand,
                                                         m_activeMode,
                                                         m_activeProfile);
        if (!nextActiveTheme.ok) {
            logThemeErrors(QStringLiteral("active theme reload failed:"), nextActiveTheme.errors);
            return false;
        }
    }

    const QVariantList nextAvailableThemes =
        MerceThemeManifestLoader::availableThemesForRegistry(registry.colorRegistry);
    const QVariantList nextAvailableProfiles =
        MerceThemeManifestLoader::availableProfilesForRegistry(registry.profileRegistry);
    const bool availableThemesDidChange = m_availableThemes != nextAvailableThemes;
    const bool availableProfilesDidChange = m_availableProfiles != nextAvailableProfiles;

    m_colorRegistry = registry.colorRegistry;
    m_profileRegistry = registry.profileRegistry;
    m_availableThemes = nextAvailableThemes;
    m_availableProfiles = nextAvailableProfiles;

    if (availableThemesDidChange && emitAvailableThemesChanged)
        emit availableThemesChanged();
    if (availableProfilesDidChange && emitAvailableThemesChanged)
        emit availableProfilesChanged();

    if (hasActiveTheme)
        applyLoadedTheme(nextActiveTheme);

    return true;
}

bool MerceTheme::applyLoadedTheme(const MerceThemeLoadResult &result)
{
    if (!result.ok)
        return false;

    const QJsonObject manifest = result.finalManifest;
    auto *nextColors = new MerceColors(this);
    auto *nextSpacing = new MerceSpacing(this);
    auto *nextRadius = new MerceRadius(this);
    auto *nextSize = new MerceSize(this);
    auto *nextState = new MerceState(this);
    auto *nextTypography = new MerceTypography(this);

    nextColors->applyManifestSection(manifest.value(QStringLiteral("colors")).toObject());
    nextSpacing->applyManifestSection(manifest.value(QStringLiteral("spacing")).toObject());
    nextRadius->applyManifestSection(manifest.value(QStringLiteral("radius")).toObject());
    nextSize->applyManifestSection(manifest.value(QStringLiteral("size")).toObject());
    nextState->applyManifestSection(manifest.value(QStringLiteral("state")).toObject());
    nextTypography->applyManifestSection(manifest.value(QStringLiteral("typography")).toObject());

    MerceColors *oldColors = m_colors;
    MerceSpacing *oldSpacing = m_spacing;
    MerceRadius *oldRadius = m_radius;
    MerceSize *oldSize = m_size;
    MerceState *oldState = m_state;
    MerceTypography *oldTypography = m_typography;

    m_colors = nextColors;
    m_spacing = nextSpacing;
    m_radius = nextRadius;
    m_size = nextSize;
    m_state = nextState;
    m_typography = nextTypography;

    const bool activeThemeDidChange =
        updateActiveThemeState(result.brandId, result.mode, result.profile);
    emit colorsChanged();
    emit spacingChanged();
    emit radiusChanged();
    emit typographyChanged();
    emit stateChanged();
    emit sizeChanged();
    if (activeThemeDidChange)
        emit activeThemeChanged();

    ++m_generation;
    emit generationChanged();

    oldColors->deleteLater();
    oldSpacing->deleteLater();
    oldRadius->deleteLater();
    oldSize->deleteLater();
    oldState->deleteLater();
    oldTypography->deleteLater();
    return true;
}

bool MerceTheme::updateActiveThemeState(const QString &brand,
                                        const QString &mode,
                                        const QString &profile)
{
    if (m_activeBrand == brand && m_activeMode == mode
        && m_activeProfile == profile) {
        return false;
    }

    m_activeBrand = brand;
    m_activeMode = mode;
    m_activeProfile = profile;
    return true;
}
