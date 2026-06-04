#pragma once

#include <QColor>
#include <QJsonObject>
#include <QObject>
#include <QString>
#include <QtQml/qqmlregistration.h>

class MercePaletteRaw : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QColor primary READ primary NOTIFY changed FINAL)
    Q_PROPERTY(QColor primaryLight READ primaryLight NOTIFY changed FINAL)
    Q_PROPERTY(QColor primaryDark READ primaryDark NOTIFY changed FINAL)
    Q_PROPERTY(QColor secondary READ secondary NOTIFY changed FINAL)
    Q_PROPERTY(QColor secondaryLight READ secondaryLight NOTIFY changed FINAL)
    Q_PROPERTY(QColor secondaryDark READ secondaryDark NOTIFY changed FINAL)
    Q_PROPERTY(QColor success READ success NOTIFY changed FINAL)
    Q_PROPERTY(QColor successLight READ successLight NOTIFY changed FINAL)
    Q_PROPERTY(QColor warning READ warning NOTIFY changed FINAL)
    Q_PROPERTY(QColor warningLight READ warningLight NOTIFY changed FINAL)
    Q_PROPERTY(QColor error READ error NOTIFY changed FINAL)
    Q_PROPERTY(QColor errorLight READ errorLight NOTIFY changed FINAL)
    Q_PROPERTY(QColor info READ info NOTIFY changed FINAL)
    Q_PROPERTY(QColor infoLight READ infoLight NOTIFY changed FINAL)
    Q_PROPERTY(QColor gray50 READ gray50 NOTIFY changed FINAL)
    Q_PROPERTY(QColor gray100 READ gray100 NOTIFY changed FINAL)
    Q_PROPERTY(QColor gray200 READ gray200 NOTIFY changed FINAL)
    Q_PROPERTY(QColor gray300 READ gray300 NOTIFY changed FINAL)
    Q_PROPERTY(QColor gray400 READ gray400 NOTIFY changed FINAL)
    Q_PROPERTY(QColor gray500 READ gray500 NOTIFY changed FINAL)
    Q_PROPERTY(QColor gray600 READ gray600 NOTIFY changed FINAL)
    Q_PROPERTY(QColor gray700 READ gray700 NOTIFY changed FINAL)
    Q_PROPERTY(QColor gray800 READ gray800 NOTIFY changed FINAL)
    Q_PROPERTY(QColor gray900 READ gray900 NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MercePaletteRaw(QObject *parent = nullptr) : QObject(parent) {}

    QColor primary() const { return QColor(QStringLiteral("#C4785A")); }
    QColor primaryLight() const { return QColor(QStringLiteral("#E8B5A3")); }
    QColor primaryDark() const { return QColor(QStringLiteral("#9A4F34")); }
    QColor secondary() const { return QColor(QStringLiteral("#2D4A3E")); }
    QColor secondaryLight() const { return QColor(QStringLiteral("#4A6B5D")); }
    QColor secondaryDark() const { return QColor(QStringLiteral("#1A2C24")); }
    QColor success() const { return QColor(QStringLiteral("#4A7C59")); }
    QColor successLight() const { return QColor(QStringLiteral("#A8D4B8")); }
    QColor warning() const { return QColor(QStringLiteral("#D4A854")); }
    QColor warningLight() const { return QColor(QStringLiteral("#F0D9A8")); }
    QColor error() const { return QColor(QStringLiteral("#C45A5A")); }
    QColor errorLight() const { return QColor(QStringLiteral("#E8A8A8")); }
    QColor info() const { return QColor(QStringLiteral("#5A8FC4")); }
    QColor infoLight() const { return QColor(QStringLiteral("#A8CCE8")); }
    QColor gray50() const { return QColor(QStringLiteral("#FAF8F6")); }
    QColor gray100() const { return QColor(QStringLiteral("#F5F0EB")); }
    QColor gray200() const { return QColor(QStringLiteral("#E8DFD5")); }
    QColor gray300() const { return QColor(QStringLiteral("#D4C4B5")); }
    QColor gray400() const { return QColor(QStringLiteral("#B8A494")); }
    QColor gray500() const { return QColor(QStringLiteral("#9A8472")); }
    QColor gray600() const { return QColor(QStringLiteral("#7A6556")); }
    QColor gray700() const { return QColor(QStringLiteral("#5C4A3D")); }
    QColor gray800() const { return QColor(QStringLiteral("#3D2F26")); }
    QColor gray900() const { return QColor(QStringLiteral("#1F1510")); }

signals:
    void changed();
};

