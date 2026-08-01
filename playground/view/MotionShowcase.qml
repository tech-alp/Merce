pragma ComponentBehavior: Bound

import QtQuick
import Qt.labs.StyleKit as SK
import Merce.Theme
import Merce.Foundation
import Merce.Controls

Item {
    id: root

    objectName: "merce.playground.showcase.motion"
    implicitHeight: page.implicitHeight
    height: implicitHeight

    property bool reducedMotion: false
    readonly property bool compactLayout: width < 720
    readonly property var durationTokens: [
        { "name": "Instant", "value": Theme.motion.durationInstant },
        { "name": "Fast", "value": Theme.motion.durationFast },
        { "name": "Normal", "value": Theme.motion.durationNormal },
        { "name": "Slow", "value": Theme.motion.durationSlow },
        { "name": "Slower", "value": Theme.motion.durationSlower }
    ]
    readonly property var presetTokens: [
        { "name": "hover", "usage": "Pointer feedback", "value": Theme.motion.hover },
        { "name": "press", "usage": "Activation feedback", "value": Theme.motion.press },
        { "name": "appear", "usage": "New content", "value": Theme.motion.appear },
        { "name": "enter", "usage": "Incoming content", "value": Theme.motion.enter },
        { "name": "exit", "usage": "Outgoing content", "value": Theme.motion.exit }
    ]

    component SectionTitle: AppLabel {
        textType: AppLabel.H4
        color: Theme.colors.content.primary
    }

    component MotionTrack: Item {
        id: trackRoot

        required property string label
        required property string token
        required property int durationValue
        required property int easingValue

        implicitHeight: 72

        function play() {
            marker.x = 0
            if (root.reducedMotion)
                marker.x = track.width - marker.width
            else
                movement.restart()
        }

        AppLabel {
            id: trackLabel
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            width: root.compactLayout ? 92 : 132
            textType: AppLabel.BodySmall
            text: trackRoot.label
            color: Theme.colors.content.primary
        }

        Item {
            id: track
            anchors {
                left: trackLabel.right
                leftMargin: Theme.spacing.md
                right: runButton.left
                rightMargin: Theme.spacing.md
                verticalCenter: parent.verticalCenter
            }
            height: 40

            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                height: Theme.size.outline.hairline
                color: Theme.colors.outline.strong
            }

            Repeater {
                model: 5

                delegate: Rectangle {
                    required property int index

                    x: index * (track.width - width) / 4
                    anchors.verticalCenter: parent.verticalCenter
                    width: 6
                    height: 6
                    radius: 3
                    color: Theme.colors.outline.strong
                }
            }

            Rectangle {
                id: marker
                anchors.verticalCenter: parent.verticalCenter
                width: 24
                height: 24
                radius: Theme.radius.small
                color: Theme.colors.action.primary.container
            }

            XAnimator {
                id: movement
                target: marker
                from: 0
                to: track.width - marker.width
                duration: trackRoot.durationValue
                easing.type: trackRoot.easingValue
            }
        }

        MButton {
            id: runButton
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            objectName: "merce.playground.motion.run." + trackRoot.token
            text: "Run"
            variant: MButton.Outline
            size: MButton.Small
            iconPosition: MButton.IconNone
            Accessible.name: "Run " + trackRoot.label
            onClicked: trackRoot.play()
        }

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: Theme.size.outline.hairline
            color: Theme.colors.outline.subtle
        }
    }

    Column {
        id: page

        width: root.width
        spacing: Theme.spacing.xl

        Surface {
            objectName: "merce.playground.motion.durationTokens"
            width: page.width
            implicitHeight: durationColumn.implicitHeight + Theme.spacing.xl2
            height: implicitHeight
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large

            Column {
                id: durationColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.xl
                }
                spacing: Theme.spacing.lg

                SectionTitle { text: "Duration tokens" }

                Flow {
                    id: durationFlow
                    width: parent.width
                    spacing: Theme.spacing.md

                    Repeater {
                        model: root.durationTokens

                        delegate: Item {
                            id: durationToken

                            required property var modelData

                            width: root.compactLayout
                                   ? (durationFlow.width - durationFlow.spacing) / 2
                                   : (durationFlow.width - durationFlow.spacing * 4) / 5
                            height: 72

                            AppLabel {
                                anchors {
                                    top: parent.top
                                    left: parent.left
                                    right: parent.right
                                }
                                textType: AppLabel.BodySmall
                                text: durationToken.modelData.name
                                color: Theme.colors.content.secondary
                            }
                            AppLabel {
                                anchors {
                                    left: parent.left
                                    bottom: parent.bottom
                                }
                                textType: AppLabel.H4
                                text: durationToken.modelData.value + " ms"
                                color: Theme.colors.content.primary
                            }
                            Rectangle {
                                anchors {
                                    left: parent.left
                                    bottom: parent.bottom
                                }
                                height: 4
                                radius: 2
                                color: Theme.colors.action.primary.container
                                width: Math.max(16, parent.width * durationToken.modelData.value
                                                   / Theme.motion.durationSlower)
                            }
                        }
                    }
                }
            }
        }

        Surface {
            objectName: "merce.playground.motion.easingPreview"
            width: page.width
            implicitHeight: easingColumn.implicitHeight + Theme.spacing.xl2
            height: implicitHeight
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large

            Column {
                id: easingColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.xl
                }
                spacing: Theme.spacing.sm

                Item {
                    width: parent.width
                    height: Math.max(sectionHeading.implicitHeight, reducedMotionSwitch.implicitHeight)

                    SectionTitle {
                        id: sectionHeading
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                        }
                        text: "Easing preview"
                    }
                    SK.Switch {
                        id: reducedMotionSwitch
                        objectName: "merce.playground.motion.reducedMotion"
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        text: "Reduced motion"
                        checked: root.reducedMotion
                        onToggled: root.reducedMotion = checked
                    }
                }

                MotionTrack {
                    objectName: "merce.playground.motion.track.standard"
                    width: parent.width
                    label: "Standard"
                    token: "standard"
                    durationValue: Theme.motion.durationNormal
                    easingValue: Theme.motion.easingDefault
                }
                MotionTrack {
                    objectName: "merce.playground.motion.track.emphasized"
                    width: parent.width
                    label: "Emphasized"
                    token: "emphasized"
                    durationValue: Theme.motion.durationSlow
                    easingValue: Theme.motion.easingEaseOut
                }
                MotionTrack {
                    objectName: "merce.playground.motion.track.decelerate"
                    width: parent.width
                    label: "Decelerate"
                    token: "decelerate"
                    durationValue: Theme.motion.durationSlower
                    easingValue: Theme.motion.easingOut
                }
            }
        }

        Surface {
            objectName: "merce.playground.motion.presets"
            width: page.width
            implicitHeight: presetColumn.implicitHeight + Theme.spacing.xl2
            height: implicitHeight
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large

            Column {
                id: presetColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.xl
                }
                spacing: 0

                SectionTitle {
                    width: parent.width
                    text: "Motion presets"
                }

                Repeater {
                    model: root.presetTokens

                    delegate: Item {
                        id: presetRow

                        required property var modelData

                        width: presetColumn.width
                        height: 44

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
                            width: parent.width * 0.28
                            textType: AppLabel.BodySmall
                            text: "motion." + presetRow.modelData.name
                            color: Theme.colors.content.primary
                        }
                        AppLabel {
                            anchors {
                                left: parent.left
                                leftMargin: parent.width * 0.28
                                verticalCenter: parent.verticalCenter
                            }
                            width: parent.width * 0.5
                            textType: AppLabel.BodySmall
                            text: presetRow.modelData.usage
                            color: Theme.colors.content.secondary
                        }
                        AppLabel {
                            anchors {
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                            }
                            width: parent.width * 0.22
                            horizontalAlignment: Text.AlignRight
                            textType: AppLabel.BodySmall
                            text: presetRow.modelData.value.duration + " ms"
                            color: Theme.colors.content.primary
                        }
                    }
                }
            }
        }
    }
}
