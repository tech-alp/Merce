#pragma once

#include <QJsonObject>
#include <QObject>
#include <QtQml/qqmlregistration.h>

class MerceControlSize : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int small READ small NOTIFY changed FINAL)
    Q_PROPERTY(int medium READ medium NOTIFY changed FINAL)
    Q_PROPERTY(int large READ large NOTIFY changed FINAL)
    Q_PROPERTY(int minimum READ minimum NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MerceControlSize(QObject *parent = nullptr) : QObject(parent) {}

    int small() const { return m_small; }
    int medium() const { return m_medium; }
    int large() const { return m_large; }
    int minimum() const { return m_minimum; }

    void applyManifestSection(const QJsonObject &section)
    {
        m_small = section.value(QStringLiteral("small")).toInt();
        m_medium = section.value(QStringLiteral("medium")).toInt();
        m_large = section.value(QStringLiteral("large")).toInt();
        m_minimum = section.value(QStringLiteral("minimum")).toInt();
        emit changed();
    }

signals:
    void changed();

private:
    int m_small = 40;
    int m_medium = 48;
    int m_large = 56;
    int m_minimum = 40;
};

class MerceIconSize : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int small READ small NOTIFY changed FINAL)
    Q_PROPERTY(int medium READ medium NOTIFY changed FINAL)
    Q_PROPERTY(int large READ large NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MerceIconSize(QObject *parent = nullptr) : QObject(parent) {}

    int small() const { return m_small; }
    int medium() const { return m_medium; }
    int large() const { return m_large; }

    void applyManifestSection(const QJsonObject &section)
    {
        m_small = section.value(QStringLiteral("small")).toInt();
        m_medium = section.value(QStringLiteral("medium")).toInt();
        m_large = section.value(QStringLiteral("large")).toInt();
        emit changed();
    }

signals:
    void changed();

private:
    int m_small = 24;
    int m_medium = 32;
    int m_large = 48;
};

class MerceOutlineSize : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int hairline READ hairline NOTIFY changed FINAL)
    Q_PROPERTY(int strong READ strong NOTIFY changed FINAL)
    Q_PROPERTY(int focus READ focus NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MerceOutlineSize(QObject *parent = nullptr) : QObject(parent) {}

    int hairline() const { return m_hairline; }
    int strong() const { return m_strong; }
    int focus() const { return m_focus; }

    void applyManifestSection(const QJsonObject &section)
    {
        m_hairline = section.value(QStringLiteral("hairline")).toInt();
        m_strong = section.value(QStringLiteral("strong")).toInt();
        m_focus = section.value(QStringLiteral("focus")).toInt();
        emit changed();
    }

signals:
    void changed();

private:
    int m_hairline = 1;
    int m_strong = 2;
    int m_focus = 3;
};

class MerceDialogSize : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int small READ small NOTIFY changed FINAL)
    Q_PROPERTY(int medium READ medium NOTIFY changed FINAL)
    Q_PROPERTY(int large READ large NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MerceDialogSize(QObject *parent = nullptr) : QObject(parent) {}

    int small() const { return m_small; }
    int medium() const { return m_medium; }
    int large() const { return m_large; }

    void applyManifestSection(const QJsonObject &section)
    {
        m_small = section.value(QStringLiteral("small")).toInt();
        m_medium = section.value(QStringLiteral("medium")).toInt();
        m_large = section.value(QStringLiteral("large")).toInt();
        emit changed();
    }

signals:
    void changed();

private:
    int m_small = 320;
    int m_medium = 480;
    int m_large = 640;
};

class MerceSize : public QObject
{
    Q_OBJECT
    Q_PROPERTY(MerceControlSize *control READ control CONSTANT FINAL)
    Q_PROPERTY(MerceIconSize *icon READ icon CONSTANT FINAL)
    Q_PROPERTY(MerceOutlineSize *outline READ outline CONSTANT FINAL)
    Q_PROPERTY(MerceDialogSize *dialog READ dialog CONSTANT FINAL)
    QML_ANONYMOUS

public:
    explicit MerceSize(QObject *parent = nullptr)
        : QObject(parent),
          m_control(new MerceControlSize(this)),
          m_icon(new MerceIconSize(this)),
          m_outline(new MerceOutlineSize(this)),
          m_dialog(new MerceDialogSize(this))
    {
    }

    MerceControlSize *control() const { return m_control; }
    MerceIconSize *icon() const { return m_icon; }
    MerceOutlineSize *outline() const { return m_outline; }
    MerceDialogSize *dialog() const { return m_dialog; }

    void applyManifestSection(const QJsonObject &section)
    {
        m_control->applyManifestSection(section.value(QStringLiteral("control")).toObject());
        m_icon->applyManifestSection(section.value(QStringLiteral("icon")).toObject());
        m_outline->applyManifestSection(section.value(QStringLiteral("outline")).toObject());
        m_dialog->applyManifestSection(section.value(QStringLiteral("dialog")).toObject());
        emit changed();
    }

signals:
    void changed();

private:
    MerceControlSize *m_control = nullptr;
    MerceIconSize *m_icon = nullptr;
    MerceOutlineSize *m_outline = nullptr;
    MerceDialogSize *m_dialog = nullptr;
};
