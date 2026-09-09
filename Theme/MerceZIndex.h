#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>

class MerceZIndex : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int dropdown READ dropdown NOTIFY changed FINAL)
    Q_PROPERTY(int sticky READ sticky NOTIFY changed FINAL)
    Q_PROPERTY(int overlay READ overlay NOTIFY changed FINAL)
    Q_PROPERTY(int modal READ modal NOTIFY changed FINAL)
    Q_PROPERTY(int popover READ popover NOTIFY changed FINAL)
    Q_PROPERTY(int tooltip READ tooltip NOTIFY changed FINAL)
    Q_PROPERTY(int notification READ notification NOTIFY changed FINAL)
    // A full-screen state the user cannot dismiss: setup required, an update in
    // progress, a credential prompt. It outranks a notification because a toast
    // must not cover the reason the app is unusable.
    Q_PROPERTY(int blocking READ blocking NOTIFY changed FINAL)
    // The input surface the platform raises. Top of the scale by necessity: it
    // has to sit above whatever it types into, and a blocking credential prompt
    // is exactly that.
    Q_PROPERTY(int inputPanel READ inputPanel NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MerceZIndex(QObject *parent = nullptr) : QObject(parent) {}

    int dropdown() const { return 1000; }
    int sticky() const { return 1100; }
    int overlay() const { return 1200; }
    int modal() const { return 1300; }
    int popover() const { return 1400; }
    int tooltip() const { return 1500; }
    int notification() const { return 1600; }
    int blocking() const { return 1700; }
    int inputPanel() const { return 1800; }

signals:
    void changed();
};
