import QtQuick
import Merce.Theme
import Merce.Foundation

/**
 * MInput - Text input component
 * Touch-optimized input field with validation states
 */
Surface {
    id: root

    // ====================================================================
    // REQUIRED PROPERTIES
    // ====================================================================
    surfaceType: Surface.Default

    // ====================================================================
    // INPUT PROPERTIES
    // ====================================================================
    property string placeholder: ""
    property string text: ""
    property string inputType: "text"  // text, email, password, number, search
    property bool isRequired: false

    // Validation states
    enum ValidationState { Normal, Error, Success, Warning }
    property int validationState: MInput.Normal

    // Character limits
    property int maxLength: 0
    property int currentLength: text.length

    // Readonly and disabled
    property bool isReadOnly: false
    property bool isDisabled: false

    // Icon support
    property string icon: ""
    property string trailingIcon: ""

    // ====================================================================
    // OVERRIDEN PROPERTIES
    // ====================================================================
    override property color backgroundColor: {
        if (root.isDisabled) return Theme.colors.surface.disabled
        return Theme.colors.surface.base
    }

    override property color borderColor: {
        if (root.isDisabled) return Theme.colors.border.base
        if (root.validationState === MInput.Error) return Theme.colors.status.error.border
        if (root.validationState === MInput.Success) return Theme.colors.status.success.border
        if (root.isFocused) return Theme.colors.border.focus
        if (root.isHovered) return Theme.colors.border.strong
        return Theme.colors.border.base
    }

    override property int borderWidth: root.isFocused ? 2 : 1
    override property int radiusValue: Theme.radius.input

    // ====================================================================
    // DIMENSIONS
    // ====================================================================
    implicitWidth: 280
    implicitHeight: Theme.spacing.touchTarget

    // ====================================================================
    // SIGNALS
    // ====================================================================
    signal inputTextChanged(string text)
    signal accepted()

    // ====================================================================
    // INPUT HANDLING
    // ====================================================================
    property alias input: textInput

    TextInput {
        id: textInput
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: root.icon !== "" ? Theme.spacing.xl2 : Theme.spacing.md
            rightMargin: root.trailingIcon !== "" ? Theme.spacing.xl2 : Theme.spacing.md
        }

        text: root.text
        font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
        font.pixelSize: Theme.typography.sizeMedium
        color: {
            if (root.isDisabled) return Theme.colors.text.disabled
            return Theme.colors.text.primary
        }

        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter

        // Input type
        echoMode: root.inputType === "password" ? TextInput.Password :
                  TextInput.Normal
        inputMethodHints: {
            if (root.inputType === "email") return Qt.ImhEmailCharactersOnly
            if (root.inputType === "number") return Qt.ImhDigitsOnly
            return Qt.ImhNone
        }
        validator: {
            if (root.inputType === "email") return emailValidator
            if (root.inputType === "number") return numberValidator
            return null
        }

        RegularExpressionValidator {
            id: emailValidator
            regularExpression: /.+@.+\..+/
        }

        IntValidator {
            id: numberValidator
        }

        // Behavior
        readOnly: root.isReadOnly
        enabled: !root.isDisabled
        selectByMouse: true
        maximumLength: root.maxLength > 0 ? root.maxLength : 32767

        // Placeholder
        Text {
            anchors.fill: parent
            text: root.placeholder
            font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
            font.pixelSize: Theme.typography.sizeMedium
            color: Theme.colors.text.tertiary
            visible: root.text === "" && !root.isFocused
            verticalAlignment: Text.AlignVCenter
        }

        // Signals
        onTextChanged: {
            root.text = text
            root.currentLength = text.length
            root.inputTextChanged(text)
        }

        onAccepted: root.accepted()
        // Focus handling
        onFocusChanged: {
            root.isFocused = focus
        }
    }

    // ====================================================================
    // ICONS
    // ====================================================================
    AppIcon {
        id: leadingIcon
        name: root.icon
        size: Theme.icons.medium
        color: {
            if (root.isDisabled) return Theme.colors.text.disabled
            if (root.validationState === MInput.Error) return Theme.colors.status.error.foreground
            return Theme.colors.text.tertiary
        }
        anchors {
            left: parent.left
            leftMargin: Theme.spacing.md
            verticalCenter: parent.verticalCenter
        }
        visible: root.icon !== ""
    }

    AppIcon {
        id: trailingIcon
        name: root.trailingIcon
        size: Theme.icons.medium
        color: {
            if (root.isDisabled) return Theme.colors.text.disabled
            if (root.validationState === MInput.Error) return Theme.colors.status.error.foreground
            if (root.validationState === MInput.Success) return Theme.colors.status.success.foreground
            return Theme.colors.text.tertiary
        }
        anchors {
            right: parent.right
            rightMargin: Theme.spacing.md
            verticalCenter: parent.verticalCenter
        }
        visible: root.trailingIcon !== ""

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.inputType === "password") {
                    // Toggle password visibility
                }
            }
        }
    }

    // Character count (optional)
    Text {
        id: charCount
        anchors {
            right: parent.right
            bottom: parent.top
            bottomMargin: Theme.spacing.xxs
        }
        text: root.currentLength + (root.maxLength > 0 ? " / " + root.maxLength : "")
        font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
        font.pixelSize: Theme.typography.sizeXSmall
        color: {
            if (root.currentLength > root.maxLength && root.maxLength > 0) {
                return Theme.colors.status.error.foreground
            }
            return Theme.colors.text.tertiary
        }
        visible: root.maxLength > 0
    }

    // ====================================================================
    // MOUSE HANDLING
    // ====================================================================
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor
        enabled: !root.isDisabled && !root.isReadOnly
        onClicked: textInput.forceActiveFocus()
        hoverEnabled: true
        onEntered: root.isHovered = true
        onExited: root.isHovered = false
    }

    // ====================================================================
    // BEHAVIOR
    // ====================================================================
    Behavior on borderColor {
        ColorAnimation {
            duration: Theme.motion.durationFast
            easing: Theme.motion.easingOut
        }
    }
}
