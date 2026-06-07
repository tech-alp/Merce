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

signals:
    void changed();
};
