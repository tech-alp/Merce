#pragma once

#include <QObject>
#include <QVariantMap>
#include <QtQml/qqmlregistration.h>

class MerceTypography : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString fontDisplay READ fontDisplay NOTIFY changed FINAL)
    Q_PROPERTY(QString fontBody READ fontBody NOTIFY changed FINAL)
    Q_PROPERTY(QString fontMono READ fontMono NOTIFY changed FINAL)
    Q_PROPERTY(QString fontDisplayFallback READ fontDisplayFallback NOTIFY changed FINAL)
    Q_PROPERTY(QString fontBodyFallback READ fontBodyFallback NOTIFY changed FINAL)
    Q_PROPERTY(int sizeXSmall READ sizeXSmall NOTIFY changed FINAL)
    Q_PROPERTY(int sizeSmall READ sizeSmall NOTIFY changed FINAL)
    Q_PROPERTY(int sizeMedium READ sizeMedium NOTIFY changed FINAL)
    Q_PROPERTY(int sizeLarge READ sizeLarge NOTIFY changed FINAL)
    Q_PROPERTY(int sizeXLarge READ sizeXLarge NOTIFY changed FINAL)
    Q_PROPERTY(int size2XLarge READ size2XLarge NOTIFY changed FINAL)
    Q_PROPERTY(int size3XLarge READ size3XLarge NOTIFY changed FINAL)
    Q_PROPERTY(int size4XLarge READ size4XLarge NOTIFY changed FINAL)
    Q_PROPERTY(int size5XLarge READ size5XLarge NOTIFY changed FINAL)
    Q_PROPERTY(int size6XLarge READ size6XLarge NOTIFY changed FINAL)
    Q_PROPERTY(int size7XLarge READ size7XLarge NOTIFY changed FINAL)
    Q_PROPERTY(int weightRegular READ weightRegular NOTIFY changed FINAL)
    Q_PROPERTY(int weightMedium READ weightMedium NOTIFY changed FINAL)
    Q_PROPERTY(int weightSemibold READ weightSemibold NOTIFY changed FINAL)
    Q_PROPERTY(int weightBold READ weightBold NOTIFY changed FINAL)
    Q_PROPERTY(qreal leadingTight READ leadingTight NOTIFY changed FINAL)
    Q_PROPERTY(qreal leadingSnug READ leadingSnug NOTIFY changed FINAL)
    Q_PROPERTY(qreal leadingNormal READ leadingNormal NOTIFY changed FINAL)
    Q_PROPERTY(qreal leadingRelaxed READ leadingRelaxed NOTIFY changed FINAL)
    Q_PROPERTY(qreal trackingTight READ trackingTight NOTIFY changed FINAL)
    Q_PROPERTY(qreal trackingNormal READ trackingNormal NOTIFY changed FINAL)
    Q_PROPERTY(qreal trackingWide READ trackingWide NOTIFY changed FINAL)
    Q_PROPERTY(qreal trackingWider READ trackingWider NOTIFY changed FINAL)
    Q_PROPERTY(qreal trackingWidest READ trackingWidest NOTIFY changed FINAL)
    Q_PROPERTY(QVariantMap display READ display NOTIFY changed FINAL)
    Q_PROPERTY(QVariantMap h1 READ h1 NOTIFY changed FINAL)
    Q_PROPERTY(QVariantMap h2 READ h2 NOTIFY changed FINAL)
    Q_PROPERTY(QVariantMap h3 READ h3 NOTIFY changed FINAL)
    Q_PROPERTY(QVariantMap h4 READ h4 NOTIFY changed FINAL)
    Q_PROPERTY(QVariantMap body READ body NOTIFY changed FINAL)
    Q_PROPERTY(QVariantMap bodyLarge READ bodyLarge NOTIFY changed FINAL)
    Q_PROPERTY(QVariantMap bodySmall READ bodySmall NOTIFY changed FINAL)
    Q_PROPERTY(QVariantMap caption READ caption NOTIFY changed FINAL)
    Q_PROPERTY(QVariantMap overline READ overline NOTIFY changed FINAL)
    Q_PROPERTY(QVariantMap button READ button NOTIFY changed FINAL)
    Q_PROPERTY(QVariantMap price READ price NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MerceTypography(QObject *parent = nullptr) : QObject(parent) {}

    QString fontDisplay() const { return QStringLiteral("Playfair Display"); }
    QString fontBody() const { return QStringLiteral("DM Sans"); }
    QString fontMono() const { return QStringLiteral("SF Mono"); }
    QString fontDisplayFallback() const { return QStringLiteral("Georgia, serif"); }
    QString fontBodyFallback() const { return QStringLiteral("-apple-system, BlinkMacSystemFont, sans-serif"); }
    int sizeXSmall() const { return 12; }
    int sizeSmall() const { return 14; }
    int sizeMedium() const { return 16; }
    int sizeLarge() const { return 18; }
    int sizeXLarge() const { return 20; }
    int size2XLarge() const { return 24; }
    int size3XLarge() const { return 30; }
    int size4XLarge() const { return 36; }
    int size5XLarge() const { return 48; }
    int size6XLarge() const { return 60; }
    int size7XLarge() const { return 72; }
    int weightRegular() const { return 400; }
    int weightMedium() const { return 500; }
    int weightSemibold() const { return 600; }
    int weightBold() const { return 700; }
    qreal leadingTight() const { return 1.2; }
    qreal leadingSnug() const { return 1.35; }
    qreal leadingNormal() const { return 1.5; }
    qreal leadingRelaxed() const { return 1.7; }
    qreal trackingTight() const { return -0.02; }
    qreal trackingNormal() const { return 0.0; }
    qreal trackingWide() const { return 0.02; }
    qreal trackingWider() const { return 0.05; }
    qreal trackingWidest() const { return 0.1; }

    QVariantMap display() const { return preset(fontDisplay(), size5XLarge(), weightBold(), leadingTight(), trackingTight()); }
    QVariantMap h1() const { return preset(fontDisplay(), size4XLarge(), weightSemibold(), leadingTight(), trackingTight()); }
    QVariantMap h2() const { return preset(fontDisplay(), size3XLarge(), weightSemibold(), leadingSnug(), trackingTight()); }
    QVariantMap h3() const { return preset(fontDisplay(), size2XLarge(), weightMedium(), leadingSnug(), trackingTight()); }
    QVariantMap h4() const { return preset(fontBody(), sizeXLarge(), weightSemibold(), leadingSnug(), trackingNormal()); }
    QVariantMap body() const { return preset(fontBody(), sizeMedium(), weightRegular(), leadingNormal(), trackingNormal()); }
    QVariantMap bodyLarge() const { return preset(fontBody(), sizeLarge(), weightRegular(), leadingRelaxed(), trackingNormal()); }
    QVariantMap bodySmall() const { return preset(fontBody(), sizeSmall(), weightRegular(), leadingRelaxed(), trackingNormal()); }
    QVariantMap caption() const { return preset(fontBody(), sizeXSmall(), weightMedium(), leadingNormal(), trackingWide()); }
    QVariantMap overline() const { return preset(fontBody(), sizeXSmall(), weightSemibold(), leadingNormal(), trackingWidest(), true); }
    QVariantMap button() const { return preset(fontBody(), sizeSmall(), weightSemibold(), leadingTight(), trackingNormal()); }
    QVariantMap price() const { return preset(fontBody(), size2XLarge(), weightBold(), leadingTight(), trackingTight()); }

signals:
    void changed();

private:
    static QVariantMap preset(const QString &family, int size, int weight, qreal leading, qreal tracking, bool uppercase = false)
    {
        QVariantMap map;
        map.insert(QStringLiteral("family"), family);
        map.insert(QStringLiteral("size"), size);
        map.insert(QStringLiteral("weight"), weight);
        map.insert(QStringLiteral("leading"), leading);
        map.insert(QStringLiteral("tracking"), tracking);
        if (uppercase)
            map.insert(QStringLiteral("uppercase"), true);
        return map;
    }
};
