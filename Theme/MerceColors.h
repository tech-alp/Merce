#pragma once

#include <QColor>
#include <QJsonObject>
#include <QJsonValue>
#include <QObject>
#include <QString>
#include <QtQml/qqmlregistration.h>

#include <utility>

namespace MerceColorJson {

inline QColor colorValue(const QJsonValue &value, const QColor &fallback)
{
    QJsonValue resolvedValue = value;
    if (value.isObject()) {
        const QJsonObject object = value.toObject();
        resolvedValue = object.value(QStringLiteral("$value"));
        if (resolvedValue.isUndefined())
            resolvedValue = object.value(QStringLiteral("value"));
    }

    const QColor candidate(resolvedValue.toString());
    return candidate.isValid() ? candidate : fallback;
}

inline QColor color(const QJsonObject &object, const QString &field, const QColor &fallback)
{
    return colorValue(object.value(field), fallback);
}

} // namespace MerceColorJson

class MerceColorsContent : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QColor primary READ primary NOTIFY changed FINAL)
    Q_PROPERTY(QColor secondary READ secondary NOTIFY changed FINAL)
    Q_PROPERTY(QColor tertiary READ tertiary NOTIFY changed FINAL)
    Q_PROPERTY(QColor inverse READ inverse NOTIFY changed FINAL)
    Q_PROPERTY(QColor disabled READ disabled NOTIFY changed FINAL)
    Q_PROPERTY(QColor link READ link NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MerceColorsContent(QObject *parent = nullptr) : QObject(parent) {}

    QColor primary() const { return m_primary; }
    QColor secondary() const { return m_secondary; }
    QColor tertiary() const { return m_tertiary; }
    QColor inverse() const { return m_inverse; }
    QColor disabled() const { return m_disabled; }
    QColor link() const { return m_link; }

    void applyManifestSection(const QJsonObject &section)
    {
        m_primary = MerceColorJson::color(section, QStringLiteral("primary"), m_primary);
        m_secondary = MerceColorJson::color(section, QStringLiteral("secondary"), m_secondary);
        m_tertiary = MerceColorJson::color(section, QStringLiteral("tertiary"), m_tertiary);
        m_inverse = MerceColorJson::color(section, QStringLiteral("inverse"), m_inverse);
        m_disabled = MerceColorJson::color(section, QStringLiteral("disabled"), m_disabled);
        m_link = MerceColorJson::color(section, QStringLiteral("link"), m_link);
        emit changed();
    }

signals:
    void changed();

private:
    QColor m_primary = QColor(QStringLiteral("#151A19"));
    QColor m_secondary = QColor(QStringLiteral("#4E5B58"));
    QColor m_tertiary = QColor(QStringLiteral("#6D7874"));
    QColor m_inverse = QColor(QStringLiteral("#FFFFFF"));
    QColor m_disabled = QColor(QStringLiteral("#7A847F"));
    QColor m_link = QColor(QStringLiteral("#006B63"));
};

class MerceColorsOutline : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QColor subtle READ subtle NOTIFY changed FINAL)
    Q_PROPERTY(QColor strong READ strong NOTIFY changed FINAL)
    Q_PROPERTY(QColor focus READ focus NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MerceColorsOutline(QObject *parent = nullptr) : QObject(parent) {}

    QColor subtle() const { return m_subtle; }
    QColor strong() const { return m_strong; }
    QColor focus() const { return m_focus; }

    void applyManifestSection(const QJsonObject &section)
    {
        m_subtle = MerceColorJson::color(section, QStringLiteral("subtle"), m_subtle);
        m_strong = MerceColorJson::color(section, QStringLiteral("strong"), m_strong);
        m_focus = MerceColorJson::color(section, QStringLiteral("focus"), m_focus);
        emit changed();
    }

signals:
    void changed();

private:
    QColor m_subtle = QColor(QStringLiteral("#CBD2CF"));
    QColor m_strong = QColor(QStringLiteral("#A9B2AE"));
    QColor m_focus = QColor(QStringLiteral("#006B63"));
};

