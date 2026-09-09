pragma ComponentBehavior: Bound

import QtQuick
import Merce.Effects
import Merce.Theme
import Merce.Foundation

Item {
    id: root

    objectName: "merce.playground.showcase.shadows"
    implicitHeight: page.implicitHeight
    height: implicitHeight

    readonly property bool compactLayout: width < 720
    readonly property var elevationTokens: [
        { "name": "shadow.none", "usage": "Flat surfaces", "layers": Theme.shadows.none },
        { "name": "shadow.small", "usage": "Buttons", "layers": Theme.shadows.small },
        { "name": "shadow.medium", "usage": "Cards", "layers": Theme.shadows.medium },
        { "name": "shadow.large", "usage": "Raised cards", "layers": Theme.shadows.large },
        { "name": "shadow.xlarge", "usage": "Dropdowns", "layers": Theme.shadows.xlarge },
        { "name": "shadow.xxlarge", "usage": "Dialogs", "layers": Theme.shadows.xxlarge }
    ]

    component SectionTitle: AppLabel {
        textType: AppLabel.H4
        color: Theme.colors.content.primary
        wrapMode: Text.WordWrap
    }

    component ShadowPreview: Item {
        id: preview

        required property string label
        required property var shadows
        property color previewBackground: Theme.colors.surface.containerSunken
        property color labelColor: Theme.colors.content.primary
        property color surfaceColor: Theme.colors.surface.containerRaised
        property bool darkSurfaceTreatmentEnabled: Theme.activeMode === "dark"

        implicitHeight: 148

        AppLabel {
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
            textType: AppLabel.Caption
            text: preview.label
            color: preview.labelColor
        }

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                topMargin: Theme.spacing.xl
            }
            height: 96
            radius: Theme.radius.medium
            color: preview.previewBackground

            Item {
                anchors.centerIn: parent
                width: Math.min(92, parent.width - Theme.spacing.xl)
                height: 64

                MShadow {
                    anchors.fill: card
                    layers: preview.shadows
                    surfaceRadius: card.radius
                    surfaceColor: preview.surfaceColor
                    darkSurfaceTreatmentEnabled: preview.darkSurfaceTreatmentEnabled
                }

                Rectangle {
                    id: card

                    objectName: "merce.playground.shadows.preview." + preview.label
                    anchors.fill: parent
                    radius: Theme.radius.medium
                    color: preview.surfaceColor
                }
            }
        }

        AppLabel {
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
            textType: AppLabel.Caption
            text: preview.shadows.length + (preview.shadows.length === 1 ? " layer" : " layers")
            color: preview.labelColor
        }
    }

    Column {
        id: page

        width: root.width
        spacing: Theme.spacing.xl

        Surface {
            objectName: "merce.playground.shadows.scale"
            width: page.width
            implicitHeight: scaleColumn.implicitHeight + Theme.spacing.xl2
            height: implicitHeight
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large

            Column {
                id: scaleColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.xl
                }
                spacing: Theme.spacing.lg

            SectionTitle {
                width: parent.width
                text: "Elevation scale"
            }

                Flow {
                    id: scaleFlow
                    width: parent.width
                    spacing: Theme.spacing.md

                    Repeater {
                        model: root.elevationTokens.slice(0, 5)

                        delegate: ShadowPreview {
                            required property var modelData

                            width: root.compactLayout
                                   ? (scaleFlow.width - scaleFlow.spacing) / 2
                                   : (scaleFlow.width - scaleFlow.spacing * 4) / 5
                            label: modelData.name.replace("shadow.", "")
                            shadows: modelData.layers
                        }
                    }
                }
            }
        }

        Surface {
            objectName: "merce.playground.shadows.reference"
            width: page.width
            implicitHeight: referenceColumn.implicitHeight + Theme.spacing.xl2
            height: implicitHeight
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large

            Column {
                id: referenceColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.xl
                }
                spacing: 0

                SectionTitle {
                    width: parent.width
                    text: "Shadow tokens"
                }

                Item {
                    width: parent.width
                    height: root.compactLayout ? 40 : Theme.spacing.xl2

                    AppLabel {
                        anchors.verticalCenter: parent.verticalCenter
                        width: root.compactLayout ? parent.width * 0.74
                                                  : parent.width * 0.34
                        textType: AppLabel.Caption
                        text: "Token"
                        color: Theme.colors.content.secondary
                    }
                    AppLabel {
                        anchors {
                            left: parent.left
                            leftMargin: parent.width * 0.34
                            verticalCenter: parent.verticalCenter
                        }
                        width: parent.width * 0.46
                        textType: AppLabel.Caption
                        text: "Usage"
                        color: Theme.colors.content.secondary
                        visible: !root.compactLayout
                    }
                    AppLabel {
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        width: parent.width * 0.2
                        horizontalAlignment: Text.AlignRight
                        textType: AppLabel.Caption
                        text: "Layers"
                        color: Theme.colors.content.secondary
                    }
                }

                Repeater {
                    model: root.elevationTokens

                    delegate: Item {
                        id: tokenRow

                        required property var modelData

                        width: referenceColumn.width
                        height: root.compactLayout ? 64 : Theme.spacing.xl2

                        Rectangle {
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                            }
                            height: Theme.size.outline.hairline
                            color: Theme.colors.outline.subtle
                        }
                        AppLabel {
                            x: 0
                            y: root.compactLayout ? Theme.spacing.xs : 0
                            width: root.compactLayout ? parent.width * 0.74
                                                      : parent.width * 0.34
                            height: root.compactLayout ? 28 : parent.height
                            verticalAlignment: Text.AlignVCenter
                            textType: AppLabel.BodySmall
                            text: tokenRow.modelData.name
                            color: Theme.colors.content.primary
                            elide: Text.ElideRight
                        }
                        AppLabel {
                            x: root.compactLayout ? 0 : parent.width * 0.34
                            y: root.compactLayout ? 34 : 0
                            width: root.compactLayout ? parent.width * 0.8
                                                      : parent.width * 0.46
                            height: root.compactLayout ? 28 : parent.height
                            verticalAlignment: Text.AlignVCenter
                            textType: AppLabel.BodySmall
                            text: tokenRow.modelData.usage
                            color: Theme.colors.content.secondary
                            elide: Text.ElideRight
                        }
                        AppLabel {
                            anchors.right: parent.right
                            y: root.compactLayout ? Theme.spacing.xs : 0
                            width: parent.width * 0.2
                            height: root.compactLayout ? 28 : parent.height
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignRight
                            textType: AppLabel.BodySmall
                            text: String(tokenRow.modelData.layers.length)
                            color: Theme.colors.content.primary
                        }
                    }
                }
            }
        }

        Surface {
            objectName: "merce.playground.shadows.inverseElevation"
            width: page.width
            implicitHeight: inverseColumn.implicitHeight + Theme.spacing.xl2
            height: implicitHeight
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large

            Column {
                id: inverseColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.xl
                }
                spacing: Theme.spacing.lg

                SectionTitle {
                    width: parent.width
                    text: qsTr("Inverse surface elevation")
                }

                Flow {
                    id: inverseFlow
                    width: parent.width
                    spacing: Theme.spacing.md

                    Repeater {
                        model: root.elevationTokens.slice(2)

                        delegate: ShadowPreview {
                            required property var modelData

                            width: root.compactLayout
                                   ? (inverseFlow.width - inverseFlow.spacing) / 2
                                   : (inverseFlow.width - inverseFlow.spacing * 3) / 4
                            label: modelData.name.replace("shadow.", "")
                            shadows: modelData.layers
                            surfaceColor: Theme.colors.surface.inverse
                            darkSurfaceTreatmentEnabled: false
                        }
                    }
                }
            }
        }
    }
}
