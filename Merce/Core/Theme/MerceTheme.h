#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>

#include "MerceBreakpoints.h"
#include "MerceIconography.h"
#include "MerceMotion.h"
#include "MercePalette.h"
#include "MerceRadius.h"
#include "MerceShadows.h"
#include "MerceSpacing.h"
#include "MerceTypography.h"
#include "MerceZIndex.h"

class MerceTheme : public QObject
{
    Q_OBJECT
    Q_PROPERTY(MercePalette *palette READ palette NOTIFY paletteChanged FINAL)
    Q_PROPERTY(MercePalette *colors READ colors NOTIFY paletteChanged FINAL)
    Q_PROPERTY(MerceSpacing *spacing READ spacing NOTIFY spacingChanged FINAL)
    Q_PROPERTY(MerceRadius *radius READ radius NOTIFY radiusChanged FINAL)
    Q_PROPERTY(MerceTypography *typography READ typography NOTIFY typographyChanged FINAL)
    Q_PROPERTY(MerceMotion *motion READ motion NOTIFY motionChanged FINAL)
    Q_PROPERTY(MerceIconography *icons READ icons NOTIFY iconsChanged FINAL)
    Q_PROPERTY(MerceIconography *iconography READ iconography NOTIFY iconsChanged FINAL)
    Q_PROPERTY(MerceZIndex *zIndex READ zIndex NOTIFY zIndexChanged FINAL)
    Q_PROPERTY(MerceBreakpoints *breakpoint READ breakpoint NOTIFY breakpointsChanged FINAL)
    Q_PROPERTY(MerceBreakpoints *breakpoints READ breakpoints NOTIFY breakpointsChanged FINAL)
    Q_PROPERTY(MerceShadows *shadows READ shadows NOTIFY shadowsChanged FINAL)
    QML_NAMED_ELEMENT(Theme)
    QML_SINGLETON

public:
    explicit MerceTheme(QObject *parent = nullptr);

    MercePalette *palette() const { return m_palette; }
    MercePalette *colors() const { return m_palette; }
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

signals:
    void paletteChanged();
    void spacingChanged();
    void radiusChanged();
    void typographyChanged();
    void motionChanged();
    void iconsChanged();
    void zIndexChanged();
    void breakpointsChanged();
    void shadowsChanged();

private:
    MercePalette *m_palette = nullptr;
    MerceSpacing *m_spacing = nullptr;
    MerceRadius *m_radius = nullptr;
    MerceTypography *m_typography = nullptr;
    MerceMotion *m_motion = nullptr;
    MerceIconography *m_icons = nullptr;
    MerceZIndex *m_zIndex = nullptr;
    MerceBreakpoints *m_breakpoints = nullptr;
    MerceShadows *m_shadows = nullptr;
};
