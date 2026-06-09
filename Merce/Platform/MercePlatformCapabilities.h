#pragma once

#include <QObject>
#include <QString>
#include <QtQml/qqmlregistration.h>

class MercePlatformCapabilities : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name CONSTANT FINAL)
    Q_PROPERTY(bool offscreen READ offscreen CONSTANT FINAL)
    Q_PROPERTY(bool hasPrimaryScreen READ hasPrimaryScreen NOTIFY changed FINAL)
    Q_PROPERTY(qreal devicePixelRatio READ devicePixelRatio NOTIFY changed FINAL)
    QML_NAMED_ELEMENT(Platform)
    QML_SINGLETON

public:
    explicit MercePlatformCapabilities(QObject *parent = nullptr);

    QString name() const;
    bool offscreen() const;
    bool hasPrimaryScreen() const;
    qreal devicePixelRatio() const;

signals:
    void changed();
};
