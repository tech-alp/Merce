#pragma once

#include <QColor>
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
    explicit MercePaletteAction(MercePaletteRaw *raw, QObject *parent = nullptr)
        : QObject(parent), m_raw(raw)
    {
    }

    QColor primary() const { return m_raw->primary(); }
    QColor primaryLight() const { return m_raw->primaryLight(); }
    QColor primaryDark() const { return m_raw->primaryDark(); }
    QColor secondary() const { return m_raw->secondary(); }
    QColor secondaryLight() const { return m_raw->secondaryLight(); }
    QColor secondaryDark() const { return m_raw->secondaryDark(); }
    QColor success() const { return m_raw->success(); }
    QColor warning() const { return m_raw->warning(); }
    QColor destructive() const { return m_raw->error(); }

    Q_INVOKABLE QColor base(const QString &variant) const
    {
        if (variant == QStringLiteral("success"))
            return success();
        if (variant == QStringLiteral("warning"))
            return warning();
        if (variant == QStringLiteral("destructive") || variant == QStringLiteral("error"))
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
            return m_raw->successLight();
        if (variant == QStringLiteral("warning"))
            return m_raw->warningLight();
        if (variant == QStringLiteral("destructive") || variant == QStringLiteral("error"))
            return m_raw->errorLight();
        if (variant == QStringLiteral("secondary"))
            return secondaryLight();
        return primaryLight();
    }

signals:
    void changed();

private:
    MercePaletteRaw *m_raw = nullptr;
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
    explicit MercePaletteProduct(MercePaletteRaw *raw, QObject *parent = nullptr)
        : QObject(parent), m_raw(raw)
    {
    }

    QColor priceRegular() const { return m_raw->gray900(); }
    QColor priceSale() const { return m_raw->error(); }
    QColor priceOriginal() const { return m_raw->gray500(); }
    QColor badgeNew() const { return m_raw->primaryLight(); }
    QColor badgeSale() const { return m_raw->errorLight(); }
    QColor badgeBestSeller() const { return m_raw->successLight(); }
    QColor badgeLimited() const { return m_raw->warningLight(); }
    QColor badgeLowStock() const { return m_raw->warningLight(); }

signals:
    void changed();

private:
    MercePaletteRaw *m_raw = nullptr;
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
    explicit MercePaletteText(MercePaletteRaw *raw, QObject *parent = nullptr)
        : QObject(parent), m_raw(raw)
    {
    }

    QColor primary() const { return m_raw->gray900(); }
    QColor secondary() const { return m_raw->gray700(); }
    QColor tertiary() const { return m_raw->gray500(); }
    QColor inverse() const { return m_raw->gray50(); }
    QColor link() const { return m_raw->primary(); }
    QColor linkHover() const { return m_raw->primaryDark(); }
    QColor disabled() const { return m_raw->gray400(); }

signals:
    void changed();

private:
    MercePaletteRaw *m_raw = nullptr;
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
    explicit MercePaletteBackground(MercePaletteRaw *raw, QObject *parent = nullptr)
        : QObject(parent), m_raw(raw)
    {
    }

    QColor base() const { return m_raw->gray50(); }
    QColor surface() const { return QColor(QStringLiteral("#FFFFFF")); }
    QColor elevated() const { return QColor(QStringLiteral("#FFFFFF")); }
    QColor hover() const { return m_raw->gray100(); }
    QColor pressed() const { return m_raw->gray200(); }
    QColor overlay() const { return QColor::fromRgbF(31.0 / 255.0, 21.0 / 255.0, 16.0 / 255.0, 0.5); }
    QColor tinted() const { return m_raw->gray100(); }

signals:
    void changed();

private:
    MercePaletteRaw *m_raw = nullptr;
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
    explicit MercePaletteBorder(MercePaletteRaw *raw, QObject *parent = nullptr)
        : QObject(parent), m_raw(raw)
    {
    }

    QColor base() const { return m_raw->gray200(); }
    QColor strong() const { return m_raw->gray300(); }
    QColor focus() const { return m_raw->primary(); }
    QColor error() const { return m_raw->error(); }
    QColor success() const { return m_raw->success(); }

signals:
    void changed();

private:
    MercePaletteRaw *m_raw = nullptr;
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
    explicit MercePaletteStatus(MercePaletteRaw *raw, QObject *parent = nullptr)
        : QObject(parent), m_raw(raw)
    {
    }

    QColor success() const { return m_raw->success(); }
    QColor successLight() const { return m_raw->successLight(); }
    QColor warning() const { return m_raw->warning(); }
    QColor warningLight() const { return m_raw->warningLight(); }
    QColor error() const { return m_raw->error(); }
    QColor errorLight() const { return m_raw->errorLight(); }
    QColor info() const { return m_raw->info(); }
    QColor infoLight() const { return m_raw->infoLight(); }

signals:
    void changed();

private:
    MercePaletteRaw *m_raw = nullptr;
};

class MercePaletteSurface : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QColor base READ base NOTIFY changed FINAL)
    Q_PROPERTY(QColor tinted READ tinted NOTIFY changed FINAL)
    Q_PROPERTY(QColor raised READ raised NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MercePaletteSurface(MercePaletteRaw *raw, QObject *parent = nullptr)
        : QObject(parent), m_raw(raw)
    {
    }

    QColor base() const { return QColor(QStringLiteral("#FFFFFF")); }
    QColor tinted() const { return m_raw->gray100(); }
    QColor raised() const { return QColor(QStringLiteral("#FFFFFF")); }

signals:
    void changed();

private:
    MercePaletteRaw *m_raw = nullptr;
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
    Q_PROPERTY(QColor statusError READ statusError NOTIFY changed FINAL)
    QML_ANONYMOUS

public:
    explicit MercePalette(QObject *parent = nullptr)
        : QObject(parent),
          m_raw(new MercePaletteRaw(this)),
          m_action(new MercePaletteAction(m_raw, this)),
          m_product(new MercePaletteProduct(m_raw, this)),
          m_text(new MercePaletteText(m_raw, this)),
          m_background(new MercePaletteBackground(m_raw, this)),
          m_border(new MercePaletteBorder(m_raw, this)),
          m_status(new MercePaletteStatus(m_raw, this)),
          m_surface(new MercePaletteSurface(m_raw, this))
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
    QColor statusError() const { return m_status->error(); }

signals:
    void changed();

private:
    MercePaletteRaw *m_raw = nullptr;
    MercePaletteAction *m_action = nullptr;
    MercePaletteProduct *m_product = nullptr;
    MercePaletteText *m_text = nullptr;
    MercePaletteBackground *m_background = nullptr;
    MercePaletteBorder *m_border = nullptr;
    MercePaletteStatus *m_status = nullptr;
    MercePaletteSurface *m_surface = nullptr;
};
