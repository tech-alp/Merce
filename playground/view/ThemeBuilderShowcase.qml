import QtQuick
import Qt.labs.StyleKit as SK
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
    readonly property bool authoringEnabled: false

    readonly property var fontOptions: [
        { "value": "Inter", "label": "Inter" },
        { "value": "Roboto Mono", "label": "Roboto Mono" },
        { "value": "sans-serif", "label": "System Sans" },
        { "value": "serif", "label": "System Serif" },
        { "value": "monospace", "label": "System Mono" }
    ]

    readonly property var colorGroups: [
        {
            "key": "surface",
            "title": qsTr("Surface"),
            "description": qsTr("Canvas, containers, floating layers, and effects."),
            "tokens": [
                { "key": "canvas", "usage": qsTr("Application canvas") },
                { "key": "container", "usage": qsTr("Default component container") },
                { "key": "containerRaised", "usage": qsTr("Raised container") },
                { "key": "containerSunken", "usage": qsTr("Sunken container") },
                { "key": "containerTinted", "usage": qsTr("Tinted container") },
                { "key": "floating", "usage": qsTr("Popup and dialog surface") },
                { "key": "scrim", "usage": qsTr("Modal scrim") },
                { "key": "inverse", "usage": qsTr("Inverse surface") },
                { "key": "shadow", "usage": qsTr("Shadow color") }
            ]
        },
        {
            "key": "content",
            "title": qsTr("Content"),
            "description": qsTr("Text, icons, links, and content hierarchy."),
            "tokens": [
                { "key": "primary", "usage": qsTr("Primary content") },
                { "key": "secondary", "usage": qsTr("Secondary content") },
                { "key": "tertiary", "usage": qsTr("Low-emphasis content") },
                { "key": "inverse", "usage": qsTr("Content on inverse surfaces") },
                { "key": "disabled", "usage": qsTr("Disabled content") },
                { "key": "link", "usage": qsTr("Links and inline actions") }
            ]
        },
        {
            "key": "action",
            "title": qsTr("Action"),
            "description": qsTr("Container, content, and outline roles for commands."),
            "tokens": [
                { "key": "primary.container", "usage": qsTr("Primary action container") },
                { "key": "primary.content", "usage": qsTr("Content on primary action") },
                { "key": "primary.outline", "usage": qsTr("Primary action outline") },
                { "key": "secondary.container", "usage": qsTr("Secondary action container") },
                { "key": "secondary.content", "usage": qsTr("Content on secondary action") },
                { "key": "secondary.outline", "usage": qsTr("Secondary action outline") },
                { "key": "destructive.container", "usage": qsTr("Destructive action container") },
                { "key": "destructive.content", "usage": qsTr("Content on destructive action") },
                { "key": "destructive.outline", "usage": qsTr("Destructive action outline") }
            ]
        },
        {
            "key": "status",
            "title": qsTr("Status"),
            "description": qsTr("Container, content, and outline roles for feedback."),
            "tokens": [
                { "key": "success.container", "usage": qsTr("Success feedback container") },
                { "key": "success.content", "usage": qsTr("Success feedback content") },
                { "key": "success.outline", "usage": qsTr("Success feedback outline") },
                { "key": "warning.container", "usage": qsTr("Warning feedback container") },
                { "key": "warning.content", "usage": qsTr("Warning feedback content") },
                { "key": "warning.outline", "usage": qsTr("Warning feedback outline") },
                { "key": "error.container", "usage": qsTr("Error feedback container") },
                { "key": "error.content", "usage": qsTr("Error feedback content") },
                { "key": "error.outline", "usage": qsTr("Error feedback outline") },
                { "key": "info.container", "usage": qsTr("Information feedback container") },
                { "key": "info.content", "usage": qsTr("Information feedback content") },
                { "key": "info.outline", "usage": qsTr("Information feedback outline") },
                { "key": "neutral.container", "usage": qsTr("Neutral feedback container") },
                { "key": "neutral.content", "usage": qsTr("Neutral feedback content") },
                { "key": "neutral.outline", "usage": qsTr("Neutral feedback outline") }
            ]
        },
        {
            "key": "outline",
            "title": qsTr("Outline"),
            "description": qsTr("Dividers, emphasized boundaries, and focus rings."),
            "tokens": [
                { "key": "subtle", "usage": qsTr("Default divider and boundary") },
                { "key": "strong", "usage": qsTr("Emphasized boundary") },
                { "key": "focus", "usage": qsTr("Focus ring") }
            ]
        }
    ]

    function colorLabel(value) {
        const text = String(value || "").trim()
        if (/^#[0-9a-fA-F]{6}$/.test(text))
            return text.toUpperCase()

        const alpha = Math.round(value.a * 255)
        const red = Math.round(value.r * 255)
        const green = Math.round(value.g * 255)
        const blue = Math.round(value.b * 255)
        return "#" + (alpha < 255 ? hexByte(alpha) : "")
                + hexByte(red) + hexByte(green) + hexByte(blue)
    }

    function colorPath(group, token) {
        return group + "." + token
    }

    function colorValue(path, fallback) {
        return colorEdits[path] || colorLabel(fallback)
    }

    function currentColor(group, token) {
        let value = Theme.colors[group]
        for (const segment of token.split(".")) {
            if (!value)
                return "#000000"
            value = value[segment]
        }
        return value || "#000000"
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
                assignNestedColor(section, token.key, colorValue(path, currentColor(group.key, token.key)))
            }
            manifest[group.key] = section
        }
        return manifest
    }

    function assignNestedColor(section, token, value) {
        const segments = token.split(".")
        let cursor = section
        for (let i = 0; i < segments.length - 1; ++i) {
            const segment = segments[i]
            if (!cursor[segment])
                cursor[segment] = {}
            cursor = cursor[segment]
        }
        cursor[segments[segments.length - 1]] = value
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
        if (!authoringEnabled) {
            statusOk = false
            statusMessage = qsTr("Read-only: tenant-brand v1 accepts one seed; resolved themes cannot be authored here.")
            return
        }
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
        color: Theme.colors.content.primary
        wrapMode: Text.WordWrap
    }

    component SectionCaption: AppLabel {
        textType: AppLabel.Caption
        color: Theme.colors.content.secondary
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

        SK.ComboBox {
            width: parent.width
            model: root.fontOptions
            textRole: "label"
            valueRole: "value"
            currentValue: parent.selectedValue
            onActivated: {
                parent.selected(String(currentValue))
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
                    text: qsTr("Theme Inspector")
                    color: Theme.colors.content.primary
                    wrapMode: Text.WordWrap
                }

                SectionCaption {
                    width: parent.width
                    text: qsTr("Read-only resolved-theme inspector. tenant-brand v1 accepts one seed; direct semantic-role authoring is disabled.")
                }
            }

            Row {
                width: parent.width
                spacing: Theme.spacing.md

                SK.TextField {
                    width: Math.min(360, parent.width - applyButton.width - parent.spacing)
                    text: root.themeName
                    placeholderText: qsTr("Theme name")
                    onTextEdited: {
                        root.themeName = text
                    }
                }

                MButton {
                    id: applyButton
                    text: qsTr("Save & Apply")
                    enabled: root.authoringEnabled
                    onClicked: root.saveAndApply()
                }
            }

            MBadge {
                text: root.statusMessage
                variant: root.statusOk ? MBadge.Success : MBadge.Error
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
                                color: Theme.colors.content.primary
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
                                    enabled: root.authoringEnabled
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
                            color: Theme.colors.outline.subtle
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
                    color: root.colorValue("surface.container", Theme.colors.surface.container)
                    border.width: 1
                    border.color: root.colorValue("outline.focus", Theme.colors.outline.focus)

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
                            color: root.colorValue("content.primary", Theme.colors.content.primary)
                            font.family: FoundationFonts.resolveFamily(root.displayFont)
                            font.pixelSize: Theme.typography.sizeLarge
                            font.weight: Theme.typography.weightSemibold
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            text: qsTr("Semantic colors and font roles.")
                            color: root.colorValue("content.secondary", Theme.colors.content.secondary)
                            font.family: FoundationFonts.resolveFamily(root.bodyFont)
                            font.pixelSize: Theme.typography.sizeSmall
                            wrapMode: Text.WordWrap
                        }

                        Rectangle {
                            width: parent.width
                            height: Theme.spacing.touchTargetCompact
                            radius: Theme.radius.button
                            color: root.colorValue("action.primary.container", Theme.colors.action.primary.container)

                            Text {
                                anchors.centerIn: parent
                                text: qsTr("Primary")
                                color: Theme.colors.action.primary.content
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
                        color: Theme.colors.content.primary
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
