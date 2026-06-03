import QtQuick

/**
 * Merce Color Palette
 * Shopping-focused color palette optimized for e-commerce conversion
 */
QtObject {
    id: root

    // ========================================================================
    // RAW PALETTE (Base color values)
    // ========================================================================

    readonly property QtObject raw: QtObject {
        // Primary - Warm Terracotta (conversion-focused)
        readonly property color primary: "#C4785A"
        readonly property color primaryLight: "#E8B5A3"
        readonly property color primaryDark: "#9A4F34"

        // Secondary - Deep Forest (trust & elegance)
        readonly property color secondary: "#2D4A3E"
        readonly property color secondaryLight: "#4A6B5D"
        readonly property color secondaryDark: "#1A2C24"

        // Semantic Colors
        readonly property color success: "#4A7C59"
        readonly property color successLight: "#A8D4B8"
        readonly property color warning: "#D4A854"
        readonly property color warningLight: "#F0D9A8"
        readonly property color error: "#C45A5A"
        readonly property color errorLight: "#E8A8A8"
        readonly property color info: "#5A8FC4"
        readonly property color infoLight: "#A8CCE8"

        // Neutral - Warm Grays
        readonly property color gray50: "#FAF8F6"
        readonly property color gray100: "#F5F0EB"
        readonly property color gray200: "#E8DFD5"
        readonly property color gray300: "#D4C4B5"
        readonly property color gray400: "#B8A494"
        readonly property color gray500: "#9A8472"
        readonly property color gray600: "#7A6556"
        readonly property color gray700: "#5C4A3D"
        readonly property color gray800: "#3D2F26"
        readonly property color gray900: "#1F1510"
    }

    // ========================================================================
    // SEMANTIC COLORS (Organized by usage)
    // ========================================================================

    // Action Colors (CTAs, buttons, links)
    property QtObject action: QtObject {
        readonly property color primary: root.raw.primary
        readonly property color primaryLight: root.raw.primaryLight
        readonly property color primaryDark: root.raw.primaryDark
        readonly property color secondary: root.raw.secondary
        readonly property color secondaryLight: root.raw.secondaryLight
        readonly property color secondaryDark: root.raw.secondaryDark

        readonly property color success: root.raw.success
        readonly property color warning: root.raw.warning
        readonly property color destructive: root.raw.error

        // Helper: Get action color by variant string
        function base(variant) {
            if (variant === "success") return success
            if (variant === "warning") return warning
            if (variant === "destructive" || variant === "error") return destructive
            if (variant === "secondary") return secondary
            return primary
        }

        function light(variant) {
            if (variant === "success") return root.raw.successLight
            if (variant === "warning") return root.raw.warningLight
            if (variant === "destructive" || variant === "error") return root.raw.errorLight
            if (variant === "secondary") return root.raw.secondaryLight
            return root.raw.primaryLight
        }
    }

    // Product Colors (e-commerce specific)
    property QtObject product: QtObject {
        readonly property color priceRegular: root.raw.gray900
        readonly property color priceSale: root.raw.error
        readonly property color priceOriginal: root.raw.gray500
        readonly property color badgeNew: root.raw.primaryLight
        readonly property color badgeSale: root.raw.errorLight
        readonly property color badgeBestSeller: root.raw.successLight
        readonly property color badgeLimited: root.raw.warningLight
        readonly property color badgeLowStock: root.raw.warningLight
    }

    // Text Colors
    property QtObject text: QtObject {
        readonly property color primary: root.raw.gray900
        readonly property color secondary: root.raw.gray700
        readonly property color tertiary: root.raw.gray500
        readonly property color inverse: root.raw.gray50
        readonly property color link: root.raw.primary
        readonly property color linkHover: root.raw.primaryDark
        readonly property color disabled: root.raw.gray400
    }

    // Background Colors
    property QtObject background: QtObject {
        readonly property color base: root.raw.gray50
        readonly property color surface: "#FFFFFF"
        readonly property color elevated: "#FFFFFF"
        readonly property color hover: root.raw.gray100
        readonly property color pressed: root.raw.gray200
        readonly property color overlay: Qt.rgba(31 / 255, 21 / 255, 16 / 255, 0.5)
    }

    // Border Colors
    property QtObject border: QtObject {
        readonly property color base: root.raw.gray200
        readonly property color strong: root.raw.gray300
        readonly property color focus: root.raw.primary
        readonly property color error: root.raw.error
        readonly property color success: root.raw.success
    }

    // Status Colors
    property QtObject status: QtObject {
        readonly property color success: root.raw.success
        readonly property color successLight: root.raw.successLight
        readonly property color warning: root.raw.warning
        readonly property color warningLight: root.raw.warningLight
        readonly property color error: root.raw.error
        readonly property color errorLight: root.raw.errorLight
        readonly property color info: root.raw.info
        readonly property color infoLight: root.raw.infoLight
    }

    // Surface Colors
    property QtObject surface: QtObject {
        readonly property color base: "#FFFFFF"
        readonly property color tinted: root.raw.gray100
        readonly property color raised: "#FFFFFF"
    }
}
