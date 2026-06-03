#pragma once

#include <QEasingCurve>
#include <QObject>
#include <QVariantMap>
#include <QtQml/qqmlregistration.h>

class MerceMotion : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int durationInstant READ durationInstant NOTIFY changed FINAL)
    Q_PROPERTY(int durationFast READ durationFast NOTIFY changed FINAL)
    Q_PROPERTY(int durationNormal READ durationNormal NOTIFY changed FINAL)
    Q_PROPERTY(int durationSlow READ durationSlow NOTIFY changed FINAL)
    Q_PROPERTY(int durationSlower READ durationSlower NOTIFY changed FINAL)
    Q_PROPERTY(int durationSlowest READ durationSlowest NOTIFY changed FINAL)
    Q_PROPERTY(int easingDefault READ easingDefault NOTIFY changed FINAL)
    Q_PROPERTY(int easingIn READ easingIn NOTIFY changed FINAL)
    Q_PROPERTY(int easingOut READ easingOut NOTIFY changed FINAL)
    Q_PROPERTY(int easingInOut READ easingInOut NOTIFY changed FINAL)
    Q_PROPERTY(int easingEaseIn READ easingEaseIn NOTIFY changed FINAL)
    Q_PROPERTY(int easingEaseOut READ easingEaseOut NOTIFY changed FINAL)
    Q_PROPERTY(int easingBounce READ easingBounce NOTIFY changed FINAL)
    Q_PROPERTY(int springMass READ springMass NOTIFY changed FINAL)
    Q_PROPERTY(int springStiffness READ springStiffness NOTIFY changed FINAL)
    Q_PROPERTY(int springDamping READ springDamping NOTIFY changed FINAL)
    Q_PROPERTY(QVariantMap hover READ hover NOTIFY changed FINAL)
    Q_PROPERTY(QVariantMap press READ press NOTIFY changed FINAL)
    Q_PROPERTY(QVariantMap appear READ appear NOTIFY changed FINAL)
    Q_PROPERTY(QVariantMap enter READ enter NOTIFY changed FINAL)
    Q_PROPERTY(QVariantMap exit READ exit NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MerceMotion(QObject *parent = nullptr) : QObject(parent) {}

    int durationInstant() const { return 100; }
    int durationFast() const { return 150; }
    int durationNormal() const { return 200; }
    int durationSlow() const { return 300; }
    int durationSlower() const { return 500; }
    int durationSlowest() const { return 800; }
    int easingDefault() const { return static_cast<int>(QEasingCurve::InOutQuad); }
    int easingIn() const { return static_cast<int>(QEasingCurve::InQuad); }
    int easingOut() const { return static_cast<int>(QEasingCurve::OutQuad); }
    int easingInOut() const { return static_cast<int>(QEasingCurve::InOutQuad); }
    int easingEaseIn() const { return static_cast<int>(QEasingCurve::InCubic); }
    int easingEaseOut() const { return static_cast<int>(QEasingCurve::OutCubic); }
    int easingBounce() const { return static_cast<int>(QEasingCurve::OutBounce); }
    int springMass() const { return 1; }
    int springStiffness() const { return 200; }
    int springDamping() const { return 20; }

    QVariantMap hover() const { return preset(durationFast(), easingOut()); }
    QVariantMap press() const { return preset(durationInstant(), easingIn()); }
    QVariantMap appear() const { return preset(durationSlow(), easingEaseOut()); }
    QVariantMap enter() const { return preset(durationNormal(), easingEaseOut()); }
    QVariantMap exit() const { return preset(durationFast(), easingIn()); }

signals:
    void changed();

private:
    static QVariantMap preset(int duration, int easing)
    {
        QVariantMap map;
        map.insert(QStringLiteral("duration"), duration);
        map.insert(QStringLiteral("easing"), easing);
        return map;
    }
};
