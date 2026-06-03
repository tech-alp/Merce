#include "MerceThemeRegistry.h"

#include <QDir>
#include <QFileInfo>
#include <QJsonValue>

namespace {

QString indexDirectory(const QString &indexPath)
{
    const QString path = QFileInfo(indexPath).path();
    if (path.isEmpty() || path == QStringLiteral("."))
        return QString();
    return path;
}

QString resolvedManifestPath(const QString &indexPath, const QString &fileName)
{
    const QString directory = indexDirectory(indexPath);
    if (directory.isEmpty())
        return fileName;
    return directory + QLatin1Char('/') + fileName;
}

bool isUnsafeManifestFileName(const QString &fileName)
{
    return fileName.isEmpty()
        || QDir::isAbsolutePath(fileName)
        || fileName.startsWith(QLatin1Char(':'))
        || fileName.contains(QStringLiteral("../"))
        || fileName.contains(QStringLiteral("..\\"))
        || fileName.contains(QLatin1Char('/'))
        || fileName.contains(QLatin1Char('\\'));
}

QString validatedPath(const QString &indexPath,
                      const QString &themeName,
                      const QString &variantName,
                      const QString &fieldName,
                      const QJsonValue &value,
                      QStringList *errors)
{
    if (!value.isString()) {
        errors->append(QStringLiteral("theme '%1'%2 field '%3' must be a string")
                           .arg(themeName,
                                variantName.isEmpty() ? QString() : QStringLiteral(" variant '%1'").arg(variantName),
                                fieldName));
        return {};
    }

    const QString fileName = value.toString();
    if (isUnsafeManifestFileName(fileName)) {
        errors->append(QStringLiteral("theme '%1'%2 field '%3' has unsafe manifest path '%4'")
                           .arg(themeName,
                                variantName.isEmpty() ? QString() : QStringLiteral(" variant '%1'").arg(variantName),
                                fieldName,
                                fileName));
        return {};
    }

    return resolvedManifestPath(indexPath, fileName);
}

bool hasThemeEntry(const QList<MerceThemeRegistryEntry> &entries, const QString &theme)
{
    for (const auto &entry : entries) {
        if (entry.theme == theme)
            return true;
    }
    return false;
}

} // namespace