class MerceColorsActionRole : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QColor container READ container NOTIFY changed FINAL)
    Q_PROPERTY(QColor content READ content NOTIFY changed FINAL)
    Q_PROPERTY(QColor outline READ outline NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    MerceColorsActionRole(QColor container,
                          QColor content,
                          QColor outline,
                          QObject *parent = nullptr)
        : QObject(parent),
          m_container(std::move(container)),
          m_content(std::move(content)),
          m_outline(std::move(outline))
    {
    }

    QColor container() const { return m_container; }
    QColor content() const { return m_content; }
    QColor outline() const { return m_outline; }

    void applyManifestSection(const QJsonObject &section)
    {
        m_container = MerceColorJson::color(section, QStringLiteral("container"), m_container);
        m_content = MerceColorJson::color(section, QStringLiteral("content"), m_content);
        m_outline = MerceColorJson::color(section, QStringLiteral("outline"), m_outline);
        emit changed();
    }

signals:
    void changed();

private:
    QColor m_container;
    QColor m_content;
    QColor m_outline;
};

class MerceColorsAction : public QObject
{
    Q_OBJECT
    Q_PROPERTY(MerceColorsActionRole *primary READ primary CONSTANT FINAL)
    Q_PROPERTY(MerceColorsActionRole *secondary READ secondary CONSTANT FINAL)
    Q_PROPERTY(MerceColorsActionRole *destructive READ destructive CONSTANT FINAL)
    QML_ANONYMOUS

public:
    explicit MerceColorsAction(QObject *parent = nullptr)
        : QObject(parent),
          m_primary(new MerceColorsActionRole(QColor(QStringLiteral("#006B63")),
                                              QColor(QStringLiteral("#FFFFFF")),
                                              QColor(QStringLiteral("#006B63")),
                                              this)),
          m_secondary(new MerceColorsActionRole(QColor(QStringLiteral("#65716D")),
                                                QColor(QStringLiteral("#FFFFFF")),
                                                QColor(QStringLiteral("#65716D")),
                                                this)),
          m_destructive(new MerceColorsActionRole(QColor(QStringLiteral("#B3261E")),
                                                  QColor(QStringLiteral("#FFFFFF")),
                                                  QColor(QStringLiteral("#B3261E")),
                                                  this))
    {
    }

    MerceColorsActionRole *primary() const { return m_primary; }
    MerceColorsActionRole *secondary() const { return m_secondary; }
    MerceColorsActionRole *destructive() const { return m_destructive; }

    void applyManifestSection(const QJsonObject &section)
    {
        m_primary->applyManifestSection(section.value(QStringLiteral("primary")).toObject());
        m_secondary->applyManifestSection(section.value(QStringLiteral("secondary")).toObject());
        m_destructive->applyManifestSection(
            section.value(QStringLiteral("destructive")).toObject());
    }

private:
    MerceColorsActionRole *m_primary = nullptr;
    MerceColorsActionRole *m_secondary = nullptr;
    MerceColorsActionRole *m_destructive = nullptr;
};

class MerceColorsStatusRole : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QColor container READ container NOTIFY changed FINAL)
    Q_PROPERTY(QColor content READ content NOTIFY changed FINAL)
    Q_PROPERTY(QColor outline READ outline NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    MerceColorsStatusRole(QColor container,
                          QColor content,
                          QColor outline,
                          QObject *parent = nullptr)
        : QObject(parent),
          m_container(std::move(container)),
          m_content(std::move(content)),
          m_outline(std::move(outline))
    {
    }

    QColor container() const { return m_container; }
    QColor content() const { return m_content; }
    QColor outline() const { return m_outline; }

    void applyManifestSection(const QJsonObject &section)
    {
        m_container = MerceColorJson::color(section, QStringLiteral("container"), m_container);
        m_content = MerceColorJson::color(section, QStringLiteral("content"), m_content);
        m_outline = MerceColorJson::color(section, QStringLiteral("outline"), m_outline);
        emit changed();
    }

signals:
    void changed();

private:
    QColor m_container;
    QColor m_content;
    QColor m_outline;
};

