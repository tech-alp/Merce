import QtQuick
import Merce.Core
import Merce.Core.Effects
import Merce.Foundation

/**
 * MButton - Primary button component
 * Touch-optimized button with variant support
 */
MBaseControl {
    id: root

    // ====================================================================
    // REQUIRED PROPERTIES
    // ====================================================================
    controlType: "button"

    // ====================================================================
    // BUTTON PROPERTIES
    // ====================================================================
    property string text: ""
    property string variant: "primary"  // primary, secondary, outline, ghost, destructive
    property string size: "medium"      // small, medium, large

    // Icon support
    property url iconSource: ""
    property string iconPosition: "left"  // left, right

    // Loading state
    property bool isLoading: false

    // Full width
    property bool fullWidth: false

    // ====================================================================
    // OVERRIDEN PROPERTIES (from MBaseControl)
    // ====================================================================
    override property color accentColor: {
        if (variant === "secondary") return Theme.colors.action.secondary
        if (variant === "outline") return Theme.colors.action.primary
        if (variant === "ghost") return Theme.colors.action.primary
        if (variant === "destructive") return Theme.colors.action.destructive
        return Theme.colors.action.primary
    }

    override property color backgroundColor: {
        if (root.isDisabled) return Theme.colors.background.hover
        if (variant === "outline" || variant === "ghost") return "transparent"
        if (root.isHovered || root.isPressed) return Theme.colors.action.base(variant + "Dark")
        return Theme.colors.action.base(variant)
    }

    override property color accentHoverColor: Theme.colors.action.base(variant + "Dark")

    // Size dimensions
    readonly property var sizeConfig: {
        "small": {
            "height": Theme.spacing.touchTargetCompact,
            "paddingH": Theme.spacing.md,
            "fontSize": Theme.typography.sizeXSmall,
            "iconSize": Theme.icons.small
        },
        "medium": {
            "height": Theme.spacing.touchTarget,
            "paddingH": Theme.spacing.xl,
            "fontSize": Theme.typography.sizeSmall,
            "iconSize": Theme.icons.medium
        },
        "large": {
            "height": 52,
            "paddingH": Theme.spacing.xl2,
            "fontSize": Theme.typography.sizeMedium,
            "iconSize": Theme.icons.large
        }
    }

    // ====================================================================
    // DIMENSIONS
    // ====================================================================
    override property int contentHeight: sizeConfig[size].height
    override property int contentWidth: fullWidth ? parent.width : implicitContentWidth

    property int implicitContentWidth: {
        const paddingH = sizeConfig[size].paddingH
        const iconWidth = iconSource !== "" ? sizeConfig[size].iconSize + Theme.spacing.sm : 0
        const textWidth = textMetrics.width
        return paddingH * 2 + iconWidth + textWidth + Theme.spacing.sm
    }

    // ====================================================================
    // VISUAL
    // ====================================================================
    width: contentWidth
    height: contentHeight

    // Border (for outline variant)
    property int borderWidth: variant === "outline" ? 2 : 0
    property color borderColor: root.isHovered ? accentHoverColor : accentColor

    // Background
    Rectangle {
        anchors.fill: parent
        radius: Theme.radius.button
        color: root.backgroundColor
        border.width: root.borderWidth
        border.color: root.borderColor

        // Shadow for non-ghost variants
        layer.enabled: variant !== "ghost" && variant !== "outline" && !root.isLoading
        layer.effect: ElevationEffect {
            elevation: root.isPressed ? 0 : (root.isHovered ? 2 : 1)
        }
    }

    // Content
    Row {
        anchors.centerIn: parent
        spacing: Theme.spacing.sm
        layoutDirection: iconPosition === "right" ? Qt.RightToLeft : Qt.LeftToRight

        // Icon
        Icon {
            id: icon
            source: root.iconSource
            size: root.sizeConfig[root.size].iconSize
            color: {
                if (root.isDisabled) return Theme.colors.text.disabled
                if (variant === "outline" || variant === "ghost") return root.accentColor
                return Theme.colors.text.inverse
            }
            visible: root.iconSource !== "" && !root.isLoading
        }

        // Text
        Text {
            id: buttonText
            text: root.text
            font.family: Theme.typography.fontBody
            font.pixelSize: root.sizeConfig[root.size].fontSize
            font.weight: Theme.typography.weightSemibold
            color: {
                if (root.isDisabled) return Theme.colors.text.disabled
                if (variant === "outline" || variant === "ghost") return root.accentColor
                return Theme.colors.text.inverse
            }
            visible: root.text !== "" && !root.isLoading
        }

        // Loading indicator
        LoadingIndicator {
            size: root.sizeConfig[root.size].iconSize
            color: {
                if (root.isDisabled) return Theme.colors.text.disabled
                if (variant === "outline" || variant === "ghost") return root.accentColor
                return Theme.colors.text.inverse
            }
            visible: root.isLoading
            running: root.isLoading
        }
    }

    // Text metrics for width calculation
    TextMetrics {
        id: textMetrics
        text: root.text
        font.family: Theme.typography.fontBody
        font.pixelSize: sizeConfig[size].fontSize
        font.weight: Theme.typography.weightSemibold
    }

    // ====================================================================
    // BEHAVIOR
    // ====================================================================
    enabled: !root.isDisabled && !root.isLoading

    // Animation for background color
    Behavior on backgroundColor {
        ColorAnimation {
            duration: Theme.motion.durationFast
            easing: Theme.motion.easingOut
        }
    }

    Behavior on borderColor {
        ColorAnimation {
            duration: Theme.motion.durationFast
            easing: Theme.motion.easingOut
        }
    }
}
