#pragma once

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QtQml/qqmlregistration.h>

class MerceShadows : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList none READ none NOTIFY changed FINAL)
    Q_PROPERTY(QVariantList small READ small NOTIFY changed FINAL)
    Q_PROPERTY(QVariantList medium READ medium NOTIFY changed FINAL)
    Q_PROPERTY(QVariantList large READ large NOTIFY changed FINAL)
    Q_PROPERTY(QVariantList xlarge READ xlarge NOTIFY changed FINAL)
    Q_PROPERTY(QVariantList xxlarge READ xxlarge NOTIFY changed FINAL)
    Q_PROPERTY(QVariantList button READ button NOTIFY changed FINAL)
    Q_PROPERTY(QVariantList card READ card NOTIFY changed FINAL)
    Q_PROPERTY(QVariantList cardElevated READ cardElevated NOTIFY changed FINAL)
    Q_PROPERTY(QVariantList dialog READ dialog NOTIFY changed FINAL)
    Q_PROPERTY(QVariantList dropdown READ dropdown NOTIFY changed FINAL)
    Q_PROPERTY(QVariantList tooltip READ tooltip NOTIFY changed FINAL)
    Q_PROPERTY(QVariantList hover READ hover NOTIFY changed FINAL)
    Q_PROPERTY(QVariantList focus READ focus NOTIFY changed FINAL)
    Q_PROPERTY(QVariantList pressed READ pressed NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MerceShadows(QObject *parent = nullptr) : QObject(parent) {}

    // Geometry follows the Tailwind scale, spread included. Opacity increases
    // with elevation so adjacent steps stay legible on tokenized surfaces. The
    // wide layer carries the float, the tight one the contact edge.
    QVariantList none() const { return {}; }
    QVariantList small() const
    {
        return {
            shadow(0, 1, 3, 0, 0.10),
            shadow(0, 1, 2, -1, 0.10),
        };
    }
    QVariantList medium() const
    {
        return {
            shadow(0, 4, 6, -1, 0.12),
            shadow(0, 2, 4, -2, 0.12),
        };
    }
    QVariantList large() const
    {
        return {
            shadow(0, 10, 15, -3, 0.14),
            shadow(0, 4, 6, -4, 0.14),
        };
    }
    QVariantList xlarge() const
    {
        return {
            shadow(0, 20, 25, -5, 0.16),
            shadow(0, 8, 10, -6, 0.16),
        };
    }
    QVariantList xxlarge() const
    {
        return {
            shadow(0, 25, 50, -12, 0.25),
        };
    }

    QVariantList button() const { return small(); }
    QVariantList card() const { return medium(); }
    QVariantList cardElevated() const { return large(); }
    QVariantList dialog() const { return xxlarge(); }
    QVariantList dropdown() const { return xlarge(); }
    QVariantList tooltip() const { return medium(); }
    QVariantList hover() const { return medium(); }
    QVariantList focus() const { return medium(); }
    QVariantList pressed() const { return small(); }

signals:
    void changed();

private:
    // A layer carries geometry and opacity only. The hue is colors.surface.shadow,
    // which varies per theme (near-black in light modes, pure black in dark ones);
    // baking a colour in here made every theme share one warm brown shadow.
    //
    // spread insets the shadow rect before the blur, which is what keeps a shadow
    // tucked under its surface instead of bleeding out the sides. The scale below
    // comes from Tailwind, whose every step depends on it.
    static QVariantMap shadow(int xOffset, int yOffset, int blur, int spread, qreal opacity)
    {
        QVariantMap map;
        map.insert(QStringLiteral("xOffset"), xOffset);
        map.insert(QStringLiteral("yOffset"), yOffset);
        map.insert(QStringLiteral("blur"), blur);
        map.insert(QStringLiteral("spread"), spread);
        map.insert(QStringLiteral("opacity"), opacity);
        return map;
    }
};
