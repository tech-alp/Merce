#include "MerceThemeManifestLoader.h"

#include "BrandDerivation.h"
#include "ThemeValidator.h"

#include <QColor>
#include <QFile>
#include <QFileInfo>
#include <QHash>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QSet>
#include <QVariantMap>

#include <cmath>
#include <limits>

namespace {

constexpr qint64 kMaxThemeDocumentBytes = 1024 * 1024;

struct JsonObjectResult
{
    bool ok = false;
    QJsonObject object;
    QStringList errors;
};

const QStringList spacingFields()
{
    return {
        QStringLiteral("base"), QStringLiteral("none"), QStringLiteral("xxs"),
        QStringLiteral("xs"), QStringLiteral("sm"), QStringLiteral("md"),
        QStringLiteral("lg"), QStringLiteral("xl"), QStringLiteral("xl2"),
        QStringLiteral("xl3"), QStringLiteral("xl4"), QStringLiteral("xl5"),
        QStringLiteral("xl6"), QStringLiteral("componentGap"),
        QStringLiteral("sectionGap"), QStringLiteral("pagePadding"),
        QStringLiteral("touchTarget"), QStringLiteral("touchTargetCompact"),
        QStringLiteral("gridGap"), QStringLiteral("stackGap"),
        QStringLiteral("inlineGap"),
    };
}

const QStringList radiusFields()
{
    return {
        QStringLiteral("none"), QStringLiteral("small"), QStringLiteral("medium"),
        QStringLiteral("large"), QStringLiteral("xlarge"), QStringLiteral("xxlarge"),
        QStringLiteral("full"), QStringLiteral("button"), QStringLiteral("input"),
        QStringLiteral("card"), QStringLiteral("badge"), QStringLiteral("dialog"),
        QStringLiteral("tooltip"),
    };
}

const QStringList typographyIntegerFields()
{
    return {
        QStringLiteral("sizeXSmall"), QStringLiteral("sizeSmall"),
        QStringLiteral("sizeMedium"), QStringLiteral("sizeLarge"),
        QStringLiteral("sizeXLarge"), QStringLiteral("size2XLarge"),
        QStringLiteral("size3XLarge"), QStringLiteral("size4XLarge"),
        QStringLiteral("size5XLarge"), QStringLiteral("size6XLarge"),
        QStringLiteral("size7XLarge"), QStringLiteral("weightRegular"),
        QStringLiteral("weightMedium"), QStringLiteral("weightSemibold"),
        QStringLiteral("weightBold"), QStringLiteral("weightExtraBold"),
    };
}

const QStringList typographyLeadingFields()
{
    return {
        QStringLiteral("leadingTight"),
        QStringLiteral("leadingSnug"), QStringLiteral("leadingNormal"),
        QStringLiteral("leadingRelaxed"),
    };
}

const QStringList typographyTrackingFields()
{
    return {
        QStringLiteral("trackingTight"),
        QStringLiteral("trackingNormal"), QStringLiteral("trackingWide"),
        QStringLiteral("trackingWider"), QStringLiteral("trackingWidest"),
    };
}

QStringList unexpectedFields(const QJsonObject &object,
                             const QString &section,
                             const QStringList &allowedFields)
{
    QStringList errors;
    const QSet<QString> allowed(allowedFields.cbegin(), allowedFields.cend());
    for (const QString &field : object.keys()) {
        if (!allowed.contains(field)) {
            errors.append(QStringLiteral("profile.unexpected_field|%1.%2|field is not allowed")
                              .arg(section, field));
        }
    }
    return errors;
}

JsonObjectResult readJsonObject(const QString &path, const QString &label)
{
    JsonObjectResult result;
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly)) {
        result.errors.append(QStringLiteral("%1.open_failed|%2|%3")
                                 .arg(label, path, file.errorString()));
        return result;
    }
    const QByteArray json = file.read(kMaxThemeDocumentBytes + 1);
    if (json.size() > kMaxThemeDocumentBytes) {
        result.errors.append(QStringLiteral("%1.too_large|%2|maximum document size is %3 bytes")
                                 .arg(label,
                                      path,
                                      QString::number(kMaxThemeDocumentBytes)));
        return result;
    }

    QJsonParseError parseError;
    const QJsonDocument document = QJsonDocument::fromJson(json, &parseError);
    if (parseError.error != QJsonParseError::NoError) {
        result.errors.append(QStringLiteral("%1.parse_error|%2|byte %3: %4")
                                 .arg(label,
                                      path,
                                      QString::number(parseError.offset),
                                      parseError.errorString()));
        return result;
    }
    if (!document.isObject()) {
        result.errors.append(QStringLiteral("%1.not_object|%2|JSON document must be an object")
                                 .arg(label, path));
        return result;
    }

    result.ok = true;
    result.object = document.object();
    return result;
}