class MercePaletteAction : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QColor primary READ primary NOTIFY changed FINAL)
    Q_PROPERTY(QColor primaryLight READ primaryLight NOTIFY changed FINAL)
    Q_PROPERTY(QColor primaryDark READ primaryDark NOTIFY changed FINAL)
    Q_PROPERTY(QColor secondary READ secondary NOTIFY changed FINAL)
    Q_PROPERTY(QColor secondaryLight READ secondaryLight NOTIFY changed FINAL)
    Q_PROPERTY(QColor secondaryDark READ secondaryDark NOTIFY changed FINAL)
    Q_PROPERTY(QColor success READ success NOTIFY changed FINAL)
    Q_PROPERTY(QColor warning READ warning NOTIFY changed FINAL)
    Q_PROPERTY(QColor destructive READ destructive NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MercePaletteAction(QObject *parent = nullptr) : QObject(parent) {}

    QColor primary() const { return m_primary; }
    QColor primaryLight() const { return m_primaryLight; }
    QColor primaryDark() const { return m_primaryDark; }
    QColor secondary() const { return m_secondary; }
    QColor secondaryLight() const { return QColor(QStringLiteral("#4A6B5D")); }
    QColor secondaryDark() const { return QColor(QStringLiteral("#1A2C24")); }
    QColor success() const { return m_success; }
    QColor warning() const { return m_warning; }
    QColor destructive() const { return m_destructive; }

    Q_INVOKABLE QColor base(const QString &variant) const
    {
        if (variant == QStringLiteral("success"))
            return success();
        if (variant == QStringLiteral("warning"))
            return warning();
        if (variant == QStringLiteral("destructive") || variant == QStringLiteral("error"))
            return destructive();
        if (variant == QStringLiteral("destructiveDark") || variant == QStringLiteral("errorDark"))
            return destructive();
        if (variant == QStringLiteral("secondary"))
            return secondary();
        if (variant == QStringLiteral("secondaryDark"))
            return secondaryDark();
        if (variant == QStringLiteral("primaryDark"))
            return primaryDark();
        return primary();
    }

    Q_INVOKABLE QColor light(const QString &variant) const
    {
        if (variant == QStringLiteral("success"))
            return QColor(QStringLiteral("#A8D4B8"));
        if (variant == QStringLiteral("warning"))
            return QColor(QStringLiteral("#F0D9A8"));
        if (variant == QStringLiteral("destructive") || variant == QStringLiteral("error"))
            return QColor(QStringLiteral("#E8A8A8"));
        if (variant == QStringLiteral("secondary"))
            return secondaryLight();
        return primaryLight();
    }

    void applyValues(const QColor &primary,
                     const QColor &primaryLight,
                     const QColor &primaryDark,
                     const QColor &secondary,
                     const QColor &success,
                     const QColor &warning,
                     const QColor &destructive)
    {
        m_primary = primary;
        m_primaryLight = primaryLight;
        m_primaryDark = primaryDark;
        m_secondary = secondary;
        m_success = success;
        m_warning = warning;
        m_destructive = destructive;
        emit changed();
    }

signals:
    void changed();

private:
    QColor m_primary = QColor(QStringLiteral("#C4785A"));
    QColor m_primaryLight = QColor(QStringLiteral("#E8B5A3"));
    QColor m_primaryDark = QColor(QStringLiteral("#9A4F34"));
    QColor m_secondary = QColor(QStringLiteral("#2D4A3E"));
    QColor m_success = QColor(QStringLiteral("#4A7C59"));
    QColor m_warning = QColor(QStringLiteral("#D4A854"));
    QColor m_destructive = QColor(QStringLiteral("#C45A5A"));
};

