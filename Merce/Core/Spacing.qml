import QtQuick

/**
 * Merce Spacing System
 * 8pt-based spacing scale for consistent layouts
 */
QtObject {
    // Base unit: 8px
    readonly property int base: 8

    // Spacing scale (multiples of base unit)
    readonly property int none: 0
    readonly property int xxs: 4      // 0.5x base
    readonly property int xs: 8       // 1x base
    readonly property int sm: 12      // 1.5x base
    readonly property int md: 16      // 2x base
    readonly property int lg: 20      // 2.5x base
    readonly property int xl: 24      // 3x base
    readonly property int xl2: 32     // 4x base
    readonly property int xl3: 40     // 5x base
    readonly property int xl4: 48     // 6x base
    readonly property int xl5: 64     // 8x base
    readonly property int xl6: 80     // 10x base

    // Component-specific spacing
    readonly property int componentGap: 16
    readonly property int sectionGap: 48
    readonly property int pagePadding: 24

    // Touch-friendly spacing
    final property int touchTarget: 44
    final property int touchTargetCompact: 36

    // Layout gaps
    readonly property int gridGap: 16
    readonly property int stackGap: 12
    readonly property int inlineGap: 8
}
