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

inline QColor stateColor(const QColor &container, bool darkMode, int factor)
{
    return darkMode ? container.lighter(factor) : container.darker(factor);
}

} // namespace MerceColorJson

class MerceColorsText : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QColor primary READ primary NOTIFY changed FINAL)
    Q_PROPERTY(QColor secondary READ secondary NOTIFY changed FINAL)
    Q_PROPERTY(QColor tertiary READ tertiary NOTIFY changed FINAL)
    Q_PROPERTY(QColor inverse READ inverse NOTIFY changed FINAL)
    Q_PROPERTY(QColor disabled READ disabled NOTIFY changed FINAL)
    Q_PROPERTY(QColor link READ link NOTIFY changed FINAL)
    Q_PROPERTY(QColor linkHover READ linkHover NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MerceColorsText(QObject *parent = nullptr) : QObject(parent) {}

    QColor primary() const { return m_primary; }
    QColor secondary() const { return m_secondary; }
    QColor tertiary() const { return m_tertiary; }
    QColor inverse() const { return m_inverse; }
    QColor disabled() const { return m_disabled; }
    QColor link() const { return m_link; }
    QColor linkHover() const { return m_linkHover; }

    void applyManifestSection(const QJsonObject &section)
    {
        m_primary = MerceColorJson::color(section, QStringLiteral("primary"), m_primary);
        m_secondary = MerceColorJson::color(section, QStringLiteral("secondary"), m_secondary);
        m_tertiary = MerceColorJson::color(section, QStringLiteral("tertiary"), m_tertiary);
        m_inverse = MerceColorJson::color(section, QStringLiteral("inverse"), m_inverse);
        m_disabled = MerceColorJson::color(section, QStringLiteral("disabled"), m_disabled);
        m_link = MerceColorJson::color(section, QStringLiteral("link"), m_link);
        m_linkHover = MerceColorJson::color(section, QStringLiteral("linkHover"), m_linkHover);
        emit changed();
    }

signals:
    void changed();

private:
    QColor m_primary = QColor(QStringLiteral("#1F1510"));
    QColor m_secondary = QColor(QStringLiteral("#5C4A3D"));
    QColor m_tertiary = QColor(QStringLiteral("#9A8472"));
    QColor m_inverse = QColor(QStringLiteral("#FAF8F6"));
    QColor m_disabled = QColor(QStringLiteral("#B8A494"));
    QColor m_link = QColor(QStringLiteral("#C4785A"));
    QColor m_linkHover = QColor(QStringLiteral("#9A4F34"));
};

