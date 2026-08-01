#pragma once

#include <QColor>
#include <QJsonObject>
#include <QMetaType>
#include <QString>

enum class BrandMode {
    Light,
    Dark,
};

Q_DECLARE_METATYPE(BrandMode)

struct BrandDerivationResult
{
    bool ok = false;
    QJsonObject colors;
    QJsonObject state;
    // Interaction previews prove direction without adding obsolete hover/pressed
    // roles to the resolved 42-role manifest; runtime states use opacity layers.
    QColor hoverContainer;
    QColor pressedContainer;
    QString errorCode;
    QString errorPath;
    QString errorMessage;
};

class BrandDerivation
{
public:
    // CAM16-UCS ΔE 10 allows a necessary, still recognisable luminance correction;
    // larger moves are an obvious repaint and must be rejected instead of hidden.
    static constexpr double kMaxSeedContainerDeltaE = 10.0;

    static BrandDerivationResult derive(const QColor &seed, BrandMode mode);
};