MerceThemeRegistryResult MerceThemeRegistry::fromJson(const QJsonObject &index, const QString &indexPath)
{
    MerceThemeRegistryResult result;

    if (index.value(QStringLiteral("schemaVersion")).toInt(-1) != 1) {
        result.errors.append(QStringLiteral("theme index schemaVersion must be 1"));
    }

    const QJsonValue defaultThemeValue = index.value(QStringLiteral("defaultTheme"));
    if (!defaultThemeValue.isString() || defaultThemeValue.toString().isEmpty()) {
        result.errors.append(QStringLiteral("theme index must declare a non-empty defaultTheme"));
    } else {
        result.registry.m_defaultTheme = defaultThemeValue.toString();
    }

    const QJsonValue themesValue = index.value(QStringLiteral("themes"));
    if (!themesValue.isObject() || themesValue.toObject().isEmpty()) {
        result.errors.append(QStringLiteral("theme index must declare a non-empty themes object"));
        result.ok = false;
        return result;
    }

    const QJsonObject themes = themesValue.toObject();
    for (const QString &themeName : themes.keys()) {
        if (themeName.isEmpty()) {
            result.errors.append(QStringLiteral("theme index contains an empty theme name"));
            continue;
        }

        const QJsonValue themeValue = themes.value(themeName);
        if (!themeValue.isObject()) {
            result.errors.append(QStringLiteral("theme '%1' must be an object").arg(themeName));
            continue;
        }

        const QJsonObject theme = themeValue.toObject();
        const QJsonValue displayNameValue = theme.value(QStringLiteral("displayName"));
        if (!displayNameValue.isString() || displayNameValue.toString().isEmpty()) {
            result.errors.append(QStringLiteral("theme '%1' must declare a non-empty displayName").arg(themeName));
        }

        QString basePath;
        if (theme.contains(QStringLiteral("basePath"))) {
            basePath = validatedPath(indexPath, themeName, QString(), QStringLiteral("basePath"),
                                     theme.value(QStringLiteral("basePath")), &result.errors);
        }

        const bool hasPath = theme.contains(QStringLiteral("path"));
        const bool hasVariants = theme.contains(QStringLiteral("variants"));
        if (hasPath && hasVariants) {
            result.errors.append(QStringLiteral("theme '%1' must not declare both path and variants").arg(themeName));
        }

        if (hasVariants) {
            const QJsonValue variantsValue = theme.value(QStringLiteral("variants"));
            if (!variantsValue.isObject() || variantsValue.toObject().isEmpty()) {
                result.errors.append(QStringLiteral("theme '%1' variants must be a non-empty object").arg(themeName));
                continue;
            }

            const QJsonValue defaultVariantValue = theme.value(QStringLiteral("defaultVariant"));
            if (!defaultVariantValue.isString() || defaultVariantValue.toString().isEmpty()) {
                result.errors.append(QStringLiteral("theme '%1' must declare a non-empty defaultVariant").arg(themeName));
            } else if (themeName == result.registry.m_defaultTheme) {
                result.registry.m_defaultVariant = defaultVariantValue.toString();
            }

            const QJsonObject variants = variantsValue.toObject();
            if (defaultVariantValue.isString()
                && !variants.contains(defaultVariantValue.toString())) {
                result.errors.append(QStringLiteral("theme '%1' defaultVariant '%2' is not registered")
                                         .arg(themeName, defaultVariantValue.toString()));
            }

            for (const QString &variantName : variants.keys()) {
                if (variantName.isEmpty()) {
                    result.errors.append(QStringLiteral("theme '%1' contains an empty variant name").arg(themeName));
                    continue;
                }

                const QString manifestPath = validatedPath(indexPath, themeName, variantName, QStringLiteral("variants"),
                                                           variants.value(variantName), &result.errors);
                result.registry.m_entries.append({
                    themeName,
                    displayNameValue.toString(themeName),
                    variantName,
                    manifestPath,
                    basePath,
                });
            }
            continue;
        }

        if (!hasPath) {
            result.errors.append(QStringLiteral("theme '%1' must declare path or variants").arg(themeName));
            continue;
        }

        const QString manifestPath = validatedPath(indexPath, themeName, QString(), QStringLiteral("path"),
                                                   theme.value(QStringLiteral("path")), &result.errors);
        result.registry.m_entries.append({
            themeName,
            displayNameValue.toString(themeName),
            QString(),
            manifestPath,
            basePath,
        });
    }

    if (!result.registry.m_defaultTheme.isEmpty()
        && !hasThemeEntry(result.registry.m_entries, result.registry.m_defaultTheme)) {
        result.errors.append(QStringLiteral("defaultTheme '%1' is not registered").arg(result.registry.m_defaultTheme));
    }

    result.ok = result.errors.isEmpty();
    return result;
}

MerceThemeRegistryLookupResult MerceThemeRegistry::lookup(const QString &theme, const QString &variant) const
{
    MerceThemeRegistryLookupResult result;

    bool foundTheme = false;
    QString effectiveVariant = variant;
    if (theme == m_defaultTheme && effectiveVariant.isEmpty())
        effectiveVariant = m_defaultVariant;

    for (const auto &entry : m_entries) {
        if (entry.theme != theme)
            continue;

        foundTheme = true;
        if (entry.variant == effectiveVariant) {
            result.ok = true;
            result.entry = entry;
            return result;
        }
    }

    if (!foundTheme) {
        result.errors.append(QStringLiteral("theme '%1' is not registered").arg(theme));
    } else if (effectiveVariant.isEmpty()) {
        result.errors.append(QStringLiteral("theme '%1' requires a registered variant").arg(theme));
    } else {
        result.errors.append(QStringLiteral("variant '%1' is not registered for theme '%2'").arg(effectiveVariant, theme));
    }

    return result;
}

MerceThemeRegistryLookupResult MerceThemeRegistry::defaultEntry() const
{
    return lookup(m_defaultTheme, m_defaultVariant);
}
