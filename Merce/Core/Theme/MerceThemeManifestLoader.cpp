#include "MerceThemeManifestLoader.h"

#include "MerceThemeRegistry.h"

#include <QColor>
#include <QFile>
#include <QJsonDocument>
#include <QJsonParseError>
#include <QJsonValue>
#include <QLoggingCategory>
#include <QVariantMap>

Q_LOGGING_CATEGORY(merceThemeLoaderLog, "merce.theme.loader")

namespace {

struct JsonObjectResult
{
    bool ok = false;
    QJsonObject object;
    QStringList errors;
};

struct RegistryLoadResult
{
    bool ok = false;
    MerceThemeRegistry registry;
    QStringList errors;
};

const QStringList supportedSections()
{
    return {
        QStringLiteral("colors"),
        QStringLiteral("spacing"),
        QStringLiteral("radius"),
        QStringLiteral("typography"),
    };
}

const QStringList colorFields()
{
    return {
        QStringLiteral("text.primary"),
        QStringLiteral("text.secondary"),
        QStringLiteral("text.tertiary"),
        QStringLiteral("text.inverse"),
        QStringLiteral("text.disabled"),
        QStringLiteral("text.link"),
        QStringLiteral("text.linkHover"),
        QStringLiteral("background.base"),
        QStringLiteral("background.surface"),
        QStringLiteral("background.elevated"),
        QStringLiteral("background.hover"),
        QStringLiteral("background.pressed"),
        QStringLiteral("background.tinted"),
        QStringLiteral("background.overlay"),
        QStringLiteral("border.base"),
        QStringLiteral("border.strong"),
        QStringLiteral("border.focus"),
        QStringLiteral("border.error"),
        QStringLiteral("border.success"),
        QStringLiteral("action.primary"),
        QStringLiteral("action.primaryHover"),
        QStringLiteral("action.primaryPressed"),
        QStringLiteral("action.primarySubtle"),
        QStringLiteral("action.secondary"),
        QStringLiteral("action.secondaryHover"),
        QStringLiteral("action.secondaryPressed"),
        QStringLiteral("action.disabled"),
        QStringLiteral("status.success"),
        QStringLiteral("status.successSubtle"),
        QStringLiteral("status.warning"),
        QStringLiteral("status.warningSubtle"),
        QStringLiteral("status.error"),
        QStringLiteral("status.errorSubtle"),
        QStringLiteral("status.info"),
        QStringLiteral("status.infoSubtle"),
        QStringLiteral("surface.base"),
        QStringLiteral("surface.tinted"),
        QStringLiteral("surface.raised"),
    };
}

const QStringList spacingFields()
{
    return {
        QStringLiteral("base"),
        QStringLiteral("none"),
        QStringLiteral("xxs"),
        QStringLiteral("xs"),
        QStringLiteral("sm"),
        QStringLiteral("md"),
        QStringLiteral("lg"),
        QStringLiteral("xl"),
        QStringLiteral("xl2"),
        QStringLiteral("xl3"),
        QStringLiteral("xl4"),
        QStringLiteral("xl5"),
        QStringLiteral("xl6"),
        QStringLiteral("componentGap"),
        QStringLiteral("sectionGap"),
        QStringLiteral("pagePadding"),
        QStringLiteral("touchTarget"),
        QStringLiteral("touchTargetCompact"),
        QStringLiteral("gridGap"),
        QStringLiteral("stackGap"),
        QStringLiteral("inlineGap"),
    };
}

const QStringList radiusFields()
{
    return {
        QStringLiteral("none"),
        QStringLiteral("small"),
        QStringLiteral("medium"),
        QStringLiteral("large"),
        QStringLiteral("xlarge"),
        QStringLiteral("xxlarge"),
        QStringLiteral("full"),
        QStringLiteral("button"),
        QStringLiteral("input"),
        QStringLiteral("card"),
        QStringLiteral("badge"),
        QStringLiteral("dialog"),
        QStringLiteral("tooltip"),
    };
}

const QStringList typographyFields()
{
    return {
        QStringLiteral("displayFont"),
        QStringLiteral("bodyFont"),
        QStringLiteral("monoFont"),
        QStringLiteral("displayFontFallback"),
        QStringLiteral("bodyFontFallback"),
        QStringLiteral("sizeXSmall"),
        QStringLiteral("sizeSmall"),
        QStringLiteral("sizeMedium"),
        QStringLiteral("sizeLarge"),
        QStringLiteral("sizeXLarge"),
        QStringLiteral("size2XLarge"),
        QStringLiteral("size3XLarge"),
        QStringLiteral("size4XLarge"),
        QStringLiteral("size5XLarge"),
        QStringLiteral("size6XLarge"),
        QStringLiteral("size7XLarge"),
        QStringLiteral("weightRegular"),
        QStringLiteral("weightMedium"),
        QStringLiteral("weightSemibold"),
        QStringLiteral("weightBold"),
        QStringLiteral("leadingTight"),
        QStringLiteral("leadingSnug"),
        QStringLiteral("leadingNormal"),
        QStringLiteral("leadingRelaxed"),
        QStringLiteral("trackingTight"),
        QStringLiteral("trackingNormal"),
        QStringLiteral("trackingWide"),
        QStringLiteral("trackingWider"),
        QStringLiteral("trackingWidest"),
    };
}

const QStringList requiredFieldsForSection(const QString &section)
{
    if (section == QStringLiteral("spacing"))
        return spacingFields();
    if (section == QStringLiteral("radius"))
        return radiusFields();
    if (section == QStringLiteral("typography"))
        return typographyFields();
    return {};
}

const QStringList typographyStringFields()
{
    return {
        QStringLiteral("displayFont"),
        QStringLiteral("bodyFont"),
        QStringLiteral("monoFont"),
        QStringLiteral("displayFontFallback"),
        QStringLiteral("bodyFontFallback"),
    };
}

QJsonValue valueAtPath(const QJsonObject &object, const QString &path)
{
    QJsonValue value = object;
    const QStringList segments = path.split(QLatin1Char('.'));
    for (const QString &segment : segments) {
        if (!value.isObject())
            return {};
        value = value.toObject().value(segment);
    }
    return value;
}

void requireColorPath(const QJsonObject &object, const QString &fieldPath, QStringList *errors)
{
    const QJsonValue value = valueAtPath(object, fieldPath);
    const QString fullPath = QStringLiteral("colors.%1").arg(fieldPath);
    if (value.isUndefined()) {
        errors->append(QStringLiteral("missing required runtime field: %1").arg(fullPath));
        return;
    }

    if (!value.isString() || !QColor(value.toString()).isValid()) {
        errors->append(QStringLiteral("runtime field %1 must be a valid color string").arg(fullPath));
    }
}

void requireNumber(const QJsonObject &object, const QString &section, const QString &field, QStringList *errors)
{
    const QJsonValue value = object.value(field);
    if (!value.isDouble()) {
        errors->append(QStringLiteral("runtime field %1.%2 must be numeric").arg(section, field));
    }
}

bool isUnresolvedTokenReference(const QString &value)
{
    const QString trimmed = value.trimmed();
    return trimmed.startsWith(QLatin1Char('{')) && trimmed.endsWith(QLatin1Char('}'));
}

void requireString(const QJsonObject &object, const QString &section, const QString &field, QStringList *errors)
{
    const QJsonValue value = object.value(field);
    const QString text = value.toString().trimmed();
    if (!value.isString() || text.isEmpty() || isUnresolvedTokenReference(text)) {
        errors->append(QStringLiteral("runtime field %1.%2 must be a resolved non-empty string").arg(section, field));
    }
}

JsonObjectResult readJsonObject(const QString &path, const QString &label)
{
    JsonObjectResult result;
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly)) {
        result.errors.append(QStringLiteral("%1 '%2' could not be opened: %3")
                                 .arg(label, path, file.errorString()));
        return result;
    }

    QJsonParseError parseError;
    const QJsonDocument document = QJsonDocument::fromJson(file.readAll(), &parseError);
    if (parseError.error != QJsonParseError::NoError) {
        result.errors.append(QStringLiteral("%1 '%2' parse error at byte %3: %4")
                                 .arg(label,
                                      path,
                                      QString::number(parseError.offset),
                                      parseError.errorString()));
        return result;
    }

    if (!document.isObject()) {
        result.errors.append(QStringLiteral("%1 '%2' must contain a JSON object").arg(label, path));
        return result;
    }

    result.ok = true;
    result.object = document.object();
    return result;
}

