#pragma once

#include <QColor>
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

    QVariantList none() const { return {}; }
    QVariantList small() const
    {
        return {
            shadow(0, 1, 2, QColor::fromRgbF(31.0 / 255.0, 21.0 / 255.0, 16.0 / 255.0, 0.04)),
            shadow(0, 1, 3, QColor::fromRgbF(31.0 / 255.0, 21.0 / 255.0, 16.0 / 255.0, 0.08)),
        };
    }
    QVariantList medium() const
    {
        return {
            shadow(0, 4, 6, QColor::fromRgbF(31.0 / 255.0, 21.0 / 255.0, 16.0 / 255.0, 0.08)),
            shadow(0, 2, 4, QColor::fromRgbF(31.0 / 255.0, 21.0 / 255.0, 16.0 / 255.0, 0.04)),
        };
    }
    QVariantList large() const
    {
        return {
            shadow(0, 10, 15, QColor::fromRgbF(31.0 / 255.0, 21.0 / 255.0, 16.0 / 255.0, 0.08)),
            shadow(0, 4, 6, QColor::fromRgbF(31.0 / 255.0, 21.0 / 255.0, 16.0 / 255.0, 0.04)),
        };
    }
    QVariantList xlarge() const
    {
        return {
            shadow(0, 20, 25, QColor::fromRgbF(31.0 / 255.0, 21.0 / 255.0, 16.0 / 255.0, 0.08)),
            shadow(0, 10, 10, QColor::fromRgbF(31.0 / 255.0, 21.0 / 255.0, 16.0 / 255.0, 0.04)),
        };
    }
    QVariantList xxlarge() const
    {
        return {
            shadow(0, 25, 50, QColor::fromRgbF(31.0 / 255.0, 21.0 / 255.0, 16.0 / 255.0, 0.15)),
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
    static QVariantMap shadow(int xOffset, int yOffset, int blur, const QColor &color)
    {
        QVariantMap map;
        map.insert(QStringLiteral("xOffset"), xOffset);
        map.insert(QStringLiteral("yOffset"), yOffset);
        map.insert(QStringLiteral("blur"), blur);
        map.insert(QStringLiteral("color"), color);
        return map;
    }
};
