import QtQuick
import Merce.Theme
import Merce.Foundation
import Merce.Controls

Item {
    id: root
    objectName: "merce.playground.showcase.themeBuilder"

    implicitHeight: page.implicitHeight
    height: implicitHeight

    property var colorEdits: ({})
    property string themeName: "Custom Theme"
    property string displayFont: Theme.typography.fontDisplay
    property string bodyFont: Theme.typography.fontBody
    property string monoFont: Theme.typography.fontMono
    property string statusMessage: ""
    property bool statusOk: true

    readonly property var fontOptions: [
        { "value": "Inter", "label": "Inter" },
        { "value": "Roboto Mono", "label": "Roboto Mono" },
        { "value": "sans-serif", "label": "System Sans" },
        { "value": "serif", "label": "System Serif" },
        { "value": "monospace", "label": "System Mono" }
    ]

    readonly property var colorGroups: [
        {
            "key": "text",
            "title": qsTr("Text"),
            "description": qsTr("Content, links, inverse text, and disabled text."),
            "tokens": [
                { "key": "primary", "usage": qsTr("Main content text") },
                { "key": "secondary", "usage": qsTr("Secondary content text") },
                { "key": "tertiary", "usage": qsTr("Low-emphasis supporting text") },
                { "key": "inverse", "usage": qsTr("Text on dark or strong surfaces") },
                { "key": "disabled", "usage": qsTr("Disabled and unavailable text") },
                { "key": "link", "usage": qsTr("Links and inline actions") },
                { "key": "linkHover", "usage": qsTr("Hovered links and inline actions") }
            ]
        },
        {
            "key": "background",
            "title": qsTr("Background"),
            "description": qsTr("Application backgrounds, panels, and interaction states."),
            "tokens": [
                { "key": "base", "usage": qsTr("Application background") },
                { "key": "surface", "usage": qsTr("Panel and card background") },
                { "key": "elevated", "usage": qsTr("Raised panel background") },
                { "key": "hover", "usage": qsTr("Hovered neutral backgrounds") },
                { "key": "pressed", "usage": qsTr("Pressed neutral backgrounds") },
                { "key": "tinted", "usage": qsTr("Subtle tinted surfaces") },
                { "key": "overlay", "usage": qsTr("Modal and scrim overlays") }
            ]
        },
        {
            "key": "border",
            "title": qsTr("Border"),
            "description": qsTr("Dividers, outlines, focus rings, and semantic borders."),
            "tokens": [
                { "key": "base", "usage": qsTr("Default dividers and outlines") },
                { "key": "strong", "usage": qsTr("Higher contrast outlines") },
                { "key": "focus", "usage": qsTr("Focus ring and active outlines") },
                { "key": "error", "usage": qsTr("Error borders") },
                { "key": "success", "usage": qsTr("Success borders") }
            ]
        },
        {
            "key": "action",
            "title": qsTr("Action"),
            "description": qsTr("Interactive colors for primary, secondary, and disabled controls."),
            "tokens": [
                { "key": "primary", "usage": qsTr("Primary actions and strong brand affordances") },
                { "key": "primaryHover", "usage": qsTr("Primary action hover") },
                { "key": "primaryPressed", "usage": qsTr("Primary action pressed") },
                { "key": "primarySubtle", "usage": qsTr("Subtle primary backgrounds") },
                { "key": "secondary", "usage": qsTr("Secondary action backgrounds") },
                { "key": "secondaryHover", "usage": qsTr("Secondary action hover") },
                { "key": "secondaryPressed", "usage": qsTr("Secondary action pressed") },
                { "key": "disabled", "usage": qsTr("Disabled action background") }
            ]
        },
        {
            "key": "status",
            "title": qsTr("Status"),
            "description": qsTr("Success, warning, error, and information states."),
            "tokens": [
                { "key": "success", "usage": qsTr("Success foreground and icon") },
                { "key": "successSubtle", "usage": qsTr("Success soft background") },
                { "key": "warning", "usage": qsTr("Warning foreground and icon") },
                { "key": "warningSubtle", "usage": qsTr("Warning soft background") },
                { "key": "error", "usage": qsTr("Error foreground and icon") },
                { "key": "errorSubtle", "usage": qsTr("Error soft background") },
                { "key": "info", "usage": qsTr("Information foreground and icon") },
                { "key": "infoSubtle", "usage": qsTr("Information soft background") }
            ]
        },
        {
            "key": "surface",
            "title": qsTr("Surface"),
            "description": qsTr("Foundation surface aliases used by reusable surfaces."),
            "tokens": [
                { "key": "base", "usage": qsTr("Default reusable surface") },
                { "key": "tinted", "usage": qsTr("Tinted reusable surface") },
                { "key": "raised", "usage": qsTr("Raised reusable surface") }
            ]
        }
    ]

    function colorLabel(value) {
        const text = String(value || "").trim()
        if (/^#[0-9a-fA-F]{6}$/.test(text))
            return text.toUpperCase()

        const red = Math.round(value.r * 255)
        const green = Math.round(value.g * 255)
        const blue = Math.round(value.b * 255)
        return "#" + hexByte(red) + hexByte(green) + hexByte(blue)
    }

    function colorPath(group, token) {
        return group + "." + token
    }

    function colorValue(path, fallback) {
        return colorEdits[path] || colorLabel(fallback)
    }

    function currentColor(group, token) {
        const section = Theme.colors[group]
        return section ? section[token] : "#000000"
    }

    function hexByte(value) {
        return Math.max(0, Math.min(255, value)).toString(16).padStart(2, "0").toUpperCase()
    }

    function setColor(path, value) {
        const next = Object.assign({}, colorEdits)
        const text = String(value || "").trim()
        next[path] = /^#[0-9a-fA-F]{6}$/.test(text) ? text.toUpperCase() : colorLabel(value)
        colorEdits = next
    }

    function colorsManifest() {
        const manifest = {}
        for (const group of colorGroups) {
            const section = {}
            for (const token of group.tokens) {
                const path = colorPath(group.key, token.key)
                section[token.key] = colorValue(path, currentColor(group.key, token.key))
            }
            manifest[group.key] = section
        }
        return manifest
    }

    function spacingManifest() {
        return {
            "base": Theme.spacing.base,
            "none": Theme.spacing.none,
            "xxs": Theme.spacing.xxs,
            "xs": Theme.spacing.xs,
            "sm": Theme.spacing.sm,
            "md": Theme.spacing.md,
            "lg": Theme.spacing.lg,
            "xl": Theme.spacing.xl,
            "xl2": Theme.spacing.xl2,
            "xl3": Theme.spacing.xl3,
            "xl4": Theme.spacing.xl4,
            "xl5": Theme.spacing.xl5,
            "xl6": Theme.spacing.xl6,
            "componentGap": Theme.spacing.componentGap,
            "sectionGap": Theme.spacing.sectionGap,
            "pagePadding": Theme.spacing.pagePadding,
            "touchTarget": Theme.spacing.touchTarget,
            "touchTargetCompact": Theme.spacing.touchTargetCompact,
            "gridGap": Theme.spacing.gridGap,
            "stackGap": Theme.spacing.stackGap,
            "inlineGap": Theme.spacing.inlineGap
        }
    }

    function radiusManifest() {
        return {
            "none": Theme.radius.none,
            "small": Theme.radius.small,
            "medium": Theme.radius.medium,
            "large": Theme.radius.large,
            "xlarge": Theme.radius.xlarge,
            "xxlarge": Theme.radius.xxlarge,
            "full": Theme.radius.full,
            "button": Theme.radius.button,
            "input": Theme.radius.input,
            "card": Theme.radius.card,
            "badge": Theme.radius.badge,
            "dialog": Theme.radius.dialog,
            "tooltip": Theme.radius.tooltip
        }
    }

    function typographyManifest() {
        return {
            "displayFont": displayFont,
            "bodyFont": bodyFont,
            "monoFont": monoFont,
            "displayFontFallback": displayFont,
            "bodyFontFallback": bodyFont,
            "sizeXSmall": Theme.typography.sizeXSmall,
            "sizeSmall": Theme.typography.sizeSmall,
            "sizeMedium": Theme.typography.sizeMedium,
            "sizeLarge": Theme.typography.sizeLarge,
            "sizeXLarge": Theme.typography.sizeXLarge,
            "size2XLarge": Theme.typography.size2XLarge,
            "size3XLarge": Theme.typography.size3XLarge,
            "size4XLarge": Theme.typography.size4XLarge,
            "size5XLarge": Theme.typography.size5XLarge,
            "size6XLarge": Theme.typography.size6XLarge,
            "size7XLarge": Theme.typography.size7XLarge,
            "weightRegular": Theme.typography.weightRegular,
            "weightMedium": Theme.typography.weightMedium,
            "weightSemibold": Theme.typography.weightSemibold,
            "weightBold": Theme.typography.weightBold,
            "leadingTight": Theme.typography.leadingTight,
            "leadingSnug": Theme.typography.leadingSnug,
            "leadingNormal": Theme.typography.leadingNormal,
            "leadingRelaxed": Theme.typography.leadingRelaxed,
            "trackingTight": Theme.typography.trackingTight,
            "trackingNormal": Theme.typography.trackingNormal,
            "trackingWide": Theme.typography.trackingWide,
            "trackingWider": Theme.typography.trackingWider,
            "trackingWidest": Theme.typography.trackingWidest
        }
    }

    function saveAndApply() {
        if (!playgroundThemeBuilder) {
            statusOk = false
            statusMessage = qsTr("Theme builder service is unavailable.")
            return
        }

        const result = playgroundThemeBuilder.saveTheme({
            "theme": themeName,
            "displayName": themeName,
            "mode": "custom",
            "colors": colorsManifest(),
            "spacing": spacingManifest(),
            "radius": radiusManifest(),
            "typography": typographyManifest()
        })

        if (!result.ok) {
            statusOk = false
            statusMessage = result.error || qsTr("Could not save theme.")
            return
        }

        const added = Theme.addThemeSource(result.indexPath)
        if (!added && !Theme.reloadThemes()) {
            statusOk = false
            statusMessage = qsTr("Theme source could not be loaded.")
            return
        }

        if (!Theme.reloadThemes() || !Theme.setTheme(result.theme, result.mode)) {
            statusOk = false
            statusMessage = qsTr("Theme was saved but could not be applied.")
            return
        }

        statusOk = true
        statusMessage = qsTr("Applied %1").arg(result.displayName)
    }

    component SectionTitle: AppLabel {
        textType: AppLabel.H4
        color: Theme.colors.text.primary
        wrapMode: Text.WordWrap
    }

    component SectionCaption: AppLabel {
        textType: AppLabel.Caption
        color: Theme.colors.text.secondary
        wrapMode: Text.WordWrap
    }

    component Panel: Surface {
        default property alias content: panelColumn.data

        width: parent ? parent.width : 320
        height: panelColumn.implicitHeight + Theme.spacing.xl2
        surfaceType: Surface.Default
        radiusValue: Theme.radius.large

        Column {
            id: panelColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Theme.spacing.xl
            }
            spacing: Theme.spacing.lg
        }
    }

    component FontField: Column {
        required property string label
        property string selectedValue: "Inter"
        signal selected(string value)

        width: parent ? parent.width : 240
        spacing: Theme.spacing.xxs

        SectionCaption {
            width: parent.width
            text: parent.label
        }

        MSelect {
            width: parent.width
            options: root.fontOptions
            selectedValue: parent.selectedValue
            onSelected: function(value) {
                parent.selected(String(value))
            }
        }
    }

    Column {
        id: page
        width: root.width
        spacing: Theme.spacing.xl

        Panel {
            Column {
                width: parent.width
                spacing: Theme.spacing.xxs

                AppLabel {
                    width: parent.width
                    textType: AppLabel.H2
                    text: qsTr("Theme Builder")
                    color: Theme.colors.text.primary
                    wrapMode: Text.WordWrap
                }

                SectionCaption {
                    width: parent.width
                    text: qsTr("Create a custom Merce theme pack from semantic colors and bundled font families.")
                }
            }

            Row {
                width: parent.width
                spacing: Theme.spacing.md

                MInput {
                    width: Math.min(360, parent.width - applyButton.width - parent.spacing)
                    text: root.themeName
                    placeholder: qsTr("Theme name")
                    onInputTextChanged: function(value) {
                        root.themeName = value
                    }
                }

                MButton {
                    id: applyButton
                    text: qsTr("Save & Apply")
                    icon.name: "material:save"
                    onClicked: root.saveAndApply()
                }
            }

            MBadge {
                text: root.statusMessage
                variant: root.statusOk ? "success" : "error"
                visible: root.statusMessage.length > 0
            }
        }

        Panel {
            Column {
                width: parent.width
                spacing: Theme.spacing.xxs

                SectionTitle {
                    width: parent.width
                    text: qsTr("Color Tokens")
                }

                SectionCaption {
                    width: parent.width
                    text: qsTr("Edit the MerceColors semantic groups. The generated manifest uses the same text, background, border, action, status, and surface contract.")
                }
            }

            Column {
                width: parent.width
                spacing: Theme.spacing.xl

                Repeater {
                    model: root.colorGroups

                    delegate: Column {
                        id: colorGroupDelegate

                        required property int index
                        required property var modelData

                        width: parent.width
                        spacing: Theme.spacing.sm

                        Column {
                            width: parent.width
                            spacing: Theme.spacing.xxs

                            AppLabel {
                                width: parent.width
                                textType: AppLabel.H4
                                text: colorGroupDelegate.modelData.title
                                color: Theme.colors.text.primary
                                wrapMode: Text.WordWrap
                            }

                            SectionCaption {
                                width: parent.width
                                text: colorGroupDelegate.modelData.description
                            }
                        }

                        Flow {
                            width: parent.width
                            spacing: Theme.spacing.lg

                            Repeater {
                                model: colorGroupDelegate.modelData.tokens

                                delegate: ColorTokenCard {
                                    required property var modelData

                                    readonly property string resolvedTokenPath: root.colorPath(colorGroupDelegate.modelData.key, modelData.key)

                                    width: Math.min(280, parent.width)
                                    tokenPath: resolvedTokenPath
                                    usage: modelData.usage
                                    selectedColor: root.colorValue(resolvedTokenPath, root.currentColor(colorGroupDelegate.modelData.key, modelData.key))
                                    onColorEdited: function(value) { root.setColor(resolvedTokenPath, value) }
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: Theme.colors.border.base
                            opacity: 0.7
                            visible: index < root.colorGroups.length - 1
                        }
                    }
                }
            }
        }

        Panel {
            Column {
                width: parent.width
                spacing: Theme.spacing.xxs

                SectionTitle {
                    width: parent.width
                    text: qsTr("Fonts")
                }

                SectionCaption {
                    width: parent.width
                    text: qsTr("MVP uses bundled and generic Qt font families. TTF/OTF import is a follow-up.")
                }
            }

            Flow {
                width: parent.width
                spacing: Theme.spacing.md

                FontField {
                    width: Math.min(280, parent.width)
                    label: qsTr("Display")
                    selectedValue: root.displayFont
                    onSelected: function(value) { root.displayFont = value }
                }

                FontField {
                    width: Math.min(280, parent.width)
                    label: qsTr("Body")
                    selectedValue: root.bodyFont
                    onSelected: function(value) { root.bodyFont = value }
                }

                FontField {
                    width: Math.min(280, parent.width)
                    label: qsTr("Mono")
                    selectedValue: root.monoFont
                    onSelected: function(value) { root.monoFont = value }
                }
            }
        }

        Panel {
            Column {
                width: parent.width
                spacing: Theme.spacing.xxs

                SectionTitle {
                    width: parent.width
                    text: qsTr("Preview")
                }

                SectionCaption {
                    width: parent.width
                    text: qsTr("Save and apply the custom theme to refresh the full playground runtime.")
                }
            }

            Row {
                width: parent.width
                spacing: Theme.spacing.md

                Rectangle {
                    width: 220
                    height: 132
                    radius: Theme.radius.large
                    color: root.colorValue("background.surface", Theme.colors.background.surface)
                    border.width: 1
                    border.color: root.colorValue("border.focus", Theme.colors.border.focus)

                    Column {
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: Theme.spacing.md
                        }
                        spacing: Theme.spacing.sm

                        Text {
                            width: parent.width
                            text: qsTr("Merce Preview")
                            color: root.colorValue("text.primary", Theme.colors.text.primary)
                            font.family: FoundationFonts.resolveFamily(root.displayFont)
                            font.pixelSize: Theme.typography.sizeLarge
                            font.weight: Theme.typography.weightSemibold
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            text: qsTr("Semantic colors and font roles.")
                            color: root.colorValue("text.secondary", Theme.colors.text.secondary)
                            font.family: FoundationFonts.resolveFamily(root.bodyFont)
                            font.pixelSize: Theme.typography.sizeSmall
                            wrapMode: Text.WordWrap
                        }

                        Rectangle {
                            width: parent.width
                            height: Theme.spacing.touchTargetCompact
                            radius: Theme.radius.button
                            color: root.colorValue("action.primary", Theme.colors.action.primary)

                            Text {
                                anchors.centerIn: parent
                                text: qsTr("Primary")
                                color: Theme.colors.text.inverse
                                font.family: FoundationFonts.resolveFamily(root.bodyFont)
                                font.pixelSize: Theme.typography.sizeSmall
                                font.weight: Theme.typography.weightSemibold
                            }
                        }
                    }
                }

                Column {
                    width: Math.max(220, parent.width - 220 - Theme.spacing.md)
                    spacing: Theme.spacing.sm

                    AppLabel {
                        width: parent.width
                        textType: AppLabel.Body
                        text: qsTr("Current runtime: %1 / %2").arg(Theme.activeBrand).arg(Theme.activeMode === "" ? "default" : Theme.activeMode)
                        color: Theme.colors.text.primary
                        wrapMode: Text.WordWrap
                    }

                    SectionCaption {
                        width: parent.width
                        text: qsTr("Output root: %1").arg(playgroundThemeBuilder ? playgroundThemeBuilder.outputRoot : "-")
                    }
                }
            }
        }
    }
}
