pragma ComponentBehavior: Bound

import QtQuick
import Qt.labs.StyleKit as SK
import Merce.Controls
import Merce.Effects
import Merce.Foundation
import Merce.Style.Effects
import Merce.Theme

Item {
    id: root

    required property EffectPolicy effectPolicy
    readonly property bool shaderSupported: root.GraphicsInfo.api === GraphicsInfo.OpenGL
                                           || root.GraphicsInfo.api === GraphicsInfo.Vulkan
                                           || root.GraphicsInfo.api === GraphicsInfo.Metal
                                           || root.GraphicsInfo.api === GraphicsInfo.Direct3D11
                                           || root.GraphicsInfo.api === GraphicsInfo.Direct3D12
    implicitHeight: page.implicitHeight
    height: implicitHeight

    component SectionTitle: AppLabel {
        textType: AppLabel.H4
        color: Theme.colors.content.primary
        wrapMode: Text.WordWrap
    }

    Column {
        id: page
        width: root.width
        spacing: Theme.spacing.xl

        Surface {
            width: page.width
            surfaceType: Surface.Default
            implicitHeight: buttonColumn.implicitHeight + Theme.spacing.xl * 2
            height: implicitHeight
            radiusValue: Theme.radius.large

            Column {
                id: buttonColumn
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.spacing.xl }
                spacing: Theme.spacing.lg

                SectionTitle { width: parent.width; text: qsTr("A little light, once per hover") }

                AppLabel {
                    width: parent.width
                    textType: AppLabel.Body
                    text: qsTr("Hover a button to sweep its surface. Change the theme above to compare colors. Clicking, hiding or disabling a button stops the sweep.")
                    wrapMode: Text.WordWrap
                }

                Flow {
                    objectName: "merce.playground.effects.policy"
                    width: parent.width
                    spacing: Theme.spacing.lg
                    SK.Switch {
                        objectName: "merce.playground.effects.enabled"
                        text: qsTr("Effects")
                        checked: root.effectPolicy.enabled
                        onToggled: root.effectPolicy.enabled = checked
                    }
                    SK.Switch {
                        objectName: "merce.playground.effects.reducedMotion"
                        text: qsTr("Reduced motion")
                        checked: root.effectPolicy.reducedMotion
                        onToggled: root.effectPolicy.reducedMotion = checked
                    }
                }

                AppLabel {
                    width: parent.width
                    visible: !root.shaderSupported
                    textType: AppLabel.BodySmall
                    text: qsTr("This renderer shows the normal button surface. Animated shader effects are unavailable.")
                    color: Theme.colors.content.secondary
                    wrapMode: Text.WordWrap
                }

                Flow {
                    objectName: "merce.playground.effects.buttons"
                    width: parent.width
                    spacing: Theme.spacing.md
                    MButton { text: qsTr("Primary"); extraVariations: ["sheen"] }
                    MButton { text: qsTr("Secondary"); variant: MButton.Secondary; extraVariations: ["sheen"] }
                    MButton { text: qsTr("Outline"); variant: MButton.Outline; extraVariations: ["sheen"] }
                    MButton { text: qsTr("Ghost"); variant: MButton.Ghost; extraVariations: ["sheen"] }
                    MButton { text: qsTr("Destructive"); variant: MButton.Destructive; extraVariations: ["sheen"] }
                }

                Flow {
                    width: parent.width
                    spacing: Theme.spacing.md
                    MButton { text: qsTr("Small"); size: MButton.Small; extraVariations: ["sheen"] }
                    MButton { text: qsTr("Large"); size: MButton.Large; extraVariations: ["sheen"] }
                    MButton { text: qsTr("Loading"); loading: true; extraVariations: ["sheen"] }
                    MButton { text: qsTr("Disabled"); enabled: false; extraVariations: ["sheen"] }
                    SK.Button {
                        text: qsTr("StyleKit button")
                        SK.StyleVariation.variations: ["sheen"]
                    }
                }
            }
        }

        Surface {
            width: page.width
            surfaceType: Surface.Default
            implicitHeight: previewColumn.implicitHeight + Theme.spacing.xl * 2
            height: implicitHeight
            radiusValue: Theme.radius.large

            Column {
                id: previewColumn
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.spacing.xl }
                spacing: Theme.spacing.lg

                SectionTitle { width: parent.width; text: qsTr("Shape the surface") }

                AppLabel {
                    width: parent.width
                    textType: AppLabel.Body
                    text: qsTr("Scrub the position to inspect the primitive. This preview has independent corner radii and stays still until you move the slider.")
                    wrapMode: Text.WordWrap
                }

                Rectangle {
                    width: parent.width
                    height: 128
                    color: Theme.colors.action.primary.container
                    topLeftRadius: Theme.radius.large
                    topRightRadius: 0
                    bottomLeftRadius: Theme.radius.small
                    bottomRightRadius: Theme.radius.large

                    Loader {
                        anchors.fill: parent
                        active: root.shaderSupported && root.effectPolicy.enabled
                        sourceComponent: MSheen {
                            progress: positionSlider.value
                            intensity: 0.4
                            bandWidth: 0.3
                            topLeftRadius: Theme.radius.large
                            topRightRadius: 0
                            bottomLeftRadius: Theme.radius.small
                            bottomRightRadius: Theme.radius.large
                        }
                    }

                    AppLabel {
                        anchors.centerIn: parent
                        textType: AppLabel.H4
                        text: qsTr("Sheen")
                        color: Theme.colors.action.primary.content
                    }
                }

                SK.Slider {
                    id: positionSlider
                    objectName: "merce.playground.effects.progress"
                    width: parent.width
                    from: 0
                    to: 1
                    value: 0.5
                    Accessible.name: qsTr("Sheen position")
                }
            }
        }
    }
}
