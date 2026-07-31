#pragma once

#include <QObject>
#include <QVariantMap>

class PlaygroundThemeBuilder : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString outputRoot READ outputRoot CONSTANT FINAL)

public:
    explicit PlaygroundThemeBuilder(QObject *parent = nullptr);

    QString outputRoot() const { return m_outputRoot; }

    Q_INVOKABLE QVariantMap saveTheme(const QVariantMap &request) const;

private:
    QVariantMap failure(const QString &message) const;

    QString m_outputRoot;
};