RegistryLoadResult loadRegistry(const QString &indexPath)
{
    RegistryLoadResult result;
    const JsonObjectResult index = readJsonObject(indexPath, QStringLiteral("theme index"));
    if (!index.ok) {
        result.errors = index.errors;
        return result;
    }

    const MerceThemeRegistryResult registryResult = MerceThemeRegistry::fromJson(index.object, indexPath);
    if (!registryResult.ok) {
        result.errors = registryResult.errors;
        return result;
    }

    result.ok = true;
    result.registry = registryResult.registry;
    return result;
}

QJsonObject overlayManifest(const QJsonObject &base, const QJsonObject &active)
{
    QJsonObject merged = base;
    for (const QString &key : active.keys()) {
        if (supportedSections().contains(key) || key == QStringLiteral("schemaVersion")
            || key == QStringLiteral("theme") || key == QStringLiteral("variant")) {
            merged.insert(key, active.value(key));
        }
    }
    return merged;
}

QStringList validateNoLegacySections(const QJsonObject &manifest)
{
    QStringList errors;
    if (manifest.contains(QStringLiteral("palette")))
        errors.append(QStringLiteral("manifest must not contain a top-level palette section"));

    const QJsonValue colorsValue = manifest.value(QStringLiteral("colors"));
    if (colorsValue.isObject() && colorsValue.toObject().contains(QStringLiteral("raw")))
        errors.append(QStringLiteral("runtime colors must not expose raw color scales"));
    return errors;
}