QStringList validationErrors(const ThemeValidationResult &validation)
{
    QStringList errors;
    for (const auto &error : validation.errors) {
        errors.append(QStringLiteral("%1|%2|%3")
                          .arg(error.code, error.path, error.message));
    }
    return errors;
}

QStringList validateNumberFields(const QJsonObject &object,
                                 const QString &section,
                                 const QStringList &fields,
                                 double minimum,
                                 double maximum,
                                 bool requireInteger)
{
    QStringList errors;
    for (const QString &field : fields) {
        const QJsonValue value = object.value(field);
        const double number = value.toDouble((std::numeric_limits<double>::quiet_NaN)());
        if (!value.isDouble() || !std::isfinite(number)
            || number < minimum || number > maximum
            || (requireInteger && std::floor(number) != number)) {
            errors.append(QStringLiteral("profile.invalid_number|%1.%2|value is outside the supported numeric range")
                              .arg(section, field));
        }
    }
    return errors;
}

QStringList validateProfile(const QJsonObject &profile,
                            const MerceProfileRegistryEntry &entry)
{
    QStringList errors;
    errors.append(unexpectedFields(
        profile,
        QStringLiteral("profile"),
        {QStringLiteral("profileSchemaVersion"),
         QStringLiteral("profileId"),
         QStringLiteral("spacing"),
         QStringLiteral("radius"),
         QStringLiteral("typography"),
         QStringLiteral("size")}));
    if (profile.value(QStringLiteral("profileSchemaVersion")).toInt(-1) != 2) {
        errors.append(QStringLiteral(
            "profile.unsupported_version|profileSchemaVersion|expected exactly 2"));
    }
    if (profile.value(QStringLiteral("profileId")).toString() != entry.profileId) {
        errors.append(QStringLiteral("profile.id_mismatch|profileId|expected '%1'")
                          .arg(entry.profileId));
    }

    const QJsonObject spacing = profile.value(QStringLiteral("spacing")).toObject();
    const QJsonObject radius = profile.value(QStringLiteral("radius")).toObject();
    const QJsonObject typography = profile.value(QStringLiteral("typography")).toObject();
    if (spacing.isEmpty())
        errors.append(QStringLiteral("profile.missing_section|spacing|required section"));
    else {
        errors.append(unexpectedFields(spacing, QStringLiteral("spacing"), spacingFields()));
        errors.append(validateNumberFields(spacing,
                                           QStringLiteral("spacing"),
                                           spacingFields(),
                                           0.0,
                                           (std::numeric_limits<int>::max)(),
                                           true));
    }
    if (radius.isEmpty())
        errors.append(QStringLiteral("profile.missing_section|radius|required section"));
    else {
        errors.append(unexpectedFields(radius, QStringLiteral("radius"), radiusFields()));
        errors.append(validateNumberFields(radius,
                                           QStringLiteral("radius"),
                                           radiusFields(),
                                           0.0,
                                           (std::numeric_limits<int>::max)(),
                                           true));
    }
    if (typography.isEmpty()) {
        errors.append(QStringLiteral("profile.missing_section|typography|required section"));
    } else {
        QStringList typographyFields = typographyIntegerFields();
        typographyFields.append(typographyLeadingFields());
        typographyFields.append(typographyTrackingFields());
        errors.append(unexpectedFields(typography,
                                       QStringLiteral("typography"),
                                       typographyFields));
        errors.append(validateNumberFields(typography,
                                           QStringLiteral("typography"),
                                           typographyIntegerFields(),
                                           1.0,
                                           (std::numeric_limits<int>::max)(),
                                           true));
        errors.append(validateNumberFields(typography,
                                           QStringLiteral("typography"),
                                           typographyLeadingFields(),
                                           (std::numeric_limits<double>::min)(),
                                           (std::numeric_limits<double>::max)(),
                                           false));
        errors.append(validateNumberFields(typography,
                                           QStringLiteral("typography"),
                                           typographyTrackingFields(),
                                           -(std::numeric_limits<double>::max)(),
                                           (std::numeric_limits<double>::max)(),
                                           false));
        // Nothing string-valued is left here: the font families this used to
        // check moved to the theme, which owns the typeface.
    }

    const QJsonObject size = profile.value(QStringLiteral("size")).toObject();
    const QHash<QString, QStringList> sizeFields{
        {QStringLiteral("control"),
         {QStringLiteral("small"),
          QStringLiteral("medium"),
          QStringLiteral("large"),
          QStringLiteral("minimum")}},
        {QStringLiteral("icon"),
         {QStringLiteral("small"),
          QStringLiteral("medium"),
          QStringLiteral("large")}},
        {QStringLiteral("outline"),
         {QStringLiteral("hairline"),
          QStringLiteral("strong"),
          QStringLiteral("focus")}},
        {QStringLiteral("dialog"),
         {QStringLiteral("small"),
          QStringLiteral("medium"),
          QStringLiteral("large")}},
        {QStringLiteral("content"), {QStringLiteral("maxWidth")}},
    };
    errors.append(unexpectedFields(size, QStringLiteral("size"), sizeFields.keys()));
    for (auto it = sizeFields.cbegin(); it != sizeFields.cend(); ++it) {
        const QString &group = it.key();
        if (!size.value(group).isObject()) {
            errors.append(QStringLiteral("profile.missing_section|size.%1|required section")
                              .arg(group));
            continue;
        }
        const QJsonObject values = size.value(group).toObject();
        errors.append(unexpectedFields(values,
                                       QStringLiteral("size.") + group,
                                       it.value()));
        errors.append(validateNumberFields(values,
                                           QStringLiteral("size.") + group,
                                           it.value(),
                                           1.0,
                                           (std::numeric_limits<int>::max)(),
                                           true));
    }
    return errors;
}

