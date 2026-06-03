#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>

class MerceBreakpoints : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int small READ small NOTIFY changed FINAL)
    Q_PROPERTY(int medium READ medium NOTIFY changed FINAL)
    Q_PROPERTY(int large READ large NOTIFY changed FINAL)
    Q_PROPERTY(int xLarge READ xLarge NOTIFY changed FINAL)
    Q_PROPERTY(int xxLarge READ xxLarge NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MerceBreakpoints(QObject *parent = nullptr) : QObject(parent) {}

    int small() const { return 640; }
    int medium() const { return 768; }
    int large() const { return 1024; }
    int xLarge() const { return 1280; }
    int xxLarge() const { return 1536; }

signals:
    void changed();
};
