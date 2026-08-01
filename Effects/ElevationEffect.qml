import QtQuick
import QtQuick.Effects
import Merce.Theme as MerceRuntime

/**
 * ElevationEffect - Shadow/gölge efekti componenti
 * Qt MultiEffect kullanarak material design elevation shadow'ları oluşturur
 *
 * Kullanım:
 * ElevationEffect {
 *     elevation: 2  // 0-12 arası elevation değeri
 * }
 */
Item {
    id: root

    /**
     * Elevation level (0-12)
     * Material Design elevation standardlarına göre shadow yoğunluğu
     */
    property int elevation: 0

    /**
     * Shadow color (optional, defaults to black with alpha)
     */
    property color shadowColor: MerceRuntime.Theme.colors.surface.shadow

    /**
     * Shadow radius multiplier (for customization)
     */
    property real radiusMultiplier: 1.0

    /**
     * Shadow offset multiplier (for customization)
     */
    property real offsetMultiplier: 1.0

    // Elevation configuration based on Material Design
    readonly property var elevationConfig: {
        "0": { "blur": 0, "xOffset": 0, "yOffset": 0, "opacity": 0 },
        "1": { "blur": 4, "xOffset": 0, "yOffset": 2, "opacity": 0.12 },
        "2": { "blur": 8, "xOffset": 0, "yOffset": 4, "opacity": 0.16 },
        "3": { "blur": 12, "xOffset": 0, "yOffset": 6, "opacity": 0.20 },
        "4": { "blur": 16, "xOffset": 0, "yOffset": 8, "opacity": 0.24 },
        "5": { "blur": 20, "xOffset": 0, "yOffset": 10, "opacity": 0.28 },
        "6": { "blur": 24, "xOffset": 0, "yOffset": 12, "opacity": 0.30 },
        "7": { "blur": 28, "xOffset": 0, "yOffset": 14, "opacity": 0.32 },
        "8": { "blur": 32, "xOffset": 0, "yOffset": 16, "opacity": 0.34 },
        "9": { "blur": 36, "xOffset": 0, "yOffset": 18, "opacity": 0.36 },
        "10": { "blur": 40, "xOffset": 0, "yOffset": 20, "opacity": 0.38 },
        "11": { "blur": 44, "xOffset": 0, "yOffset": 22, "opacity": 0.40 },
        "12": { "blur": 48, "xOffset": 0, "yOffset": 24, "opacity": 0.42 }
    }

    // Get current elevation config
    readonly property var currentConfig: elevationConfig[Math.min(Math.max(root.elevation, 0), 12).toString()]

    // This component doesn't render anything itself
    // It's meant to be used as a layer.effect on other items
    visible: false
}
