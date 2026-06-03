#include "MerceTheme.h"

MerceTheme::MerceTheme(QObject *parent)
    : QObject(parent),
      m_palette(new MercePalette(this)),
      m_spacing(new MerceSpacing(this)),
      m_radius(new MerceRadius(this)),
      m_typography(new MerceTypography(this)),
      m_motion(new MerceMotion(this)),
      m_icons(new MerceIconography(this)),
      m_zIndex(new MerceZIndex(this)),
      m_breakpoints(new MerceBreakpoints(this)),
      m_shadows(new MerceShadows(this))
{
}
