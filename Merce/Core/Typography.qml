import QtQuick

/**
 * Merce Typography System
 * Editorial retail aesthetic with serif display + sans-serif body
 */
QtObject {
    // Font families
    readonly property string fontDisplay: "Playfair Display"
    readonly property string fontBody: "DM Sans"
    readonly property string fontMono: "SF Mono"

    // Alternative families (fallbacks)
    readonly property string fontDisplayFallback: "Georgia, serif"
    readonly property string fontBodyFallback: "-apple-system, BlinkMacSystemFont, sans-serif"

    // Font sizes (sp scale)
    readonly property int sizeXSmall: 12      // 12px - Caption
    readonly property int sizeSmall: 14       // 14px - Small
    readonly property int sizeMedium: 16      // 16px - Body
    readonly property int sizeLarge: 18       // 18px - Body Large
    readonly property int sizeXLarge: 20      // 20px - H4
    readonly property int size2XLarge: 24     // 24px - H3
    readonly property int size3XLarge: 30     // 30px - H2
    readonly property int size4XLarge: 36     // 36px - H1
    readonly property int size5XLarge: 48     // 48px - Display MD
    readonly property int size6XLarge: 60     // 60px - Display LG
    readonly property int size7XLarge: 72     // 72px - Display XL

    // Font weights
    readonly property int weightRegular: 400
    readonly property int weightMedium: 500
    readonly property int weightSemibold: 600
    readonly property int weightBold: 700

    // Line height (unitless multipliers)
    readonly property real leadingTight: 1.2
    readonly property real leadingSnug: 1.35
    readonly property real leadingNormal: 1.5
    readonly property real leadingRelaxed: 1.7

    // Letter spacing (em units)
    readonly property real trackingTight: -0.02
    readonly property real trackingNormal: 0
    readonly property real trackingWide: 0.02
    readonly property real trackingWider: 0.05
    readonly property real trackingWidest: 0.1

    // Text style presets
    readonly property var display: ({
        "family": fontDisplay,
        "size": size5XLarge,
        "weight": weightBold,
        "leading": leadingTight,
        "tracking": trackingTight
    })

    readonly property var h1: ({
        "family": fontDisplay,
        "size": size4XLarge,
        "weight": weightSemibold,
        "leading": leadingTight,
        "tracking": trackingTight
    })

    readonly property var h2: ({
        "family": fontDisplay,
        "size": size3XLarge,
        "weight": weightSemibold,
        "leading": leadingSnug,
        "tracking": trackingTight
    })

    readonly property var h3: ({
        "family": fontDisplay,
        "size": size2XLarge,
        "weight": weightMedium,
        "leading": leadingSnug,
        "tracking": trackingTight
    })

    readonly property var h4: ({
        "family": fontBody,
        "size": sizeXLarge,
        "weight": weightSemibold,
        "leading": leadingSnug,
        "tracking": trackingNormal
    })

    readonly property var body: ({
        "family": fontBody,
        "size": sizeMedium,
        "weight": weightRegular,
        "leading": leadingNormal,
        "tracking": trackingNormal
    })

    readonly property var bodyLarge: ({
        "family": fontBody,
        "size": sizeLarge,
        "weight": weightRegular,
        "leading": leadingRelaxed,
        "tracking": trackingNormal
    })

    readonly property var bodySmall: ({
        "family": fontBody,
        "size": sizeSmall,
        "weight": weightRegular,
        "leading": leadingRelaxed,
        "tracking": trackingNormal
    })

    readonly property var caption: ({
        "family": fontBody,
        "size": sizeXSmall,
        "weight": weightMedium,
        "leading": leadingNormal,
        "tracking": trackingWide
    })

    readonly property var overline: ({
        "family": fontBody,
        "size": sizeXSmall,
        "weight": weightSemibold,
        "leading": leadingNormal,
        "tracking": trackingWidest,
        "uppercase": true
    })

    readonly property var button: ({
        "family": fontBody,
        "size": sizeSmall,
        "weight": weightSemibold,
        "leading": leadingTight,
        "tracking": trackingNormal
    })

    readonly property var price: ({
        "family": fontBody,
        "size": size2XLarge,
        "weight": weightBold,
        "leading": leadingTight,
        "tracking": trackingTight
    })
}
