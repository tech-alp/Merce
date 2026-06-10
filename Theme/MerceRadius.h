#pragma once

#include <QJsonObject>
#include <QObject>
#include <QtQml/qqmlregistration.h>

class MerceRadius : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int none READ none NOTIFY changed FINAL)
    Q_PROPERTY(int small READ small NOTIFY changed FINAL)
    Q_PROPERTY(int medium READ medium NOTIFY changed FINAL)
    Q_PROPERTY(int large READ large NOTIFY changed FINAL)
    Q_PROPERTY(int xlarge READ xlarge NOTIFY changed FINAL)
    Q_PROPERTY(int xxlarge READ xxlarge NOTIFY changed FINAL)
    Q_PROPERTY(int full READ full NOTIFY changed FINAL)
    Q_PROPERTY(int button READ button NOTIFY changed FINAL)
    Q_PROPERTY(int input READ input NOTIFY changed FINAL)
    Q_PROPERTY(int card READ card NOTIFY changed FINAL)
    Q_PROPERTY(int badge READ badge NOTIFY changed FINAL)
    Q_PROPERTY(int dialog READ dialog NOTIFY changed FINAL)
    Q_PROPERTY(int tooltip READ tooltip NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MerceRadius(QObject *parent = nullptr) : QObject(parent) {}

    int none() const { return m_none; }
    int small() const { return m_small; }
    int medium() const { return m_medium; }
    int large() const { return m_large; }
    int xlarge() const { return m_xlarge; }
    int xxlarge() const { return m_xxlarge; }
    int full() const { return m_full; }
    int button() const { return m_button; }
    int input() const { return m_input; }
    int card() const { return m_card; }
    int badge() const { return m_badge; }
    int dialog() const { return m_dialog; }
    int tooltip() const { return m_tooltip; }

    void applyManifestSection(const QJsonObject &section)
    {
        m_none = section.value(QStringLiteral("none")).toInt();
        m_small = section.value(QStringLiteral("small")).toInt();
        m_medium = section.value(QStringLiteral("medium")).toInt();
        m_large = section.value(QStringLiteral("large")).toInt();
        m_xlarge = section.value(QStringLiteral("xlarge")).toInt();
        m_xxlarge = section.value(QStringLiteral("xxlarge")).toInt();
        m_full = section.value(QStringLiteral("full")).toInt();
        m_button = section.value(QStringLiteral("button")).toInt();
        m_input = section.value(QStringLiteral("input")).toInt();
        m_card = section.value(QStringLiteral("card")).toInt();
        m_badge = section.value(QStringLiteral("badge")).toInt();
        m_dialog = section.value(QStringLiteral("dialog")).toInt();
        m_tooltip = section.value(QStringLiteral("tooltip")).toInt();
        emit changed();
    }

signals:
    void changed();

private:
    int m_none = 0;
    int m_small = 4;
    int m_medium = 8;
    int m_large = 12;
    int m_xlarge = 16;
    int m_xxlarge = 24;
    int m_full = 9999;
    int m_button = 12;
    int m_input = 8;
    int m_card = 16;
    int m_badge = 9999;
    int m_dialog = 24;
    int m_tooltip = 4;
};
