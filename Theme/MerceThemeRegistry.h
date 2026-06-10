#pragma once

#include <QJsonObject>
#include <QHash>
#include <QList>
#include <QString>
#include <QStringList>

struct MerceThemeRegistryEntry
{
    QString theme;
    QString displayName;
    QString variant;
    QString manifestPath;
    QString basePath;
};

struct MerceThemeRegistryLookupResult
{
    bool ok = false;
    MerceThemeRegistryEntry entry;
    QStringList errors;
};

struct MerceThemeRegistryResult;

class MerceThemeRegistry
{
public:
    static MerceThemeRegistryResult fromJson(const QJsonObject &index, const QString &indexPath);

    MerceThemeRegistryLookupResult lookup(const QString &theme, const QString &variant = QString()) const;
    MerceThemeRegistryLookupResult defaultEntry() const;

    QString defaultTheme() const { return m_defaultTheme; }
    QString defaultVariant() const { return m_defaultVariant; }
    QString defaultVariantForTheme(const QString &theme) const { return m_defaultVariantsByTheme.value(theme); }
    QList<MerceThemeRegistryEntry> entries() const { return m_entries; }
    bool containsTheme(const QString &theme) const;
    bool appendRegistry(const MerceThemeRegistry &registry, QStringList *errors);

private:
    QString m_defaultTheme;
    QString m_defaultVariant;
    QHash<QString, QString> m_defaultVariantsByTheme;
    QList<MerceThemeRegistryEntry> m_entries;
};

struct MerceThemeRegistryResult
{
    bool ok = false;
    MerceThemeRegistry registry;
    QStringList errors;
};
