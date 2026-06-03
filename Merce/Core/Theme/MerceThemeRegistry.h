#pragma once

#include <QJsonObject>
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
    QList<MerceThemeRegistryEntry> entries() const { return m_entries; }

private:
    QString m_defaultTheme;
    QString m_defaultVariant;
    QList<MerceThemeRegistryEntry> m_entries;
};

struct MerceThemeRegistryResult
{
    bool ok = false;
    MerceThemeRegistry registry;
    QStringList errors;
};
