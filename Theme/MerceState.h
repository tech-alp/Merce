#pragma once

#include <QJsonObject>
#include <QObject>
#include <QtQml/qqmlregistration.h>

class MerceStateLayer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double hover READ hover CONSTANT FINAL)
    Q_PROPERTY(double focus READ focus CONSTANT FINAL)
    Q_PROPERTY(double pressed READ pressed CONSTANT FINAL)
    Q_PROPERTY(double selected READ selected CONSTANT FINAL)
    QML_ANONYMOUS

public:
    explicit MerceStateLayer(QObject *parent = nullptr) : QObject(parent) {}

    double hover() const { return m_hover; }
    double focus() const { return m_focus; }
    double pressed() const { return m_pressed; }
    double selected() const { return m_selected; }

    void applyManifestSection(const QJsonObject &section)
    {
        m_hover = section.value(QStringLiteral("hover")).toDouble();
        m_focus = section.value(QStringLiteral("focus")).toDouble();
        m_pressed = section.value(QStringLiteral("pressed")).toDouble();
        m_selected = section.value(QStringLiteral("selected")).toDouble();
    }

private:
    double m_hover = 0.08;
    double m_focus = 0.10;
    double m_pressed = 0.10;
    double m_selected = 0.12;
};

class MerceStateDisabled : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double containerOpacity READ containerOpacity CONSTANT FINAL)
    Q_PROPERTY(double contentOpacity READ contentOpacity CONSTANT FINAL)
    QML_ANONYMOUS

public:
    explicit MerceStateDisabled(QObject *parent = nullptr) : QObject(parent) {}

    double containerOpacity() const { return m_containerOpacity; }
    double contentOpacity() const { return m_contentOpacity; }

    void applyManifestSection(const QJsonObject &section)
    {
        m_containerOpacity =
            section.value(QStringLiteral("containerOpacity")).toDouble();
        m_contentOpacity =
            section.value(QStringLiteral("contentOpacity")).toDouble();
    }

private:
    double m_containerOpacity = 0.12;
    double m_contentOpacity = 0.38;
};

class MerceState : public QObject
{
    Q_OBJECT
    Q_PROPERTY(MerceStateLayer *layer READ layer CONSTANT FINAL)
    Q_PROPERTY(MerceStateDisabled *disabled READ disabled CONSTANT FINAL)
    QML_ANONYMOUS

public:
    explicit MerceState(QObject *parent = nullptr)
        : QObject(parent),
          m_layer(new MerceStateLayer(this)),
          m_disabled(new MerceStateDisabled(this))
    {
    }

    MerceStateLayer *layer() const { return m_layer; }
    MerceStateDisabled *disabled() const { return m_disabled; }

    void applyManifestSection(const QJsonObject &section)
    {
        m_layer->applyManifestSection(section.value(QStringLiteral("layer")).toObject());
        m_disabled->applyManifestSection(
            section.value(QStringLiteral("disabled")).toObject());
    }

private:
    MerceStateLayer *m_layer = nullptr;
    MerceStateDisabled *m_disabled = nullptr;
};