QStringList validateColorsSection(const QJsonObject &manifest)
{
    QStringList errors;
    const QJsonValue sectionValue = manifest.value(QStringLiteral("colors"));
    if (!sectionValue.isObject()) {
        errors.append(QStringLiteral("missing required field: colors"));
        return errors;
    }

    const QJsonObject colors = sectionValue.toObject();
    if (colors.contains(QStringLiteral("raw")))
        errors.append(QStringLiteral("runtime colors must not expose raw color scales"));

    for (const QString &fieldPath : colorFields())
        requireColorPath(colors, fieldPath, &errors);

    return errors;
}

QStringList validateSection(const QJsonObject &manifest, const QString &section)
{
    if (section == QStringLiteral("colors"))
        return validateColorsSection(manifest);

    QStringList errors;
    const QJsonValue sectionValue = manifest.value(section);
    if (!sectionValue.isObject()) {
        errors.append(QStringLiteral("missing required field: %1").arg(section));
        return errors;
    }

    const QJsonObject object = sectionValue.toObject();
    for (const QString &field : requiredFieldsForSection(section)) {
        if (!object.contains(field)) {
            errors.append(QStringLiteral("missing required runtime field: %1.%2").arg(section, field));
            continue;
        }

        if (section == QStringLiteral("typography")
            && typographyStringFields().contains(field)) {
            requireString(object, section, field, &errors);
        } else {
            requireNumber(object, section, field, &errors);
        }
    }

    return errors;
}

QStringList validateManifest(const QJsonObject &manifest, const MerceThemeRegistryEntry &entry)
{
    QStringList errors;

    if (manifest.value(QStringLiteral("schemaVersion")).toInt(-1) != 1)
        errors.append(QStringLiteral("schemaVersion must be 1"));

    const QJsonValue themeValue = manifest.value(QStringLiteral("theme"));
    if (!themeValue.isString() || themeValue.toString() != entry.theme)
        errors.append(QStringLiteral("theme must be '%1'").arg(entry.theme));

    if (entry.variant.isEmpty()) {
        if (manifest.contains(QStringLiteral("variant")))
            errors.append(QStringLiteral("single-manifest themes must not include variant"));
    } else {
        const QJsonValue variantValue = manifest.value(QStringLiteral("variant"));
        if (!variantValue.isString() || variantValue.toString() != entry.variant)
            errors.append(QStringLiteral("variant must be '%1'").arg(entry.variant));
    }

    errors.append(validateNoLegacySections(manifest));

    for (const QString &section : supportedSections())
        errors.append(validateSection(manifest, section));

    return errors;
}

MerceThemeLoadResult loadEntry(const MerceThemeRegistryEntry &entry)
{
    MerceThemeLoadResult result;
    result.theme = entry.theme;
    result.variant = entry.variant;

    QJsonObject mergedManifest;
    if (!entry.basePath.isEmpty()) {
        const JsonObjectResult base = readJsonObject(entry.basePath, QStringLiteral("base manifest"));
        if (!base.ok) {
            result.errors = base.errors;
            return result;
        }
        result.errors.append(validateNoLegacySections(base.object));
        mergedManifest = base.object;
    }

    const JsonObjectResult active = readJsonObject(entry.manifestPath, QStringLiteral("theme manifest"));
    if (!active.ok) {
        result.errors = active.errors;
        return result;
    }
    result.errors.append(validateNoLegacySections(active.object));

    mergedManifest = overlayManifest(mergedManifest, active.object);
    result.errors.append(validateManifest(mergedManifest, entry));
    result.ok = result.errors.isEmpty();
    result.finalManifest = mergedManifest;
    return result;
}

void logErrors(const QString &prefix, const QStringList &errors)
{
    for (const QString &error : errors)
        qCWarning(merceThemeLoaderLog) << prefix << error;
}

bool isDefaultEntry(const MerceThemeRegistry &registry, const MerceThemeRegistryEntry &entry)
{
    return entry.theme == registry.defaultTheme() && entry.variant == registry.defaultVariant();
}

QString modeDisplayName(QString variant)
{
    if (variant.isEmpty())
        return QStringLiteral("Default");

    variant[0] = variant.at(0).toUpper();
    return variant;
}

