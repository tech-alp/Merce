pragma ComponentBehavior: Bound

import QtQuick
import Qt.labs.StyleKit as SK
import Merce.Theme
import Merce.Foundation
import Merce.Controls

Item {
    id: root

    objectName: "merce.playground.showcase.states"
    implicitHeight: page.implicitHeight
    height: implicitHeight

    enum PreviewState {
        DefaultState,
        HoverState,
        PressedState,
        FocusedState,
        DisabledState,
        LoadingState
    }

    readonly property bool compactLayout: width < 720
    readonly property var previewStates: [
        { "label": "Default", "value": StatesShowcase.DefaultState },
        { "label": "Hover", "value": StatesShowcase.HoverState },
        { "label": "Pressed", "value": StatesShowcase.PressedState },
        { "label": "Focused", "value": StatesShowcase.FocusedState },
        { "label": "Disabled", "value": StatesShowcase.DisabledState },
        { "label": "Loading", "value": StatesShowcase.LoadingState }
    ]

    function stateLayer(container, content, opacity) {
        return Qt.tint(container, Qt.alpha(content, opacity))
    }

    function disabledContainer(container, content) {
        return stateLayer(container, content, Theme.state.disabled.containerOpacity)
    }

    component SectionTitle: AppLabel {
        textType: AppLabel.H4
        color: Theme.colors.content.primary
        wrapMode: Text.WordWrap
    }

    component StateSample: Item {
        id: sample

        required property string kind
        required property int previewState
        required property string stateLabel
        property bool showLabel: false

        readonly property bool hoveredState: previewState === StatesShowcase.HoverState
        readonly property bool pressedState: previewState === StatesShowcase.PressedState
        readonly property bool focusedState: previewState === StatesShowcase.FocusedState
        readonly property bool disabledState: previewState === StatesShowcase.DisabledState
        readonly property bool loadingState: previewState === StatesShowcase.LoadingState
        readonly property color interactionColor: hoveredState
                                                   ? root.stateLayer(Theme.colors.action.primary.container,
                                                                     Theme.colors.action.primary.content,
                                                                     Theme.state.layer.hover)
                                                   : pressedState
                                                     ? root.stateLayer(Theme.colors.action.primary.container,
                                                                       Theme.colors.action.primary.content,
                                                                       Theme.state.layer.pressed)
                                                     : Theme.colors.action.primary.container
        readonly property color controlColor: disabledState
                                              ? root.disabledContainer(Theme.colors.action.primary.container,
                                                                       Theme.colors.action.primary.content)
                                              : interactionColor

        implicitHeight: showLabel ? 84 : 62

        AppLabel {
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
            visible: sample.showLabel
            textType: AppLabel.Caption
            text: sample.stateLabel
            color: Theme.colors.content.secondary
        }

        Item {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: 52

            Rectangle {
                anchors.centerIn: parent
                visible: sample.kind === "button"
                width: Math.min(96, parent.width - Theme.spacing.sm)
                height: 40
                radius: Theme.radius.button
                color: sample.controlColor
                border.width: sample.focusedState ? Theme.size.outline.focus
                                                  : Theme.size.outline.hairline
                border.color: sample.focusedState ? Theme.colors.outline.focus
                                                  : Theme.colors.action.primary.outline

                AppLabel {
                    anchors.centerIn: parent
                    visible: !sample.loadingState
                    textType: AppLabel.Button
                    text: "Button"
                    color: sample.disabledState ? Theme.colors.content.disabled
                                                : Theme.colors.action.primary.content
                }
                LoadingIndicator {
                    anchors.centerIn: parent
                    visible: sample.loadingState
                    running: visible
                    size: Theme.icons.small
                    color: Theme.colors.action.primary.content
                }
            }

            Rectangle {
                anchors.centerIn: parent
                visible: sample.kind === "input"
                width: Math.min(104, parent.width - Theme.spacing.sm)
                height: 40
                radius: Theme.radius.input
                color: sample.disabledState
                       ? root.disabledContainer(Theme.colors.surface.container,
                                                Theme.colors.content.primary)
                       : sample.hoveredState || sample.pressedState
                         ? root.stateLayer(Theme.colors.surface.container,
                                           Theme.colors.content.primary,
                                           sample.hoveredState ? Theme.state.layer.hover
                                                               : Theme.state.layer.pressed)
                         : Theme.colors.surface.container
                border.width: sample.focusedState ? Theme.size.outline.focus
                                                  : Theme.size.outline.hairline
                border.color: sample.focusedState ? Theme.colors.outline.focus
                                                  : Theme.colors.outline.subtle

                AppLabel {
                    anchors {
                        left: parent.left
                        leftMargin: Theme.spacing.sm
                        verticalCenter: parent.verticalCenter
                    }
                    visible: !sample.loadingState
                    textType: AppLabel.BodySmall
                    text: "Input"
                    color: sample.disabledState ? Theme.colors.content.disabled
                                                : Theme.colors.content.primary
                }
                LoadingIndicator {
                    anchors {
                        right: parent.right
                        rightMargin: Theme.spacing.sm
                        verticalCenter: parent.verticalCenter
                    }
                    visible: sample.loadingState
                    running: visible
                    size: Theme.icons.small
                    color: Theme.colors.action.primary.container
                }
            }

            Rectangle {
                anchors.centerIn: parent
                visible: sample.kind === "selection"
                width: 28
                height: 28
                radius: Theme.radius.small
                color: sample.disabledState
                       ? root.disabledContainer(Theme.colors.surface.container,
                                                Theme.colors.content.primary)
                       : sample.previewState === StatesShowcase.DefaultState
                         ? Theme.colors.surface.container
                         : Theme.colors.action.primary.container
                border.width: sample.focusedState ? Theme.size.outline.focus
                                                  : Theme.size.outline.hairline
                border.color: sample.focusedState ? Theme.colors.outline.focus
                                                  : sample.previewState === StatesShowcase.DefaultState
                                                    ? Theme.colors.outline.strong
                                                    : Theme.colors.action.primary.outline

                AppIcon {
                    anchors.centerIn: parent
                    visible: sample.previewState !== StatesShowcase.DefaultState
                             && !sample.loadingState
                    name: "material:check"
                    size: Theme.icons.small
                    color: sample.disabledState ? Theme.colors.content.disabled
                                                : Theme.colors.action.primary.content
                }
                LoadingIndicator {
                    anchors.centerIn: parent
                    visible: sample.loadingState
                    running: visible
                    size: Theme.icons.small
                    color: Theme.colors.action.primary.content
                }
            }
        }
    }

    component StateRow: Item {
        id: stateRow

        required property string label
        required property string kind

        implicitHeight: stateFlow.y + stateFlow.implicitHeight

        AppLabel {
            id: rowLabel
            anchors {
                left: parent.left
                verticalCenter: stateFlow.verticalCenter
            }
            width: root.compactLayout ? 0 : 88
            visible: !root.compactLayout
            textType: AppLabel.BodySmall
            text: stateRow.label
            color: Theme.colors.content.primary
        }

        Flow {
            id: stateFlow
            x: root.compactLayout ? 0 : rowLabel.width
            width: parent.width - x
            spacing: Theme.spacing.xs

            Repeater {
                model: root.previewStates

                delegate: StateSample {
                    required property var modelData

                    width: root.compactLayout
                           ? (stateFlow.width - stateFlow.spacing * 2) / 3
                           : (stateFlow.width - stateFlow.spacing * 5) / 6
                    height: implicitHeight
                    kind: stateRow.kind
                    previewState: modelData.value
                    stateLabel: modelData.label
                    showLabel: root.compactLayout
                }
            }
        }
    }

    component TokenLegend: Item {
        id: tokenLegend

        required property string token
        required property string usage
        required property color swatchColor

        implicitHeight: 48

        Rectangle {
            id: swatch
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            width: 16
            height: 16
            radius: Theme.radius.small
            color: tokenLegend.swatchColor
            border.width: Theme.size.outline.hairline
            border.color: Theme.colors.outline.subtle
        }
        Column {
            anchors {
                left: swatch.right
                leftMargin: Theme.spacing.sm
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            spacing: 0

            AppLabel {
                width: parent.width
                textType: AppLabel.BodySmall
                text: tokenLegend.token
                color: Theme.colors.content.primary
                elide: Text.ElideRight
            }
            AppLabel {
                width: parent.width
                textType: AppLabel.Caption
                text: tokenLegend.usage
                color: Theme.colors.content.secondary
                elide: Text.ElideRight
            }
        }
    }

    Column {
        id: page

        width: root.width
        spacing: Theme.spacing.xl

        Surface {
            objectName: "merce.playground.states.matrix"
            width: page.width
            implicitHeight: matrixColumn.implicitHeight + Theme.spacing.xl2
            height: implicitHeight
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large

            Column {
                id: matrixColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.xl
                }
                spacing: Theme.spacing.sm

                SectionTitle {
                    width: parent.width
                    text: "Component state matrix"
                }

                Item {
                    width: parent.width
                    height: 28
                    visible: !root.compactLayout

                    Row {
                        id: headerRow

                        anchors {
                            left: parent.left
                            leftMargin: 88
                            right: parent.right
                        }
                        spacing: Theme.spacing.xs

                        Repeater {
                            model: root.previewStates

                            delegate: AppLabel {
                                required property var modelData

                                width: (headerRow.width - headerRow.spacing * 5) / 6
                                horizontalAlignment: Text.AlignHCenter
                                textType: AppLabel.Caption
                                text: modelData.label
                                color: Theme.colors.content.secondary
                            }
                        }
                    }
                }

                StateRow {
                    width: parent.width
                    label: "Button"
                    kind: "button"
                }
                StateRow {
                    width: parent.width
                    label: "Input"
                    kind: "input"
                }
                StateRow {
                    width: parent.width
                    label: "Selection"
                    kind: "selection"
                }
            }
        }

        Surface {
            objectName: "merce.playground.states.liveControls"
            width: page.width
            implicitHeight: liveColumn.implicitHeight + Theme.spacing.xl2
            height: implicitHeight
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large

            Column {
                id: liveColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.xl
                }
                spacing: Theme.spacing.lg

                SectionTitle {
                    width: parent.width
                    text: "Live StyleKit states"
                }

                Flow {
                    width: parent.width
                    spacing: Theme.spacing.md

                    MButton {
                        objectName: "merce.playground.states.live.button"
                        text: "Hover or press"
                    }
                    MButton {
                        text: "Disabled"
                        enabled: false
                    }
                    MButton {
                        objectName: "merce.playground.states.live.loading"
                        text: "Loading"
                        loading: true
                        enabled: false
                    }
                    SK.TextField {
                        objectName: "merce.playground.states.live.input"
                        width: 220
                        placeholderText: "Focus this input"
                    }
                    SK.CheckBox {
                        objectName: "merce.playground.states.live.checkbox"
                        text: "Selected"
                        checked: true
                    }
                    SK.Switch {
                        objectName: "merce.playground.states.live.switch"
                        text: "Enabled"
                        checked: true
                    }
                }
            }
        }

        Surface {
            objectName: "merce.playground.states.legend"
            width: page.width
            implicitHeight: legendColumn.implicitHeight + Theme.spacing.xl2
            height: implicitHeight
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large

            Column {
                id: legendColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.xl
                }
                spacing: Theme.spacing.lg

                SectionTitle {
                    width: parent.width
                    text: "Semantic interaction tokens"
                }

                Flow {
                    id: legendFlow
                    width: parent.width
                    spacing: Theme.spacing.md

                    TokenLegend {
                        width: root.compactLayout
                               ? legendFlow.width
                               : (legendFlow.width - legendFlow.spacing * 2) / 3
                        token: "action.primary"
                        usage: "Primary actions"
                        swatchColor: Theme.colors.action.primary.container
                    }
                    TokenLegend {
                        width: root.compactLayout
                               ? legendFlow.width
                               : (legendFlow.width - legendFlow.spacing * 2) / 3
                        token: "action.destructive"
                        usage: "Destructive actions"
                        swatchColor: Theme.colors.action.destructive.container
                    }
                    TokenLegend {
                        width: root.compactLayout
                               ? legendFlow.width
                               : (legendFlow.width - legendFlow.spacing * 2) / 3
                        token: "status.success"
                        usage: "Positive status"
                        swatchColor: Theme.colors.status.success.container
                    }
                    TokenLegend {
                        width: root.compactLayout
                               ? legendFlow.width
                               : (legendFlow.width - legendFlow.spacing * 2) / 3
                        token: "status.warning"
                        usage: "Warning status"
                        swatchColor: Theme.colors.status.warning.container
                    }
                    TokenLegend {
                        width: root.compactLayout
                               ? legendFlow.width
                               : (legendFlow.width - legendFlow.spacing * 2) / 3
                        token: "outline.focus"
                        usage: "Keyboard focus"
                        swatchColor: Theme.colors.outline.focus
                    }
                    TokenLegend {
                        width: root.compactLayout
                               ? legendFlow.width
                               : (legendFlow.width - legendFlow.spacing * 2) / 3
                        token: "surface.container"
                        usage: "Control surfaces"
                        swatchColor: Theme.colors.surface.container
                    }
                }
            }
        }
    }
}