class MercePaletteProduct : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QColor priceRegular READ priceRegular NOTIFY changed FINAL)
    Q_PROPERTY(QColor priceSale READ priceSale NOTIFY changed FINAL)
    Q_PROPERTY(QColor priceOriginal READ priceOriginal NOTIFY changed FINAL)
    Q_PROPERTY(QColor badgeNew READ badgeNew NOTIFY changed FINAL)
    Q_PROPERTY(QColor badgeSale READ badgeSale NOTIFY changed FINAL)
    Q_PROPERTY(QColor badgeBestSeller READ badgeBestSeller NOTIFY changed FINAL)
    Q_PROPERTY(QColor badgeLimited READ badgeLimited NOTIFY changed FINAL)
    Q_PROPERTY(QColor badgeLowStock READ badgeLowStock NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MercePaletteProduct(QObject *parent = nullptr) : QObject(parent) {}

    QColor priceRegular() const { return m_priceRegular; }
    QColor priceSale() const { return m_priceSale; }
    QColor priceOriginal() const { return m_priceOriginal; }
    QColor badgeNew() const { return QColor(QStringLiteral("#E8B5A3")); }
    QColor badgeSale() const { return QColor(QStringLiteral("#E8A8A8")); }
    QColor badgeBestSeller() const { return QColor(QStringLiteral("#A8D4B8")); }
    QColor badgeLimited() const { return QColor(QStringLiteral("#F0D9A8")); }
    QColor badgeLowStock() const { return QColor(QStringLiteral("#F0D9A8")); }

    void applyValues(const QColor &priceRegular, const QColor &priceSale, const QColor &priceOriginal)
    {
        m_priceRegular = priceRegular;
        m_priceSale = priceSale;
        m_priceOriginal = priceOriginal;
        emit changed();
    }

signals:
    void changed();

private:
    QColor m_priceRegular = QColor(QStringLiteral("#1F1510"));
    QColor m_priceSale = QColor(QStringLiteral("#C45A5A"));
    QColor m_priceOriginal = QColor(QStringLiteral("#9A8472"));
};

class MercePaletteText : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QColor primary READ primary NOTIFY changed FINAL)
    Q_PROPERTY(QColor secondary READ secondary NOTIFY changed FINAL)
    Q_PROPERTY(QColor tertiary READ tertiary NOTIFY changed FINAL)
    Q_PROPERTY(QColor inverse READ inverse NOTIFY changed FINAL)
    Q_PROPERTY(QColor link READ link NOTIFY changed FINAL)
    Q_PROPERTY(QColor linkHover READ linkHover NOTIFY changed FINAL)
    Q_PROPERTY(QColor disabled READ disabled NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MercePaletteText(QObject *parent = nullptr) : QObject(parent) {}

    QColor primary() const { return m_primary; }
    QColor secondary() const { return m_secondary; }
    QColor tertiary() const { return m_tertiary; }
    QColor inverse() const { return m_inverse; }
    QColor link() const { return m_link; }
    QColor linkHover() const { return m_linkHover; }
    QColor disabled() const { return QColor(QStringLiteral("#B8A494")); }

    void applyValues(const QColor &primary,
                     const QColor &secondary,
                     const QColor &tertiary,
                     const QColor &inverse,
                     const QColor &link,
                     const QColor &linkHover)
    {
        m_primary = primary;
        m_secondary = secondary;
        m_tertiary = tertiary;
        m_inverse = inverse;
        m_link = link;
        m_linkHover = linkHover;
        emit changed();
    }

signals:
    void changed();

private:
    QColor m_primary = QColor(QStringLiteral("#1F1510"));
    QColor m_secondary = QColor(QStringLiteral("#5C4A3D"));
    QColor m_tertiary = QColor(QStringLiteral("#9A8472"));
    QColor m_inverse = QColor(QStringLiteral("#FAF8F6"));
    QColor m_link = QColor(QStringLiteral("#C4785A"));
    QColor m_linkHover = QColor(QStringLiteral("#9A4F34"));
};

