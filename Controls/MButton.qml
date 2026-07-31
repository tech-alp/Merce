import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Templates as T
import Merce.Theme
import Merce.Foundation

/**
 * MButton - Tokenized button control.
 * Built on Qt Quick Templates Button so checked, pressed, hovered, focus,
 * keyboard activation, and accessibility come from the Qt control template.
 */
T.Button {
    id: root

    enum Variant {
        Primary,
        Secondary,
        Outline,
        Ghost,
        Destructive
    }

    enum Size {
        Small,
        Medium,
        Large
    }

    enum IconPosition {
        IconLeft,
        IconRight,
        IconTop
    }

    property int variant: MButton.Primary
    property int size: MButton.Medium
    property int iconPosition: MButton.IconLeft
    property bool isLoading: false
    property bool fullWidth: false
    property int elevation: (root.variant === MButton.Primary
                             || root.variant === MButton.Secondary
                             || root.variant === MButton.Destructive) ? 1 : 0

    readonly property real buttonHeight: root.size === MButton.Small
                                       ? Theme.spacing.touchTargetCompact
                                       : root.size === MButton.Large ? 52 : Theme.spacing.touchTarget
    readonly property real buttonHorizontalPadding: root.size === MButton.Small
                                                    ? Theme.spacing.md
                                                    : root.size === MButton.Large ? Theme.spacing.xl2 : Theme.spacing.xl
    readonly property real buttonVerticalPadding: root.size === MButton.Small
                                                  ? Theme.spacing.xs
                                                  : root.size === MButton.Large ? Theme.spacing.md : Theme.spacing.sm
    readonly property real iconSize: root.size === MButton.Small
                                     ? Theme.icons.small
                                     : root.size === MButton.Large ? Theme.icons.large : Theme.icons.medium
    readonly property real fontPixelSize: root.size === MButton.Large
                                          ? Theme.typography.sizeMedium
                                          : Theme.typography.sizeSmall
    readonly property string resolvedFontFamily: FoundationFonts.resolveFamily(Theme.typography.fontBody)
    readonly property string resolvedIconName: root.icon.name.length > 0
                                               ? root.icon.name
                                               : root.icon.source.toString().length > 0
                                                 ? "image:" + root.icon.source
                                                 : ""
    readonly property color backgroundColor: visualStyle.backgroundColor
    readonly property color foregroundColor: visualStyle.foregroundColor
    readonly property color borderColor: visualStyle.borderColor
    readonly property int borderWidth: visualStyle.borderWidth
    readonly property color transparentHoverBackground: Qt.rgba(Theme.colors.surface.hover.r,
                                                                Theme.colors.surface.hover.g,
                                                                Theme.colors.surface.hover.b,
                                                                0)

    enabled: !root.isLoading
    hoverEnabled: root.enabled && !root.isLoading
    focusPolicy: Qt.StrongFocus
    leftPadding: root.buttonHorizontalPadding
    rightPadding: root.buttonHorizontalPadding
    topPadding: root.buttonVerticalPadding
    bottomPadding: root.buttonVerticalPadding
    spacing: controlState.showContentGap ? Theme.spacing.xs : 0
    implicitWidth: Math.max(root.implicitBackgroundWidth + root.leftInset + root.rightInset,
                            root.implicitContentWidth + root.leftPadding + root.rightPadding)
    implicitHeight: Math.max(root.implicitBackgroundHeight + root.topInset + root.bottomInset,
                             root.implicitContentHeight + root.topPadding + root.bottomPadding)

    contentItem: Item {
        implicitWidth: gridLayout.implicitWidth
        implicitHeight: gridLayout.implicitHeight

        GridLayout {
            id: gridLayout

            readonly property bool showGraphic: root.isLoading || controlState.showIcon

            anchors.centerIn: parent
            width: Math.min(implicitWidth, parent.width)
            rows: controlState.topIconPosition && controlState.showContentGap ? 2 : 1
            columns: !controlState.topIconPosition && controlState.showContentGap ? 2 : 1
            flow: controlState.topIconPosition ? GridLayout.TopToBottom : GridLayout.LeftToRight
            layoutDirection: controlState.rightIconPosition ? Qt.RightToLeft : Qt.LeftToRight
            rowSpacing: root.spacing
            columnSpacing: root.spacing

            Item {
                visible: gridLayout.showGraphic
                Layout.preferredWidth: root.iconSize
                Layout.preferredHeight: root.iconSize
                Layout.alignment: Qt.AlignHCenter

                LoadingIndicator {
                    anchors.centerIn: parent
                    width: root.iconSize
                    height: root.iconSize
                    size: root.iconSize
                    color: root.foregroundColor
                    visible: root.isLoading
                    running: root.isLoading
                }

                AppIcon {
                    anchors.centerIn: parent
                    name: root.resolvedIconName
                    size: root.iconSize
                    color: root.foregroundColor
                    visible: controlState.showIcon
                }
            }

            Text {
                text: root.text
                color: root.foregroundColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                textFormat: Text.PlainText
                visible: controlState.showText
                Layout.fillWidth: !controlState.verticalContent
                Layout.alignment: Qt.AlignHCenter

                font {
                    family: root.resolvedFontFamily
                    pixelSize: root.fontPixelSize
                    weight: Theme.typography.weightSemibold
                }

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.motion.durationFast
                        easing: Theme.motion.easingOut
                    }
                }
            }
        }
    }

    background: Rectangle {
        implicitWidth: root.buttonHeight
        implicitHeight: root.buttonHeight
        radius: Theme.radius.button
        color: root.backgroundColor
        border.width: root.borderWidth
        border.color: root.borderColor
        layer.enabled: controlState.hasElevation
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#40000000"
            shadowBlur: Math.min(Math.max(root.elevation, 1), 12) / 12
            shadowOpacity: Math.min(0.10 + root.elevation * 0.04, 0.32)
            shadowHorizontalOffset: 0
            shadowVerticalOffset: Math.min(Math.max(root.elevation, 1), 12)
        }

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.durationFast
                easing: Theme.motion.easingOut
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: Theme.motion.durationFast
                easing: Theme.motion.easingOut
            }
        }
    }

    Layout.fillWidth: root.fullWidth
    Layout.preferredWidth: root.implicitWidth
    Layout.preferredHeight: root.implicitHeight
    Accessible.role: Accessible.Button
    Accessible.name: root.text.length > 0 ? root.text : root.resolvedIconName

    QtObject {
        id: visualStyle

        property color backgroundColor: Theme.colors.action.primary
        property color foregroundColor: Theme.colors.text.inverse
        property color borderColor: "transparent"
        property int borderWidth: 0
    }

    QtObject {
        id: controlState

        readonly property bool hasIcon: root.icon.name.length > 0 || root.icon.source.toString().length > 0
        readonly property bool hasText: root.text.length > 0
        readonly property bool topIconPosition: root.iconPosition === MButton.IconTop
        readonly property bool rightIconPosition: root.iconPosition === MButton.IconRight
        readonly property bool showIcon: controlState.hasIcon && !root.isLoading
        readonly property bool showText: controlState.hasText && !root.isLoading
        readonly property bool verticalContent: controlState.topIconPosition
                                                && controlState.showIcon
                                                && controlState.showText
        readonly property bool showContentGap: (controlState.showIcon || root.isLoading) && controlState.showText
        readonly property bool unavailable: !root.enabled && !root.isLoading
        readonly property bool pressed: root.pressed && !controlState.unavailable
        readonly property bool checked: root.checked && !controlState.unavailable && !controlState.pressed
        readonly property bool hovered: root.hovered
                                        && !controlState.unavailable
                                        && !controlState.pressed
                                        && !controlState.checked
        readonly property bool focused: root.visualFocus
                                        && !controlState.unavailable
                                        && !controlState.pressed
                                        && !controlState.checked
                                        && !controlState.hovered
        readonly property bool normal: !controlState.unavailable
                                       && !controlState.pressed
                                       && !controlState.checked
                                       && !controlState.focused
                                       && !controlState.hovered
        readonly property bool hasElevation: root.elevation > 0 && root.enabled && !root.isLoading
    }

    StateGroup {
        id: visualStates

        states: [
            State {
                name: "primaryDisabled"
                when: root.variant === MButton.Primary && controlState.unavailable
                PropertyChanges {
                    visualStyle.backgroundColor: Theme.colors.action.disabled
                    visualStyle.foregroundColor: Theme.colors.text.inverse
                }
                PropertyChanges {
                    visualStyle.borderColor: "transparent"
                    visualStyle.borderWidth: 0
                }
            },
            State {
                name: "primaryPressed"
                when: root.variant === MButton.Primary && (controlState.pressed || controlState.checked)
                PropertyChanges {
                    visualStyle.backgroundColor: Theme.colors.action.primaryPressed
                    visualStyle.foregroundColor: Theme.colors.text.inverse
                }
                PropertyChanges {
                    visualStyle.borderColor: "transparent"
                    visualStyle.borderWidth: 0
                }
            },
            State {
                name: "primaryFocused"
                when: root.variant === MButton.Primary && controlState.focused
                PropertyChanges {
                    visualStyle.backgroundColor: Theme.colors.action.primaryHover
                    visualStyle.foregroundColor: Theme.colors.text.inverse
                }
                PropertyChanges {
                    visualStyle.borderColor: Theme.colors.border.focus
                    visualStyle.borderWidth: 2
                }
            },
            State {
                name: "primaryHovered"
                when: root.variant === MButton.Primary && controlState.hovered
                PropertyChanges {
                    visualStyle.backgroundColor: Theme.colors.action.primaryHover
                    visualStyle.foregroundColor: Theme.colors.text.inverse
                }
                PropertyChanges {
                    visualStyle.borderColor: "transparent"
                    visualStyle.borderWidth: 0
                }
            },
            State {
                name: "primaryNormal"
                when: root.variant === MButton.Primary && controlState.normal
                PropertyChanges {
                    visualStyle.backgroundColor: Theme.colors.action.primary
                    visualStyle.foregroundColor: Theme.colors.text.inverse
                }
                PropertyChanges {
                    visualStyle.borderColor: "transparent"
                    visualStyle.borderWidth: 0
                }
            },
            State {
                name: "secondaryDisabled"
                when: root.variant === MButton.Secondary && controlState.unavailable
                PropertyChanges {
                    visualStyle.backgroundColor: Theme.colors.action.disabled
                    visualStyle.foregroundColor: Theme.colors.text.inverse
                }
                PropertyChanges {
                    visualStyle.borderColor: "transparent"
                    visualStyle.borderWidth: 0
                }
            },
            State {
                name: "secondaryPressed"
                when: root.variant === MButton.Secondary && (controlState.pressed || controlState.checked)
                PropertyChanges {
                    visualStyle.backgroundColor: Theme.colors.action.secondaryPressed
                    visualStyle.foregroundColor: Theme.colors.text.inverse
                }
                PropertyChanges {
                    visualStyle.borderColor: "transparent"
                    visualStyle.borderWidth: 0
                }
            },
            State {
                name: "secondaryFocused"
                when: root.variant === MButton.Secondary && controlState.focused
                PropertyChanges {
                    visualStyle.backgroundColor: Theme.colors.action.secondaryHover
                    visualStyle.foregroundColor: Theme.colors.text.inverse
                }
                PropertyChanges {
                    visualStyle.borderColor: Theme.colors.border.focus
                    visualStyle.borderWidth: 2
                }
            },
            State {
                name: "secondaryHovered"
                when: root.variant === MButton.Secondary && controlState.hovered
                PropertyChanges {
                    visualStyle.backgroundColor: Theme.colors.action.secondaryHover
                    visualStyle.foregroundColor: Theme.colors.text.inverse
                }
                PropertyChanges {
                    visualStyle.borderColor: "transparent"
                    visualStyle.borderWidth: 0
                }
            },
            State {
                name: "secondaryNormal"
                when: root.variant === MButton.Secondary && controlState.normal
                PropertyChanges {
                    visualStyle.backgroundColor: Theme.colors.action.secondary
                    visualStyle.foregroundColor: Theme.colors.text.inverse
                }
                PropertyChanges {
                    visualStyle.borderColor: "transparent"
                    visualStyle.borderWidth: 0
                }
            },
            State {
                name: "outlineDisabled"
                when: root.variant === MButton.Outline && controlState.unavailable
                PropertyChanges {
                    visualStyle.backgroundColor: "transparent"
                    visualStyle.foregroundColor: Theme.colors.text.disabled
                }
                PropertyChanges {
                    visualStyle.borderColor: Theme.colors.border.base
                    visualStyle.borderWidth: 1
                }
            },
            State {
                name: "outlinePressed"
                when: root.variant === MButton.Outline && controlState.pressed
                PropertyChanges {
                    visualStyle.backgroundColor: Theme.colors.surface.pressed
                    visualStyle.foregroundColor: Theme.colors.action.primary
                }
                PropertyChanges {
                    visualStyle.borderColor: Theme.colors.action.primary
                    visualStyle.borderWidth: 1
                }
            },
            State {
                name: "outlineChecked"
                when: root.variant === MButton.Outline && controlState.checked
                PropertyChanges {
                    visualStyle.backgroundColor: Theme.colors.action.primarySubtle
                    visualStyle.foregroundColor: Theme.colors.action.primary
                }
                PropertyChanges {
                    visualStyle.borderColor: Theme.colors.action.primary
                    visualStyle.borderWidth: 1
                }
            },
            State {
                name: "outlineFocused"
                when: root.variant === MButton.Outline && controlState.focused
                PropertyChanges {
                    visualStyle.backgroundColor: Theme.colors.surface.hover
                    visualStyle.foregroundColor: Theme.colors.action.primary
                }
                PropertyChanges {
                    visualStyle.borderColor: Theme.colors.border.focus
                    visualStyle.borderWidth: 2
                }
            },
            State {
                name: "outlineHovered"
                when: root.variant === MButton.Outline && controlState.hovered
                PropertyChanges {
                    visualStyle.backgroundColor: Theme.colors.surface.hover
                    visualStyle.foregroundColor: Theme.colors.action.primary
                }
                PropertyChanges {
                    visualStyle.borderColor: Theme.colors.action.primary
                    visualStyle.borderWidth: 1
                }
            },
            State {
                name: "outlineNormal"
                when: root.variant === MButton.Outline && controlState.normal
                PropertyChanges {
                    visualStyle.backgroundColor: root.transparentHoverBackground
                    visualStyle.foregroundColor: Theme.colors.action.primary
                }
                PropertyChanges {
                    visualStyle.borderColor: Theme.colors.action.primary
                    visualStyle.borderWidth: 1
                }
            },
            State {
                name: "ghostDisabled"
                when: root.variant === MButton.Ghost && controlState.unavailable
                PropertyChanges {
                    visualStyle.backgroundColor: "transparent"
                    visualStyle.foregroundColor: Theme.colors.text.disabled
                }
                PropertyChanges {
                    visualStyle.borderColor: "transparent"
                    visualStyle.borderWidth: 0
                }
            },
            State {
                name: "ghostPressed"
                when: root.variant === MButton.Ghost && controlState.pressed
                PropertyChanges {
                    visualStyle.backgroundColor: Theme.colors.surface.pressed
                    visualStyle.foregroundColor: Theme.colors.action.primary
                }
                PropertyChanges {
                    visualStyle.borderColor: "transparent"
                    visualStyle.borderWidth: 0
                }
            },
            State {
                name: "ghostChecked"
                when: root.variant === MButton.Ghost && controlState.checked
                PropertyChanges {
                    visualStyle.backgroundColor: Theme.colors.action.primarySubtle
                    visualStyle.foregroundColor: Theme.colors.action.primary
                }
                PropertyChanges {
                    visualStyle.borderColor: "transparent"
                    visualStyle.borderWidth: 0
                }
            },
            State {
                name: "ghostFocused"
                when: root.variant === MButton.Ghost && controlState.focused
                PropertyChanges {
                    visualStyle.backgroundColor: Theme.colors.surface.hover
                    visualStyle.foregroundColor: Theme.colors.action.primary
                }
                PropertyChanges {
                    visualStyle.borderColor: Theme.colors.border.focus
                    visualStyle.borderWidth: 2
                }
            },
            State {
                name: "ghostHovered"
                when: root.variant === MButton.Ghost && controlState.hovered
                PropertyChanges {
                    visualStyle.backgroundColor: Theme.colors.surface.hover
                    visualStyle.foregroundColor: Theme.colors.action.primary
                }
                PropertyChanges {
                    visualStyle.borderColor: "transparent"
                    visualStyle.borderWidth: 0
                }
            },
            State {
                name: "ghostNormal"
                when: root.variant === MButton.Ghost && controlState.normal
                PropertyChanges {
                    visualStyle.backgroundColor: root.transparentHoverBackground
                    visualStyle.foregroundColor: Theme.colors.action.primary
                }
                PropertyChanges {
                    visualStyle.borderColor: "transparent"
                    visualStyle.borderWidth: 0
                }
            },
            State {
                name: "destructiveDisabled"
                when: root.variant === MButton.Destructive && controlState.unavailable
                PropertyChanges {
                    visualStyle.backgroundColor: Theme.colors.action.disabled
                    visualStyle.foregroundColor: Theme.colors.text.inverse
                }
                PropertyChanges {
                    visualStyle.borderColor: "transparent"
                    visualStyle.borderWidth: 0
                }
            },
            State {
                name: "destructivePressed"
                when: root.variant === MButton.Destructive && (controlState.pressed || controlState.checked)
                PropertyChanges {
                    visualStyle.backgroundColor: Theme.colors.status.error.strong
                    visualStyle.foregroundColor: Theme.colors.status.error.onStrong
                }
                PropertyChanges {
                    visualStyle.borderColor: "transparent"
                    visualStyle.borderWidth: 0
                }
            },
            State {
                name: "destructiveFocused"
                when: root.variant === MButton.Destructive && controlState.focused
                PropertyChanges {
                    visualStyle.backgroundColor: Theme.colors.status.error.strong
                    visualStyle.foregroundColor: Theme.colors.status.error.onStrong
                }
                PropertyChanges {
                    visualStyle.borderColor: Theme.colors.border.focus
                    visualStyle.borderWidth: 2
                }
            },
            State {
                name: "destructiveHovered"
                when: root.variant === MButton.Destructive && controlState.hovered
                PropertyChanges {
                    visualStyle.backgroundColor: Theme.colors.status.error.strong
                    visualStyle.foregroundColor: Theme.colors.status.error.onStrong
                }
                PropertyChanges {
                    visualStyle.borderColor: "transparent"
                    visualStyle.borderWidth: 0
                }
            },
            State {
                name: "destructiveNormal"
                when: root.variant === MButton.Destructive && controlState.normal
                PropertyChanges {
                    visualStyle.backgroundColor: Theme.colors.status.error.strong
                    visualStyle.foregroundColor: Theme.colors.status.error.onStrong
                }
                PropertyChanges {
                    visualStyle.borderColor: "transparent"
                    visualStyle.borderWidth: 0
                }
            }
        ]
    }
}
