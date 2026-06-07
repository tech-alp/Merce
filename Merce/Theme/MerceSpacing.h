#pragma once

#include <QJsonObject>
#include <QObject>
#include <QtQml/qqmlregistration.h>

class MerceSpacing : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int base READ base NOTIFY changed FINAL)
    Q_PROPERTY(int none READ none NOTIFY changed FINAL)
    Q_PROPERTY(int xxs READ xxs NOTIFY changed FINAL)
    Q_PROPERTY(int xs READ xs NOTIFY changed FINAL)
    Q_PROPERTY(int sm READ sm NOTIFY changed FINAL)
    Q_PROPERTY(int md READ md NOTIFY changed FINAL)
    Q_PROPERTY(int lg READ lg NOTIFY changed FINAL)
    Q_PROPERTY(int xl READ xl NOTIFY changed FINAL)
    Q_PROPERTY(int xl2 READ xl2 NOTIFY changed FINAL)
    Q_PROPERTY(int xl3 READ xl3 NOTIFY changed FINAL)
    Q_PROPERTY(int xl4 READ xl4 NOTIFY changed FINAL)
    Q_PROPERTY(int xl5 READ xl5 NOTIFY changed FINAL)
    Q_PROPERTY(int xl6 READ xl6 NOTIFY changed FINAL)
    Q_PROPERTY(int componentGap READ componentGap NOTIFY changed FINAL)
    Q_PROPERTY(int sectionGap READ sectionGap NOTIFY changed FINAL)
    Q_PROPERTY(int pagePadding READ pagePadding NOTIFY changed FINAL)
    Q_PROPERTY(int touchTarget READ touchTarget NOTIFY changed FINAL)
    Q_PROPERTY(int touchTargetCompact READ touchTargetCompact NOTIFY changed FINAL)
    Q_PROPERTY(int gridGap READ gridGap NOTIFY changed FINAL)
    Q_PROPERTY(int stackGap READ stackGap NOTIFY changed FINAL)
    Q_PROPERTY(int inlineGap READ inlineGap NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MerceSpacing(QObject *parent = nullptr) : QObject(parent) {}

    int base() const { return m_base; }
    int none() const { return m_none; }
    int xxs() const { return m_xxs; }
    int xs() const { return m_xs; }
    int sm() const { return m_sm; }
    int md() const { return m_md; }
    int lg() const { return m_lg; }
    int xl() const { return m_xl; }
    int xl2() const { return m_xl2; }
    int xl3() const { return m_xl3; }
    int xl4() const { return m_xl4; }
    int xl5() const { return m_xl5; }
    int xl6() const { return m_xl6; }
    int componentGap() const { return m_componentGap; }
    int sectionGap() const { return m_sectionGap; }
    int pagePadding() const { return m_pagePadding; }
    int touchTarget() const { return m_touchTarget; }
    int touchTargetCompact() const { return m_touchTargetCompact; }
    int gridGap() const { return m_gridGap; }
    int stackGap() const { return m_stackGap; }
    int inlineGap() const { return m_inlineGap; }

    void applyManifestSection(const QJsonObject &section)
    {
        m_base = section.value(QStringLiteral("base")).toInt();
        m_none = section.value(QStringLiteral("none")).toInt();
        m_xxs = section.value(QStringLiteral("xxs")).toInt();
        m_xs = section.value(QStringLiteral("xs")).toInt();
        m_sm = section.value(QStringLiteral("sm")).toInt();
        m_md = section.value(QStringLiteral("md")).toInt();
        m_lg = section.value(QStringLiteral("lg")).toInt();
        m_xl = section.value(QStringLiteral("xl")).toInt();
        m_xl2 = section.value(QStringLiteral("xl2")).toInt();
        m_xl3 = section.value(QStringLiteral("xl3")).toInt();
        m_xl4 = section.value(QStringLiteral("xl4")).toInt();
        m_xl5 = section.value(QStringLiteral("xl5")).toInt();
        m_xl6 = section.value(QStringLiteral("xl6")).toInt();
        m_componentGap = section.value(QStringLiteral("componentGap")).toInt();
        m_sectionGap = section.value(QStringLiteral("sectionGap")).toInt();
        m_pagePadding = section.value(QStringLiteral("pagePadding")).toInt();
        m_touchTarget = section.value(QStringLiteral("touchTarget")).toInt();
        m_touchTargetCompact = section.value(QStringLiteral("touchTargetCompact")).toInt();
        m_gridGap = section.value(QStringLiteral("gridGap")).toInt();
        m_stackGap = section.value(QStringLiteral("stackGap")).toInt();
        m_inlineGap = section.value(QStringLiteral("inlineGap")).toInt();
        emit changed();
    }

signals:
    void changed();

private:
    int m_base = 8;
    int m_none = 0;
    int m_xxs = 4;
    int m_xs = 8;
    int m_sm = 12;
    int m_md = 16;
    int m_lg = 20;
    int m_xl = 24;
    int m_xl2 = 32;
    int m_xl3 = 40;
    int m_xl4 = 48;
    int m_xl5 = 64;
    int m_xl6 = 80;
    int m_componentGap = 16;
    int m_sectionGap = 48;
    int m_pagePadding = 24;
    int m_touchTarget = 44;
    int m_touchTargetCompact = 36;
    int m_gridGap = 16;
    int m_stackGap = 12;
    int m_inlineGap = 8;
};
