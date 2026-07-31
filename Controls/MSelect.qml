import QtQuick
import QtQuick.Controls.Basic as Basic
import QtQuick.Window
import Merce.Theme
import Merce.Foundation
import QtQuick.Effects

/**
 * MSelect - Dropdown select component
 * Touch-optimized select built on Qt Quick Controls ComboBox.
 */
Basic.ComboBox {
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

    // State aliases kept for consumers and styling
    readonly property bool isOpen: root.popup.visible
    readonly property bool isHovered: root.hovered
    readonly property bool isFocused: root.activeFocus || root.visualFocus
    readonly property real dropdownMargin: Theme.spacing.sm
    readonly property real dropdownVerticalOffset: 4
    readonly property int optionHeight: Theme.spacing.touchTargetCompact
    readonly property int optionCount: root.options ? root.options.length : 0
    readonly property color transparentOptionBackground: Qt.rgba(Theme.colors.surface.hover.r,
                                                                 Theme.colors.surface.hover.g,
                                                                 Theme.colors.surface.hover.b,
                                                                 0)
    readonly property real dropdownContentHeight: {
        const spacingHeight = Math.max(0, root.optionCount - 1) * Theme.spacing.xxs
        return root.optionCount * root.optionHeight + spacingHeight
    }
    readonly property real dropdownPopupHeight: Math.min(root.dropdownContentHeight + Theme.spacing.xs * 2, 300)
    readonly property real dropdownAvailableHeight: {
        const windowHeight = root.Window.height > 0 ? root.Window.height : 300
        return Math.max(root.optionHeight + Theme.spacing.xs * 2, windowHeight - root.dropdownMargin * 2)
    }

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
    readonly property var currentSizeConfig: root.sizeConfig[root.size] || root.sizeConfig["medium"]

    // ====================================================================
    // DIMENSIONS AND MODEL
    // ====================================================================
    implicitWidth: 280
    implicitHeight: root.currentSizeConfig.height
    z: root.isOpen ? Theme.zIndex.dropdown : 0
    enabled: !root.isDisabled
    focus: true
    currentIndex: -1
    model: root.options || []
    textRole: root.labelField
    valueRole: root.valueField

    // Get selected option
    readonly property var selectedOption: root.optionAt(root.indexOfValue(root.selectedValue))

    displayText: root.selectedOption ? root.optionLabel(root.selectedOption) : root.placeholder

    onSelectedValueChanged: root.syncCurrentIndex()
    onOptionsChanged: root.syncCurrentIndex()
    Component.onCompleted: root.syncCurrentIndex()

    onActivated: function(index) {
        const option = root.optionAt(index)
        if (!option)
            return

        root.selectOption(root.optionValue(option))
    }

    // ====================================================================
    // TRIGGER BUTTON
    // ====================================================================
    indicator: AppIcon {
        id: chevronIcon
        x: root.width - width - Theme.spacing.md
        y: root.topPadding + (root.availableHeight - height) / 2
        name: "material:keyboard_arrow_down"
        size: Theme.icons.small
        color: root.enabled ? Theme.colors.text.tertiary : Theme.colors.text.disabled
        rotation: root.isOpen ? 180 : 0

        Behavior on rotation {
            NumberAnimation {
                duration: Theme.motion.durationFast
                easing: Theme.motion.easingOut
            }
        }
    }

    contentItem: Text {
        leftPadding: Theme.spacing.md
        rightPadding: chevronIcon.width + Theme.spacing.md + Theme.spacing.sm
        text: root.displayText
        font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
        font.pixelSize: root.currentSizeConfig.fontSize
        color: {
            if (!root.enabled)
                return Theme.colors.text.disabled
            if (root.selectedOption)
                return Theme.colors.text.primary
            return Theme.colors.text.tertiary
        }
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 280
        implicitHeight: root.currentSizeConfig.height
        radius: Theme.radius.input
        color: root.enabled ? Theme.colors.surface.base : Theme.colors.background.base
        border.width: root.isOpen || root.isFocused ? 2 : 1
        border.color: {
            if (!root.enabled)
                return Theme.colors.border.base
            if (root.isOpen || root.isFocused)
                return Theme.colors.border.focus
            if (root.isHovered)
                return Theme.colors.border.strong
            return Theme.colors.border.base
        }

        Behavior on border.color {
            ColorAnimation {
                duration: Theme.motion.durationFast
                easing: Theme.motion.easingOut
            }
        }
    }

    // ====================================================================
    // OPTION DELEGATE
    // ====================================================================
    delegate: Basic.ItemDelegate {
        id: optionDelegate

        required property var modelData
        required property int index

        readonly property var optionValue: root.optionValue(modelData)
        readonly property string optionLabel: root.optionLabel(modelData)
        readonly property bool selectedOption: root.selectedValue === optionValue
        readonly property color optionContentColor: optionDelegate.selectedOption
                                                     ? Theme.colors.action.primary.content
                                                     : Theme.colors.text.primary

        objectName: root.objectName !== "" ? root.objectName + ".popup.option." + String(optionValue) : ""
        width: root.width
        height: root.optionHeight
        highlighted: root.highlightedIndex === index

        contentItem: Item {
            Text {
                id: optionText
                anchors {
                    left: parent.left
                    right: checkmark.left
                    leftMargin: Theme.spacing.md
                    rightMargin: Theme.spacing.md
                    verticalCenter: parent.verticalCenter
                }
                text: optionDelegate.optionLabel
                font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
                font.pixelSize: root.currentSizeConfig.fontSize
                color: optionDelegate.optionContentColor
                font.weight: optionDelegate.selectedOption ?
                             Theme.typography.weightSemibold : Theme.typography.weightRegular
                elide: Text.ElideRight
            }

            AppIcon {
                id: checkmark
                anchors {
                    right: parent.right
                    rightMargin: Theme.spacing.md
                    verticalCenter: parent.verticalCenter
                }
                name: "material:check"
                size: Theme.icons.small
                color: optionDelegate.optionContentColor
                visible: optionDelegate.selectedOption
            }
        }

        background: Rectangle {
            radius: Theme.radius.small
            color: {
                if (optionDelegate.selectedOption) {
                    if (optionDelegate.pressed)
                        return Theme.colors.action.primaryPressed
                    if (optionDelegate.highlighted || optionDelegate.hovered)
                        return Theme.colors.action.primaryHover
                    return Theme.colors.action.primary.container
                }
                if (optionDelegate.pressed)
                    return Theme.colors.surface.pressed
                if (optionDelegate.highlighted || optionDelegate.hovered)
                    return Theme.colors.surface.hover
                return root.transparentOptionBackground
            }

            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.durationFast
                    easing: Theme.motion.easingOut
                }
            }
        }
    }

    // ====================================================================
    // POPUP
    // ====================================================================
    popup: Basic.Popup {
        id: dropdownPopup
        objectName: root.objectName !== "" ? root.objectName + ".popup" : "merce.select.popup"
        popupType: Basic.Popup.Item
        y: root.height + root.dropdownVerticalOffset
        width: root.width
        height: Math.min(root.dropdownPopupHeight, root.dropdownAvailableHeight)
        padding: Theme.spacing.xs
        margins: root.dropdownMargin
        modal: false
        dim: false
        focus: true
        closePolicy: Basic.Popup.CloseOnEscape | Basic.Popup.CloseOnPressOutsideParent
        z: Theme.zIndex.dropdown

        onOpened: root.opened()
        onClosed: root.closed()

        background: Rectangle {
            radius: Theme.radius.input
            color: Theme.colors.surface.base
            border.width: 1
            border.color: Theme.colors.border.base

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#40000000"
                shadowBlur: 1.0
                shadowOpacity: 0.3
            }
        }

        contentItem: ListView {
            id: dropdownContent
            objectName: root.objectName !== "" ? root.objectName + ".popup.content" : "merce.select.popup.content"
            clip: true
            implicitHeight: contentHeight
            model: root.popup.visible ? root.delegateModel : null
            currentIndex: root.highlightedIndex
            spacing: Theme.spacing.xxs
            interactive: contentHeight > height
            boundsBehavior: Flickable.StopAtBounds

            Basic.ScrollBar.vertical: Basic.ScrollBar {
                policy: dropdownContent.contentHeight > dropdownContent.height ? Basic.ScrollBar.AlwaysOn : Basic.ScrollBar.AlwaysOff
            }
        }
    }

    // ====================================================================
    // PUBLIC METHODS
    // ====================================================================
    function toggleDropdown() {
        if (root.isOpen)
            root.closeDropdown()
        else
            root.openDropdown()
    }

    function openDropdown() {
        if (root.isDisabled || root.isOpen)
            return

        root.syncCurrentIndex()
        root.popup.open()
    }

    function closeDropdown() {
        if (!root.isOpen)
            return

        root.popup.close()
    }

    function selectOption(value) {
        root.selectedValue = value
        root.syncCurrentIndex()
        root.selected(value)
        root.closeDropdown()
    }

    function indexOfValue(value) {
        if (!root.options)
            return -1

        for (let i = 0; i < root.options.length; ++i) {
            if (root.optionValue(root.options[i]) === value)
                return i
        }
        return -1
    }

    function optionAt(index) {
        if (!root.options || index < 0 || index >= root.options.length)
            return null
        return root.options[index]
    }

    function optionValue(option) {
        if (!option)
            return null
        return option[root.valueField]
    }

    function optionLabel(option) {
        if (!option)
            return ""
        const value = option[root.labelField]
        return value === undefined || value === null ? "" : String(value)
    }

    function syncCurrentIndex() {
        const nextIndex = root.indexOfValue(root.selectedValue)
        if (root.currentIndex !== nextIndex)
            root.currentIndex = nextIndex
    }

    // ====================================================================
    // ACCESSIBILITY
    // ====================================================================
    Accessible.role: Accessible.ComboBox
    Accessible.name: root.displayText
}
