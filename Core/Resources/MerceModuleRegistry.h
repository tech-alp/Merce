#pragma once

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVector>
#include <QtQml/qqmlregistration.h>

class MerceModuleRegistry : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList modules READ modules NOTIFY modulesChanged FINAL)
    QML_NAMED_ELEMENT(ModuleRegistry)
    QML_SINGLETON

public:
    explicit MerceModuleRegistry(QObject *parent = nullptr);

    QVariantList modules() const;

    Q_INVOKABLE bool hasModule(const QString &uri) const;
    Q_INVOKABLE bool registerModule(const QString &uri, const QString &version = QString());

signals:
    void modulesChanged();

private:
    struct ModuleEntry {
        QString uri;
        QString version;
    };

    QVector<ModuleEntry> m_modules;
};