MerceThemeLoadResult loadColorEntry(const MerceThemeRegistryEntry &entry)
{
    MerceThemeLoadResult result;
    result.brandId = entry.brandId;
    result.mode = entry.mode;

    const JsonObjectResult source = readJsonObject(entry.sourcePath,
                                                   QStringLiteral("theme_source"));
    if (!source.ok) {
        result.errors = source.errors;
        return result;
    }

    QJsonObject resolved;
    if (entry.sourceKind == MerceThemeSourceKind::TenantBrand) {
        const ThemeValidationResult tenantValidation =
            ThemeValidator::validateTenantBrand(source.object);
        result.errors = validationErrors(tenantValidation);
        if (!result.errors.isEmpty())
            return result;

        const BrandMode mode = entry.mode == QStringLiteral("dark")
            ? BrandMode::Dark : BrandMode::Light;
        const BrandDerivationResult derivation =
            BrandDerivation::derive(QColor(source.object.value(QStringLiteral("seed")).toString()),
                                    mode);
        if (!derivation.ok) {
            result.errors.append(QStringLiteral("%1|%2|%3")
                                     .arg(derivation.errorCode,
                                          derivation.errorPath,
                                          derivation.errorMessage));
            return result;
        }

        resolved = {
            { QStringLiteral("kind"), QStringLiteral("resolved-theme") },
            { QStringLiteral("resolvedThemeSchemaVersion"), 1 },
            { QStringLiteral("brandId"), entry.brandId },
            { QStringLiteral("mode"), entry.mode },
            { QStringLiteral("identity"),
              QJsonObject{{QStringLiteral("mark"),
                           source.object.value(QStringLiteral("seed")).toString().toUpper()}} },
            { QStringLiteral("colors"), derivation.colors },
            { QStringLiteral("state"), derivation.state },
        };
    } else {
        resolved = source.object;
    }

    if (resolved.value(QStringLiteral("brandId")).toString() != entry.brandId) {
        result.errors.append(QStringLiteral("resolved.brand_mismatch|brandId|expected '%1'")
                                 .arg(entry.brandId));
    }
    if (resolved.value(QStringLiteral("mode")).toString() != entry.mode) {
        result.errors.append(QStringLiteral("resolved.mode_mismatch|mode|expected '%1'")
                                 .arg(entry.mode));
    }
    result.errors.append(validationErrors(ThemeValidator::validateResolvedTheme(resolved)));
    result.ok = result.errors.isEmpty();
    result.finalManifest = resolved;
    return result;
}