class MercePaletteBackground : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QColor base READ base NOTIFY changed FINAL)
    Q_PROPERTY(QColor surface READ surface NOTIFY changed FINAL)
    Q_PROPERTY(QColor elevated READ elevated NOTIFY changed FINAL)
    Q_PROPERTY(QColor hover READ hover NOTIFY changed FINAL)
    Q_PROPERTY(QColor pressed READ pressed NOTIFY changed FINAL)
    Q_PROPERTY(QColor overlay READ overlay NOTIFY changed FINAL)
    Q_PROPERTY(QColor tinted READ tinted NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MercePaletteBackground(QObject *parent = nullptr) : QObject(parent) {}

    QColor base() const { return m_base; }
    QColor surface() const { return m_surface; }
    QColor elevated() const { return m_elevated; }
    QColor hover() const { return m_hover; }
    QColor pressed() const { return m_pressed; }
    QColor overlay() const { return QColor::fromRgbF(31.0 / 255.0, 21.0 / 255.0, 16.0 / 255.0, 0.5); }
    QColor tinted() const { return m_tinted; }

    void applyValues(const QColor &base,
                     const QColor &surface,
                     const QColor &elevated,
                     const QColor &hover,
                     const QColor &pressed,
                     const QColor &tinted)
    {
        m_base = base;
        m_surface = surface;
        m_elevated = elevated;
        m_hover = hover;
        m_pressed = pressed;
        m_tinted = tinted;
        emit changed();
    }

signals:
    void changed();

private:
    QColor m_base = QColor(QStringLiteral("#FAF8F6"));
    QColor m_surface = QColor(QStringLiteral("#FFFFFF"));
    QColor m_elevated = QColor(QStringLiteral("#FFFFFF"));
    QColor m_hover = QColor(QStringLiteral("#F5F0EB"));
    QColor m_pressed = QColor(QStringLiteral("#E8DFD5"));
    QColor m_tinted = QColor(QStringLiteral("#F5F0EB"));
};

class MercePaletteBorder : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QColor base READ base NOTIFY changed FINAL)
    Q_PROPERTY(QColor strong READ strong NOTIFY changed FINAL)
    Q_PROPERTY(QColor focus READ focus NOTIFY changed FINAL)
    Q_PROPERTY(QColor error READ error NOTIFY changed FINAL)
    Q_PROPERTY(QColor success READ success NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MercePaletteBorder(QObject *parent = nullptr) : QObject(parent) {}

    QColor base() const { return m_base; }
    QColor strong() const { return m_strong; }
    QColor focus() const { return m_focus; }
    QColor error() const { return m_error; }
    QColor success() const { return m_success; }

    void applyValues(const QColor &base, const QColor &strong, const QColor &focus, const QColor &error, const QColor &success)
    {
        m_base = base;
        m_strong = strong;
        m_focus = focus;
        m_error = error;
        m_success = success;
        emit changed();
    }

signals:
    void changed();

private:
    QColor m_base = QColor(QStringLiteral("#E8DFD5"));
    QColor m_strong = QColor(QStringLiteral("#D4C4B5"));
    QColor m_focus = QColor(QStringLiteral("#C4785A"));
    QColor m_error = QColor(QStringLiteral("#C45A5A"));
    QColor m_success = QColor(QStringLiteral("#4A7C59"));
};

class MercePaletteStatus : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QColor success READ success NOTIFY changed FINAL)
    Q_PROPERTY(QColor successLight READ successLight NOTIFY changed FINAL)
    Q_PROPERTY(QColor warning READ warning NOTIFY changed FINAL)
    Q_PROPERTY(QColor warningLight READ warningLight NOTIFY changed FINAL)
    Q_PROPERTY(QColor error READ error NOTIFY changed FINAL)
    Q_PROPERTY(QColor errorLight READ errorLight NOTIFY changed FINAL)
    Q_PROPERTY(QColor info READ info NOTIFY changed FINAL)
    Q_PROPERTY(QColor infoLight READ infoLight NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MercePaletteStatus(QObject *parent = nullptr) : QObject(parent) {}

    QColor success() const { return m_success; }
    QColor successLight() const { return QColor(QStringLiteral("#A8D4B8")); }
    QColor warning() const { return m_warning; }
    QColor warningLight() const { return QColor(QStringLiteral("#F0D9A8")); }
    QColor error() const { return m_error; }
    QColor errorLight() const { return QColor(QStringLiteral("#E8A8A8")); }
    QColor info() const { return m_info; }
    QColor infoLight() const { return QColor(QStringLiteral("#A8CCE8")); }

    void applyValues(const QColor &success, const QColor &warning, const QColor &error, const QColor &info)
    {
        m_success = success;
        m_warning = warning;
        m_error = error;
        m_info = info;
        emit changed();
    }

signals:
    void changed();

private:
    QColor m_success = QColor(QStringLiteral("#4A7C59"));
    QColor m_warning = QColor(QStringLiteral("#D4A854"));
    QColor m_error = QColor(QStringLiteral("#C45A5A"));
    QColor m_info = QColor(QStringLiteral("#5A8FC4"));
};