MerceThemeLoadResult loadDefaultFromRegistry(const MerceThemeRegistry &registry)
{
    const MerceThemeRegistryLookupResult lookup = registry.defaultEntry();
    if (!lookup.ok) {
        MerceThemeLoadResult result;
        result.errors = lookup.errors;
        logErrors(QStringLiteral("default theme lookup failed:"), result.errors);
        return result;
    }

    MerceThemeLoadResult result = loadEntry(lookup.entry);
    if (!result.ok)
        logErrors(QStringLiteral("default theme load failed:"), result.errors);
    return result;
}

} // namespace

MerceThemeManifestLoader::MerceThemeManifestLoader(QString indexPath)
    : m_indexPath(std::move(indexPath))
{
}

MerceThemeLoadResult MerceThemeManifestLoader::loadDefault() const
{
    const RegistryLoadResult registry = loadRegistry(m_indexPath);
    if (!registry.ok) {
        MerceThemeLoadResult result;
        result.errors = registry.errors;
        logErrors(QStringLiteral("theme registry load failed:"), result.errors);
        return result;
    }

    return loadDefaultFromRegistry(registry.registry);
}

MerceThemeLoadResult MerceThemeManifestLoader::load(const QString &theme, const QString &variant) const
{
    const RegistryLoadResult registry = loadRegistry(m_indexPath);
    if (!registry.ok) {
        MerceThemeLoadResult result;
        result.theme = theme;
        result.variant = variant;
        result.errors = registry.errors;
        logErrors(QStringLiteral("theme registry load failed:"), result.errors);
        return result;
    }

    const MerceThemeRegistryLookupResult lookup = registry.registry.lookup(theme, variant);
    if (!lookup.ok) {
        MerceThemeLoadResult result;
        result.theme = theme;
        result.variant = variant;
        result.errors = lookup.errors;
        logErrors(QStringLiteral("requested theme lookup failed:"), result.errors);
        return result;
    }

    MerceThemeLoadResult requested = loadEntry(lookup.entry);
    if (requested.ok || isDefaultEntry(registry.registry, lookup.entry)) {
        if (!requested.ok)
            logErrors(QStringLiteral("requested theme load failed:"), requested.errors);
        return requested;
    }

    logErrors(QStringLiteral("requested theme load failed, falling back to default:"), requested.errors);
    MerceThemeLoadResult fallback = loadDefaultFromRegistry(registry.registry);
    if (fallback.ok) {
        fallback.usedFallback = true;
        fallback.errors = requested.errors;
        return fallback;
    }

    fallback.errors.prepend(QStringLiteral("fallback to default theme failed"));
    fallback.errors.append(requested.errors);
    return fallback;
}

QVariantList MerceThemeManifestLoader::availableThemes() const
{
    const RegistryLoadResult registry = loadRegistry(m_indexPath);
    if (!registry.ok) {
        logErrors(QStringLiteral("theme registry discovery failed:"), registry.errors);
        return {};
    }

    struct ThemeOption
    {
        QString value;
        QString label;
        QString defaultMode;
        QVariantList modes;
    };

    QList<ThemeOption> options;
    for (const auto &entry : registry.registry.entries()) {
        int optionIndex = -1;
        for (int i = 0; i < options.size(); ++i) {
            if (options.at(i).value == entry.theme) {
                optionIndex = i;
                break;
            }
        }

        if (optionIndex < 0) {
            options.append({
                entry.theme,
                entry.displayName.isEmpty() ? entry.theme : entry.displayName,
                entry.theme == registry.registry.defaultTheme() ? registry.registry.defaultVariant() : QString(),
                {},
            });
            optionIndex = options.size() - 1;
        }

        if (!entry.variant.isEmpty()) {
            QVariantMap mode;
            mode.insert(QStringLiteral("value"), entry.variant);
            mode.insert(QStringLiteral("label"), modeDisplayName(entry.variant));
            options[optionIndex].modes.append(mode);
        }
    }

    QVariantList themes;
    for (ThemeOption option : options) {
        if (option.defaultMode.isEmpty() && !option.modes.isEmpty())
            option.defaultMode = option.modes.constFirst().toMap().value(QStringLiteral("value")).toString();

        for (int i = 0; i < option.modes.size(); ++i) {
            if (option.modes.at(i).toMap().value(QStringLiteral("value")).toString() == option.defaultMode) {
                if (i > 0)
                    option.modes.move(i, 0);
                break;
            }
        }

        QVariantMap theme;
        theme.insert(QStringLiteral("value"), option.value);
        theme.insert(QStringLiteral("label"), option.label);
        theme.insert(QStringLiteral("defaultMode"), option.defaultMode);
        theme.insert(QStringLiteral("hasModes"), !option.modes.isEmpty());
        theme.insert(QStringLiteral("modes"), option.modes);
        themes.append(theme);
    }

    return themes;
}
