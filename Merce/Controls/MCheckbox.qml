import QtQuick
import Merce.Core
import Merce.Foundation

/**
 * MCheckbox - Checkbox component with indeterminate state
 * Touch-optimized checkbox with validation states
 */
MBaseControl {
    id: root

    // ====================================================================
    // REQUIRED PROPERTIES
    // ====================================================================
    controlType: "checkbox"

    // ====================================================================
    // CHECKBOX PROPERTIES
    // ====================================================================
    property bool checked: false
    property bool indeterminate: false
    property string label: ""
    property string size: "medium"  // small, medium
    property string labelPosition: "right"  // left, right

    // ====================================================================
    // SIGNALS
    // ====================================================================
    signal toggled(bool checked)

    // ====================================================================
    // OVERRIDDEN PROPERTIES
    // ====================================================================
    override property color accentColor: Theme.colors.action.primary
    override property color backgroundColor: "transparent"

    // ====================================================================
    // SIZE CONFIG
    // ====================================================================
    readonly property var sizeConfig: {
        "small": {
            "boxSize": 20,
            "strokeWidth": 2,
            "iconSize": 14,
            "fontSize": Theme.typography.sizeSmall
        },
        "medium": {
            "boxSize": 24,
            "strokeWidth": 2,
            "iconSize": 18,
            "fontSize": Theme.typography.sizeMedium
        }
    }

    // ====================================================================
    // DIMENSIONS
    // ====================================================================
    override property int contentWidth: checkboxBox.width + (label !== "" ? textMetrics.width + Theme.spacing.sm : 0)
    override property int contentHeight: Math.max(checkboxBox.height, textMetrics.height)

    // ====================================================================
    // VISUAL STATES
    // ====================================================================
    readonly property color boxBorderColor: {
        if (root.isDisabled) return Theme.colors.border.base
        if (root.isFocused) return Theme.colors.border.focus
        if (root.isHovered) return Theme.colors.border.strong
        return Theme.colors.border.base
    }

    readonly property color boxBackgroundColor: {
        if (root.isDisabled && root.checked) return Theme.colors.background.hover
        if (root.checked) return root.accentColor
        return "transparent"
    }

    readonly property color checkmarkColor: {
        if (root.isDisabled) return Theme.colors.text.disabled
        return Theme.colors.text.inverse
    }

    // ====================================================================
    // CHECKBOX BOX VISUAL
    // ====================================================================
    Rectangle {
        id: checkboxBox
        width: root.sizeConfig[root.size].boxSize
        height: root.sizeConfig[root.size].boxSize
        radius: Theme.radius.small
        color: root.boxBackgroundColor
        border.width: root.sizeConfig[root.size].strokeWidth
        border.color: root.boxBorderColor

        // Indeterminate bar
        Rectangle {
            width: parent.width * 0.5
            height: 2
            anchors.centerIn: parent
            color: root.checkmarkColor
            visible: root.indeterminate
        }

        // Checkmark (when checked)
        Text {
            anchors.centerIn: parent
            text: "\ue834"  // Material check icon
            font.family: "Material Symbols Outlined"
            font.pixelSize: root.sizeConfig[root.size].iconSize
            color: root.checkmarkColor
            visible: root.checked && !root.indeterminate
        }

        // Focus ring
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.width: 2
            border.color: Theme.colors.border.focus
            opacity: root.isFocused ? 1.0 : 0.0
        }

        // Animation for border color
        Behavior on border.color {
            ColorAnimation {
                duration: Theme.motion.durationFast
                easing: Theme.motion.easingOut
            }
        }

        // Animation for background color
        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.durationFast
                easing: Theme.motion.easingOut
            }
        }
    }

    // ====================================================================
    // LABEL
    // ====================================================================
    Text {
        id: checkboxLabel
        text: root.label
        font.family: Theme.typography.fontBody
        font.pixelSize: root.sizeConfig[root.size].fontSize
        color: root.isDisabled ? Theme.colors.text.disabled : Theme.colors.text.primary

        anchors {
            left: root.labelPosition === "right" ? checkboxBox.right : undefined
            right: root.labelPosition === "left" ? checkboxBox.left : undefined
            leftMargin: root.labelPosition === "right" ? Theme.spacing.sm : 0
            rightMargin: root.labelPosition === "left" ? Theme.spacing.sm : 0
            verticalCenter: checkboxBox.verticalCenter
        }
        visible: root.label !== ""
    }

    // ====================================================================
    // TEXT METRICS
    // ====================================================================
    TextMetrics {
        id: textMetrics
        text: root.label
        font.family: Theme.typography.fontBody
        font.pixelSize: root.sizeConfig[root.size].fontSize
    }

    // ====================================================================
    // CLICK HANDLING
    // ====================================================================
    MouseArea {
        id: clickArea
        anchors.fill: parent
        cursorShape: root.isDisabled ? Qt.ArrowCursor : Qt.PointingHandCursor
        enabled: !root.isDisabled
        hoverEnabled: true

        onClicked: {
            root.checked = !root.checked
            root.indeterminate = false
            root.toggled(root.checked)
        }
    }

    // ====================================================================
    // ACCESSIBILITY
    // ====================================================================
    Accessible.role: Accessible.CheckBox
    Accessible.name: root.label
    Accessible.onPressAction: if (!root.isDisabled) clickArea.clicked()
}
