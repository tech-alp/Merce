import QtQuick
import Merce.Theme
import Merce.Foundation
import Merce.Controls

Item {
    id: root
    objectName: "merce.playground.showcase.spacingRadius"

    implicitHeight: page.implicitHeight
    height: implicitHeight

    readonly property int patternCount: 6
    readonly property bool tokenReferenceReady: spacingScale.children.length > 0 && radiusScale.children.length > 0
    readonly property bool touchTargetReady: checklistColumn.children.length >= 4
    readonly property int patternColumns: width >= 1120 ? 3 : width >= 720 ? 2 : 1
    readonly property real patternCardWidth: Math.floor((page.width - Theme.spacing.md * (patternColumns - 1)) / patternColumns)
    readonly property bool bottomWide: width >= 1080

    component SectionTitle: AppLabel {
        textType: AppLabel.H4
        color: Theme.colors.text.primary
        wrapMode: Text.WordWrap
    }

    component BodyCopy: AppLabel {
        textType: AppLabel.BodySmall
        color: Theme.colors.text.secondary
        wrapMode: Text.WordWrap
    }

    component CaptionText: AppLabel {
        textType: AppLabel.Caption
        color: Theme.colors.text.tertiary
        wrapMode: Text.WordWrap
    }

    component TokenChip: Rectangle {
        property string label: ""

        implicitWidth: chipText.implicitWidth + Theme.spacing.sm
        implicitHeight: 24
        radius: Theme.radius.badge
        color: Theme.colors.action.primarySubtle
        border.width: 1
        border.color: Theme.colors.action.primary

        AppLabel {
            id: chipText
            anchors.centerIn: parent
            textType: AppLabel.Caption
            text: label
            color: Theme.colors.action.primary
            wrapMode: Text.NoWrap
        }
    }

    component IndexBadge: Rectangle {
        property int value: 1

        width: 24
        height: 24
        radius: Theme.radius.full
        color: Theme.colors.action.primary

        AppLabel {
            anchors.centerIn: parent
            textType: AppLabel.Caption
            text: String(value)
            color: Theme.colors.text.inverse
            wrapMode: Text.NoWrap
        }
    }

    component HeroMetric: Item {
        property string icon: "material:tune"
        property string title: ""
        property string value: ""

        width: Math.max(150, metricContent.implicitWidth)
        height: 54

        Row {
            id: metricContent
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spacing.sm

            Rectangle {
                width: 36
                height: 36
                radius: Theme.radius.medium
                color: Theme.colors.background.hover
                border.width: 1
                border.color: Theme.colors.border.base

                AppIcon {
                    anchors.centerIn: parent
                    name: icon
                    size: Theme.icons.small
                    color: Theme.colors.action.primary
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacing.xxs

                AppLabel {
                    textType: AppLabel.Caption
                    text: title
                    color: Theme.colors.text.primary
                    wrapMode: Text.NoWrap
                }

                CaptionText {
                    text: value
                    wrapMode: Text.NoWrap
                }
            }
        }
    }

    component PatternCard: Surface {
        required property int indexNumber
        required property string title
        property string metaLeft: ""
        property string metaMiddle: ""
        property string metaRight: ""
        property int previewHeight: 132
        default property alias previewContent: previewLayer.data

        width: root.patternCardWidth
        height: cardColumn.implicitHeight + Theme.spacing.lg * 2
        surfaceType: Surface.Default
        radiusValue: Theme.radius.large

        Column {
            id: cardColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Theme.spacing.lg
            }
            spacing: Theme.spacing.md

            Row {
                width: parent.width
                spacing: Theme.spacing.sm

                IndexBadge {
                    value: indexNumber
                    anchors.verticalCenter: parent.verticalCenter
                }

                SectionTitle {
                    width: parent.width - 24 - parent.spacing
                    anchors.verticalCenter: parent.verticalCenter
                    text: title
                    textType: AppLabel.BodyLarge
                }
            }

            Item {
                id: previewLayer
                width: parent.width
                height: previewHeight
                clip: false
            }

            Row {
                width: parent.width
                spacing: Theme.spacing.sm

                CaptionText {
                    width: Math.max(0, (parent.width - parent.spacing * 2) / 3)
                    text: metaLeft
                }

                CaptionText {
                    width: Math.max(0, (parent.width - parent.spacing * 2) / 3)
                    text: metaMiddle
                }

                CaptionText {
                    width: Math.max(0, (parent.width - parent.spacing * 2) / 3)
                    text: metaRight
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }

    component ScaleBar: Item {
        property string label: ""
        property int value: 0
        property int maxValue: 80

        width: 64
        height: 96

        Rectangle {
            width: parent.width - Theme.spacing.sm
            height: Math.max(6, Math.round(value / maxValue * 58))
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: labelColumn.top
                bottomMargin: Theme.spacing.xs
            }
            radius: Theme.radius.small
            color: Theme.colors.action.primaryHover
        }

        Column {
            id: labelColumn
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }
            spacing: Theme.spacing.xxs

            AppLabel {
                width: parent.parent.width
                textType: AppLabel.Caption
                text: label
                color: Theme.colors.text.primary
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.NoWrap
            }

            CaptionText {
                width: parent.parent.width
                text: value + "px"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.NoWrap
            }
        }
    }

    component RadiusToken: Item {
        property string label: ""
        property int value: 0

        width: 78
        height: 78

        Rectangle {
            width: 52
            height: 40
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
            }
            radius: Math.min(value, 20)
            color: "transparent"
            border.width: 1
            border.color: Theme.colors.border.strong
        }

        Column {
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }
            spacing: Theme.spacing.xxs

            AppLabel {
                width: parent.parent.width
                textType: AppLabel.Caption
                text: label
                color: Theme.colors.text.primary
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.NoWrap
            }

            CaptionText {
                width: parent.parent.width
                text: value + "px"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.NoWrap
            }
        }
    }

    component ChecklistRow: Item {
        property string title: ""
        property string detail: ""
        property string value: ""
        property string icon: "material:check_circle"

        width: parent ? parent.width : 0
        height: 48

        Rectangle {
            width: 32
            height: 32
            radius: Theme.radius.medium
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.colors.action.primary

            AppIcon {
                anchors.centerIn: parent
                name: icon
                size: Theme.icons.small
                color: Theme.colors.text.inverse
            }
        }

        Column {
            anchors {
                left: parent.left
                leftMargin: 42
                right: valueText.left
                rightMargin: Theme.spacing.md
                verticalCenter: parent.verticalCenter
            }
            spacing: Theme.spacing.xxs

            AppLabel {
                width: parent.width
                textType: AppLabel.Caption
                text: title
                color: Theme.colors.text.primary
                wrapMode: Text.NoWrap
                maximumLineCount: 1
            }

            CaptionText {
                width: parent.width
                text: detail
                maximumLineCount: 1
            }
        }

        AppLabel {
            id: valueText
            anchors {
                right: statusIcon.left
                rightMargin: Theme.spacing.md
                verticalCenter: parent.verticalCenter
            }
            width: 72
            textType: AppLabel.Caption
            text: value
            color: Theme.colors.text.secondary
            horizontalAlignment: Text.AlignRight
            wrapMode: Text.NoWrap
        }

        AppIcon {
            id: statusIcon
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            name: "material:check_circle"
            size: Theme.icons.small
            color: Theme.colors.status.success
        }
    }

    Column {
        id: page
        width: root.width
        spacing: Theme.spacing.xl

        Surface {
            width: page.width
            height: introColumn.implicitHeight + Theme.spacing.xl2
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large

            Column {
                id: introColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.xl
                }
                spacing: Theme.spacing.lg

                Row {
                    width: parent.width
                    spacing: Theme.spacing.lg

                    Rectangle {
                        width: 56
                        height: 56
                        radius: Theme.radius.full
                        color: Theme.colors.action.primary
                        anchors.verticalCenter: parent.verticalCenter

                        AppIcon {
                            anchors.centerIn: parent
                            name: "material:apps"
                            size: Theme.icons.large
                            color: Theme.colors.text.inverse
                        }
                    }

                    Column {
                        width: parent.width - 56 - parent.spacing
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.spacing.xs

                        SectionTitle {
                            width: parent.width
                            text: "Usage Patterns Library"
                        }

                        BodyCopy {
                            width: parent.width
                            text: "Practical spacing and radius decisions for common Merce component layouts."
                        }
                    }
                }

                Flow {
                    id: metricsFlow
                    width: parent.width
                    spacing: Theme.spacing.md

                    HeroMetric { icon: "material:tune"; title: "Design scale"; value: Theme.spacing.base + "px base unit" }
                    HeroMetric { icon: "material:format_color_fill"; title: "Spacing tokens"; value: "xxs to xl6" }
                    HeroMetric { icon: "material:palette"; title: "Radius tokens"; value: "surface + controls" }
                    HeroMetric { icon: "material:check_circle"; title: "Touch target"; value: Theme.spacing.touchTarget + "px minimum" }
                }
            }
        }

        Flow {
            id: patternsFlow
            objectName: "merce.playground.spacingRadius.patterns"
            width: page.width
            spacing: Theme.spacing.md

            PatternCard {
                objectName: "merce.playground.spacingRadius.pattern.toolbar"
                indexNumber: 1
                title: "Toolbar"
                metaLeft: "Height: touchTarget + sm"
                metaMiddle: "Horizontal padding: md"
                metaRight: "Radius: input"

                Rectangle {
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    height: Theme.spacing.touchTargetCompact + Theme.spacing.sm
                    radius: Theme.radius.input
                    color: Theme.colors.background.surface
                    border.width: 1
                    border.color: Theme.colors.border.base

                    Row {
                        anchors {
                            fill: parent
                            leftMargin: Theme.spacing.md
                            rightMargin: Theme.spacing.sm
                        }
                        spacing: Theme.spacing.sm

                        AppIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: "material:menu"
                            size: Theme.icons.small
                            color: Theme.colors.text.secondary
                        }

                        AppLabel {
                            width: Math.max(86, parent.width * 0.25)
                            anchors.verticalCenter: parent.verticalCenter
                            textType: AppLabel.Body
                            text: "Page Title"
                            color: Theme.colors.text.primary
                            wrapMode: Text.NoWrap
                        }

                        MInput {
                            width: Math.max(120, parent.width - 196)
                            anchors.verticalCenter: parent.verticalCenter
                            placeholder: "Search..."
                            inputType: "search"
                            trailingIcon: "material:search"
                            isReadOnly: true
                        }

                        AppIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: "material:notifications"
                            size: Theme.icons.small
                            color: Theme.colors.text.secondary
                        }
                    }
                }

                TokenChip {
                    anchors {
                        left: parent.left
                        top: parent.top
                    }
                    label: "spacing.md"
                }
            }

            PatternCard {
                objectName: "merce.playground.spacingRadius.pattern.formRow"
                indexNumber: 2
                title: "Form Row"
                metaLeft: "Row gap: md"
                metaMiddle: "Field padding: sm"
                metaRight: "Radius: input"

                Row {
                    anchors.centerIn: parent
                    width: Math.min(parent.width, 360)
                    spacing: Theme.spacing.md

                    AppLabel {
                        width: 72
                        anchors.verticalCenter: parent.verticalCenter
                        textType: AppLabel.Body
                        text: "Label"
                        color: Theme.colors.text.primary
                        wrapMode: Text.NoWrap
                    }

                    Column {
                        width: parent.width - 72 - parent.spacing
                        spacing: Theme.spacing.xs

                        MInput {
                            id: inputField
                            width: parent.width
                            text: "Input text"
                            isReadOnly: true
                        }

                        CaptionText {
                            width: parent.width
                            text: "Helper or hint text"
                        }
                    }
                }

                TokenChip {
                    anchors {
                        right: parent.right
                        top: parent.top
                    }
                    label: "radius.input"
                }
            }

            PatternCard {
                objectName: "merce.playground.spacingRadius.pattern.dialog"
                indexNumber: 3
                title: "Dialog Body"
                metaLeft: "Content padding: xl"
                metaMiddle: "Section gap: md"
                metaRight: "Radius: dialog"
                previewHeight: 152

                Surface {
                    width: Math.min(parent.width - Theme.spacing.xl2, 300)
                    height: 126
                    anchors.centerIn: parent
                    surfaceType: Surface.Default
                    radiusValue: Theme.radius.dialog

                    Column {
                        anchors {
                            fill: parent
                            margins: Theme.spacing.lg
                        }
                        spacing: Theme.spacing.md

                        Row {
                            width: parent.width

                            AppLabel {
                                width: parent.width - closeIcon.width
                                textType: AppLabel.BodyLarge
                                text: "Dialog Title"
                                color: Theme.colors.text.primary
                                wrapMode: Text.NoWrap
                            }

                            AppIcon {
                                id: closeIcon
                                name: "material:close"
                                size: Theme.icons.small
                                color: Theme.colors.text.secondary
                            }
                        }

                        BodyCopy {
                            width: parent.width
                            text: "Use spacing tokens for comfortable reading and predictable actions."
                            maximumLineCount: 2
                        }

                        Row {
                            anchors.right: parent.right
                            spacing: Theme.spacing.sm

                            MButton { text: "Cancel"; variant: MButton.Outline; size: MButton.Small }
                            MButton { text: "Confirm"; size: MButton.Small }
                        }
                    }
                }

                TokenChip {
                    anchors {
                        left: parent.left
                        top: parent.top
                    }
                    label: "spacing.xl"
                }
            }

            PatternCard {
                objectName: "merce.playground.spacingRadius.pattern.listRow"
                indexNumber: 4
                title: "List Row"
                metaLeft: "Row height: touchTarget + lg"
                metaMiddle: "Content padding: md"
                metaRight: "Radius: medium"

                Rectangle {
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    height: Theme.spacing.touchTarget + Theme.spacing.lg
                    radius: Theme.radius.medium
                    color: Theme.colors.background.surface
                    border.width: 1
                    border.color: Theme.colors.border.base

                    Row {
                        anchors {
                            fill: parent
                            margins: Theme.spacing.md
                        }
                        spacing: Theme.spacing.md

                        Rectangle {
                            width: 44
                            height: 44
                            radius: Theme.radius.medium
                            anchors.verticalCenter: parent.verticalCenter
                            color: Theme.colors.action.primaryHover

                            AppLabel {
                                anchors.centerIn: parent
                                textType: AppLabel.BodyLarge
                                text: "M"
                                color: Theme.colors.text.primary
                                wrapMode: Text.NoWrap
                            }
                        }

                        Column {
                            width: parent.width - 44 - chevron.width - parent.spacing * 2
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacing.xxs

                            AppLabel {
                                width: parent.width
                                textType: AppLabel.Body
                                text: "Primary text"
                                color: Theme.colors.text.primary
                                wrapMode: Text.NoWrap
                            }

                            CaptionText {
                                width: parent.width
                                text: "Secondary text"
                                maximumLineCount: 1
                            }
                        }

                        AppIcon {
                            id: chevron
                            anchors.verticalCenter: parent.verticalCenter
                            name: "material:keyboard_arrow_down"
                            size: Theme.icons.small
                            color: Theme.colors.text.secondary
                            rotation: -90
                        }
                    }
                }

                TokenChip {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top
                    }
                    label: "spacing.md"
                }
            }

            PatternCard {
                objectName: "merce.playground.spacingRadius.pattern.surface"
                indexNumber: 5
                title: "Card Surface"
                metaLeft: "Padding: md"
                metaMiddle: "Surface radius: card"
                metaRight: "Gap: sm"

                Surface {
                    width: Math.min(parent.width - Theme.spacing.xl2, 320)
                    height: 102
                    anchors.centerIn: parent
                    surfaceType: Surface.Default
                    radiusValue: Theme.radius.card

                    Row {
                        anchors {
                            fill: parent
                            margins: Theme.spacing.md
                        }
                        spacing: Theme.spacing.md

                        Rectangle {
                            width: 58
                            height: 58
                            radius: Theme.radius.small
                            anchors.verticalCenter: parent.verticalCenter
                            color: Theme.colors.background.hover

                            AppIcon {
                                anchors.centerIn: parent
                                name: "material:palette"
                                size: Theme.icons.medium
                                color: Theme.colors.text.tertiary
                            }
                        }

                        Column {
                            width: parent.width - 58 - parent.spacing
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacing.xs

                            AppLabel {
                                width: parent.width
                                textType: AppLabel.Body
                                text: "Card Title"
                                color: Theme.colors.text.primary
                                wrapMode: Text.NoWrap
                            }

                            BodyCopy {
                                width: parent.width
                                text: "Supporting copy that spans one or two lines."
                                maximumLineCount: 2
                            }
                        }
                    }
                }

                TokenChip {
                    anchors {
                        right: parent.right
                        top: parent.top
                    }
                    label: "radius.card"
                }
            }

            PatternCard {
                objectName: "merce.playground.spacingRadius.pattern.touch"
                indexNumber: 6
                title: "Kiosk Touch Control"
                metaLeft: "Min touch target: 44px"
                metaMiddle: "Spacing: sm"
                metaRight: "Radius: button"

                Row {
                    anchors.centerIn: parent
                    spacing: Theme.spacing.sm

                    MButton {
                        text: "Action"
                        icon.name: "material:home"
                        variant: MButton.Outline
                        size: MButton.Medium
                    }

                    MButton {
                        text: "Primary"
                        icon.name: "material:check_circle"
                        size: MButton.Medium
                    }

                    MButton {
                        text: "More"
                        icon.name: "material:menu"
                        variant: MButton.Outline
                        size: MButton.Medium
                    }
                }

                TokenChip {
                    anchors {
                        left: parent.left
                        top: parent.top
                    }
                    label: "touchTarget"
                }
            }
        }

        Flow {
            width: page.width
            spacing: Theme.spacing.md

            Surface {
                objectName: "merce.playground.spacingRadius.tokenReference"
                width: root.bottomWide ? Math.floor((page.width - Theme.spacing.md) * 0.62) : page.width
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
                    spacing: Theme.spacing.lg

                    SectionTitle {
                        width: parent.width
                        text: "Token Reference"
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacing.xl

                        Column {
                            width: Math.max(240, (parent.width - parent.spacing) * 0.52)
                            spacing: Theme.spacing.md

                            AppLabel {
                                width: parent.width
                                textType: AppLabel.Caption
                                text: "Spacing scale (" + Theme.spacing.base + "px base)"
                                color: Theme.colors.text.primary
                                wrapMode: Text.NoWrap
                            }

                            Flow {
                                id: spacingScale
                                width: parent.width
                                spacing: Theme.spacing.sm

                                ScaleBar { label: "xxs"; value: Theme.spacing.xxs; maxValue: Theme.spacing.xl6 }
                                ScaleBar { label: "xs"; value: Theme.spacing.xs; maxValue: Theme.spacing.xl6 }
                                ScaleBar { label: "sm"; value: Theme.spacing.sm; maxValue: Theme.spacing.xl6 }
                                ScaleBar { label: "md"; value: Theme.spacing.md; maxValue: Theme.spacing.xl6 }
                                ScaleBar { label: "lg"; value: Theme.spacing.lg; maxValue: Theme.spacing.xl6 }
                                ScaleBar { label: "xl"; value: Theme.spacing.xl; maxValue: Theme.spacing.xl6 }
                                ScaleBar { label: "xl2"; value: Theme.spacing.xl2; maxValue: Theme.spacing.xl6 }
                                ScaleBar { label: "xl4"; value: Theme.spacing.xl4; maxValue: Theme.spacing.xl6 }
                            }
                        }

                        Column {
                            width: Math.max(220, parent.width - x)
                            spacing: Theme.spacing.md

                            AppLabel {
                                width: parent.width
                                textType: AppLabel.Caption
                                text: "Radius scale"
                                color: Theme.colors.text.primary
                                wrapMode: Text.NoWrap
                            }

                            Flow {
                                id: radiusScale
                                width: parent.width
                                spacing: Theme.spacing.sm

                                RadiusToken { label: "small"; value: Theme.radius.small }
                                RadiusToken { label: "medium"; value: Theme.radius.medium }
                                RadiusToken { label: "large"; value: Theme.radius.large }
                                RadiusToken { label: "xlarge"; value: Theme.radius.xlarge }
                                RadiusToken { label: "card"; value: Theme.radius.card }
                                RadiusToken { label: "full"; value: Theme.radius.full }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.colors.border.base
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacing.sm

                        AppIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: "material:check_circle"
                            size: Theme.icons.small
                            color: Theme.colors.text.tertiary
                        }

                        CaptionText {
                            width: parent.width - Theme.icons.small - parent.spacing
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Spacing and radius tokens stay semantic; component recipes choose the final applied values."
                        }
                    }
                }
            }

            Surface {
                objectName: "merce.playground.spacingRadius.touchChecklist"
                width: root.bottomWide ? Math.floor((page.width - Theme.spacing.md) * 0.38) : page.width
                height: checklistShell.implicitHeight + Theme.spacing.xl2
                surfaceType: Surface.Default
                radiusValue: Theme.radius.large

                Column {
                    id: checklistShell
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: Theme.spacing.lg
                    }
                    spacing: Theme.spacing.md

                    SectionTitle {
                        width: parent.width
                        text: "Accessibility & Touch Target"
                    }

                    Column {
                        id: checklistColumn
                        width: parent.width
                        spacing: Theme.spacing.xs

                        ChecklistRow {
                            title: "Minimum touch target"
                            detail: "All interactive targets"
                            value: Theme.spacing.touchTarget + "px"
                            icon: "material:check_circle"
                        }

                        ChecklistRow {
                            title: "Compact target"
                            detail: "Dense toolbar controls"
                            value: Theme.spacing.touchTargetCompact + "px"
                            icon: "material:tune"
                        }

                        ChecklistRow {
                            title: "Body text"
                            detail: "Minimum readable size"
                            value: Theme.typography.sizeMedium + "px"
                            icon: "material:text_fields"
                        }

                        ChecklistRow {
                            title: "Normal contrast"
                            detail: "Text on base surface"
                            value: "AA"
                            icon: "material:palette"
                        }
                    }

                    BodyCopy {
                        width: parent.width
                        text: "Designed for kiosk and tablet environments where spacing must support repeated touch input."
                    }
                }
            }
        }
    }
}
