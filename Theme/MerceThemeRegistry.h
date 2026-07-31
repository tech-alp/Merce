#pragma once

#include <QHash>
#include <QJsonObject>
#include <QList>
#include <QString>
#include <QStringList>

enum class MerceThemeSourceKind
{
    ResolvedTheme,
    TenantBrand,
};

struct MerceThemeRegistryEntry
{
    QString brandId;
    QString displayName;
    QString mode;
    QString sourcePath;
    MerceThemeSourceKind sourceKind = MerceThemeSourceKind::ResolvedTheme;
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
    static MerceThemeRegistryResult fromTenantBrand(const QJsonObject &document,
                                                    const QString &documentPath);

    MerceThemeRegistryLookupResult lookup(const QString &brandId,
                                          const QString &mode = QString()) const;
    MerceThemeRegistryLookupResult defaultEntry() const;

    QString defaultBrand() const { return m_defaultBrand; }
    QString defaultMode() const { return m_defaultMode; }
    QString defaultModeForBrand(const QString &brandId) const
    {
        return m_defaultModesByBrand.value(brandId);
    }
    const QList<MerceThemeRegistryEntry> &entries() const { return m_entries; }
    bool isEmpty() const { return m_entries.isEmpty(); }
    bool appendRegistry(const MerceThemeRegistry &registry, QStringList *errors);

private:
    QString m_defaultBrand;
    QString m_defaultMode;
    QHash<QString, QString> m_defaultModesByBrand;
    QList<MerceThemeRegistryEntry> m_entries;
};

struct MerceThemeRegistryResult
{
    bool ok = false;
    MerceThemeRegistry registry;
    QStringList errors;
};

struct MerceProfileRegistryEntry
{
    QString profileId;
    QString displayName;
    QString manifestPath;
};

struct MerceProfileRegistryLookupResult
{
    bool ok = false;
    MerceProfileRegistryEntry entry;
    QStringList errors;
};

struct MerceProfileRegistryResult;

class MerceProfileRegistry
{
public:
    static MerceProfileRegistryResult fromJson(const QJsonObject &index,
                                               const QString &indexPath);

    MerceProfileRegistryLookupResult lookup(const QString &profileId) const;
    MerceProfileRegistryLookupResult defaultEntry() const;

    QString defaultProfile() const { return m_defaultProfile; }
    const QList<MerceProfileRegistryEntry> &entries() const { return m_entries; }
    bool isEmpty() const { return m_entries.isEmpty(); }
    bool appendRegistry(const MerceProfileRegistry &registry, QStringList *errors);

private:
    QString m_defaultProfile;
    QList<MerceProfileRegistryEntry> m_entries;
};

struct MerceProfileRegistryResult
{
    bool ok = false;
    MerceProfileRegistry registry;
    QStringList errors;
};