class MercePaletteSurface : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QColor base READ base NOTIFY changed FINAL)
    Q_PROPERTY(QColor tinted READ tinted NOTIFY changed FINAL)
    Q_PROPERTY(QColor raised READ raised NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MercePaletteSurface(QObject *parent = nullptr) : QObject(parent) {}

    QColor base() const { return m_base; }
    QColor tinted() const { return m_tinted; }
    QColor raised() const { return m_raised; }

    void applyValues(const QColor &base, const QColor &tinted, const QColor &raised)
    {
        m_base = base;
        m_tinted = tinted;
        m_raised = raised;
        emit changed();
    }

signals:
    void changed();

private:
    QColor m_base = QColor(QStringLiteral("#FFFFFF"));
    QColor m_tinted = QColor(QStringLiteral("#F5F0EB"));
    QColor m_raised = QColor(QStringLiteral("#FFFFFF"));
};

class MercePalette : public QObject
{
    Q_OBJECT
    Q_PROPERTY(MercePaletteRaw *raw READ raw CONSTANT FINAL)
    Q_PROPERTY(MercePaletteAction *action READ action CONSTANT FINAL)
    Q_PROPERTY(MercePaletteProduct *product READ product CONSTANT FINAL)
    Q_PROPERTY(MercePaletteText *text READ text CONSTANT FINAL)
    Q_PROPERTY(MercePaletteBackground *background READ background CONSTANT FINAL)
    Q_PROPERTY(MercePaletteBorder *border READ border CONSTANT FINAL)
    Q_PROPERTY(MercePaletteStatus *status READ status CONSTANT FINAL)
    Q_PROPERTY(MercePaletteSurface *surface READ surface CONSTANT FINAL)
    Q_PROPERTY(QColor textPrimary READ textPrimary NOTIFY changed FINAL)
    Q_PROPERTY(QColor textInverse READ textInverse NOTIFY changed FINAL)
    Q_PROPERTY(QColor backgroundBase READ backgroundBase NOTIFY changed FINAL)
    Q_PROPERTY(QColor backgroundSurface READ backgroundSurface NOTIFY changed FINAL)
    Q_PROPERTY(QColor actionPrimary READ actionPrimary NOTIFY changed FINAL)
    Q_PROPERTY(QColor actionSecondary READ actionSecondary NOTIFY changed FINAL)
    Q_PROPERTY(QColor borderBase READ borderBase NOTIFY changed FINAL)
    Q_PROPERTY(QColor statusSuccess READ statusSuccess NOTIFY changed FINAL)
    Q_PROPERTY(QColor statusError READ statusError NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MercePalette(QObject *parent = nullptr)
        : QObject(parent),
          m_raw(new MercePaletteRaw(this)),
          m_action(new MercePaletteAction(this)),
          m_product(new MercePaletteProduct(this)),
          m_text(new MercePaletteText(this)),
          m_background(new MercePaletteBackground(this)),
          m_border(new MercePaletteBorder(this)),
          m_status(new MercePaletteStatus(this)),
          m_surface(new MercePaletteSurface(this))
    {
    }

    MercePaletteRaw *raw() const { return m_raw; }
    MercePaletteAction *action() const { return m_action; }
    MercePaletteProduct *product() const { return m_product; }
    MercePaletteText *text() const { return m_text; }
    MercePaletteBackground *background() const { return m_background; }
    MercePaletteBorder *border() const { return m_border; }
    MercePaletteStatus *status() const { return m_status; }
    MercePaletteSurface *surface() const { return m_surface; }

    QColor textPrimary() const { return m_text->primary(); }
    QColor textInverse() const { return m_text->inverse(); }
    QColor backgroundBase() const { return m_background->base(); }
    QColor backgroundSurface() const { return m_background->surface(); }
    QColor actionPrimary() const { return m_action->primary(); }
    QColor actionSecondary() const { return m_action->secondary(); }
    QColor borderBase() const { return m_border->base(); }
    QColor statusSuccess() const { return m_status->success(); }
    QColor statusError() const { return m_status->error(); }

    void applyManifestSection(const QJsonObject &section)
    {
        const QColor textPrimary = color(section, QStringLiteral("textPrimary"));
        const QColor textSecondary = color(section, QStringLiteral("textSecondary"));
        const QColor textTertiary = color(section, QStringLiteral("textTertiary"));
        const QColor textInverse = color(section, QStringLiteral("textInverse"));
        const QColor link = color(section, QStringLiteral("link"));
        const QColor backgroundBase = color(section, QStringLiteral("backgroundBase"));
        const QColor backgroundSurface = color(section, QStringLiteral("backgroundSurface"));
        const QColor backgroundElevated = color(section, QStringLiteral("backgroundElevated"));
        const QColor backgroundHover = color(section, QStringLiteral("backgroundHover"));
        const QColor backgroundPressed = color(section, QStringLiteral("backgroundPressed"));
        const QColor actionPrimary = color(section, QStringLiteral("actionPrimary"));
        const QColor actionPrimaryLight = color(section, QStringLiteral("actionPrimaryLight"));
        const QColor actionPrimaryDark = color(section, QStringLiteral("actionPrimaryDark"));
        const QColor actionSecondary = color(section, QStringLiteral("actionSecondary"));
        const QColor borderBase = color(section, QStringLiteral("borderBase"));
        const QColor borderStrong = color(section, QStringLiteral("borderStrong"));
        const QColor borderFocus = color(section, QStringLiteral("borderFocus"));
        const QColor statusError = color(section, QStringLiteral("statusError"));
        const QColor statusSuccess = color(section, QStringLiteral("statusSuccess"));
        const QColor statusWarning = color(section, QStringLiteral("statusWarning"));
        const QColor statusInfo = color(section, QStringLiteral("statusInfo"));
        const QColor surfaceBase = color(section, QStringLiteral("surfaceBase"));
        const QColor surfaceTinted = color(section, QStringLiteral("surfaceTinted"));

        m_action->applyValues(actionPrimary, actionPrimaryLight, actionPrimaryDark, actionSecondary, statusSuccess, statusWarning, statusError);
        m_product->applyValues(textPrimary, statusError, textTertiary);
        m_text->applyValues(textPrimary, textSecondary, textTertiary, textInverse, link, actionPrimaryDark);
        m_background->applyValues(backgroundBase, backgroundSurface, backgroundElevated, backgroundHover, backgroundPressed, surfaceTinted);
        m_border->applyValues(borderBase, borderStrong, borderFocus, statusError, statusSuccess);
        m_status->applyValues(statusSuccess, statusWarning, statusError, statusInfo);
        m_surface->applyValues(surfaceBase, surfaceTinted, backgroundElevated);
        emit changed();
    }

signals:
    void changed();

private:
    static QColor color(const QJsonObject &section, const QString &name)
    {
        return QColor(section.value(name).toString());
    }

    MercePaletteRaw *m_raw = nullptr;
    MercePaletteAction *m_action = nullptr;
    MercePaletteProduct *m_product = nullptr;
    MercePaletteText *m_text = nullptr;
    MercePaletteBackground *m_background = nullptr;
    MercePaletteBorder *m_border = nullptr;
    MercePaletteStatus *m_status = nullptr;
    MercePaletteSurface *m_surface = nullptr;
};
