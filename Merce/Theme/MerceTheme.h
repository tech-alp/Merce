#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariantList>
#include <QtQml/qqmlregistration.h>

#include "MerceBreakpoints.h"
#include "MerceIconography.h"
#include "MerceMotion.h"
#include "MerceColors.h"
#include "MerceRadius.h"
#include "MerceShadows.h"
#include "MerceSpacing.h"
#include "MerceThemeRegistry.h"
#include "MerceTypography.h"
#include "MerceZIndex.h"

struct MerceThemeLoadResult;

class MerceTheme : public QObject
{
    Q_OBJECT
    Q_PROPERTY(MerceColors *colors READ colors CONSTANT FINAL)
    Q_PROPERTY(MerceSpacing *spacing READ spacing CONSTANT FINAL)
    Q_PROPERTY(MerceRadius *radius READ radius CONSTANT FINAL)
    Q_PROPERTY(MerceTypography *typography READ typography CONSTANT FINAL)
    Q_PROPERTY(MerceMotion *motion READ motion NOTIFY motionChanged FINAL)
    Q_PROPERTY(MerceIconography *icons READ icons NOTIFY iconsChanged FINAL)
    Q_PROPERTY(MerceIconography *iconography READ iconography NOTIFY iconsChanged FINAL)
    Q_PROPERTY(MerceZIndex *zIndex READ zIndex NOTIFY zIndexChanged FINAL)
    Q_PROPERTY(MerceBreakpoints *breakpoint READ breakpoint NOTIFY breakpointsChanged FINAL)
    Q_PROPERTY(MerceBreakpoints *breakpoints READ breakpoints NOTIFY breakpointsChanged FINAL)
    Q_PROPERTY(MerceShadows *shadows READ shadows NOTIFY shadowsChanged FINAL)
    Q_PROPERTY(QString activeBrand READ activeBrand NOTIFY activeThemeChanged FINAL)
    Q_PROPERTY(QString activeMode READ activeMode NOTIFY activeThemeChanged FINAL)
    Q_PROPERTY(QVariantList availableThemes READ availableThemes NOTIFY availableThemesChanged FINAL)
    QML_NAMED_ELEMENT(Theme)
    QML_SINGLETON

public:
    explicit MerceTheme(QObject *parent = nullptr);

    MerceColors *colors() const { return m_colors; }
    MerceSpacing *spacing() const { return m_spacing; }
    MerceRadius *radius() const { return m_radius; }
    MerceTypography *typography() const { return m_typography; }
    MerceMotion *motion() const { return m_motion; }
    MerceIconography *icons() const { return m_icons; }
    MerceIconography *iconography() const { return m_icons; }
    MerceZIndex *zIndex() const { return m_zIndex; }
    MerceBreakpoints *breakpoint() const { return m_breakpoints; }
    MerceBreakpoints *breakpoints() const { return m_breakpoints; }
    MerceShadows *shadows() const { return m_shadows; }
    QString activeBrand() const;
    QString activeMode() const;
    QVariantList availableThemes() const { return m_availableThemes; }

    Q_INVOKABLE bool setTheme(const QString &brand, const QString &mode = QString());
    Q_INVOKABLE bool addThemeSource(const QString &indexPath);
    Q_INVOKABLE void clearThemeSources();
    Q_INVOKABLE bool reloadThemes();

signals:
    void colorsChanged();
    void spacingChanged();
    void radiusChanged();
    void typographyChanged();
    void motionChanged();
    void iconsChanged();
    void zIndexChanged();
    void breakpointsChanged();
    void shadowsChanged();
    void activeThemeChanged();
    void availableThemesChanged();

private:
    explicit MerceTheme(const QString &manifestIndexPath, QObject *parent = nullptr);

    bool reloadThemesInternal(bool emitAvailableThemesChanged);
    bool applyLoadedTheme(const MerceThemeLoadResult &result);
    void setActiveThemeState(const QString &brand, const QString &mode);

    friend class tst_merce_theme_runtime_switch;

    QString m_builtinManifestIndexPath;
    QStringList m_externalThemeSourcePaths;
    MerceThemeRegistry m_registry;
    QString m_activeBrand;
    QString m_activeMode;
    QVariantList m_availableThemes;
    MerceColors *m_colors = nullptr;
    MerceSpacing *m_spacing = nullptr;
    MerceRadius *m_radius = nullptr;
    MerceTypography *m_typography = nullptr;
    MerceMotion *m_motion = nullptr;
    MerceIconography *m_icons = nullptr;
    MerceZIndex *m_zIndex = nullptr;
    MerceBreakpoints *m_breakpoints = nullptr;
    MerceShadows *m_shadows = nullptr;
};