class MerceColorsBackground : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QColor base READ base NOTIFY changed FINAL)
    Q_PROPERTY(QColor subtle READ subtle NOTIFY changed FINAL)
    Q_PROPERTY(QColor surface READ surface NOTIFY changed FINAL)
    Q_PROPERTY(QColor elevated READ elevated NOTIFY changed FINAL)
    Q_PROPERTY(QColor hover READ hover NOTIFY changed FINAL)
    Q_PROPERTY(QColor pressed READ pressed NOTIFY changed FINAL)
    Q_PROPERTY(QColor tinted READ tinted NOTIFY changed FINAL)
    Q_PROPERTY(QColor overlay READ overlay NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MerceColorsBackground(QObject *parent = nullptr) : QObject(parent) {}

    QColor base() const { return m_base; }
    QColor subtle() const { return m_subtle; }
    QColor surface() const { return m_surface; }
    QColor elevated() const { return m_elevated; }
    QColor hover() const { return m_hover; }
    QColor pressed() const { return m_pressed; }
    QColor tinted() const { return m_tinted; }
    QColor overlay() const { return m_overlay; }

    void applyManifestSection(const QJsonObject &section)
    {
        m_base = MerceColorJson::color(section, QStringLiteral("base"), m_base);
        m_subtle = MerceColorJson::color(section, QStringLiteral("subtle"), m_subtle);
        if (!section.contains(QStringLiteral("subtle")))
            m_subtle = MerceColorJson::color(section, QStringLiteral("tinted"), m_subtle);
        m_surface = MerceColorJson::color(section, QStringLiteral("surface"), m_surface);
        m_elevated = MerceColorJson::color(section, QStringLiteral("elevated"), m_elevated);
        m_hover = MerceColorJson::color(section, QStringLiteral("hover"), m_hover);
        m_pressed = MerceColorJson::color(section, QStringLiteral("pressed"), m_pressed);
        m_tinted = MerceColorJson::color(section, QStringLiteral("tinted"), m_tinted);
        m_overlay = MerceColorJson::color(section, QStringLiteral("overlay"), m_overlay);
        emit changed();
    }

    void applySurfaceCompatibilitySection(const QJsonObject &section)
    {
        m_surface = MerceColorJson::color(section, QStringLiteral("base"), m_surface);
        m_elevated = MerceColorJson::color(section, QStringLiteral("raised"), m_elevated);
        m_hover = MerceColorJson::color(section, QStringLiteral("hover"), m_hover);
        m_pressed = MerceColorJson::color(section, QStringLiteral("pressed"), m_pressed);
        m_tinted = MerceColorJson::color(section, QStringLiteral("tinted"), m_tinted);
        emit changed();
    }

signals:
    void changed();

private:
    QColor m_base = QColor(QStringLiteral("#FAF8F6"));
    QColor m_subtle = QColor(QStringLiteral("#F5F0EB"));
    QColor m_surface = QColor(QStringLiteral("#FFFFFF"));
    QColor m_elevated = QColor(QStringLiteral("#FFFFFF"));
    QColor m_hover = QColor(QStringLiteral("#F5F0EB"));
    QColor m_pressed = QColor(QStringLiteral("#E8DFD5"));
    QColor m_tinted = QColor(QStringLiteral("#F5F0EB"));
    QColor m_overlay = QColor::fromRgbF(31.0 / 255.0, 21.0 / 255.0, 16.0 / 255.0, 0.5);
};

