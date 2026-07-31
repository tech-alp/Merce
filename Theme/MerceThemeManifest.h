#pragma once

#include <QJsonObject>
#include <QString>
#include <QStringList>

struct MerceThemeLoadResult
{
    bool ok = false;
    QString brandId;
    QString mode;
    QString profile;
    QStringList errors;
    QJsonObject finalManifest;
};