class MerceColorsStatus : public QObject
{
    Q_OBJECT
    Q_PROPERTY(MerceColorsStatusRole *success READ success CONSTANT FINAL)
    Q_PROPERTY(MerceColorsStatusRole *warning READ warning CONSTANT FINAL)
    Q_PROPERTY(MerceColorsStatusRole *error READ error CONSTANT FINAL)
    Q_PROPERTY(MerceColorsStatusRole *info READ info CONSTANT FINAL)
    Q_PROPERTY(MerceColorsStatusRole *neutral READ neutral CONSTANT FINAL)
    QML_ANONYMOUS

public:
    explicit MerceColorsStatus(QObject *parent = nullptr)
        : QObject(parent),
          m_success(new MerceColorsStatusRole(QColor(QStringLiteral("#ECFDF3")),
                                              QColor(QStringLiteral("#166B3B")),
                                              QColor(QStringLiteral("#166B3B")),
                                              this)),
          m_warning(new MerceColorsStatusRole(QColor(QStringLiteral("#FFFBEB")),
                                              QColor(QStringLiteral("#8A4B00")),
                                              QColor(QStringLiteral("#8A4B00")),
                                              this)),
          m_error(new MerceColorsStatusRole(QColor(QStringLiteral("#FEF2F2")),
                                            QColor(QStringLiteral("#B3261E")),
                                            QColor(QStringLiteral("#B3261E")),
                                            this)),
          m_info(new MerceColorsStatusRole(QColor(QStringLiteral("#EFF4FC")),
                                           QColor(QStringLiteral("#245EA8")),
                                           QColor(QStringLiteral("#245EA8")),
                                           this)),
          m_neutral(new MerceColorsStatusRole(QColor(QStringLiteral("#EFF1F0")),
                                              QColor(QStringLiteral("#4E5B58")),
                                              QColor(QStringLiteral("#65716D")),
                                              this))
    {
    }

    MerceColorsStatusRole *success() const { return m_success; }
    MerceColorsStatusRole *warning() const { return m_warning; }
    MerceColorsStatusRole *error() const { return m_error; }
    MerceColorsStatusRole *info() const { return m_info; }
    MerceColorsStatusRole *neutral() const { return m_neutral; }

    void applyManifestSection(const QJsonObject &section)
    {
        m_success->applyManifestSection(section.value(QStringLiteral("success")).toObject());
        m_warning->applyManifestSection(section.value(QStringLiteral("warning")).toObject());
        m_error->applyManifestSection(section.value(QStringLiteral("error")).toObject());
        m_info->applyManifestSection(section.value(QStringLiteral("info")).toObject());
        m_neutral->applyManifestSection(section.value(QStringLiteral("neutral")).toObject());
        emit changed();
    }

signals:
    void changed();

private:
    MerceColorsStatusRole *m_success = nullptr;
    MerceColorsStatusRole *m_warning = nullptr;
    MerceColorsStatusRole *m_error = nullptr;
    MerceColorsStatusRole *m_info = nullptr;
    MerceColorsStatusRole *m_neutral = nullptr;
};

