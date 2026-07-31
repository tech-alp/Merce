#include "BrandDerivation.h"

#include "cpp/cam/cam.h"
#include "cpp/cam/hct.h"
#include "cpp/contrast/contrast.h"
#include "cpp/palettes/tones.h"
#include "cpp/utils/utils.h"

#include <algorithm>
#include <cmath>
#include <utility>

using namespace material_color_utilities;

namespace {

Argb argb(const QColor &color)
{
    return ArgbFromRgb(color.red(), color.green(), color.blue());
}

QColor color(Argb value)
{
    return QColor(RedFromInt(value), GreenFromInt(value), BlueFromInt(value));
}

QString colorString(const QColor &value)
{
    return value.name(value.alpha() == 255 ? QColor::HexRgb : QColor::HexArgb).toUpper();
}

double deltaE(const QColor &left, const QColor &right)
{
    const Cam a = CamFromInt(argb(left));
    const Cam b = CamFromInt(argb(right));
    const double dj = a.jstar - b.jstar;
    const double da = a.astar - b.astar;
    const double db = a.bstar - b.bstar;
    const double prime = std::sqrt(dj * dj + da * da + db * db);
    return 1.41 * std::pow(prime, 0.63);
}

double hueDistance(double left, double right)
{
    return std::abs(std::remainder(left - right, 360.0));
}

QJsonObject triple(const QColor &container, const QColor &content, const QColor &outline)
{
    return {
        {QStringLiteral("container"), colorString(container)},
        {QStringLiteral("content"), colorString(content)},
        {QStringLiteral("outline"), colorString(outline)},
    };
}

QColor paletteColor(const TonalPalette &palette, double tone)
{
    return color(palette.get(std::clamp(tone, 0.0, 100.0)));
}

double contrastingTone(double backgroundTone, double ratio)
{
    const double lighter = Lighter(backgroundTone, ratio);
    return lighter >= 0.0 ? lighter : Darker(backgroundTone, ratio);
}

QJsonObject surfaces(BrandMode mode)
{
    if (mode == BrandMode::Dark) {
        return {
            {QStringLiteral("canvas"), QStringLiteral("#0E1514")},
            {QStringLiteral("container"), QStringLiteral("#191F1E")},
            {QStringLiteral("containerRaised"), QStringLiteral("#242B29")},
            {QStringLiteral("containerSunken"), QStringLiteral("#0A100F")},
            {QStringLiteral("containerTinted"), QStringLiteral("#162421")},
            {QStringLiteral("floating"), QStringLiteral("#242B29")},
            {QStringLiteral("scrim"), QStringLiteral("#A3000000")},
            {QStringLiteral("inverse"), QStringLiteral("#F6F4EE")},
        };
    }

    return {
        {QStringLiteral("canvas"), QStringLiteral("#F6F4EE")},
        {QStringLiteral("container"), QStringLiteral("#FFFFFF")},
        {QStringLiteral("containerRaised"), QStringLiteral("#FFFFFF")},
        {QStringLiteral("containerSunken"), QStringLiteral("#EDEAE2")},
        {QStringLiteral("containerTinted"), QStringLiteral("#EFF5F3")},
        {QStringLiteral("floating"), QStringLiteral("#FFFFFF")},
        {QStringLiteral("scrim"), QStringLiteral("#A3000000")},
        {QStringLiteral("inverse"), QStringLiteral("#0E1514")},
    };
}

QJsonObject statuses(BrandMode mode)
{
    if (mode == BrandMode::Dark) {
        return {
            {QStringLiteral("success"),
             triple(QColor(QStringLiteral("#153322")),
                    QColor(QStringLiteral("#6EDB91")),
                    QColor(QStringLiteral("#6EDB91")))},
            {QStringLiteral("warning"),
             triple(QColor(QStringLiteral("#3A2A0A")),
                    QColor(QStringLiteral("#F4C15D")),
                    QColor(QStringLiteral("#F4C15D")))},
            {QStringLiteral("error"),
             triple(QColor(QStringLiteral("#3B1716")),
                    QColor(QStringLiteral("#FFB4AB")),
                    QColor(QStringLiteral("#FFB4AB")))},
            {QStringLiteral("info"),
             triple(QColor(QStringLiteral("#172A46")),
                    QColor(QStringLiteral("#A8C7FA")),
                    QColor(QStringLiteral("#A8C7FA")))},
            {QStringLiteral("neutral"),
             triple(QColor(QStringLiteral("#242B29")),
                    QColor(QStringLiteral("#CBD3D0")),
                    QColor(QStringLiteral("#CBD3D0")))},
        };
    }

    return {
        {QStringLiteral("success"),
         triple(QColor(QStringLiteral("#ECFDF3")),
                QColor(QStringLiteral("#166B3B")),
                QColor(QStringLiteral("#166B3B")))},
        {QStringLiteral("warning"),
         triple(QColor(QStringLiteral("#FFFBEB")),
                QColor(QStringLiteral("#7A4200")),
                QColor(QStringLiteral("#7A4200")))},
        {QStringLiteral("error"),
         triple(QColor(QStringLiteral("#FEF2F2")),
                QColor(QStringLiteral("#A61B14")),
                QColor(QStringLiteral("#A61B14")))},
        {QStringLiteral("info"),
         triple(QColor(QStringLiteral("#EFF4FC")),
                QColor(QStringLiteral("#245EA8")),
                QColor(QStringLiteral("#245EA8")))},
        {QStringLiteral("neutral"),
         triple(QColor(QStringLiteral("#F1F3F2")),
                QColor(QStringLiteral("#39413F")),
                QColor(QStringLiteral("#39413F")))},
    };
}

QJsonObject contents(BrandMode mode, const TonalPalette &palette, double canvasTone)
{
    const QColor link = paletteColor(palette, contrastingTone(canvasTone, 4.5));
    if (mode == BrandMode::Dark) {
        return {
            {QStringLiteral("primary"), QStringLiteral("#F2F5F3")},
            {QStringLiteral("secondary"), QStringLiteral("#B3BDB9")},
            {QStringLiteral("tertiary"), QStringLiteral("#949E9A")},
            {QStringLiteral("inverse"), QStringLiteral("#151A19")},
            {QStringLiteral("disabled"), QStringLiteral("#78817E")},
            {QStringLiteral("link"), colorString(link)},
        };
    }

    return {
        {QStringLiteral("primary"), QStringLiteral("#151A19")},
        {QStringLiteral("secondary"), QStringLiteral("#4E5B58")},
        {QStringLiteral("tertiary"), QStringLiteral("#606D69")},
        {QStringLiteral("inverse"), QStringLiteral("#FFFFFF")},
        {QStringLiteral("disabled"), QStringLiteral("#7D8783")},
        {QStringLiteral("link"), colorString(link)},
    };
}

QColor focusColor(const QColor &candidate, const QJsonObject &status, BrandMode mode)
{
    const Hct focus(argb(candidate));
    for (const QString &name : status.keys()) {
        const QColor semantic(
            status.value(name).toObject().value(QStringLiteral("content")).toString());
        const Hct semanticHct(argb(semantic));
        if (focus.get_chroma() >= 10.0 && semanticHct.get_chroma() >= 10.0
            && hueDistance(focus.get_hue(), semanticHct.get_hue()) < 30.0) {
            return QColor(mode == BrandMode::Dark ? QStringLiteral("#CBD3D0")
                                                  : QStringLiteral("#151A19"));
        }
    }
    return candidate;
}

BrandDerivationResult failure(QString code, QString path, QString message)
{
    BrandDerivationResult result;
    result.errorCode = std::move(code);
    result.errorPath = std::move(path);
    result.errorMessage = std::move(message);
    return result;
}

} // namespace

