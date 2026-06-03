#pragma once

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

    int none() const { return 0; }
    int small() const { return 4; }
    int medium() const { return 8; }
    int large() const { return 12; }
    int xlarge() const { return 16; }
    int xxlarge() const { return 24; }
    int full() const { return 9999; }
    int button() const { return large(); }
    int input() const { return medium(); }
    int card() const { return xlarge(); }
    int badge() const { return full(); }
    int dialog() const { return xxlarge(); }
    int tooltip() const { return small(); }

signals:
    void changed();
};
