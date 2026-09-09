import QtQuick
import QtQuick.Layouts
import Merce.Theme
import Merce.Foundation

Item {
    id: root
    objectName: "merce.playground.showcase.spacingRadius"

    implicitHeight: page.implicitHeight
    height: implicitHeight

    readonly property int patternCount: 0
    readonly property bool compactLayout: width < 760
    readonly property bool tokenReferenceReady: spacingRows.count === 7 && radiusRows.count === 6
    readonly property bool touchTargetReady: touchTargets.count === 3
    readonly property int summaryColumns: width >= 900 ? 4 : width >= 520 ? 2 : 1
    readonly property int scaleColumns: width >= 620 ? 2 : 1
    readonly property int touchColumns: width >= 960 ? 3 : width >= 620 ? 2 : 1
    readonly property color dividerColor: Theme.colors.outline.subtle
    readonly property color accentColor: Theme.colors.action.primary.container

    component SectionTitle: AppLabel {
        textType: AppLabel.H4
        color: Theme.colors.content.primary
        wrapMode: Text.WordWrap
    }

    component BodyCopy: AppLabel {
        textType: AppLabel.BodySmall
        color: Theme.colors.content.secondary
        wrapMode: Text.WordWrap
    }

    component CaptionText: AppLabel {
        textType: AppLabel.Caption
        color: Theme.colors.content.tertiary
        wrapMode: Text.WordWrap
    }

    component SummaryMetric: Item {
        required property string iconName
        required property string label
        required property string value
        required property string detail

        implicitWidth: 220
        implicitHeight: 66

        RowLayout {
            anchors.fill: parent
            spacing: Theme.spacing.md

            Rectangle {
                Layout.preferredWidth: 44
                Layout.preferredHeight: 44
                radius: Theme.radius.full
                color: root.accentColor

                AppIcon {
                    anchors.centerIn: parent
                    name: iconName
                    size: Theme.icons.small
                    color: Theme.colors.content.inverse
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.xxs

                CaptionText {
                    Layout.fillWidth: true
                    text: label
                    maximumLineCount: 1
                    elide: Text.ElideRight
                }

                AppLabel {
                    Layout.fillWidth: true
                    textType: AppLabel.Body
                    text: value
                    color: Theme.colors.content.primary
                    wrapMode: Text.NoWrap
                    maximumLineCount: 1
                    elide: Text.ElideRight
                }

                CaptionText {
                    Layout.fillWidth: true
                    text: detail
                    maximumLineCount: 1
                    elide: Text.ElideRight
                }
            }
        }
    }

    component ValueChip: Rectangle {
        required property string label

        implicitWidth: Math.max(42, valueLabel.implicitWidth + Theme.spacing.md)
        implicitHeight: 30
        radius: Theme.radius.small
        color: Theme.colors.surface.containerTinted
        border.width: 1
        border.color: root.dividerColor

        CaptionText {
            id: valueLabel
            anchors.centerIn: parent
            text: label
            color: Theme.colors.content.primary
            wrapMode: Text.NoWrap
        }
    }

    component SpacingScaleRow: Item {
        required property string tokenName
        required property int tokenValue
        required property int maxValue

        implicitHeight: 42

        RowLayout {
            anchors.fill: parent
            spacing: Theme.spacing.sm

            AppLabel {
                Layout.preferredWidth: 44
                textType: AppLabel.Caption
                text: tokenName
                color: Theme.colors.content.primary
                wrapMode: Text.NoWrap
            }

            ValueChip {
                label: String(tokenValue)
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 18

                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.max(18, Math.min(parent.width,
                                                parent.width * tokenValue / Math.max(1, maxValue)))
                    height: 2
                    color: root.accentColor

                    Rectangle {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: 2
                        height: 10
                        color: root.accentColor
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 2
                        height: 10
                        color: root.accentColor
                    }
                }
            }

            CaptionText {
                Layout.preferredWidth: 54
                text: tokenValue + qsTr("px")
                color: Theme.colors.content.secondary
                wrapMode: Text.NoWrap
            }
        }
    }

    component RadiusScaleRow: Item {
        required property string tokenName
        required property int tokenValue

        implicitHeight: 42

        RowLayout {
            anchors.fill: parent
            spacing: Theme.spacing.sm

            AppLabel {
                Layout.preferredWidth: 62
                textType: AppLabel.Caption
                text: tokenName
                color: Theme.colors.content.primary
                wrapMode: Text.NoWrap
            }

            ValueChip {
                label: tokenValue >= 999 ? "999" : String(tokenValue)
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 34

                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 54
                    height: 32
                    radius: Math.min(tokenValue, 16)
                    color: "transparent"
                    border.width: 1
                    border.color: Theme.colors.outline.strong
                }
            }

            CaptionText {
                Layout.preferredWidth: 58
                text: tokenValue >= 999 ? qsTr("full") : tokenValue + qsTr("px")
                color: Theme.colors.content.secondary
                wrapMode: Text.NoWrap
            }
        }
    }

    component TouchTargetItem: Item {
        required property int targetSize
        required property string label
        required property string detail
        required property string iconName
        property bool recommended: false

        implicitWidth: 290
        implicitHeight: 150

        RowLayout {
            anchors.fill: parent
            spacing: Theme.spacing.lg

            ColumnLayout {
                Layout.preferredWidth: Math.max(76, targetSize + Theme.spacing.sm)
                spacing: Theme.spacing.xs

                AppLabel {
                    Layout.fillWidth: true
                    textType: AppLabel.Caption
                    text: targetSize + qsTr(" px")
                    color: Theme.colors.content.primary
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.NoWrap
                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: targetSize
                    Layout.preferredHeight: targetSize
                    radius: Theme.radius.medium
                    color: Theme.colors.surface.containerTinted
                    border.width: 1
                    border.color: root.accentColor

                    AppIcon {
                        anchors.centerIn: parent
                        name: iconName
                        size: Theme.icons.medium
                        color: Theme.colors.content.secondary
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.xs

                AppLabel {
                    Layout.fillWidth: true
                    textType: AppLabel.Body
                    text: label
                    color: recommended ? root.accentColor : Theme.colors.content.primary
                    wrapMode: Text.WordWrap
                }

                BodyCopy {
                    Layout.fillWidth: true
                    text: detail
                }
            }
        }
    }

    ColumnLayout {
        id: page
        width: root.width
        spacing: Theme.spacing.lg

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.xs

            AppLabel {
                Layout.fillWidth: true
                textType: AppLabel.H1
                text: qsTr("Spacing & Radius")
                color: Theme.colors.content.primary
                wrapMode: Text.WordWrap
            }

            BodyCopy {
                Layout.fillWidth: true
                text: qsTr("A practical scale for consistent layouts and surfaces.")
            }
        }

        Surface {
            Layout.fillWidth: true
            Layout.preferredHeight: summaryGrid.implicitHeight + Theme.spacing.lg * 2
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large

            GridLayout {
                id: summaryGrid
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.lg
                }
                columns: root.summaryColumns
                columnSpacing: Theme.spacing.xl
                rowSpacing: Theme.spacing.md

                SummaryMetric {
                    Layout.fillWidth: true
                    iconName: "material:straighten"
                    label: qsTr("Base unit")
                    value: Theme.spacing.base + qsTr(" px")
                    detail: qsTr("1 unit = %1px").arg(Theme.spacing.base)
                }

                SummaryMetric {
                    Layout.fillWidth: true
                    iconName: "material:adjust"
                    label: qsTr("Touch target")
                    value: Theme.spacing.touchTarget + qsTr(" px")
                    detail: qsTr("Recommended size")
                }

                SummaryMetric {
                    Layout.fillWidth: true
                    iconName: "material:apps"
                    label: qsTr("Density")
                    value: qsTr("Comfortable")
                    detail: qsTr("Balanced spacing")
                }

                SummaryMetric {
                    Layout.fillWidth: true
                    iconName: "material:grid_view"
                    label: qsTr("Grid")
                    value: qsTr("8 columns")
                    detail: qsTr("Layout system")
                }
            }
        }

        GridLayout {
            id: tokenReference
            objectName: "merce.playground.spacingRadius.tokenReference"
            Layout.fillWidth: true
            columns: root.scaleColumns
            columnSpacing: Theme.spacing.md
            rowSpacing: Theme.spacing.md

            Surface {
                id: spacingScaleCard
                objectName: "merce.playground.spacingRadius.spacingScale"
                Layout.fillWidth: true
                Layout.preferredHeight: spacingColumn.implicitHeight + Theme.spacing.lg * 2
                surfaceType: Surface.Default
                radiusValue: Theme.radius.large

                ColumnLayout {
                    id: spacingColumn
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: Theme.spacing.lg
                    }
                    spacing: Theme.spacing.xs

                    SectionTitle {
                        Layout.fillWidth: true
                        text: qsTr("Spacing Scale")
                    }

                    Repeater {
                        id: spacingRows
                        model: [
                            { "name": "xxs", "value": Theme.spacing.xxs },
                            { "name": "xs", "value": Theme.spacing.xs },
                            { "name": "sm", "value": Theme.spacing.sm },
                            { "name": "md", "value": Theme.spacing.md },
                            { "name": "lg", "value": Theme.spacing.lg },
                            { "name": "xl", "value": Theme.spacing.xl },
                            { "name": "xxl", "value": Theme.spacing.xl2 }
                        ]

                        SpacingScaleRow {
                            required property var modelData
                            Layout.fillWidth: true
                            tokenName: modelData.name
                            tokenValue: modelData.value
                            maxValue: Theme.spacing.xl2
                        }
                    }
                }
            }

            Surface {
                id: radiusScaleCard
                objectName: "merce.playground.spacingRadius.radiusScale"
                Layout.fillWidth: true
                Layout.preferredHeight: radiusColumn.implicitHeight + Theme.spacing.lg * 2
                surfaceType: Surface.Default
                radiusValue: Theme.radius.large

                ColumnLayout {
                    id: radiusColumn
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: Theme.spacing.lg
                    }
                    spacing: Theme.spacing.xs

                    SectionTitle {
                        Layout.fillWidth: true
                        text: qsTr("Radius Scale")
                    }

                    Repeater {
                        id: radiusRows
                        model: [
                            { "name": qsTr("none"), "value": Theme.radius.none },
                            { "name": qsTr("small"), "value": Theme.radius.small },
                            { "name": qsTr("medium"), "value": Theme.radius.medium },
                            { "name": qsTr("large"), "value": Theme.radius.large },
                            { "name": "xl", "value": Theme.radius.xlarge },
                            { "name": qsTr("pill"), "value": Theme.radius.full }
                        ]

                        RadiusScaleRow {
                            required property var modelData
                            Layout.fillWidth: true
                            tokenName: modelData.name
                            tokenValue: modelData.value
                        }
                    }
                }
            }
        }

        Surface {
            id: touchChecklist
            objectName: "merce.playground.spacingRadius.touchChecklist"
            Layout.fillWidth: true
            Layout.preferredHeight: touchChecklistColumn.implicitHeight + Theme.spacing.lg * 2
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large

            ColumnLayout {
                id: touchChecklistColumn

                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.lg
                }
                spacing: Theme.spacing.md

                SectionTitle {
                    Layout.fillWidth: true
                    text: qsTr("Touch Targets")
                }

                GridLayout {
                    id: touchGrid
                    Layout.fillWidth: true
                    columns: root.touchColumns
                    columnSpacing: Theme.spacing.xl
                    rowSpacing: Theme.spacing.md

                    Repeater {
                        id: touchTargets
                        model: [
                            {
                                "size": Theme.spacing.touchTargetCompact,
                                "label": qsTr("Minimum"),
                                "detail": qsTr("Use only when space is limited."),
                                "icon": "material:menu",
                                "recommended": false
                            },
                            {
                                "size": Theme.spacing.touchTarget,
                                "label": qsTr("Recommended"),
                                "detail": qsTr("Best balance of comfort and space."),
                                "icon": "material:check_box",
                                "recommended": true
                            },
                            {
                                "size": Theme.spacing.touchTarget + Theme.spacing.md,
                                "label": qsTr("Comfortable"),
                                "detail": qsTr("Extra breathing room for key actions."),
                                "icon": "material:add_circle",
                                "recommended": false
                            }
                        ]

                        TouchTargetItem {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: implicitHeight
                            targetSize: modelData.size
                            label: modelData.label
                            detail: modelData.detail
                            iconName: modelData.icon
                            recommended: modelData.recommended
                        }
                    }
                }
            }
        }
    }
}
