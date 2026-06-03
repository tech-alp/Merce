#pragma once

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

    int base() const { return 8; }
    int none() const { return 0; }
    int xxs() const { return 4; }
    int xs() const { return 8; }
    int sm() const { return 12; }
    int md() const { return 16; }
    int lg() const { return 20; }
    int xl() const { return 24; }
    int xl2() const { return 32; }
    int xl3() const { return 40; }
    int xl4() const { return 48; }
    int xl5() const { return 64; }
    int xl6() const { return 80; }
    int componentGap() const { return 16; }
    int sectionGap() const { return 48; }
    int pagePadding() const { return 24; }
    int touchTarget() const { return 44; }
    int touchTargetCompact() const { return 36; }
    int gridGap() const { return 16; }
    int stackGap() const { return 12; }
    int inlineGap() const { return 8; }

signals:
    void changed();
};