JsonObjectResult loadProfileEntry(const MerceProfileRegistryEntry &entry)
{
    JsonObjectResult result = readJsonObject(entry.manifestPath,
                                             QStringLiteral("profile_manifest"));
    if (!result.ok)
        return result;
    result.errors = validateProfile(result.object, entry);
    result.ok = result.errors.isEmpty();
    return result;
}

QStringList validateRegistryEntries(const MerceThemeRegistry &colors,
                                    const MerceProfileRegistry &profiles)
{
    QStringList errors;
    for (const auto &entry : colors.entries()) {
        const MerceThemeLoadResult loaded = loadColorEntry(entry);
        for (const QString &error : loaded.errors) {
            errors.append(QStringLiteral("%1/%2: %3")
                              .arg(entry.brandId)
                              .arg(entry.mode)
                              .arg(error));
        }
    }
    for (const auto &entry : profiles.entries()) {
        const JsonObjectResult loaded = loadProfileEntry(entry);
        for (const QString &error : loaded.errors)
            errors.append(QStringLiteral("%1: %2").arg(entry.profileId).arg(error));
    }
    return errors;
}

QString modeDisplayName(QString mode)
{
    if (!mode.isEmpty())
        mode[0] = mode.at(0).toUpper();
    return mode;
}

} // namespace

MerceThemeManifestLoader::MerceThemeManifestLoader(QString indexPath)
    : m_indexPath(std::move(indexPath))
{
}

MerceThemeLoadResult MerceThemeManifestLoader::loadDefault() const
{
    const MerceThemeRegistryLoadResult registries = loadRegistry(m_indexPath);
    if (!registries.ok) {
        MerceThemeLoadResult result;
        result.errors = registries.errors;
        return result;
    }
    return loadDefaultFromRegistries(registries.colorRegistry,
                                     registries.profileRegistry);
}

MerceThemeLoadResult MerceThemeManifestLoader::load(const QString &brandId,
                                                    const QString &mode,
                                                    const QString &profile) const
{
    const MerceThemeRegistryLoadResult registries = loadRegistry(m_indexPath);
    if (!registries.ok) {
        MerceThemeLoadResult result;
        result.brandId = brandId;
        result.mode = mode;
        result.profile = profile;
        result.errors = registries.errors;
        return result;
    }
    return loadFromRegistries(registries.colorRegistry,
                              registries.profileRegistry,
                              brandId,
                              mode,
                              profile);
}

QVariantList MerceThemeManifestLoader::availableThemes() const
{
    const MerceThemeRegistryLoadResult registries = loadRegistry(m_indexPath);
    return registries.ok ? availableThemesForRegistry(registries.colorRegistry)
                         : QVariantList{};
}

QVariantList MerceThemeManifestLoader::availableProfiles() const
{
    const MerceThemeRegistryLoadResult registries = loadRegistry(m_indexPath);
    return registries.ok ? availableProfilesForRegistry(registries.profileRegistry)
                         : QVariantList{};
}

