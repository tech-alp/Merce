#pragma once

#include <QJsonObject>
#include <QList>
#include <QString>

struct ThemeValidationError
{
    QString code;
    QString path;
    QString message;
};

struct ThemeValidationResult
{
    bool ok = false;
    QList<ThemeValidationError> errors;
};

class ThemeValidator
{
public:
    static constexpr int kSupportedTenantBrandSchemaVersion = 1;
    static constexpr int kSupportedResolvedThemeSchemaVersion = 1;
    static constexpr double kBodyContrastRatio = 4.5;
    static constexpr double kLargeAndNonTextContrastRatio = 3.0;
    static constexpr double kPrimaryBodyContrastRatio = 7.0;
    // CAM16-UCS ΔE below 5 is close enough to be mistaken for the locked
    // semantic colour; a wider threshold incorrectly rejects AlGit's teal.
    static constexpr double kStatusProximityDeltaE = 5.0;

    static ThemeValidationResult validateTenantBrand(const QJsonObject &document);
    static ThemeValidationResult validateResolvedTheme(const QJsonObject &document);
    static ThemeValidationResult validateColors(const QJsonObject &colors);
};