class MerceColorsSurface : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QColor canvas READ canvas NOTIFY changed FINAL)
    Q_PROPERTY(QColor container READ container NOTIFY changed FINAL)
    Q_PROPERTY(QColor containerRaised READ containerRaised NOTIFY changed FINAL)
    Q_PROPERTY(QColor containerSunken READ containerSunken NOTIFY changed FINAL)
    Q_PROPERTY(QColor containerTinted READ containerTinted NOTIFY changed FINAL)
    Q_PROPERTY(QColor floating READ floating NOTIFY changed FINAL)
    Q_PROPERTY(QColor scrim READ scrim NOTIFY changed FINAL)
    Q_PROPERTY(QColor inverse READ inverse NOTIFY changed FINAL)
    Q_PROPERTY(QColor shadow READ shadow NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MerceColorsSurface(QObject *parent = nullptr) : QObject(parent) {}

    QColor container() const { return m_container; }
    QColor containerRaised() const { return m_containerRaised; }
    QColor containerTinted() const { return m_containerTinted; }
    QColor canvas() const { return m_canvas; }
    QColor containerSunken() const { return m_containerSunken; }
    QColor floating() const { return m_floating; }
    QColor scrim() const { return m_scrim; }
    QColor inverse() const { return m_inverse; }
    QColor shadow() const { return m_shadow; }

    void applyManifestSection(const QJsonObject &section)
    {
        m_canvas = MerceColorJson::color(section, QStringLiteral("canvas"), m_canvas);
        m_container = MerceColorJson::color(section, QStringLiteral("container"), m_container);
        m_containerTinted = MerceColorJson::color(
            section, QStringLiteral("containerTinted"), m_containerTinted);
        m_containerRaised = MerceColorJson::color(
            section, QStringLiteral("containerRaised"), m_containerRaised);
        m_containerSunken =
            MerceColorJson::color(section, QStringLiteral("containerSunken"), m_containerSunken);
        m_floating = MerceColorJson::color(section, QStringLiteral("floating"), m_floating);
        m_scrim = MerceColorJson::color(section, QStringLiteral("scrim"), m_scrim);
        m_inverse = MerceColorJson::color(section, QStringLiteral("inverse"), m_inverse);
        m_shadow = MerceColorJson::color(section, QStringLiteral("shadow"), m_shadow);
        emit changed();
    }

signals:
    void changed();

private:
    QColor m_container = QColor(QStringLiteral("#FFFFFF"));
    QColor m_containerTinted = QColor(QStringLiteral("#EFF5F3"));
    QColor m_containerRaised = QColor(QStringLiteral("#FFFFFF"));
    QColor m_canvas = QColor(QStringLiteral("#F6F4EE"));
    QColor m_containerSunken = QColor(QStringLiteral("#EDEAE2"));
    QColor m_floating = QColor(QStringLiteral("#FFFFFF"));
    QColor m_scrim = QColor(QStringLiteral("#99000000"));
    QColor m_inverse = QColor(QStringLiteral("#151A19"));
    QColor m_shadow = QColor(QStringLiteral("#151A19"));
};

class MerceColors : public QObject
{
    Q_OBJECT
    Q_PROPERTY(MerceColorsContent *content READ content CONSTANT FINAL)
    Q_PROPERTY(MerceColorsOutline *outline READ outline CONSTANT FINAL)
    Q_PROPERTY(MerceColorsAction *action READ action CONSTANT FINAL)
    Q_PROPERTY(MerceColorsStatus *status READ status CONSTANT FINAL)
    Q_PROPERTY(MerceColorsSurface *surface READ surface CONSTANT FINAL)
    QML_ANONYMOUS

public:
    explicit MerceColors(QObject *parent = nullptr)
        : QObject(parent),
          m_content(new MerceColorsContent(this)),
          m_outline(new MerceColorsOutline(this)),
          m_action(new MerceColorsAction(this)),
          m_status(new MerceColorsStatus(this)),
          m_surface(new MerceColorsSurface(this))
    {
    }

    MerceColorsContent *content() const { return m_content; }
    MerceColorsOutline *outline() const { return m_outline; }
    MerceColorsAction *action() const { return m_action; }
    MerceColorsStatus *status() const { return m_status; }
    MerceColorsSurface *surface() const { return m_surface; }

    void applyManifestSection(const QJsonObject &section)
    {
        m_content->applyManifestSection(section.value(QStringLiteral("content")).toObject());
        m_outline->applyManifestSection(section.value(QStringLiteral("outline")).toObject());
        m_action->applyManifestSection(section.value(QStringLiteral("action")).toObject());
        m_status->applyManifestSection(section.value(QStringLiteral("status")).toObject());
        m_surface->applyManifestSection(section.value(QStringLiteral("surface")).toObject());
        emit changed();
    }

signals:
    void changed();

private:
    MerceColorsContent *m_content = nullptr;
    MerceColorsOutline *m_outline = nullptr;
    MerceColorsAction *m_action = nullptr;
    MerceColorsStatus *m_status = nullptr;
    MerceColorsSurface *m_surface = nullptr;
};