BrandDerivationResult BrandDerivation::derive(const QColor &seed, BrandMode mode)
{
    if (!seed.isValid()) {
        return failure(QStringLiteral("seed.invalid"),
                       QStringLiteral("seed"),
                       QStringLiteral("seed must be a valid color string"));
    }

    const QColor opaqueSeed(seed.red(), seed.green(), seed.blue());
    const Hct seedHct(argb(opaqueSeed));
    const TonalPalette palette(seedHct);
    const QJsonObject surface = surfaces(mode);
    const QColor canvas(surface.value(QStringLiteral("canvas")).toString());
    const double canvasTone = Hct(argb(canvas)).get_tone();

    double containerTone = seedHct.get_tone();
    if (RatioOfTones(containerTone, canvasTone) < 3.0) {
        containerTone = mode == BrandMode::Dark ? Lighter(canvasTone, 3.0)
                                                : Darker(canvasTone, 3.0);
    }
    if (containerTone < 0.0) {
        return failure(QStringLiteral("seed.contrast_unreachable"),
                       QStringLiteral("seed"),
                       QStringLiteral("seed cannot produce a primary container with 3:1 contrast"));
    }

    // Reserve enough room for both mode-aware state previews at gamut boundaries.
    containerTone = std::clamp(containerTone, 8.0, 92.0);

    const QColor primaryContainer = paletteColor(palette, containerTone);
    const double deviation = deltaE(opaqueSeed, primaryContainer);
    if (deviation > kMaxSeedContainerDeltaE) {
        return failure(
            QStringLiteral("seed.deviation_exceeded"),
            QStringLiteral("seed"),
            QStringLiteral("primary container would move %1 ΔE from the seed; maximum is %2")
                .arg(deviation, 0, 'f', 2)
                .arg(kMaxSeedContainerDeltaE, 0, 'f', 2));
    }

    const double contentTone = contrastingTone(containerTone, 4.5);
    if (contentTone < 0.0) {
        return failure(
            QStringLiteral("seed.content_contrast_unreachable"),
            QStringLiteral("seed"),
            QStringLiteral("seed cannot produce primary content with 4.5:1 contrast"));
    }
    const QColor primaryContent = paletteColor(palette, contentTone);

    const double direction = mode == BrandMode::Dark ? 1.0 : -1.0;
    const QColor hover = paletteColor(palette, containerTone + direction * 4.0);
    const QColor pressed = paletteColor(palette, containerTone + direction * 8.0);

    const QJsonObject status = statuses(mode);
    const QColor focus = focusColor(primaryContainer, status, mode);

    QJsonObject action;
    action.insert(QStringLiteral("primary"),
                  triple(primaryContainer, primaryContent, primaryContainer));
    if (mode == BrandMode::Dark) {
        action.insert(QStringLiteral("secondary"),
                      triple(QColor(QStringLiteral("#AAB5B1")),
                             QColor(QStringLiteral("#16201D")),
                             QColor(QStringLiteral("#AAB5B1"))));
        action.insert(QStringLiteral("destructive"),
                      triple(QColor(QStringLiteral("#FFB4AB")),
                             QColor(QStringLiteral("#3B0907")),
                             QColor(QStringLiteral("#FFB4AB"))));
    } else {
        action.insert(QStringLiteral("secondary"),
                      triple(QColor(QStringLiteral("#53615D")),
                             QColor(QStringLiteral("#FFFFFF")),
                             QColor(QStringLiteral("#53615D"))));
        action.insert(QStringLiteral("destructive"),
                      triple(QColor(QStringLiteral("#B3261E")),
                             QColor(QStringLiteral("#FFFFFF")),
                             QColor(QStringLiteral("#B3261E"))));
    }

    const QJsonObject outline{
        {QStringLiteral("subtle"),
         mode == BrandMode::Dark ? QStringLiteral("#35423F") : QStringLiteral("#CBD2CF")},
        {QStringLiteral("strong"),
         mode == BrandMode::Dark ? QStringLiteral("#697572") : QStringLiteral("#87928E")},
        {QStringLiteral("focus"), colorString(focus)},
    };

    BrandDerivationResult result;
    result.ok = true;
    result.colors = {
        {QStringLiteral("surface"), surface},
        {QStringLiteral("content"), contents(mode, palette, canvasTone)},
        {QStringLiteral("action"), action},
        {QStringLiteral("status"), status},
        {QStringLiteral("outline"), outline},
    };
    result.state = {
        {QStringLiteral("layer"),
         QJsonObject{
             {QStringLiteral("hover"), 0.08},
             {QStringLiteral("focus"), 0.10},
             {QStringLiteral("pressed"), 0.10},
             {QStringLiteral("selected"), 0.12},
         }},
        {QStringLiteral("disabled"),
         QJsonObject{
             {QStringLiteral("containerOpacity"), 0.12},
             {QStringLiteral("contentOpacity"), 0.38},
         }},
    };
    result.hoverContainer = hover;
    result.pressedContainer = pressed;
    return result;
}
