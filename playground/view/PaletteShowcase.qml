import QtQuick
import Qt.labs.StyleKit as SK
import Merce.Theme
import Merce.Foundation
import Merce.Controls

Item {
    id: root
    objectName: "merce.playground.showcase.palette"

    implicitHeight: page.implicitHeight
    height: implicitHeight

    readonly property int wideBreakpoint: 1180
    readonly property int mediumBreakpoint: 760
    readonly property real cardGap: Theme.spacing.md

    function colorLabel(value) {
        const alpha = Math.round(value.a * 255)
        const red = Math.round(value.r * 255)
        const green = Math.round(value.g * 255)
        const blue = Math.round(value.b * 255)
        return "#" + (alpha < 255 ? hexByte(alpha) : "")
                + hexByte(red) + hexByte(green) + hexByte(blue)
    }

    function breakableTokenLabel(value) {
        return String(value).split(".").join(".\u200B")
    }

    function contrastRatio(foreground, background) {
        const foregroundLuminance = relativeLuminance(foreground)
        const backgroundLuminance = relativeLuminance(background)
        const lighter = Math.max(foregroundLuminance, backgroundLuminance)
        const darker = Math.min(foregroundLuminance, backgroundLuminance)
        return (lighter + 0.05) / (darker + 0.05)
    }

    function contrastThreshold(kind) {
        if (kind === "largeText" || kind === "nonText")
            return 3
        return 4.5
    }

    function gradeFor(ratio, kind) {
        if (kind === "nonText")
            return ratio >= 3 ? "AA" : "Fail"
        if (ratio >= 7)
            return "AAA"
        if (ratio >= contrastThreshold(kind))
            return "AA"
        return "Fail"
    }

    function categoryCardWidth(availableWidth) {
        const columns = availableWidth >= root.wideBreakpoint ? 3 : availableWidth >= root.mediumBreakpoint ? 2 : 1
        return Math.floor((availableWidth - root.cardGap * (columns - 1)) / columns)
    }

    function metricCardWidth(availableWidth) {
        const columns = availableWidth >= root.wideBreakpoint ? 4 : availableWidth >= root.mediumBreakpoint ? 2 : 1
        return Math.floor((availableWidth - root.cardGap * (columns - 1)) / columns)
    }

    function previewCardWidth(availableWidth) {
        const columns = availableWidth >= root.wideBreakpoint ? 4 : availableWidth >= root.mediumBreakpoint ? 2 : 1
        return Math.floor((availableWidth - root.cardGap * (columns - 1)) / columns)
    }

    function hexByte(value) {
        return Math.max(0, Math.min(255, value)).toString(16).padStart(2, "0").toUpperCase()
    }

    function linearChannel(channel) {
        return channel <= 0.04045 ? channel / 12.92 : Math.pow((channel + 0.055) / 1.055, 2.4)
    }

    function relativeLuminance(value) {
        return 0.2126 * linearChannel(value.r)
                + 0.7152 * linearChannel(value.g)
                + 0.0722 * linearChannel(value.b)
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

    component ColorSwatch: Rectangle {
        required property color swatchColor

        width: 44
        height: 44
        radius: Theme.radius.medium
        color: swatchColor
        border.width: 1
        border.color: Theme.colors.outline.subtle
    }

    component ContrastBadge: Rectangle {
        required property color foregroundColor
        required property color backgroundColor
        property string kind: "text"

        readonly property real ratio: root.contrastRatio(foregroundColor, backgroundColor)
        readonly property string grade: root.gradeFor(ratio, kind)

        implicitWidth: badgeText.implicitWidth + Theme.spacing.sm
        implicitHeight: 26
        radius: Theme.radius.full
        color: grade === "Fail" ? Theme.colors.status.error.container : Theme.colors.status.success.container
        border.width: 1
        border.color: grade === "Fail" ? Theme.colors.status.error.outline : Theme.colors.status.success.outline

        AppLabel {
            id: badgeText
            anchors.centerIn: parent
            textType: AppLabel.Caption
            text: parent.grade + " " + parent.ratio.toFixed(2)
            color: parent.grade === "Fail" ? Theme.colors.status.error.content : Theme.colors.status.success.content
            wrapMode: Text.NoWrap
            maximumLineCount: 1
        }
    }

    component TokenRow: Item {
        required property string label
        required property color swatchColor
        property string usage: ""
        property bool showContrast: false
        property color contrastForeground: Theme.colors.content.primary
        property color contrastBackground: swatchColor
        property string contrastKind: "text"

        width: parent ? parent.width : 320
        height: Math.max(58, tokenRow.implicitHeight)

        Row {
            id: tokenRow
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            spacing: Theme.spacing.sm

            ColorSwatch {
                swatchColor: parent.parent.swatchColor
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                width: Math.max(120, parent.width - 44 - Theme.spacing.sm - valueColumn.width - Theme.spacing.sm)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacing.xxs

                AppLabel {
                    width: parent.width
                    textType: AppLabel.Caption
                    text: root.breakableTokenLabel(label)
                    color: Theme.colors.content.primary
                    wrapMode: Text.WordWrap
                    textFormat: Text.PlainText
                }

                SectionCaption {
                    width: parent.width
                    text: usage
                    visible: usage.length > 0
                }
            }

            Column {
                id: valueColumn
                width: Math.max(84, contrastBadge.visible ? contrastBadge.implicitWidth : 84)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacing.xxs

                AppLabel {
                    width: parent.width
                    textType: AppLabel.Caption
                    text: root.colorLabel(swatchColor)
                    color: Theme.colors.content.secondary
                    horizontalAlignment: Text.AlignRight
                    wrapMode: Text.NoWrap
                    maximumLineCount: 1
                }

                ContrastBadge {
                    id: contrastBadge
                    anchors.right: parent.right
                    visible: showContrast
                    foregroundColor: contrastForeground
                    backgroundColor: contrastBackground
                    kind: contrastKind
                }
            }
        }
    }

    component TokenGroup: Surface {
        required property string title
        property string subtitle: ""
        default property alias content: tokenColumn.data

        width: root.categoryCardWidth(parent ? parent.width : root.width)
        height: tokenColumn.implicitHeight + Theme.spacing.xl2
        surfaceType: Surface.Default
        radiusValue: Theme.radius.large

        Column {
            id: tokenColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Theme.spacing.lg
            }
            spacing: Theme.spacing.md

            Column {
                width: parent.width
                spacing: Theme.spacing.xxs

                SectionTitle {
                    width: parent.width
                    text: title
                }

                SectionCaption {
                    width: parent.width
                    text: subtitle
                    visible: subtitle.length > 0
                }
            }
        }
    }

    component MetricCard: Surface {
        required property string label
        required property color foregroundColor
        required property color sampleBackgroundColor
        property string kind: "text"

        width: root.metricCardWidth(parent ? parent.width : root.width)
        height: metricColumn.implicitHeight + Theme.spacing.lg
        surfaceType: Surface.Default
        radiusValue: Theme.radius.large

        Column {
            id: metricColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Theme.spacing.md
            }
            spacing: Theme.spacing.sm

            Row {
                width: parent.width
                spacing: Theme.spacing.sm

                Rectangle {
                    width: 48
                    height: 36
                    radius: Theme.radius.medium
                    color: sampleBackgroundColor
                    border.width: 1
                    border.color: Theme.colors.outline.subtle

                    AppLabel {
                        anchors.centerIn: parent
                        textType: AppLabel.Caption
                        text: kind === "nonText" ? "" : "Aa"
                        color: foregroundColor
                        wrapMode: Text.NoWrap
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 22
                        height: 2
                        radius: 1
                        color: foregroundColor
                        visible: kind === "nonText"
                    }
                }

                Column {
                    width: parent.width - 48 - Theme.spacing.sm
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacing.xxs

                    AppLabel {
                        width: parent.width
                        textType: AppLabel.Caption
                        text: label
                        color: Theme.colors.content.primary
                        wrapMode: Text.WordWrap
                    }

                    SectionCaption {
                        width: parent.width
                        text: kind === "nonText" ? "WCAG 1.4.11" : "WCAG 1.4.3"
                    }
                }
            }

            ContrastBadge {
                foregroundColor: parent.parent.foregroundColor
                backgroundColor: parent.parent.sampleBackgroundColor
                kind: parent.parent.kind
            }
        }
    }

    component InputPreview: Rectangle {
        property string text: ""
        property bool focused: false

        width: parent ? parent.width : 240
        height: Theme.spacing.touchTarget
        radius: Theme.radius.input
        color: Theme.colors.surface.container
        border.width: focused ? 2 : 1
        border.color: focused ? Theme.colors.outline.focus : Theme.colors.outline.subtle

        AppLabel {
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                leftMargin: Theme.spacing.md
                rightMargin: Theme.spacing.md
            }
            textType: AppLabel.Body
            text: parent.text
            color: Theme.colors.content.primary
            wrapMode: Text.NoWrap
            maximumLineCount: 1
        }
    }

    component PreviewCard: Surface {
        required property string title
        default property alias content: previewContent.data

        width: root.previewCardWidth(parent ? parent.width : root.width)
        height: previewContent.implicitHeight + Theme.spacing.xl2
        surfaceType: Surface.Default
        radiusValue: Theme.radius.large

        Column {
            id: previewContent
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Theme.spacing.lg
            }
            spacing: Theme.spacing.md

            SectionTitle {
                width: parent.width
                text: title
            }
        }
    }

    component AlertPreview: Rectangle {
        required property string label
        required property string iconName
        required property color accentColor
        required property color fillColor

        width: parent ? parent.width : 240
        height: 44
        radius: Theme.radius.medium
        color: fillColor
        border.width: 1
        border.color: accentColor

        Row {
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: Theme.spacing.md
            }
            spacing: Theme.spacing.sm

            AppIcon {
                anchors.verticalCenter: parent.verticalCenter
                name: iconName
                size: Theme.icons.small
                color: accentColor
            }

            AppLabel {
                width: parent.width - Theme.icons.small - Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                textType: AppLabel.Caption
                text: label
                color: accentColor
                wrapMode: Text.WordWrap
            }
        }
    }

    Column {
        id: page
        width: root.width
        spacing: Theme.spacing.xl

        Surface {
            width: parent.width
            height: headerColumn.implicitHeight + Theme.spacing.xl2
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large

            Column {
                id: headerColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.xl
                }
                spacing: Theme.spacing.sm

                Row {
                    width: parent.width
                    spacing: Theme.spacing.md

                    AppIcon {
                        name: "material:palette"
                        size: Theme.icons.large
                        color: Theme.colors.action.primary.container
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        width: parent.width - Theme.icons.large - Theme.spacing.md
                        spacing: Theme.spacing.xxs

                        AppLabel {
                            width: parent.width
                            textType: AppLabel.H2
                            text: "Colors"
                            color: Theme.colors.content.primary
                            wrapMode: Text.WordWrap
                        }

                        SectionCaption {
                            width: parent.width
                            text: "Semantic color tokens used across Merce components and patterns."
                        }
                    }
                }

                Row {
                    spacing: Theme.spacing.sm

                    MBadge {
                        text: Theme.activeBrand
                        variant: MBadge.Primary
                        size: MBadge.Small
                    }

                    MBadge {
                        text: Theme.activeMode === "" ? "default mode" : Theme.activeMode + " mode"
                        variant: MBadge.Neutral
                        size: MBadge.Small
                    }
                }
            }
        }

        Flow {
            width: parent.width
            spacing: root.cardGap

            TokenGroup {
                title: "Surface"
                subtitle: "Canvas, containers, floating layers, and effects"

                TokenRow {
                    label: "colors.surface.canvas"
                    swatchColor: Theme.colors.surface.canvas
                    usage: "Application canvas"
                    showContrast: true
                    contrastForeground: Theme.colors.content.primary
                }
                TokenRow { label: "colors.surface.container"; swatchColor: Theme.colors.surface.container; usage: "Default component container" }
                TokenRow { label: "colors.surface.containerRaised"; swatchColor: Theme.colors.surface.containerRaised; usage: "Raised container" }
                TokenRow { label: "colors.surface.containerSunken"; swatchColor: Theme.colors.surface.containerSunken; usage: "Sunken container" }
                TokenRow { label: "colors.surface.containerTinted"; swatchColor: Theme.colors.surface.containerTinted; usage: "Tinted container" }
                TokenRow { label: "colors.surface.floating"; swatchColor: Theme.colors.surface.floating; usage: "Popup and dialog surface" }
                TokenRow { label: "colors.surface.scrim"; swatchColor: Theme.colors.surface.scrim; usage: "Modal scrim" }
                TokenRow { label: "colors.surface.inverse"; swatchColor: Theme.colors.surface.inverse; usage: "Inverse surface" }
                TokenRow { label: "colors.surface.shadow"; swatchColor: Theme.colors.surface.shadow; usage: "Shadow color" }
            }

            TokenGroup {
                title: "Content"
                subtitle: "Text, icons, links, and content hierarchy"

                TokenRow {
                    label: "colors.content.primary"
                    swatchColor: Theme.colors.content.primary
                    usage: "Primary content"
                    showContrast: true
                    contrastForeground: Theme.colors.content.primary
                    contrastBackground: Theme.colors.surface.canvas
                }
                TokenRow {
                    label: "colors.content.secondary"
                    swatchColor: Theme.colors.content.secondary
                    usage: "Secondary content"
                    showContrast: true
                    contrastForeground: Theme.colors.content.secondary
                    contrastBackground: Theme.colors.surface.canvas
                }
                TokenRow { label: "colors.content.tertiary"; swatchColor: Theme.colors.content.tertiary; usage: "Low-emphasis content" }
                TokenRow { label: "colors.content.inverse"; swatchColor: Theme.colors.content.inverse; usage: "Content on inverse surfaces" }
                TokenRow { label: "colors.content.disabled"; swatchColor: Theme.colors.content.disabled; usage: "Disabled content" }
                TokenRow { label: "colors.content.link"; swatchColor: Theme.colors.content.link; usage: "Links and inline actions" }
            }

            TokenGroup {
                title: "Action"
                subtitle: "Container, content, and outline roles for commands"

                TokenRow {
                    label: "colors.action.primary.container"
                    swatchColor: Theme.colors.action.primary.container
                    usage: "Primary action container"
                    showContrast: true
                    contrastForeground: Theme.colors.action.primary.content
                }
                TokenRow { label: "colors.action.primary.content"; swatchColor: Theme.colors.action.primary.content; usage: "Content on primary action" }
                TokenRow {
                    label: "colors.action.primary.outline"
                    swatchColor: Theme.colors.action.primary.outline
                    usage: "Primary action outline"
                    showContrast: true
                    contrastForeground: Theme.colors.action.primary.outline
                    contrastBackground: Theme.colors.surface.canvas
                    contrastKind: "nonText"
                }
                TokenRow {
                    label: "colors.action.secondary.container"
                    swatchColor: Theme.colors.action.secondary.container
                    usage: "Secondary action container"
                    showContrast: true
                    contrastForeground: Theme.colors.action.secondary.content
                }
                TokenRow { label: "colors.action.secondary.content"; swatchColor: Theme.colors.action.secondary.content; usage: "Content on secondary action" }
                TokenRow { label: "colors.action.secondary.outline"; swatchColor: Theme.colors.action.secondary.outline; usage: "Secondary action outline" }
                TokenRow {
                    label: "colors.action.destructive.container"
                    swatchColor: Theme.colors.action.destructive.container
                    usage: "Destructive action container"
                    showContrast: true
                    contrastForeground: Theme.colors.action.destructive.content
                }
                TokenRow { label: "colors.action.destructive.content"; swatchColor: Theme.colors.action.destructive.content; usage: "Content on destructive action" }
                TokenRow { label: "colors.action.destructive.outline"; swatchColor: Theme.colors.action.destructive.outline; usage: "Destructive action outline" }
            }

            TokenGroup {
                title: "Status"
                subtitle: "Container, content, and outline roles for feedback"

                TokenRow {
                    label: "colors.status.success.container"
                    swatchColor: Theme.colors.status.success.container
                    usage: "Success feedback container"
                    showContrast: true
                    contrastForeground: Theme.colors.status.success.content
                }
                TokenRow { label: "colors.status.success.content"; swatchColor: Theme.colors.status.success.content; usage: "Success feedback content" }
                TokenRow { label: "colors.status.success.outline"; swatchColor: Theme.colors.status.success.outline; usage: "Success feedback outline" }
                TokenRow {
                    label: "colors.status.warning.container"
                    swatchColor: Theme.colors.status.warning.container
                    usage: "Warning feedback container"
                    showContrast: true
                    contrastForeground: Theme.colors.status.warning.content
                }
                TokenRow { label: "colors.status.warning.content"; swatchColor: Theme.colors.status.warning.content; usage: "Warning feedback content" }
                TokenRow { label: "colors.status.warning.outline"; swatchColor: Theme.colors.status.warning.outline; usage: "Warning feedback outline" }
                TokenRow {
                    label: "colors.status.error.container"
                    swatchColor: Theme.colors.status.error.container
                    usage: "Error feedback container"
                    showContrast: true
                    contrastForeground: Theme.colors.status.error.content
                }
                TokenRow { label: "colors.status.error.content"; swatchColor: Theme.colors.status.error.content; usage: "Error feedback content" }
                TokenRow { label: "colors.status.error.outline"; swatchColor: Theme.colors.status.error.outline; usage: "Error feedback outline" }
                TokenRow {
                    label: "colors.status.info.container"
                    swatchColor: Theme.colors.status.info.container
                    usage: "Information feedback container"
                    showContrast: true
                    contrastForeground: Theme.colors.status.info.content
                }
                TokenRow { label: "colors.status.info.content"; swatchColor: Theme.colors.status.info.content; usage: "Information feedback content" }
                TokenRow { label: "colors.status.info.outline"; swatchColor: Theme.colors.status.info.outline; usage: "Information feedback outline" }
                TokenRow {
                    label: "colors.status.neutral.container"
                    swatchColor: Theme.colors.status.neutral.container
                    usage: "Neutral feedback container"
                    showContrast: true
                    contrastForeground: Theme.colors.status.neutral.content
                }
                TokenRow { label: "colors.status.neutral.content"; swatchColor: Theme.colors.status.neutral.content; usage: "Neutral feedback content" }
                TokenRow { label: "colors.status.neutral.outline"; swatchColor: Theme.colors.status.neutral.outline; usage: "Neutral feedback outline" }
            }

            TokenGroup {
                title: "Outline"
                subtitle: "Dividers, emphasized boundaries, and focus rings"

                TokenRow { label: "colors.outline.subtle"; swatchColor: Theme.colors.outline.subtle; usage: "Default divider and boundary" }
                TokenRow { label: "colors.outline.strong"; swatchColor: Theme.colors.outline.strong; usage: "Emphasized boundary" }
                TokenRow {
                    label: "colors.outline.focus"
                    swatchColor: Theme.colors.outline.focus
                    usage: "Focus ring"
                    showContrast: true
                    contrastForeground: Theme.colors.outline.focus
                    contrastBackground: Theme.colors.surface.canvas
                    contrastKind: "nonText"
                }
            }
        }

        Surface {
            width: parent.width
            height: previewColumn.implicitHeight + Theme.spacing.xl2
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large

            Column {
                id: previewColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.xl
                }
                spacing: Theme.spacing.lg

                Column {
                    width: parent.width
                    spacing: Theme.spacing.xxs

                    SectionTitle {
                        width: parent.width
                        text: "Component Previews"
                    }

                    SectionCaption {
                        width: parent.width
                        text: "Representative component states using the active semantic color tokens."
                    }
                }

                Flow {
                    width: parent.width
                    spacing: root.cardGap

                    PreviewCard {
                        title: "Buttons"

                        SK.Button {
                            width: parent.width
                            text: "Primary Button"
                        }

                        SK.Button {
                            width: parent.width
                            text: "Secondary Button"
                            SK.StyleVariation.variations: ["secondary"]
                        }

                        SK.Button {
                            width: parent.width
                            text: "Outline Button"
                            SK.StyleVariation.variations: ["outline"]
                        }
                    }

                    PreviewCard {
                        title: "Inputs"

                        InputPreview { text: "Default input" }

                        InputPreview { text: "Focused input"; focused: true }

                        SK.TextField {
                            width: parent.width
                            text: "Error input"
                            readOnly: true
                            rightPadding: Theme.spacing.xl2
                            SK.StyleVariation.variations: ["error"]

                            AppIcon {
                                anchors {
                                    right: parent.right
                                    rightMargin: Theme.spacing.md
                                    verticalCenter: parent.verticalCenter
                                }
                                name: "material:error"
                                size: Theme.icons.small
                                color: Theme.colors.status.error.content
                            }
                        }
                    }

                    PreviewCard {
                        title: "Alerts"

                        AlertPreview {
                            label: "Success message"
                            iconName: "material:check_circle"
                            accentColor: Theme.colors.status.success.content
                            fillColor: Theme.colors.status.success.container
                        }

                        AlertPreview {
                            label: "Warning message"
                            iconName: "material:warning"
                            accentColor: Theme.colors.status.warning.content
                            fillColor: Theme.colors.status.warning.container
                        }

                        AlertPreview {
                            label: "Error message"
                            iconName: "material:error"
                            accentColor: Theme.colors.status.error.content
                            fillColor: Theme.colors.status.error.container
                        }
                    }

                    PreviewCard {
                        title: "Badges"

                        Flow {
                            width: parent.width
                            spacing: Theme.spacing.sm

                            MBadge { text: "Primary"; variant: MBadge.Primary }
                            MBadge { text: "Success"; variant: MBadge.Success }
                            MBadge { text: "Warning"; variant: MBadge.Warning }
                            MBadge { text: "Error"; variant: MBadge.Error }
                            MBadge { text: "Info"; variant: MBadge.Info }
                            MBadge { text: "Neutral"; variant: MBadge.Neutral }
                        }
                    }
                }
            }
        }

        Surface {
            width: parent.width
            height: accessibilityColumn.implicitHeight + Theme.spacing.xl2
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large

            Column {
                id: accessibilityColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.xl
                }
                spacing: Theme.spacing.lg

                Row {
                    width: parent.width
                    spacing: Theme.spacing.md

                    Column {
                        width: parent.width - wcagBadge.width - Theme.spacing.md
                        spacing: Theme.spacing.xxs

                        SectionTitle {
                            width: parent.width
                            text: "Accessibility"
                        }

                        SectionCaption {
                            width: parent.width
                            text: "WCAG 2.2 AA is the baseline; AAA is shown when a text pair reaches enhanced contrast."
                        }
                    }

                    MBadge {
                        id: wcagBadge
                        anchors.verticalCenter: parent.verticalCenter
                        text: "WCAG 2.2"
                        variant: MBadge.Success
                        size: MBadge.Small
                    }
                }

                Flow {
                    width: parent.width
                    spacing: root.cardGap

                    MetricCard {
                        label: "Primary text on page"
                        foregroundColor: Theme.colors.content.primary
                        sampleBackgroundColor: Theme.colors.surface.canvas
                    }

                    MetricCard {
                        label: "Secondary text on page"
                        foregroundColor: Theme.colors.content.secondary
                        sampleBackgroundColor: Theme.colors.surface.canvas
                    }

                    MetricCard {
                        label: "Inverse text on primary"
                        foregroundColor: Theme.colors.content.inverse
                        sampleBackgroundColor: Theme.colors.action.primary.container
                    }

                    MetricCard {
                        label: "Inverse text on secondary"
                        foregroundColor: Theme.colors.content.inverse
                        sampleBackgroundColor: Theme.colors.action.secondary.container
                    }

                    MetricCard {
                        label: "Focus ring on surface"
                        foregroundColor: Theme.colors.outline.focus
                        sampleBackgroundColor: Theme.colors.surface.container
                        kind: "nonText"
                    }

                    MetricCard {
                        label: "Error icon on soft fill"
                        foregroundColor: Theme.colors.status.error.content
                        sampleBackgroundColor: Theme.colors.status.error.container
                        kind: "nonText"
                    }

                    MetricCard {
                        label: "Success icon on soft fill"
                        foregroundColor: Theme.colors.status.success.content
                        sampleBackgroundColor: Theme.colors.status.success.container
                        kind: "nonText"
                    }

                    MetricCard {
                        label: "Warning icon on soft fill"
                        foregroundColor: Theme.colors.status.warning.content
                        sampleBackgroundColor: Theme.colors.status.warning.container
                        kind: "nonText"
                    }
                }
            }
        }
    }
}
