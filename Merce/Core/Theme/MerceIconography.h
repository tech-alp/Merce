#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>

class MerceIconography : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int xSmall READ xSmall NOTIFY changed FINAL)
    Q_PROPERTY(int small READ small NOTIFY changed FINAL)
    Q_PROPERTY(int medium READ medium NOTIFY changed FINAL)
    Q_PROPERTY(int large READ large NOTIFY changed FINAL)
    Q_PROPERTY(int xLarge READ xLarge NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MerceIconography(QObject *parent = nullptr) : QObject(parent) {}

    int xSmall() const { return 16; }
    int small() const { return 20; }
    int medium() const { return 24; }
    int large() const { return 32; }
    int xLarge() const { return 48; }

signals:
    void changed();
};
