pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
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
    }

    component ShadowPreview: Item {
        id: preview

        required property string label
        required property var shadows
        property color previewBackground: Theme.colors.surface.containerSunken
        property color labelColor: Theme.colors.content.primary

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

                Repeater {
                    model: preview.shadows

                    Rectangle {
                        required property var modelData
                        required property int index

                        objectName: "merce.playground.shadows.preview." + preview.label + ".layer." + index
                        anchors.fill: parent
                        radius: Theme.radius.medium
                        color: Theme.colors.surface.containerRaised

                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowBlur: Math.min(1, Number(modelData.blur) / 32)
                            shadowHorizontalOffset: Number(modelData.xOffset)
                            shadowVerticalOffset: Number(modelData.yOffset)
                            shadowColor: modelData.color
                            shadowOpacity: 1
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radius.medium
                    color: Theme.colors.surface.containerRaised
                    border.width: Theme.size.outline.hairline
                    border.color: Theme.colors.outline.subtle
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

                SectionTitle { text: "Elevation scale" }

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
                    height: Theme.spacing.xl2

                    AppLabel {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width * 0.34
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
                        height: Theme.spacing.xl2

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
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width * 0.34
                            textType: AppLabel.BodySmall
                            text: tokenRow.modelData.name
                            color: Theme.colors.content.primary
                        }
                        AppLabel {
                            anchors {
                                left: parent.left
                                leftMargin: parent.width * 0.34
                                verticalCenter: parent.verticalCenter
                            }
                            width: parent.width * 0.46
                            textType: AppLabel.BodySmall
                            text: tokenRow.modelData.usage
                            color: Theme.colors.content.secondary
                        }
                        AppLabel {
                            anchors {
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                            }
                            width: parent.width * 0.2
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
            objectName: "merce.playground.shadows.darkComparison"
            width: page.width
            implicitHeight: darkColumn.implicitHeight + Theme.spacing.xl2
            height: implicitHeight
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large
            backgroundColor: Theme.colors.surface.inverse
            borderColor: Theme.colors.outline.strong

            Column {
                id: darkColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.xl
                }
                spacing: Theme.spacing.lg

                SectionTitle {
                    text: "On inverse surface"
                    color: Theme.colors.content.inverse
                }

                Flow {
                    id: darkFlow
                    width: parent.width
                    spacing: Theme.spacing.md

                    Repeater {
                        model: root.elevationTokens.slice(2)

                        delegate: ShadowPreview {
                            required property var modelData

                            width: root.compactLayout
                                   ? (darkFlow.width - darkFlow.spacing) / 2
                                   : (darkFlow.width - darkFlow.spacing * 3) / 4
                            label: modelData.name.replace("shadow.", "")
                            shadows: modelData.layers
                            previewBackground: Theme.colors.surface.inverse
                            labelColor: Theme.colors.content.inverse
                        }
                    }
                }
            }
        }
    }
}