class MerceColorsBorder : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QColor subtle READ base NOTIFY changed FINAL)
    Q_PROPERTY(QColor base READ base NOTIFY changed FINAL)
    Q_PROPERTY(QColor strong READ strong NOTIFY changed FINAL)
    Q_PROPERTY(QColor focus READ focus NOTIFY changed FINAL)
    Q_PROPERTY(QColor disabled READ disabled NOTIFY changed FINAL)
    Q_PROPERTY(QColor error READ error NOTIFY changed FINAL)
    Q_PROPERTY(QColor success READ success NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MerceColorsBorder(QObject *parent = nullptr) : QObject(parent) {}

    QColor base() const { return m_base; }
    QColor strong() const { return m_strong; }
    QColor focus() const { return m_focus; }
    QColor disabled() const { return m_disabled; }
    QColor error() const { return m_error; }
    QColor success() const { return m_success; }

    void applyManifestSection(const QJsonObject &section)
    {
        m_base = MerceColorJson::color(
            section,
            section.contains(QStringLiteral("subtle")) ? QStringLiteral("subtle")
                                                       : QStringLiteral("base"),
            m_base);
        m_strong = MerceColorJson::color(section, QStringLiteral("strong"), m_strong);
        m_focus = MerceColorJson::color(section, QStringLiteral("focus"), m_focus);
        m_disabled = MerceColorJson::color(section,
                                           QStringLiteral("disabled"),
                                           section.contains(QStringLiteral("disabled")) ? m_disabled : m_base);
        m_error = MerceColorJson::color(section, QStringLiteral("error"), m_error);
        m_success = MerceColorJson::color(section, QStringLiteral("success"), m_success);
        emit changed();
    }

    void applyStatusCompatibilitySection(const QJsonObject &section)
    {
        m_error = MerceColorJson::color(section.value(QStringLiteral("error")).toObject(),
                                        QStringLiteral("border"),
                                        m_error);
        m_success = MerceColorJson::color(section.value(QStringLiteral("success")).toObject(),
                                          QStringLiteral("border"),
                                          m_success);
        emit changed();
    }

signals:
    void changed();

private:
    QColor m_base = QColor(QStringLiteral("#E8DFD5"));
    QColor m_strong = QColor(QStringLiteral("#D4C4B5"));
    QColor m_focus = QColor(QStringLiteral("#C4785A"));
    QColor m_disabled = QColor(QStringLiteral("#E8DFD5"));
    QColor m_error = QColor(QStringLiteral("#C45A5A"));
    QColor m_success = QColor(QStringLiteral("#4A7C59"));
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
    Q_PROPERTY(QColor primaryHover READ primaryHover NOTIFY changed FINAL)
    Q_PROPERTY(QColor primaryPressed READ primaryPressed NOTIFY changed FINAL)
    Q_PROPERTY(QColor primarySubtle READ primarySubtle NOTIFY changed FINAL)
    Q_PROPERTY(QColor secondaryHover READ secondaryHover NOTIFY changed FINAL)
    Q_PROPERTY(QColor secondaryPressed READ secondaryPressed NOTIFY changed FINAL)
    Q_PROPERTY(QColor destructiveHover READ destructiveHover NOTIFY changed FINAL)
    Q_PROPERTY(QColor destructivePressed READ destructivePressed NOTIFY changed FINAL)
    Q_PROPERTY(QColor disabled READ disabled NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MerceColorsAction(QObject *parent = nullptr)
        : QObject(parent),
          m_primary(new MerceColorsActionRole(QColor(QStringLiteral("#C4785A")),
                                              QColor(QStringLiteral("#FFFFFF")),
                                              QColor(QStringLiteral("#C4785A")),
                                              this)),
          m_secondary(new MerceColorsActionRole(QColor(QStringLiteral("#53615D")),
                                                QColor(QStringLiteral("#FFFFFF")),
                                                QColor(QStringLiteral("#53615D")),
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
    QColor primaryHover() const { return m_primaryHover; }
    QColor primaryPressed() const { return m_primaryPressed; }
    QColor primarySubtle() const { return m_primarySubtle; }
    QColor secondaryHover() const { return m_secondaryHover; }
    QColor secondaryPressed() const { return m_secondaryPressed; }
    QColor destructiveHover() const { return m_destructiveHover; }
    QColor destructivePressed() const { return m_destructivePressed; }
    QColor disabled() const { return m_disabled; }

    Q_INVOKABLE QColor base(const QString &variant) const
    {
        if (variant == QStringLiteral("secondary"))
            return secondary()->container();
        if (variant == QStringLiteral("destructive"))
            return destructive()->container();
        if (variant == QStringLiteral("disabled"))
            return disabled();
        return primary()->container();
    }

    Q_INVOKABLE QColor hover(const QString &variant) const
    {
        if (variant == QStringLiteral("secondary"))
            return secondaryHover();
        if (variant == QStringLiteral("destructive"))
            return destructiveHover();
        if (variant == QStringLiteral("disabled"))
            return disabled();
        return primaryHover();
    }

    Q_INVOKABLE QColor pressed(const QString &variant) const
    {
        if (variant == QStringLiteral("secondary"))
            return secondaryPressed();
        if (variant == QStringLiteral("destructive"))
            return destructivePressed();
        if (variant == QStringLiteral("disabled"))
            return disabled();
        return primaryPressed();
    }

    void applyManifestSection(const QJsonObject &section, bool darkMode)
    {
        m_primary->applyManifestSection(section.value(QStringLiteral("primary")).toObject());
        m_secondary->applyManifestSection(section.value(QStringLiteral("secondary")).toObject());
        m_destructive->applyManifestSection(
            section.value(QStringLiteral("destructive")).toObject());

        m_primaryHover = MerceColorJson::stateColor(m_primary->container(), darkMode, 108);
        m_primaryPressed = MerceColorJson::stateColor(m_primary->container(), darkMode, 116);
        m_secondaryHover = MerceColorJson::stateColor(m_secondary->container(), darkMode, 108);
        m_secondaryPressed = MerceColorJson::stateColor(m_secondary->container(), darkMode, 116);
        m_destructiveHover =
            MerceColorJson::stateColor(m_destructive->container(), darkMode, 108);
        m_destructivePressed =
            MerceColorJson::stateColor(m_destructive->container(), darkMode, 116);
        m_primarySubtle = m_primary->container();
        m_primarySubtle.setAlphaF(0.10);
        m_disabled = m_primary->container();
        m_disabled.setAlphaF(0.12);
        emit changed();
    }

signals:
    void changed();

private:
    MerceColorsActionRole *m_primary = nullptr;
    MerceColorsActionRole *m_secondary = nullptr;
    MerceColorsActionRole *m_destructive = nullptr;
    QColor m_primaryHover = QColor(QStringLiteral("#E8B5A3"));
    QColor m_primaryPressed = QColor(QStringLiteral("#9A4F34"));
    QColor m_primarySubtle = QColor(QStringLiteral("#2D4A3E"));
    QColor m_secondaryHover = QColor(QStringLiteral("#9A4F34"));
    QColor m_secondaryPressed = QColor(QStringLiteral("#1A2C24"));
    QColor m_destructiveHover = QColor(QStringLiteral("#9F201A"));
    QColor m_destructivePressed = QColor(QStringLiteral("#881812"));
    QColor m_disabled = QColor(QStringLiteral("#B8A494"));
};

class MerceColorsStatusRole : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QColor container READ background NOTIFY changed FINAL)
    Q_PROPERTY(QColor content READ foreground NOTIFY changed FINAL)
    Q_PROPERTY(QColor outline READ border NOTIFY changed FINAL)
    Q_PROPERTY(QColor foreground READ foreground NOTIFY changed FINAL)
    Q_PROPERTY(QColor background READ background NOTIFY changed FINAL)
    Q_PROPERTY(QColor border READ border NOTIFY changed FINAL)
    Q_PROPERTY(QColor strong READ strong NOTIFY changed FINAL)
    Q_PROPERTY(QColor onStrong READ onStrong NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MerceColorsStatusRole(const QColor &foreground,
                                   const QColor &background,
                                   const QColor &border,
                                   const QColor &strong,
                                   const QColor &onStrong,
                                   QObject *parent = nullptr)
        : QObject(parent),
          m_foreground(foreground),
          m_background(background),
          m_border(border),
          m_strong(strong),
          m_onStrong(onStrong)
    {
    }

    QColor foreground() const { return m_foreground; }
    QColor background() const { return m_background; }
    QColor border() const { return m_border; }
    QColor strong() const { return m_strong; }
    QColor onStrong() const { return m_onStrong; }

    void applyManifestSection(const QJsonObject &section)
    {
        m_foreground = MerceColorJson::color(
            section,
            section.contains(QStringLiteral("content")) ? QStringLiteral("content")
                                                        : QStringLiteral("foreground"),
            m_foreground);
        m_background = MerceColorJson::color(
            section,
            section.contains(QStringLiteral("container")) ? QStringLiteral("container")
                                                          : QStringLiteral("background"),
            m_background);
        m_border = MerceColorJson::color(
            section,
            section.contains(QStringLiteral("outline")) ? QStringLiteral("outline")
                                                        : QStringLiteral("border"),
            m_border);
        m_strong = MerceColorJson::color(section, QStringLiteral("strong"), m_strong);
        m_onStrong = MerceColorJson::color(section, QStringLiteral("onStrong"), m_onStrong);
        emit changed();
    }

    void applyLegacyColors(const QJsonValue &foregroundValue, const QJsonValue &backgroundValue)
    {
        const QColor foreground = MerceColorJson::colorValue(foregroundValue, m_foreground);
        const QColor background = MerceColorJson::colorValue(backgroundValue, m_background);

        m_foreground = foreground;
        m_background = background;
        m_border = foreground;
        m_strong = foreground;
        emit changed();
    }

signals:
    void changed();

private:
    QColor m_foreground;
    QColor m_background;
    QColor m_border;
    QColor m_strong;
    QColor m_onStrong;
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
          m_success(new MerceColorsStatusRole(QColor(QStringLiteral("#4A7C59")),
                                              QColor(QStringLiteral("#A8D4B8")),
                                              QColor(QStringLiteral("#4A7C59")),
                                              QColor(QStringLiteral("#4A7C59")),
                                              QColor(QStringLiteral("#FAF8F6")),
                                              this)),
          m_warning(new MerceColorsStatusRole(QColor(QStringLiteral("#1F1510")),
                                              QColor(QStringLiteral("#F0D9A8")),
                                              QColor(QStringLiteral("#D4A854")),
                                              QColor(QStringLiteral("#D4A854")),
                                              QColor(QStringLiteral("#1F1510")),
                                              this)),
          m_error(new MerceColorsStatusRole(QColor(QStringLiteral("#C45A5A")),
                                            QColor(QStringLiteral("#E8A8A8")),
                                            QColor(QStringLiteral("#C45A5A")),
                                            QColor(QStringLiteral("#C45A5A")),
                                            QColor(QStringLiteral("#FAF8F6")),
                                            this)),
          m_info(new MerceColorsStatusRole(QColor(QStringLiteral("#5A8FC4")),
                                           QColor(QStringLiteral("#A8CCE8")),
                                           QColor(QStringLiteral("#5A8FC4")),
                                           QColor(QStringLiteral("#5A8FC4")),
                                           QColor(QStringLiteral("#FAF8F6")),
                                           this)),
          m_neutral(new MerceColorsStatusRole(QColor(QStringLiteral("#4E5B58")),
                                              QColor(QStringLiteral("#EDEAE2")),
                                              QColor(QStringLiteral("#A9B2AE")),
                                              QColor(QStringLiteral("#4E5B58")),
                                              QColor(QStringLiteral("#FFFFFF")),
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
        applyRole(m_success,
                  section,
                  QStringLiteral("success"),
                  QStringLiteral("successSubtle"));
        applyRole(m_warning,
                  section,
                  QStringLiteral("warning"),
                  QStringLiteral("warningSubtle"));
        applyRole(m_error,
                  section,
                  QStringLiteral("error"),
                  QStringLiteral("errorSubtle"));
        applyRole(m_info,
                  section,
                  QStringLiteral("info"),
                  QStringLiteral("infoSubtle"));
        applyRole(m_neutral,
                  section,
                  QStringLiteral("neutral"),
                  QStringLiteral("neutralSubtle"));
        emit changed();
    }

signals:
    void changed();

private:
    static void applyRole(MerceColorsStatusRole *role,
                          const QJsonObject &section,
                          const QString &name,
                          const QString &legacyBackgroundName)
    {
        const QJsonValue value = section.value(name);
        if (value.isObject()) {
            role->applyManifestSection(value.toObject());
            return;
        }

        role->applyLegacyColors(value, section.value(legacyBackgroundName));
    }

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
    Q_PROPERTY(QColor container READ base NOTIFY changed FINAL)
    Q_PROPERTY(QColor containerRaised READ raised NOTIFY changed FINAL)
    Q_PROPERTY(QColor containerSunken READ containerSunken NOTIFY changed FINAL)
    Q_PROPERTY(QColor containerTinted READ tinted NOTIFY changed FINAL)
    Q_PROPERTY(QColor floating READ floating NOTIFY changed FINAL)
    Q_PROPERTY(QColor scrim READ scrim NOTIFY changed FINAL)
    Q_PROPERTY(QColor inverse READ inverse NOTIFY changed FINAL)
    Q_PROPERTY(QColor base READ base NOTIFY changed FINAL)
    Q_PROPERTY(QColor tinted READ tinted NOTIFY changed FINAL)
    Q_PROPERTY(QColor raised READ raised NOTIFY changed FINAL)
    Q_PROPERTY(QColor hover READ hover NOTIFY changed FINAL)
    Q_PROPERTY(QColor pressed READ pressed NOTIFY changed FINAL)
    Q_PROPERTY(QColor disabled READ disabled NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MerceColorsSurface(QObject *parent = nullptr) : QObject(parent) {}

    QColor base() const { return m_base; }
    QColor tinted() const { return m_tinted; }
    QColor raised() const { return m_raised; }
    QColor hover() const { return m_hover; }
    QColor pressed() const { return m_pressed; }
    QColor disabled() const { return m_disabled; }
    QColor canvas() const { return m_canvas; }
    QColor containerSunken() const { return m_containerSunken; }
    QColor floating() const { return m_floating; }
    QColor scrim() const { return m_scrim; }
    QColor inverse() const { return m_inverse; }

    void applyManifestSection(const QJsonObject &section)
    {
        m_canvas = MerceColorJson::color(section, QStringLiteral("canvas"), m_canvas);
        m_base = MerceColorJson::color(
            section,
            section.contains(QStringLiteral("container")) ? QStringLiteral("container")
                                                          : QStringLiteral("base"),
            m_base);
        m_tinted = MerceColorJson::color(
            section,
            section.contains(QStringLiteral("containerTinted"))
                ? QStringLiteral("containerTinted") : QStringLiteral("tinted"),
            m_tinted);
        m_raised = MerceColorJson::color(
            section,
            section.contains(QStringLiteral("containerRaised"))
                ? QStringLiteral("containerRaised") : QStringLiteral("raised"),
            m_raised);
        m_containerSunken =
            MerceColorJson::color(section, QStringLiteral("containerSunken"), m_containerSunken);
        m_floating = MerceColorJson::color(section, QStringLiteral("floating"), m_floating);
        m_scrim = MerceColorJson::color(section, QStringLiteral("scrim"), m_scrim);
        m_inverse = MerceColorJson::color(section, QStringLiteral("inverse"), m_inverse);
        m_hover = MerceColorJson::color(section, QStringLiteral("hover"), m_hover);
        m_pressed = MerceColorJson::color(section, QStringLiteral("pressed"), m_pressed);
        m_disabled = MerceColorJson::color(section, QStringLiteral("disabled"), m_disabled);
        if (section.contains(QStringLiteral("containerSunken"))) {
            m_hover = m_tinted;
            m_pressed = m_containerSunken;
            m_disabled = m_containerSunken;
        }
        emit changed();
    }

    void applyBackgroundCompatibilitySection(const QJsonObject &section)
    {
        m_base = MerceColorJson::color(section, QStringLiteral("surface"), m_base);
        m_tinted = MerceColorJson::color(section, QStringLiteral("tinted"), m_tinted);
        m_raised = MerceColorJson::color(section, QStringLiteral("elevated"), m_raised);
        m_hover = MerceColorJson::color(section, QStringLiteral("hover"), m_hover);
        m_pressed = MerceColorJson::color(section, QStringLiteral("pressed"), m_pressed);
        m_disabled = MerceColorJson::color(section, QStringLiteral("hover"), m_disabled);
        emit changed();
    }

signals:
    void changed();

private:
    QColor m_base = QColor(QStringLiteral("#FFFFFF"));
    QColor m_tinted = QColor(QStringLiteral("#F5F0EB"));
    QColor m_raised = QColor(QStringLiteral("#FFFFFF"));
    QColor m_hover = QColor(QStringLiteral("#F5F0EB"));
    QColor m_pressed = QColor(QStringLiteral("#E8DFD5"));
    QColor m_disabled = QColor(QStringLiteral("#F5F0EB"));
    QColor m_canvas = QColor(QStringLiteral("#FAF8F6"));
    QColor m_containerSunken = QColor(QStringLiteral("#EDEAE2"));
    QColor m_floating = QColor(QStringLiteral("#FFFFFF"));
    QColor m_scrim = QColor(QStringLiteral("#80000000"));
    QColor m_inverse = QColor(QStringLiteral("#151A19"));
};

class MerceColors : public QObject
{
    Q_OBJECT
    Q_PROPERTY(MerceColorsText *text READ text CONSTANT FINAL)
    Q_PROPERTY(MerceColorsText *content READ text CONSTANT FINAL)
    Q_PROPERTY(MerceColorsBackground *background READ background CONSTANT FINAL)
    Q_PROPERTY(MerceColorsBorder *border READ border CONSTANT FINAL)
    Q_PROPERTY(MerceColorsBorder *outline READ border CONSTANT FINAL)
    Q_PROPERTY(MerceColorsAction *action READ action CONSTANT FINAL)
    Q_PROPERTY(MerceColorsStatus *status READ status CONSTANT FINAL)
    Q_PROPERTY(MerceColorsSurface *surface READ surface CONSTANT FINAL)
    QML_ANONYMOUS

public:
    explicit MerceColors(QObject *parent = nullptr)
        : QObject(parent),
          m_text(new MerceColorsText(this)),
          m_background(new MerceColorsBackground(this)),
          m_border(new MerceColorsBorder(this)),
          m_action(new MerceColorsAction(this)),
          m_status(new MerceColorsStatus(this)),
          m_surface(new MerceColorsSurface(this))
    {
    }

    MerceColorsText *text() const { return m_text; }
    MerceColorsBackground *background() const { return m_background; }
    MerceColorsBorder *border() const { return m_border; }
    MerceColorsAction *action() const { return m_action; }
    MerceColorsStatus *status() const { return m_status; }
    MerceColorsSurface *surface() const { return m_surface; }

    void applyManifestSection(const QJsonObject &section, const QString &mode = {})
    {
        QJsonObject backgroundSection = section.value(QStringLiteral("background")).toObject();
        QJsonObject borderSection = section.value(QStringLiteral("border")).toObject();
        const QJsonObject statusSection = section.value(QStringLiteral("status")).toObject();
        const QJsonObject surfaceSection = section.value(QStringLiteral("surface")).toObject();
        if (backgroundSection.isEmpty() && surfaceSection.contains(QStringLiteral("canvas"))) {
            backgroundSection = {
                { QStringLiteral("base"), surfaceSection.value(QStringLiteral("canvas")) },
                { QStringLiteral("surface"), surfaceSection.value(QStringLiteral("container")) },
                { QStringLiteral("elevated"), surfaceSection.value(QStringLiteral("containerRaised")) },
                { QStringLiteral("hover"), surfaceSection.value(QStringLiteral("containerTinted")) },
                { QStringLiteral("pressed"), surfaceSection.value(QStringLiteral("containerSunken")) },
                { QStringLiteral("tinted"), surfaceSection.value(QStringLiteral("containerTinted")) },
                { QStringLiteral("overlay"), surfaceSection.value(QStringLiteral("scrim")) },
            };
        }
        if (borderSection.isEmpty())
            borderSection = section.value(QStringLiteral("outline")).toObject();

        m_text->applyManifestSection(
            section.contains(QStringLiteral("content"))
                ? section.value(QStringLiteral("content")).toObject()
                : section.value(QStringLiteral("text")).toObject());
        m_background->applyManifestSection(backgroundSection);
        m_border->applyManifestSection(borderSection);
        m_action->applyManifestSection(section.value(QStringLiteral("action")).toObject(),
                                       mode == QStringLiteral("dark"));
        m_status->applyManifestSection(statusSection);
        m_surface->applyManifestSection(surfaceSection);
        m_surface->applyBackgroundCompatibilitySection(backgroundSection);
        m_background->applySurfaceCompatibilitySection(surfaceSection);
        m_border->applyStatusCompatibilitySection(statusSection);
        emit changed();
    }

signals:
    void changed();

private:
    MerceColorsText *m_text = nullptr;
    MerceColorsBackground *m_background = nullptr;
    MerceColorsBorder *m_border = nullptr;
    MerceColorsAction *m_action = nullptr;
    MerceColorsStatus *m_status = nullptr;
    MerceColorsSurface *m_surface = nullptr;
};