MerceThemeRegistryLoadResult MerceThemeManifestLoader::loadRegistry(
    const QString &sourcePath)
{
    MerceThemeRegistryLoadResult result;
    const JsonObjectResult source = readJsonObject(sourcePath, QStringLiteral("theme_source"));
    if (!source.ok) {
        result.errors = source.errors;
        return result;
    }

    if (source.object.value(QStringLiteral("kind")).toString()
        == QStringLiteral("tenant-brand")) {
        const ThemeValidationResult validation =
            ThemeValidator::validateTenantBrand(source.object);
        result.errors = validationErrors(validation);
        if (!result.errors.isEmpty())
            return result;

        const MerceThemeRegistryResult colors =
            MerceThemeRegistry::fromTenantBrand(source.object, sourcePath);
        result.ok = colors.ok;
        result.colorRegistry = colors.registry;
        result.errors.append(colors.errors);
        return result;
    }

    if (source.object.value(QStringLiteral("schemaVersion")).toInt(-1) != 1) {
        result.errors.append(QStringLiteral(
            "index.unsupported_version|schemaVersion|expected exactly 1"));
        return result;
    }

    const MerceThemeRegistryResult colors =
        MerceThemeRegistry::fromJson(source.object, sourcePath);
    const MerceProfileRegistryResult profiles =
        MerceProfileRegistry::fromJson(source.object, sourcePath);
    result.errors.append(colors.errors);
    result.errors.append(profiles.errors);
    result.ok = colors.ok && profiles.ok
        && (!colors.registry.isEmpty() || !profiles.registry.isEmpty());
    if (!result.ok && result.errors.isEmpty()) {
        result.errors.append(QStringLiteral(
            "index.empty|brands/profiles|at least one registry is required"));
    }
    result.colorRegistry = colors.registry;
    result.profileRegistry = profiles.registry;
    return result;
}

MerceThemeRegistryLoadResult MerceThemeManifestLoader::loadMergedRegistry(
    const QStringList &sourcePaths)
{
    MerceThemeRegistryLoadResult result;
    if (sourcePaths.isEmpty()) {
        result.errors.append(QStringLiteral(
            "index.missing|sources|at least one source path is required"));
        return result;
    }

    for (int i = 0; i < sourcePaths.size(); ++i) {
        const MerceThemeRegistryLoadResult source = loadRegistry(sourcePaths.at(i));
        if (!source.ok) {
            for (const QString &error : source.errors)
                result.errors.append(QStringLiteral("%1: %2")
                                         .arg(sourcePaths.at(i))
                                         .arg(error));
            return result;
        }
        if (i == 0) {
            result.colorRegistry = source.colorRegistry;
            result.profileRegistry = source.profileRegistry;
            continue;
        }

        QStringList mergeErrors;
        const bool colorsOk =
            result.colorRegistry.appendRegistry(source.colorRegistry, &mergeErrors);
        const bool profilesOk =
            result.profileRegistry.appendRegistry(source.profileRegistry, &mergeErrors);
        if (!colorsOk || !profilesOk) {
            for (const QString &error : mergeErrors)
                result.errors.append(QStringLiteral("%1: %2")
                                         .arg(sourcePaths.at(i))
                                         .arg(error));
            return result;
        }
    }

    if (result.colorRegistry.defaultBrand().isEmpty()
        || result.profileRegistry.defaultProfile().isEmpty()) {
        result.errors.append(QStringLiteral(
            "index.missing_default|defaultBrand/defaultProfile|bundled registry requires both"));
        return result;
    }

    result.errors = validateRegistryEntries(result.colorRegistry,
                                            result.profileRegistry);
    result.ok = result.errors.isEmpty();
    return result;
}

MerceThemeLoadResult MerceThemeManifestLoader::loadDefaultFromRegistries(
    const MerceThemeRegistry &colorRegistry,
    const MerceProfileRegistry &profileRegistry)
{
    return loadFromRegistries(colorRegistry,
                              profileRegistry,
                              colorRegistry.defaultBrand(),
                              colorRegistry.defaultMode(),
                              profileRegistry.defaultProfile());
}

