#pragma once

#include <QJsonObject>
#include <QString>
#include <QStringList>

struct MerceThemeLoadResult
{
    bool ok = false;
    QString theme;
    QString variant;
    bool usedFallback = false;
    QStringList errors;
    QJsonObject finalManifest;
};
