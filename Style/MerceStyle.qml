pragma ComponentBehavior: Bound

import QtQuick
import Qt.labs.StyleKit
import Merce.Foundation
import Merce.Theme

Style {
    id: style

    // Merce.Theme owns light/dark mode. Keep StyleKit on one loaded theme axis.
    themeName: "Light"

    readonly property var colors: Theme.colors
    readonly property var spacingTokens: Theme.spacing
    readonly property var radiusTokens: Theme.radius
    readonly property var sizeTokens: Theme.size
    readonly property var stateTokens: Theme.state
    readonly property var typographyTokens: Theme.typography
    // StyleKit's shadow group is a single layer with no spread, so a Controls
    // shadow can only ever approximate the token: the second, tighter layer and
    // every spread inset are dropped. Qt 6.12 does not change this. Merce's own
    // surfaces go through MShadow instead and render the token in full.
    readonly property var dropdownShadow: Theme.shadows.dropdown[0]

    function stateLayer(container, content, opacity) {
        return Qt.tint(container, Qt.alpha(content, opacity))
    }

    function disabledContainer(container, content) {
        return stateLayer(container, content, style.stateTokens.disabled.containerOpacity)
    }

    function disabledContent(container, content) {
        return stateLayer(disabledContainer(container, content),
                          content,
                          style.stateTokens.disabled.contentOpacity)
    }

    fonts {
        system {
            family: FoundationFonts.resolveFamily(style.typographyTokens.fontBody)
            pixelSize: style.typographyTokens.sizeMedium
            weight: style.typographyTokens.weightRegular
            capitalization: Font.MixedCase
        }
        button {
            family: FoundationFonts.resolveFamily(style.typographyTokens.fontBody)
            pixelSize: style.typographyTokens.sizeSmall
            weight: style.typographyTokens.weightSemibold
            capitalization: Font.MixedCase
        }
    }

    palettes {
        system {
            window: style.colors.surface.canvas
            windowText: style.colors.content.primary
            text: style.colors.content.primary
            placeholderText: style.colors.content.tertiary
            highlight: style.colors.action.primary.container
            highlightedText: style.colors.action.primary.content
            link: style.colors.content.link
            disabled {
                text: style.colors.content.disabled
                windowText: style.colors.content.disabled
            }
        }
        textField {
            text: style.colors.content.primary
            placeholderText: style.colors.content.tertiary
            highlight: style.colors.action.primary.container
            highlightedText: style.colors.action.primary.content
            disabled.text: style.colors.content.disabled
        }
    }

    applicationWindow {
        background {
            color: style.colors.surface.canvas
            border.width: 0
            shadow.visible: false
        }
    }

    control {
        spacing: style.spacingTokens.xs
        leftPadding: style.spacingTokens.md
        rightPadding: style.spacingTokens.md
        topPadding: style.spacingTokens.xs
        bottomPadding: style.spacingTokens.xs
        transition: Transition {
            StyleAnimation {
                animateColors: true
                duration: Theme.motion.durationFast
                easing.type: Theme.motion.easingOut
            }
        }
        background {
            implicitHeight: style.sizeTokens.control.medium
            radius: style.radiusTokens.medium
            border.width: style.sizeTokens.outline.hairline
            border.color: style.colors.outline.subtle
            color: style.colors.surface.container
            shadow.visible: false
        }
        text {
            color: style.colors.content.primary
            alignment: Qt.AlignVCenter | Qt.AlignLeft
        }
        hovered.background.color: style.stateLayer(
                                      style.colors.surface.container,
                                      style.colors.content.primary,
                                      style.stateTokens.layer.hover)
        focused {
            background {
                color: style.stateLayer(style.colors.surface.container,
                                        style.colors.content.primary,
                                        style.stateTokens.layer.focus)
                border.color: style.colors.outline.focus
                border.width: style.sizeTokens.outline.focus
            }
        }
        pressed.background.color: style.stateLayer(
                                      style.colors.surface.container,
                                      style.colors.content.primary,
                                      style.stateTokens.layer.pressed)
        checked.background.color: style.stateLayer(
                                      style.colors.surface.container,
                                      style.colors.content.primary,
                                      style.stateTokens.layer.selected)
        highlighted.background.color: style.stateLayer(
                                          style.colors.surface.container,
                                          style.colors.content.primary,
                                          style.stateTokens.layer.selected)
        disabled {
            background {
                color: style.disabledContainer(style.colors.surface.container,
                                               style.colors.content.primary)
                border.color: style.colors.outline.subtle
            }
            text.color: style.disabledContent(style.colors.surface.container,
                                              style.colors.content.primary)
            checked {
                background.color: style.disabledContainer(
                                      style.stateLayer(style.colors.surface.container,
                                                       style.colors.content.primary,
                                                       style.stateTokens.layer.selected),
                                      style.colors.content.primary)
                text.color: style.disabledContent(
                                style.stateLayer(style.colors.surface.container,
                                                 style.colors.content.primary,
                                                 style.stateTokens.layer.selected),
                                style.colors.content.primary)
            }
        }
    }

    button {
        leftPadding: style.spacingTokens.xl
        rightPadding: style.spacingTokens.xl
        background {
            implicitWidth: style.sizeTokens.control.medium
            implicitHeight: style.sizeTokens.control.medium
            radius: style.radiusTokens.button
            border.width: style.sizeTokens.outline.hairline
            border.color: style.colors.action.primary.outline
            color: style.colors.action.primary.container
        }
        text {
            color: style.colors.action.primary.content
            alignment: Qt.AlignCenter
        }
        hovered.background.color: style.stateLayer(
                                      style.colors.action.primary.container,
                                      style.colors.action.primary.content,
                                      style.stateTokens.layer.hover)
        focused {
            background {
                color: style.stateLayer(style.colors.action.primary.container,
                                        style.colors.action.primary.content,
                                        style.stateTokens.layer.focus)
                border.color: style.colors.outline.focus
                border.width: style.sizeTokens.outline.focus
            }
        }
        pressed.background.color: style.stateLayer(
                                      style.colors.action.primary.container,
                                      style.colors.action.primary.content,
                                      style.stateTokens.layer.pressed)
        checked.background.color: style.stateLayer(
                                      style.colors.action.primary.container,
                                      style.colors.action.primary.content,
                                      style.stateTokens.layer.selected)
        highlighted.background.color: style.stateLayer(
                                          style.colors.action.primary.container,
                                          style.colors.action.primary.content,
                                          style.stateTokens.layer.selected)
        disabled {
            background.color: style.disabledContainer(
                                  style.colors.action.primary.container,
                                  style.colors.action.primary.content)
            text.color: style.disabledContent(style.colors.action.primary.container,
                                              style.colors.action.primary.content)
            checked {
                background.color: style.disabledContainer(
                                      style.colors.action.primary.container,
                                      style.colors.action.primary.content)
                text.color: style.disabledContent(style.colors.action.primary.container,
                                                  style.colors.action.primary.content)
            }
        }
    }

    comboBox {
        background {
            implicitWidth: style.sizeTokens.control.large * 3
            implicitHeight: style.sizeTokens.control.medium
            radius: style.radiusTokens.input
            border.width: style.sizeTokens.outline.hairline
            border.color: style.colors.outline.subtle
            color: style.colors.surface.container
        }
        text.color: style.colors.content.primary
        indicator {
            implicitWidth: style.sizeTokens.icon.small
            implicitHeight: style.sizeTokens.icon.small
            color: Qt.alpha(style.colors.surface.container, 0)
            border.width: 0
            foreground {
                color: Qt.alpha(style.colors.surface.container, 0)
                border.width: 0
                image.color: style.colors.content.secondary
            }
        }
        hovered.background.color: style.stateLayer(
                                      style.colors.surface.container,
                                      style.colors.content.primary,
                                      style.stateTokens.layer.hover)
        focused {
            background {
                color: style.stateLayer(style.colors.surface.container,
                                        style.colors.content.primary,
                                        style.stateTokens.layer.focus)
                border.color: style.colors.outline.focus
                border.width: style.sizeTokens.outline.focus
            }
        }
        pressed.background.color: style.stateLayer(
                                      style.colors.surface.container,
                                      style.colors.content.primary,
                                      style.stateTokens.layer.pressed)
        checked.background.color: style.stateLayer(
                                      style.colors.surface.container,
                                      style.colors.content.primary,
                                      style.stateTokens.layer.selected)
        highlighted.background.color: style.stateLayer(
                                          style.colors.surface.container,
                                          style.colors.content.primary,
                                          style.stateTokens.layer.selected)
        disabled {
            background.color: style.disabledContainer(style.colors.surface.container,
                                                      style.colors.content.primary)
            text.color: style.disabledContent(style.colors.surface.container,
                                              style.colors.content.primary)
        }
    }

    popup {
        // Qt 6.11 ComboBox fixes popup height to content implicitHeight and
        // does not add popup padding. Delegates own the required inset.
        padding: 0
        background {
            color: style.colors.surface.floating
            radius: style.radiusTokens.dialog
            border.width: style.sizeTokens.outline.hairline
            border.color: style.colors.outline.subtle
            shadow {
                visible: true
                color: style.colors.surface.shadow
                opacity: style.dropdownShadow.opacity
                blur: style.dropdownShadow.blur
                horizontalOffset: style.dropdownShadow.xOffset
                verticalOffset: style.dropdownShadow.yOffset
            }
        }
        disabled.background.color: style.disabledContainer(
                                       style.colors.surface.floating,
                                       style.colors.content.primary)
    }

    itemDelegate {
        leftPadding: style.spacingTokens.md
        rightPadding: style.spacingTokens.md
        background {
            implicitHeight: style.sizeTokens.control.minimum
            radius: style.radiusTokens.small
            border.width: 0
            color: style.colors.surface.floating
        }
        text.color: style.colors.content.primary
        hovered.background.color: style.stateLayer(
                                      style.colors.surface.floating,
                                      style.colors.content.primary,
                                      style.stateTokens.layer.hover)
        focused {
            background {
                color: style.stateLayer(style.colors.surface.floating,
                                        style.colors.content.primary,
                                        style.stateTokens.layer.focus)
                border.color: style.colors.outline.focus
                border.width: style.sizeTokens.outline.focus
            }
        }
        pressed.background.color: style.stateLayer(
                                      style.colors.surface.floating,
                                      style.colors.content.primary,
                                      style.stateTokens.layer.pressed)
        checked.background.color: style.stateLayer(
                                      style.colors.surface.floating,
                                      style.colors.content.primary,
                                      style.stateTokens.layer.selected)
        highlighted.background.color: style.stateLayer(
                                          style.colors.surface.floating,
                                          style.colors.content.primary,
                                          style.stateTokens.layer.selected)
        disabled {
            background.color: style.disabledContainer(style.colors.surface.floating,
                                                      style.colors.content.primary)
            text.color: style.disabledContent(style.colors.surface.floating,
                                              style.colors.content.primary)
            checked {
                background.color: style.disabledContainer(
                                      style.stateLayer(style.colors.surface.floating,
                                                       style.colors.content.primary,
                                                       style.stateTokens.layer.selected),
                                      style.colors.content.primary)
                text.color: style.disabledContent(
                                style.stateLayer(style.colors.surface.floating,
                                                 style.colors.content.primary,
                                                 style.stateTokens.layer.selected),
                                style.colors.content.primary)
            }
        }
    }

    scrollBar {
        padding: 0
        background {
            visible: false
            implicitHeight: style.sizeTokens.icon.small
        }
        indicator {
            implicitHeight: style.sizeTokens.icon.small
            radius: style.radiusTokens.full
            border.width: 0
            foreground {
                color: style.colors.outline.strong
                radius: style.radiusTokens.full
            }
        }
        vertical {
            background.implicitWidth: style.sizeTokens.icon.small
            indicator.implicitWidth: style.sizeTokens.icon.small
        }
        hovered.indicator.foreground.color: style.stateLayer(
                                                style.colors.outline.strong,
                                                style.colors.content.primary,
                                                style.stateTokens.layer.hover)
        focused.indicator.foreground.color: style.stateLayer(
                                                style.colors.outline.strong,
                                                style.colors.content.primary,
                                                style.stateTokens.layer.focus)
        pressed.indicator.foreground.color: style.stateLayer(
                                                style.colors.outline.strong,
                                                style.colors.content.primary,
                                                style.stateTokens.layer.pressed)
        checked.indicator.foreground.color: style.stateLayer(
                                                style.colors.outline.strong,
                                                style.colors.content.primary,
                                                style.stateTokens.layer.selected)
        highlighted.indicator.foreground.color: style.stateLayer(
                                                    style.colors.outline.strong,
                                                    style.colors.content.primary,
                                                    style.stateTokens.layer.selected)
        disabled.indicator.foreground.color: style.disabledContainer(
                                                 style.colors.surface.container,
                                                 style.colors.outline.strong)
    }

    scrollIndicator {
        padding: 0
        background {
            visible: false
            implicitHeight: style.sizeTokens.outline.strong * 2
        }
        indicator {
            implicitHeight: style.sizeTokens.outline.strong * 2
            radius: style.radiusTokens.full
            border.width: 0
            foreground {
                margins: 0
                radius: style.radiusTokens.full
                color: style.colors.outline.strong
            }
        }
        vertical {
            background.implicitWidth: style.sizeTokens.outline.strong * 2
            indicator.implicitWidth: style.sizeTokens.outline.strong * 2
        }
        hovered.indicator.foreground.color: style.stateLayer(
                                                style.colors.outline.strong,
                                                style.colors.content.primary,
                                                style.stateTokens.layer.hover)
        focused.indicator.foreground.color: style.stateLayer(
                                                style.colors.outline.strong,
                                                style.colors.content.primary,
                                                style.stateTokens.layer.focus)
        pressed.indicator.foreground.color: style.stateLayer(
                                                style.colors.outline.strong,
                                                style.colors.content.primary,
                                                style.stateTokens.layer.pressed)
        checked.indicator.foreground.color: style.stateLayer(
                                                style.colors.outline.strong,
                                                style.colors.content.primary,
                                                style.stateTokens.layer.selected)
        highlighted.indicator.foreground.color: style.stateLayer(
                                                    style.colors.outline.strong,
                                                    style.colors.content.primary,
                                                    style.stateTokens.layer.selected)
        disabled.indicator.foreground.color: style.disabledContainer(
                                                 style.colors.surface.container,
                                                 style.colors.outline.strong)
    }

    textField {
        background {
            implicitWidth: style.sizeTokens.control.large * 3
            implicitHeight: style.sizeTokens.control.medium
            radius: style.radiusTokens.input
            border.width: style.sizeTokens.outline.hairline
            border.color: style.colors.outline.subtle
            color: style.colors.surface.container
        }
        text.color: style.colors.content.primary
        hovered.background.color: style.stateLayer(
                                      style.colors.surface.container,
                                      style.colors.content.primary,
                                      style.stateTokens.layer.hover)
        focused {
            background {
                color: style.stateLayer(style.colors.surface.container,
                                        style.colors.content.primary,
                                        style.stateTokens.layer.focus)
                border.color: style.colors.outline.focus
                border.width: style.sizeTokens.outline.focus
            }
        }
        pressed.background.color: style.stateLayer(
                                      style.colors.surface.container,
                                      style.colors.content.primary,
                                      style.stateTokens.layer.pressed)
        checked.background.color: style.stateLayer(
                                      style.colors.surface.container,
                                      style.colors.content.primary,
                                      style.stateTokens.layer.selected)
        highlighted.background.color: style.stateLayer(
                                          style.colors.surface.container,
                                          style.colors.content.primary,
                                          style.stateTokens.layer.selected)
        disabled {
            background.color: style.disabledContainer(style.colors.surface.container,
                                                      style.colors.content.primary)
            text.color: style.disabledContent(style.colors.surface.container,
                                              style.colors.content.primary)
        }
    }

    textArea {
        leftPadding: style.spacingTokens.sm
        rightPadding: style.spacingTokens.sm
        topPadding: style.spacingTokens.sm
        bottomPadding: style.spacingTokens.sm
        background {
            implicitWidth: style.sizeTokens.control.large * 3
            implicitHeight: style.sizeTokens.control.medium * 2
            radius: style.radiusTokens.input
            border.width: style.sizeTokens.outline.hairline
            border.color: style.colors.outline.subtle
            color: style.colors.surface.container
        }
        text {
            color: style.colors.content.primary
            alignment: Qt.AlignLeft | Qt.AlignTop
        }
        hovered.background.color: style.stateLayer(
                                      style.colors.surface.container,
                                      style.colors.content.primary,
                                      style.stateTokens.layer.hover)
        focused {
            background {
                color: style.stateLayer(style.colors.surface.container,
                                        style.colors.content.primary,
                                        style.stateTokens.layer.focus)
                border.color: style.colors.outline.focus
                border.width: style.sizeTokens.outline.focus
            }
        }
        disabled {
            background.color: style.disabledContainer(style.colors.surface.container,
                                                      style.colors.content.primary)
            text.color: style.disabledContent(style.colors.surface.container,
                                              style.colors.content.primary)
        }
    }

    checkBox {
        background {
            visible: false
            implicitHeight: style.sizeTokens.control.medium
        }
        indicator {
            implicitWidth: style.sizeTokens.icon.medium
            implicitHeight: style.sizeTokens.icon.medium
            radius: style.radiusTokens.small
            border.width: style.sizeTokens.outline.hairline
            border.color: style.colors.outline.strong
            color: style.colors.surface.container
            foreground {
                color: style.colors.action.primary.container
                image.color: style.colors.action.primary.content
            }
        }
        text.color: style.colors.content.primary
        hovered.indicator.color: style.stateLayer(
                                     style.colors.surface.container,
                                     style.colors.content.primary,
                                     style.stateTokens.layer.hover)
        focused {
            indicator {
                color: style.stateLayer(style.colors.surface.container,
                                        style.colors.content.primary,
                                        style.stateTokens.layer.focus)
                border.color: style.colors.outline.focus
                border.width: style.sizeTokens.outline.focus
            }
        }
        pressed.indicator.color: style.stateLayer(
                                     style.colors.surface.container,
                                     style.colors.content.primary,
                                     style.stateTokens.layer.pressed)
        checked {
            indicator {
                color: style.colors.action.primary.container
                border.color: style.colors.action.primary.outline
            }
        }
        highlighted.indicator.color: style.stateLayer(
                                         style.colors.action.primary.container,
                                         style.colors.action.primary.content,
                                         style.stateTokens.layer.selected)
        disabled {
            indicator.color: style.disabledContainer(style.colors.surface.container,
                                                     style.colors.content.primary)
            text.color: style.disabledContent(style.colors.surface.container,
                                              style.colors.content.primary)
            checked {
                indicator {
                    color: style.disabledContainer(style.colors.action.primary.container,
                                                   style.colors.action.primary.content)
                    border.color: style.colors.outline.subtle
                    foreground.image.color: style.disabledContent(
                                                style.colors.action.primary.container,
                                                style.colors.action.primary.content)
                }
            }
        }
    }

    radioButton {
        background {
            visible: false
            implicitHeight: style.sizeTokens.control.medium
        }
        indicator {
            implicitWidth: style.sizeTokens.icon.medium
            implicitHeight: style.sizeTokens.icon.medium
            radius: style.radiusTokens.full
            border.width: style.sizeTokens.outline.hairline
            border.color: style.colors.outline.strong
            color: style.colors.surface.container
            foreground {
                margins: style.spacingTokens.xxs
                radius: style.radiusTokens.full
                color: style.colors.action.primary.container
            }
        }
        text.color: style.colors.content.primary
        hovered.indicator.color: style.stateLayer(
                                     style.colors.surface.container,
                                     style.colors.content.primary,
                                     style.stateTokens.layer.hover)
        focused {
            indicator {
                color: style.stateLayer(style.colors.surface.container,
                                        style.colors.content.primary,
                                        style.stateTokens.layer.focus)
                border.color: style.colors.outline.focus
                border.width: style.sizeTokens.outline.focus
            }
        }
        pressed.indicator.color: style.stateLayer(
                                     style.colors.surface.container,
                                     style.colors.content.primary,
                                     style.stateTokens.layer.pressed)
        checked.indicator.border.color: style.colors.action.primary.outline
        highlighted.indicator.color: style.stateLayer(
                                         style.colors.surface.container,
                                         style.colors.content.primary,
                                         style.stateTokens.layer.selected)
        disabled {
            indicator.color: style.disabledContainer(style.colors.surface.container,
                                                     style.colors.content.primary)
            text.color: style.disabledContent(style.colors.surface.container,
                                              style.colors.content.primary)
            checked {
                indicator {
                    border.color: style.colors.outline.subtle
                    foreground.color: style.disabledContent(
                                          style.colors.surface.container,
                                          style.colors.action.primary.container)
                }
            }
        }
    }

    switchControl {
        topPadding: 0
        bottomPadding: 0
        background {
            visible: false
            implicitHeight: style.sizeTokens.control.medium
        }
        indicator {
            implicitWidth: style.sizeTokens.control.medium
            implicitHeight: style.sizeTokens.icon.medium
            radius: style.radiusTokens.full
            border.width: style.sizeTokens.outline.hairline
            border.color: style.colors.outline.subtle
            color: style.colors.surface.containerSunken
            foreground.visible: false
        }
        handle {
            implicitWidth: style.sizeTokens.icon.small
            implicitHeight: style.sizeTokens.icon.small
            leftMargin: style.spacingTokens.xxs
            rightMargin: style.spacingTokens.xxs
            radius: style.radiusTokens.full
            border.width: 0
            color: style.colors.content.secondary
        }
        text.color: style.colors.content.primary
        hovered.indicator.color: style.stateLayer(
                                     style.colors.surface.containerSunken,
                                     style.colors.content.primary,
                                     style.stateTokens.layer.hover)
        focused {
            indicator {
                color: style.stateLayer(style.colors.surface.containerSunken,
                                        style.colors.content.primary,
                                        style.stateTokens.layer.focus)
                border.color: style.colors.outline.focus
                border.width: style.sizeTokens.outline.focus
            }
        }
        pressed.indicator.color: style.stateLayer(
                                     style.colors.surface.containerSunken,
                                     style.colors.content.primary,
                                     style.stateTokens.layer.pressed)
        checked {
            indicator.color: style.colors.action.primary.container
            handle.color: style.colors.action.primary.content
        }
        highlighted.indicator.color: style.stateLayer(
                                         style.colors.action.primary.container,
                                         style.colors.action.primary.content,
                                         style.stateTokens.layer.selected)
        disabled {
            indicator.color: style.disabledContainer(style.colors.surface.containerSunken,
                                                     style.colors.content.primary)
            handle.color: style.disabledContent(style.colors.surface.containerSunken,
                                                style.colors.content.secondary)
            text.color: style.disabledContent(style.colors.surface.container,
                                              style.colors.content.primary)
            checked {
                indicator.color: style.disabledContainer(
                                     style.colors.action.primary.container,
                                     style.colors.action.primary.content)
                handle.color: style.disabledContent(style.colors.action.primary.container,
                                                    style.colors.action.primary.content)
            }
        }
    }

    progressBar {
        background {
            visible: false
            implicitHeight: style.sizeTokens.icon.small
        }
        indicator {
            implicitWidth: style.sizeTokens.control.large * 3
            implicitHeight: style.sizeTokens.icon.small
            radius: style.radiusTokens.full
            color: style.colors.surface.containerSunken
            foreground {
                color: style.colors.action.primary.container
                radius: style.radiusTokens.full
            }
        }
        disabled {
            indicator {
                color: style.disabledContainer(style.colors.surface.containerSunken,
                                               style.colors.content.primary)
                foreground.color: style.disabledContainer(
                                      style.colors.surface.container,
                                      style.colors.action.primary.container)
            }
        }
    }

    slider {
        background {
            visible: false
            implicitWidth: style.sizeTokens.control.large * 3
            implicitHeight: style.sizeTokens.control.medium
        }
        indicator {
            implicitWidth: Style.Stretch
            implicitHeight: style.sizeTokens.outline.strong * 2
            radius: style.radiusTokens.full
            color: style.colors.surface.containerSunken
            foreground {
                color: style.colors.action.primary.container
                radius: style.radiusTokens.full
            }
        }
        handle {
            implicitWidth: style.sizeTokens.icon.medium
            implicitHeight: style.sizeTokens.icon.medium
            radius: style.radiusTokens.full
            border.width: style.sizeTokens.outline.hairline
            border.color: style.colors.action.primary.outline
            color: style.colors.action.primary.container
        }
        hovered.handle.color: style.stateLayer(
                                  style.colors.action.primary.container,
                                  style.colors.action.primary.content,
                                  style.stateTokens.layer.hover)
        focused {
            handle {
                color: style.stateLayer(style.colors.action.primary.container,
                                        style.colors.action.primary.content,
                                        style.stateTokens.layer.focus)
                border.color: style.colors.outline.focus
                border.width: style.sizeTokens.outline.focus
            }
        }
        pressed.handle.color: style.stateLayer(
                                  style.colors.action.primary.container,
                                  style.colors.action.primary.content,
                                  style.stateTokens.layer.pressed)
        checked.handle.color: style.stateLayer(
                                  style.colors.action.primary.container,
                                  style.colors.action.primary.content,
                                  style.stateTokens.layer.selected)
        highlighted.handle.color: style.stateLayer(
                                      style.colors.action.primary.container,
                                      style.colors.action.primary.content,
                                      style.stateTokens.layer.selected)
        disabled {
            indicator.foreground.color: style.disabledContainer(
                                            style.colors.surface.container,
                                            style.colors.action.primary.container)
            handle.color: style.disabledContainer(style.colors.surface.container,
                                                  style.colors.action.primary.container)
        }
    }

    spinBox {
        leftPadding: 0
        rightPadding: 0
        background {
            implicitWidth: style.sizeTokens.control.large * 3
            implicitHeight: style.sizeTokens.control.medium
            radius: style.radiusTokens.input
            border.width: style.sizeTokens.outline.hairline
            border.color: style.colors.outline.subtle
            color: style.colors.surface.container
        }
        text {
            color: style.colors.content.primary
            alignment: Qt.AlignHCenter | Qt.AlignVCenter
        }
        indicator {
            implicitWidth: style.sizeTokens.control.small
            implicitHeight: Style.Stretch
            margins: 0
            border.width: 0
            color: Qt.alpha(style.colors.surface.container, 0)
            foreground {
                implicitWidth: style.sizeTokens.icon.small
                implicitHeight: style.sizeTokens.icon.small
                alignment: Qt.AlignCenter
                color: Qt.alpha(style.colors.surface.container, 0)
                image.color: style.colors.content.secondary
            }
            down.alignment: Qt.AlignLeft | Qt.AlignVCenter
            up.alignment: Qt.AlignRight | Qt.AlignVCenter
        }
        hovered {
            background.color: style.stateLayer(
                                  style.colors.surface.container,
                                  style.colors.content.primary,
                                  style.stateTokens.layer.hover)
            indicator.foreground.image.color: style.colors.content.primary
        }
        focused {
            background {
                color: style.stateLayer(style.colors.surface.container,
                                        style.colors.content.primary,
                                        style.stateTokens.layer.focus)
                border.color: style.colors.outline.focus
                border.width: style.sizeTokens.outline.focus
            }
        }
        pressed {
            background.color: style.stateLayer(
                                  style.colors.surface.container,
                                  style.colors.content.primary,
                                  style.stateTokens.layer.pressed)
            indicator.foreground.image.color: style.colors.action.primary.container
        }
        disabled {
            background.color: style.disabledContainer(style.colors.surface.container,
                                                      style.colors.content.primary)
            text.color: style.disabledContent(style.colors.surface.container,
                                              style.colors.content.primary)
            indicator.foreground.image.color: style.disabledContent(
                                                  style.colors.surface.container,
                                                  style.colors.content.secondary)
        }
    }

    label {
        background {
            visible: false
            implicitWidth: 0
            implicitHeight: 0
        }
        text.color: style.colors.content.primary
        disabled.text.color: style.colors.content.disabled
    }

    StyleVariation {
        name: "secondary"
        control {
            background {
                color: style.colors.action.secondary.container
                border.color: style.colors.action.secondary.outline
            }
            text.color: style.colors.action.secondary.content
            hovered.background.color: style.stateLayer(
                                          style.colors.action.secondary.container,
                                          style.colors.action.secondary.content,
                                          style.stateTokens.layer.hover)
            focused {
                background {
                    color: style.stateLayer(style.colors.action.secondary.container,
                                            style.colors.action.secondary.content,
                                            style.stateTokens.layer.focus)
                    border.color: style.colors.outline.focus
                    border.width: style.sizeTokens.outline.focus
                }
            }
            pressed.background.color: style.stateLayer(
                                          style.colors.action.secondary.container,
                                          style.colors.action.secondary.content,
                                          style.stateTokens.layer.pressed)
            checked.background.color: style.stateLayer(
                                          style.colors.action.secondary.container,
                                          style.colors.action.secondary.content,
                                          style.stateTokens.layer.selected)
            highlighted.background.color: style.stateLayer(
                                              style.colors.action.secondary.container,
                                              style.colors.action.secondary.content,
                                              style.stateTokens.layer.selected)
            disabled {
                background.color: style.disabledContainer(
                                      style.colors.action.secondary.container,
                                      style.colors.action.secondary.content)
                text.color: style.disabledContent(style.colors.action.secondary.container,
                                                  style.colors.action.secondary.content)
                checked {
                    background.color: style.disabledContainer(
                                          style.colors.action.secondary.container,
                                          style.colors.action.secondary.content)
                    text.color: style.disabledContent(
                                    style.colors.action.secondary.container,
                                    style.colors.action.secondary.content)
                }
            }
        }
    }

    StyleVariation {
        name: "destructive"
        control {
            background {
                color: style.colors.action.destructive.container
                border.color: style.colors.action.destructive.outline
            }
            text.color: style.colors.action.destructive.content
            hovered.background.color: style.stateLayer(
                                          style.colors.action.destructive.container,
                                          style.colors.action.destructive.content,
                                          style.stateTokens.layer.hover)
            focused {
                background {
                    color: style.stateLayer(style.colors.action.destructive.container,
                                            style.colors.action.destructive.content,
                                            style.stateTokens.layer.focus)
                    border.color: style.colors.outline.focus
                    border.width: style.sizeTokens.outline.focus
                }
            }
            pressed.background.color: style.stateLayer(
                                          style.colors.action.destructive.container,
                                          style.colors.action.destructive.content,
                                          style.stateTokens.layer.pressed)
            checked.background.color: style.stateLayer(
                                          style.colors.action.destructive.container,
                                          style.colors.action.destructive.content,
                                          style.stateTokens.layer.selected)
            highlighted.background.color: style.stateLayer(
                                              style.colors.action.destructive.container,
                                              style.colors.action.destructive.content,
                                              style.stateTokens.layer.selected)
            disabled {
                background.color: style.disabledContainer(
                                      style.colors.action.destructive.container,
                                      style.colors.action.destructive.content)
                text.color: style.disabledContent(style.colors.action.destructive.container,
                                                  style.colors.action.destructive.content)
                checked {
                    background.color: style.disabledContainer(
                                          style.colors.action.destructive.container,
                                          style.colors.action.destructive.content)
                    text.color: style.disabledContent(
                                    style.colors.action.destructive.container,
                                    style.colors.action.destructive.content)
                }
            }
        }
    }

    StyleVariation {
        name: "outline"
        control {
            background {
                color: style.colors.surface.container
                border.color: style.colors.action.primary.outline
            }
            text.color: style.colors.action.primary.container
            hovered.background.color: style.stateLayer(
                                          style.colors.surface.container,
                                          style.colors.action.primary.container,
                                          style.stateTokens.layer.hover)
            focused {
                background {
                    color: style.stateLayer(style.colors.surface.container,
                                            style.colors.action.primary.container,
                                            style.stateTokens.layer.focus)
                    border.color: style.colors.outline.focus
                    border.width: style.sizeTokens.outline.focus
                }
            }
            pressed.background.color: style.stateLayer(
                                          style.colors.surface.container,
                                          style.colors.action.primary.container,
                                          style.stateTokens.layer.pressed)
            checked {
                background {
                    color: style.colors.action.primary.container
                    border.color: style.colors.action.primary.outline
                }
                text.color: style.colors.action.primary.content
                hovered.background.color: style.stateLayer(
                                              style.colors.action.primary.container,
                                              style.colors.action.primary.content,
                                              style.stateTokens.layer.hover)
                focused {
                    background {
                        color: style.colors.action.primary.container
                        border.color: style.colors.outline.focus
                        border.width: style.sizeTokens.outline.focus
                    }
                    text.color: style.colors.action.primary.content
                }
                pressed.background.color: style.stateLayer(
                                              style.colors.action.primary.container,
                                              style.colors.action.primary.content,
                                              style.stateTokens.layer.pressed)
            }
            highlighted.background.color: style.stateLayer(
                                              style.colors.surface.container,
                                              style.colors.action.primary.container,
                                              style.stateTokens.layer.selected)
            disabled {
                background.color: style.disabledContainer(style.colors.surface.container,
                                                          style.colors.action.primary.container)
                text.color: style.disabledContent(style.colors.surface.container,
                                                  style.colors.action.primary.container)
                checked {
                    background.color: style.disabledContainer(
                                          style.colors.surface.container,
                                          style.colors.action.primary.container)
                    text.color: style.disabledContent(
                                    style.colors.surface.container,
                                    style.colors.action.primary.container)
                }
            }
        }
    }

    StyleVariation {
        name: "ghost"
        control {
            background {
                color: Qt.alpha(style.colors.surface.container, 0)
                border.width: 0
                shadow.visible: false
            }
            text.color: style.colors.action.primary.container
            hovered.background.color: style.stateLayer(
                                          style.colors.surface.container,
                                          style.colors.action.primary.container,
                                          style.stateTokens.layer.hover)
            focused {
                background {
                    color: style.stateLayer(style.colors.surface.container,
                                            style.colors.action.primary.container,
                                            style.stateTokens.layer.focus)
                    border.color: style.colors.outline.focus
                    border.width: style.sizeTokens.outline.focus
                }
            }
            pressed.background.color: style.stateLayer(
                                          style.colors.surface.container,
                                          style.colors.action.primary.container,
                                          style.stateTokens.layer.pressed)
            checked.background.color: style.stateLayer(
                                          style.colors.surface.container,
                                          style.colors.action.primary.container,
                                          style.stateTokens.layer.selected)
            highlighted.background.color: style.stateLayer(
                                              style.colors.surface.container,
                                              style.colors.action.primary.container,
                                              style.stateTokens.layer.selected)
            disabled {
                background.color: Qt.alpha(style.colors.surface.container, 0)
                text.color: style.colors.content.disabled
                checked {
                    background.color: Qt.alpha(style.colors.surface.container, 0)
                    text.color: style.colors.content.disabled
                }
            }
        }
    }

    StyleVariation {
        name: "small"
        control {
            background.implicitHeight: style.sizeTokens.control.small
            leftPadding: style.spacingTokens.md
            rightPadding: style.spacingTokens.md
        }
    }

    StyleVariation {
        name: "large"
        control {
            background.implicitHeight: style.sizeTokens.control.large
            leftPadding: style.spacingTokens.xl2
            rightPadding: style.spacingTokens.xl2
        }
        control.background.implicitWidth: style.sizeTokens.control.large
    }

    StyleVariation {
        name: "loading"
        control {
            background.opacity: 0.72
            text.color: style.disabledContent(style.colors.action.primary.container,
                                              style.colors.action.primary.content)
        }
    }

    StyleVariation {
        name: "success"
        textField {
            background.border.color: style.colors.status.success.outline
            focused {
                background {
                    border.color: style.colors.status.success.outline
                    border.width: style.sizeTokens.outline.focus
                }
            }
        }
    }

    StyleVariation {
        name: "warning"
        textField {
            background.border.color: style.colors.status.warning.outline
            focused {
                background {
                    border.color: style.colors.status.warning.outline
                    border.width: style.sizeTokens.outline.focus
                }
            }
        }
    }

    StyleVariation {
        name: "error"
        textField {
            background.border.color: style.colors.status.error.outline
            focused {
                background {
                    border.color: style.colors.status.error.outline
                    border.width: style.sizeTokens.outline.focus
                }
            }
        }
    }

    StyleVariation {
        name: "indeterminate"
        checkBox {
            indicator {
                color: style.colors.action.primary.container
                border.color: style.colors.action.primary.outline
                foreground {
                    visible: true
                    margins: style.spacingTokens.xxs
                    radius: style.radiusTokens.full
                    color: style.colors.action.primary.content
                    image.source: ""
                }
            }
            hovered.indicator.color: style.stateLayer(
                                         style.colors.action.primary.container,
                                         style.colors.action.primary.content,
                                         style.stateTokens.layer.hover)
            focused {
                indicator {
                    color: style.stateLayer(style.colors.action.primary.container,
                                            style.colors.action.primary.content,
                                            style.stateTokens.layer.focus)
                    border.color: style.colors.outline.focus
                    border.width: style.sizeTokens.outline.focus
                }
            }
            pressed.indicator.color: style.stateLayer(
                                         style.colors.action.primary.container,
                                         style.colors.action.primary.content,
                                         style.stateTokens.layer.pressed)
            checked.indicator.color: style.stateLayer(
                                         style.colors.action.primary.container,
                                         style.colors.action.primary.content,
                                         style.stateTokens.layer.selected)
            highlighted.indicator.color: style.stateLayer(
                                             style.colors.action.primary.container,
                                             style.colors.action.primary.content,
                                             style.stateTokens.layer.selected)
            disabled {
                indicator {
                    color: style.disabledContainer(style.colors.action.primary.container,
                                                   style.colors.action.primary.content)
                    border.color: style.colors.outline.subtle
                    foreground.color: style.disabledContent(
                                          style.colors.action.primary.container,
                                          style.colors.action.primary.content)
                }
                text.color: style.disabledContent(style.colors.surface.container,
                                                  style.colors.content.primary)
            }
        }
    }
}
