#pragma once

#include <QJsonObject>
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

    QString fontDisplay() const { return m_fontDisplay; }
    QString fontBody() const { return m_fontBody; }
    QString fontMono() const { return m_fontMono; }
    QString fontDisplayFallback() const { return m_fontDisplayFallback; }
    QString fontBodyFallback() const { return m_fontBodyFallback; }
    int sizeXSmall() const { return m_sizeXSmall; }
    int sizeSmall() const { return m_sizeSmall; }
    int sizeMedium() const { return m_sizeMedium; }
    int sizeLarge() const { return m_sizeLarge; }
    int sizeXLarge() const { return m_sizeXLarge; }
    int size2XLarge() const { return m_size2XLarge; }
    int size3XLarge() const { return m_size3XLarge; }
    int size4XLarge() const { return m_size4XLarge; }
    int size5XLarge() const { return m_size5XLarge; }
    int size6XLarge() const { return m_size6XLarge; }
    int size7XLarge() const { return m_size7XLarge; }
    int weightRegular() const { return m_weightRegular; }
    int weightMedium() const { return m_weightMedium; }
    int weightSemibold() const { return m_weightSemibold; }
    int weightBold() const { return m_weightBold; }
    qreal leadingTight() const { return m_leadingTight; }
    qreal leadingSnug() const { return m_leadingSnug; }
    qreal leadingNormal() const { return m_leadingNormal; }
    qreal leadingRelaxed() const { return m_leadingRelaxed; }
    qreal trackingTight() const { return m_trackingTight; }
    qreal trackingNormal() const { return m_trackingNormal; }
    qreal trackingWide() const { return m_trackingWide; }
    qreal trackingWider() const { return m_trackingWider; }
    qreal trackingWidest() const { return m_trackingWidest; }

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

    void applyManifestSection(const QJsonObject &section)
    {
        m_fontDisplay = section.value(QStringLiteral("displayFont")).toString();
        m_fontBody = section.value(QStringLiteral("bodyFont")).toString();
        m_fontMono = section.value(QStringLiteral("monoFont")).toString();
        m_fontDisplayFallback = section.value(QStringLiteral("displayFontFallback")).toString();
        m_fontBodyFallback = section.value(QStringLiteral("bodyFontFallback")).toString();
        m_sizeXSmall = section.value(QStringLiteral("sizeXSmall")).toInt();
        m_sizeSmall = section.value(QStringLiteral("sizeSmall")).toInt();
        m_sizeMedium = section.value(QStringLiteral("sizeMedium")).toInt();
        m_sizeLarge = section.value(QStringLiteral("sizeLarge")).toInt();
        m_sizeXLarge = section.value(QStringLiteral("sizeXLarge")).toInt();
        m_size2XLarge = section.value(QStringLiteral("size2XLarge")).toInt();
        m_size3XLarge = section.value(QStringLiteral("size3XLarge")).toInt();
        m_size4XLarge = section.value(QStringLiteral("size4XLarge")).toInt();
        m_size5XLarge = section.value(QStringLiteral("size5XLarge")).toInt();
        m_size6XLarge = section.value(QStringLiteral("size6XLarge")).toInt();
        m_size7XLarge = section.value(QStringLiteral("size7XLarge")).toInt();
        m_weightRegular = section.value(QStringLiteral("weightRegular")).toInt();
        m_weightMedium = section.value(QStringLiteral("weightMedium")).toInt();
        m_weightSemibold = section.value(QStringLiteral("weightSemibold")).toInt();
        m_weightBold = section.value(QStringLiteral("weightBold")).toInt();
        m_leadingTight = section.value(QStringLiteral("leadingTight")).toDouble();
        m_leadingSnug = section.value(QStringLiteral("leadingSnug")).toDouble();
        m_leadingNormal = section.value(QStringLiteral("leadingNormal")).toDouble();
        m_leadingRelaxed = section.value(QStringLiteral("leadingRelaxed")).toDouble();
        m_trackingTight = section.value(QStringLiteral("trackingTight")).toDouble();
        m_trackingNormal = section.value(QStringLiteral("trackingNormal")).toDouble();
        m_trackingWide = section.value(QStringLiteral("trackingWide")).toDouble();
        m_trackingWider = section.value(QStringLiteral("trackingWider")).toDouble();
        m_trackingWidest = section.value(QStringLiteral("trackingWidest")).toDouble();
        emit changed();
    }

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

    QString m_fontDisplay = QStringLiteral("Playfair Display");
    QString m_fontBody = QStringLiteral("DM Sans");
    QString m_fontMono = QStringLiteral("SF Mono");
    QString m_fontDisplayFallback = QStringLiteral("Georgia, serif");
    QString m_fontBodyFallback = QStringLiteral("-apple-system, BlinkMacSystemFont, sans-serif");
    int m_sizeXSmall = 12;
    int m_sizeSmall = 14;
    int m_sizeMedium = 16;
    int m_sizeLarge = 18;
    int m_sizeXLarge = 20;
    int m_size2XLarge = 24;
    int m_size3XLarge = 30;
    int m_size4XLarge = 36;
    int m_size5XLarge = 48;
    int m_size6XLarge = 60;
    int m_size7XLarge = 72;
    int m_weightRegular = 400;
    int m_weightMedium = 500;
    int m_weightSemibold = 600;
    int m_weightBold = 700;
    qreal m_leadingTight = 1.2;
    qreal m_leadingSnug = 1.35;
    qreal m_leadingNormal = 1.5;
    qreal m_leadingRelaxed = 1.7;
    qreal m_trackingTight = -0.02;
    qreal m_trackingNormal = 0.0;
    qreal m_trackingWide = 0.02;
    qreal m_trackingWider = 0.05;
    qreal m_trackingWidest = 0.1;
};