MerceThemeLoadResult MerceThemeManifestLoader::loadFromRegistries(
    const MerceThemeRegistry &colorRegistry,
    const MerceProfileRegistry &profileRegistry,
    const QString &brandId,
    const QString &mode,
    const QString &profile)
{
    MerceThemeLoadResult result;
    result.brandId = brandId;
    result.mode = mode;
    result.profile = profile;

    const MerceThemeRegistryLookupResult color = colorRegistry.lookup(brandId, mode);
    const QString effectiveProfile =
        profile.isEmpty() ? profileRegistry.defaultProfile() : profile;
    const MerceProfileRegistryLookupResult metrics =
        profileRegistry.lookup(effectiveProfile);
    if (!color.ok)
        result.errors.append(color.errors);
    if (!metrics.ok)
        result.errors.append(metrics.errors);
    if (!result.errors.isEmpty())
        return result;

    MerceThemeLoadResult loadedColor = loadColorEntry(color.entry);
    const JsonObjectResult loadedProfile = loadProfileEntry(metrics.entry);
    result.errors.append(loadedColor.errors);
    result.errors.append(loadedProfile.errors);
    if (!result.errors.isEmpty())
        return result;

    result.brandId = color.entry.brandId;
    result.mode = color.entry.mode;
    result.profile = metrics.entry.profileId;
    result.finalManifest = loadedColor.finalManifest;
    for (const QString &section : {QStringLiteral("spacing"),
                                   QStringLiteral("radius"),
                                   QStringLiteral("size")}) {
        result.finalManifest.insert(section, loadedProfile.object.value(section));
    }

    // Typography is the one section both layers speak to, so it is merged
    // rather than replaced: the profile brings the metrics that follow the
    // panel, the theme brings the families that follow the brand. Overwriting
    // wholesale would drop whichever half was written second.
    QJsonObject typography = loadedProfile.object.value(QStringLiteral("typography")).toObject();
    const QJsonObject themeTypography =
        result.finalManifest.value(QStringLiteral("typography")).toObject();
    for (auto it = themeTypography.constBegin(); it != themeTypography.constEnd(); ++it)
        typography.insert(it.key(), it.value());
    result.finalManifest.insert(QStringLiteral("typography"), typography);
    result.ok = true;
    return result;
}

QVariantList MerceThemeManifestLoader::availableThemesForRegistry(
    const MerceThemeRegistry &registry)
{
    QVariantList result;
    QStringList seen;
    for (const auto &entry : registry.entries()) {
        if (seen.contains(entry.brandId))
            continue;
        seen.append(entry.brandId);

        QVariantList modes;
        for (const auto &candidate : registry.entries()) {
            if (candidate.brandId != entry.brandId)
                continue;
            modes.append(QVariantMap{
                {QStringLiteral("value"), candidate.mode},
                {QStringLiteral("label"), modeDisplayName(candidate.mode)},
            });
        }
        const QString defaultMode = registry.defaultModeForBrand(entry.brandId);
        for (qsizetype i = 0; i < modes.size(); ++i) {
            if (modes.at(i).toMap().value(QStringLiteral("value")).toString()
                == defaultMode) {
                if (i > 0)
                    modes.move(i, 0);
                break;
            }
        }
        result.append(QVariantMap{
            {QStringLiteral("value"), entry.brandId},
            {QStringLiteral("label"), entry.displayName},
            {QStringLiteral("defaultMode"), defaultMode},
            {QStringLiteral("modes"), modes},
        });
    }
    return result;
}

QVariantList MerceThemeManifestLoader::availableProfilesForRegistry(
    const MerceProfileRegistry &registry)
{
    QVariantList result;
    for (const auto &entry : registry.entries()) {
        result.append(QVariantMap{
            {QStringLiteral("value"), entry.profileId},
            {QStringLiteral("label"), entry.displayName},
        });
    }
    return result;
}
