import QtQuick
import QtQuick.Controls
import Merce.Core
import Merce.Foundation
import QtQuick.Effects

/**
 * MSelect - Dropdown select component
 * Touch-optimized select with keyboard navigation
 */
Item {
    id: root

    // ====================================================================
    // SELECT PROPERTIES
    // ====================================================================
    property string placeholder: "Select an option"
    property var selectedValue: null
    property var options: []  // Array of objects: [{value: "id", label: "Text"}, ...]
    property string size: "medium"  // small, medium
    property bool isDisabled: false
    property bool isRequired: false

    // Display and value fields
    property string valueField: "value"
    property string labelField: "label"

    // State
    property bool isOpen: false
    property bool isHovered: false
    property bool isFocused: false

    // ====================================================================
    // SIGNALS
    // ====================================================================
    signal selected(var value)
    signal opened()
    signal closed()

    // ====================================================================
    // SIZE CONFIG
    // ====================================================================
    readonly property var sizeConfig: {
        "small": {
            "height": Theme.spacing.touchTargetCompact,
            "fontSize": Theme.typography.sizeSmall
        },
        "medium": {
            "height": Theme.spacing.touchTarget,
            "fontSize": Theme.typography.sizeMedium
        }
    }

    // ====================================================================
    // DIMENSIONS
    // ====================================================================
    implicitWidth: 280
    implicitHeight: root.sizeConfig[root.size].height

    // Get selected option
    readonly property var selectedOption: {
        if (root.selectedValue === null) return null
        return root.options.find(opt => opt[root.valueField] === root.selectedValue)
    }

    // Get display text
    readonly property string displayText: {
        if (root.selectedOption) return root.selectedOption[root.labelField]
        return root.placeholder
    }

    // ====================================================================
    // TRIGGER BUTTON
    // ====================================================================
    MSurface {
        id: selectTrigger
        anchors.fill: parent
        surfaceType: types["default"]

        override property color borderColor: {
            if (root.isDisabled) return Theme.colors.border.base
            if (root.isOpen || root.isFocused) return Theme.colors.border.focus
            if (root.isHovered) return Theme.colors.border.strong
            return Theme.colors.border.base
        }

        override property int borderWidth: root.isOpen || root.isFocused ? 2 : 1
        override property int radiusValue: Theme.radius.input

        // Content
        Item {
            anchors {
                fill: parent
                leftMargin: Theme.spacing.md
                rightMargin: Theme.spacing.md
            }

            // Selected text
            Text {
                id: selectedText
                anchors {
                    left: parent.left
                    right: chevronIcon.left
                    rightMargin: Theme.spacing.sm
                    verticalCenter: parent.verticalCenter
                }
                text: root.displayText
                font.family: Theme.typography.fontBody
                font.pixelSize: root.sizeConfig[root.size].fontSize
                color: {
                    if (root.isDisabled) return Theme.colors.text.disabled
                    if (root.selectedOption) return Theme.colors.text.primary
                    return Theme.colors.text.tertiary
                }
                elide: Text.ElideRight
            }

            // Chevron icon
            Text {
                id: chevronIcon
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                text: root.isOpen ? "\ue5e7" : "\ue5c5"  // Material up/down arrows
                font.family: "Material Symbols Outlined"
                font.pixelSize: Theme.icons.small
                color: {
                    if (root.isDisabled) return Theme.colors.text.disabled
                    return Theme.colors.text.tertiary
                }

                // Rotate animation
                rotation: root.isOpen ? 180 : 0

                Behavior on rotation {
                    NumberAnimation {
                        duration: Theme.motion.durationFast
                        easing: Theme.motion.easingOut
                    }
                }
            }
        }

        // Mouse area for trigger
        MouseArea {
            anchors.fill: parent
            cursorShape: root.isDisabled ? Qt.ArrowCursor : Qt.PointingHandCursor
            enabled: !root.isDisabled
            hoverEnabled: true

            onClicked: root.toggleDropdown()
            onEntered: root.isHovered = true
            onExited: root.isHovered = false
        }

        // Animation for border color
        Behavior on borderColor {
            ColorAnimation {
                duration: Theme.motion.durationFast
                easing: Theme.motion.easingOut
            }
        }
    }

    // ====================================================================
    // DROPDOWN OVERLAY
    // ====================================================================
    Item {
        id: dropdownOverlay
        anchors.fill: parent
        visible: root.isOpen
        z: 1000

        // Backdrop (click outside to close)
        Rectangle {
            id: backdrop
            anchors.fill: parent
            color: "transparent"
            visible: root.isOpen

            MouseArea {
                anchors.fill: parent
                onClicked: root.closeDropdown()
            }
        }

        // Dropdown menu
        Rectangle {
            id: dropdownMenu
            x: 0
            y: selectTrigger.height + 4
            width: root.width
            height: Math.min(dropdownContent.height + Theme.spacing.md, 300)
            radius: Theme.radius.input
            color: Theme.colors.background.surface

            // Shadow
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#40000000"
                shadowBlur: 1.0
                shadowOpacity: 0.3
            }

            // Border
            border.width: 1
            border.color: Theme.colors.border.base

            // Opacity and scale animation
            opacity: root.isOpen ? 1.0 : 0.0
            scale: root.isOpen ? 1.0 : 0.95

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.motion.durationFast
                    easing: Theme.motion.easingOut
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: Theme.motion.durationFast
                    easing: Theme.motion.easingOut
                }
            }

            // Clip content
            clip: true

            // Dropdown content (scrollable)
            ListView {
                id: dropdownContent
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: Theme.spacing.xs
                }
                height: Math.min(contentHeight, 280)
                model: root.options
                spacing: Theme.spacing.xxs
                interactive: contentHeight > 280
                clip: true

                // Scroll bar
                ScrollBar.vertical: ScrollBar {
                    policy: dropdownContent.contentHeight > 280 ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                }

                delegate: Rectangle {
                    id: optionItem
                    width: dropdownMenu.width - Theme.spacing.sm
                    height: Theme.spacing.touchTargetCompact
                    radius: Theme.radius.small
                    color: {
                        if (root.selectedValue === modelData[root.valueField]) {
                            return Theme.colors.action.light("primary")
                        }
                        if (optionMouseArea.containsMouse) {
                            return Theme.colors.background.hover
                        }
                        return "transparent"
                    }

                    // Option text
                    Text {
                        id: optionText
                        anchors {
                            left: parent.left
                            right: checkmark.left
                            leftMargin: Theme.spacing.md
                            rightMargin: Theme.spacing.md
                            verticalCenter: parent.verticalCenter
                        }
                        text: modelData[root.labelField]
                        font.family: Theme.typography.fontBody
                        font.pixelSize: root.sizeConfig[root.size].fontSize
                        color: {
                            if (root.selectedValue === modelData[root.valueField]) {
                                return Theme.colors.action.primary
                            }
                            return Theme.colors.text.primary
                        }
                        font.weight: root.selectedValue === modelData[root.valueField] ?
                                   Theme.typography.weightSemibold : Theme.typography.weightRegular
                        elide: Text.ElideRight
                    }

                    // Checkmark for selected option
                    Text {
                        id: checkmark
                        anchors {
                            right: parent.right
                            rightMargin: Theme.spacing.md
                            verticalCenter: parent.verticalCenter
                        }
                        text: "\ue834"  // Material check icon
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: Theme.icons.small
                        color: Theme.colors.action.primary
                        visible: root.selectedValue === modelData[root.valueField]
                    }

                    // Mouse area for option
                    MouseArea {
                        id: optionMouseArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        onClicked: root.selectOption(modelData[root.valueField])
                    }

                    // Animation for background color
                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.motion.durationFast
                            easing: Theme.motion.easingOut
                        }
                    }
                }
            }
        }
    }

    // ====================================================================
    // PUBLIC METHODS
    // ====================================================================
    function toggleDropdown() {
        if (root.isOpen) {
            root.closeDropdown()
        } else {
            root.openDropdown()
        }
    }

    function openDropdown() {
        root.isOpen = true
        root.opened()
    }

    function closeDropdown() {
        root.isOpen = false
        root.closed()
    }

    function selectOption(value) {
        root.selectedValue = value
        root.selected(value)
        root.closeDropdown()
    }

    // ====================================================================
    // KEYBOARD HANDLING
    // ====================================================================
    focus: true
    Keys.onSpacePressed: {
        if (!root.isDisabled && !root.isOpen) {
            root.toggleDropdown()
        }
    }
    Keys.onUpPressed: {
        if (root.isOpen) {
            let currentIndex = dropdownContent.currentIndex
            if (currentIndex > 0) {
                dropdownContent.currentIndex = currentIndex - 1
            }
        }
    }
    Keys.onDownPressed: {
        if (root.isOpen) {
            let currentIndex = dropdownContent.currentIndex
            if (currentIndex < root.options.length - 1) {
                dropdownContent.currentIndex = currentIndex + 1
            }
        } else if (!root.isDisabled) {
            root.openDropdown()
        }
    }
    Keys.onEnterPressed: {
        if (root.isOpen && dropdownContent.currentIndex >= 0) {
            let selectedOption = root.options[dropdownContent.currentIndex]
            root.selectOption(selectedOption[root.valueField])
        }
    }
    Keys.onReturnPressed: root.Keys.onEnterPressed(event)
    Keys.onEscapePressed: root.closeDropdown()

    // ====================================================================
    // ACCESSIBILITY
    // ====================================================================
    Accessible.role: Accessible.ComboBox
    Accessible.name: root.displayText
}
