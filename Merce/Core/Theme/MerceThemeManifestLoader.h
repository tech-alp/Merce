#pragma once

#include "MerceThemeManifest.h"

#include <QString>

class MerceThemeManifestLoader
{
public:
    explicit MerceThemeManifestLoader(QString indexPath = QStringLiteral(":/merce/themes/index.json"));

    MerceThemeLoadResult loadDefault() const;
    MerceThemeLoadResult load(const QString &theme, const QString &variant = QString()) const;

private:
    QString m_indexPath;
};
