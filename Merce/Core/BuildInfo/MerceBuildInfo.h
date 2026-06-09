#pragma once

#include <QObject>
#include <QString>
#include <QtQml/qqmlregistration.h>

class MerceBuildInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString version READ version CONSTANT FINAL)
    Q_PROPERTY(QString qtVersion READ qtVersion CONSTANT FINAL)
    Q_PROPERTY(QString buildType READ buildType CONSTANT FINAL)
    QML_NAMED_ELEMENT(BuildInfo)
    QML_SINGLETON

public:
    explicit MerceBuildInfo(QObject *parent = nullptr);

    QString version() const;
    QString qtVersion() const;
    QString buildType() const;
};
