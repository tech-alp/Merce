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
#include "MerceSize.h"
#include "MerceShadows.h"
#include "MerceSpacing.h"
#include "MerceState.h"
#include "MerceThemeRegistry.h"
#include "MerceTypography.h"
#include "MerceZIndex.h"

struct MerceThemeLoadResult;

class MerceTheme : public QObject
{
    Q_OBJECT
    Q_PROPERTY(MerceColors *colors READ colors NOTIFY colorsChanged FINAL)
    Q_PROPERTY(MerceSpacing *spacing READ spacing NOTIFY spacingChanged FINAL)
    Q_PROPERTY(MerceRadius *radius READ radius NOTIFY radiusChanged FINAL)
    Q_PROPERTY(MerceSize *size READ size NOTIFY sizeChanged FINAL)
    Q_PROPERTY(MerceState *state READ state NOTIFY stateChanged FINAL)
    Q_PROPERTY(MerceTypography *typography READ typography NOTIFY typographyChanged FINAL)
    Q_PROPERTY(MerceMotion *motion READ motion NOTIFY motionChanged FINAL)
    Q_PROPERTY(MerceIconography *icons READ icons NOTIFY iconsChanged FINAL)
    Q_PROPERTY(MerceIconography *iconography READ iconography NOTIFY iconsChanged FINAL)
    Q_PROPERTY(MerceZIndex *zIndex READ zIndex NOTIFY zIndexChanged FINAL)
    Q_PROPERTY(MerceBreakpoints *breakpoint READ breakpoint NOTIFY breakpointsChanged FINAL)
    Q_PROPERTY(MerceBreakpoints *breakpoints READ breakpoints NOTIFY breakpointsChanged FINAL)
    Q_PROPERTY(MerceShadows *shadows READ shadows NOTIFY shadowsChanged FINAL)
    Q_PROPERTY(QString activeBrand READ activeBrand NOTIFY activeThemeChanged FINAL)
    Q_PROPERTY(QString activeMode READ activeMode NOTIFY activeThemeChanged FINAL)
    Q_PROPERTY(QString activeProfile READ activeProfile NOTIFY activeThemeChanged FINAL)
    Q_PROPERTY(quint64 generation READ generation NOTIFY generationChanged FINAL)
    Q_PROPERTY(QVariantList availableThemes READ availableThemes NOTIFY availableThemesChanged FINAL)
    Q_PROPERTY(QVariantList availableProfiles READ availableProfiles NOTIFY availableProfilesChanged FINAL)
    QML_NAMED_ELEMENT(Theme)
    QML_SINGLETON

public:
    explicit MerceTheme(QObject *parent = nullptr);

    MerceColors *colors() const { return m_colors; }
    MerceSpacing *spacing() const { return m_spacing; }
    MerceRadius *radius() const { return m_radius; }
    MerceSize *size() const { return m_size; }
    MerceState *state() const { return m_state; }
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
    QString activeProfile() const;
    quint64 generation() const { return m_generation; }
    QVariantList availableThemes() const { return m_availableThemes; }
    QVariantList availableProfiles() const { return m_availableProfiles; }

    Q_INVOKABLE bool setContext(const QString &brand,
                                const QString &mode,
                                const QString &profile);
    Q_INVOKABLE bool setTheme(const QString &brand, const QString &mode = QString());
    Q_INVOKABLE bool addThemeSource(const QString &indexPath);
    Q_INVOKABLE void clearThemeSources();
    Q_INVOKABLE bool reloadThemes();

signals:
    void colorsChanged();
    void spacingChanged();
    void radiusChanged();
    void sizeChanged();
    void stateChanged();
    void typographyChanged();
    void motionChanged();
    void iconsChanged();
    void zIndexChanged();
    void breakpointsChanged();
    void shadowsChanged();
    void activeThemeChanged();
    void availableThemesChanged();
    void availableProfilesChanged();
    void generationChanged();

private:
    explicit MerceTheme(const QString &manifestIndexPath, QObject *parent = nullptr);

    bool reloadThemesInternal(bool emitAvailableThemesChanged);
    bool applyLoadedTheme(const MerceThemeLoadResult &result);
    bool updateActiveThemeState(const QString &brand,
                                const QString &mode,
                                const QString &profile);

    friend class tst_merce_theme_runtime_switch;

    QString m_builtinManifestIndexPath;
    QStringList m_externalThemeSourcePaths;
    MerceThemeRegistry m_colorRegistry;
    MerceProfileRegistry m_profileRegistry;
    QString m_activeBrand;
    QString m_activeMode;
    QString m_activeProfile;
    QVariantList m_availableThemes;
    QVariantList m_availableProfiles;
    MerceColors *m_colors = nullptr;
    MerceSpacing *m_spacing = nullptr;
    MerceRadius *m_radius = nullptr;
    MerceSize *m_size = nullptr;
    MerceState *m_state = nullptr;
    MerceTypography *m_typography = nullptr;
    MerceMotion *m_motion = nullptr;
    MerceIconography *m_icons = nullptr;
    MerceZIndex *m_zIndex = nullptr;
    MerceBreakpoints *m_breakpoints = nullptr;
    MerceShadows *m_shadows = nullptr;
    quint64 m_generation = 0;
    bool m_contextMutationInProgress = false;
};
