import QtQuick
import QtQuick.Layouts
import Qt.labs.StyleKit as SK
import Merce.Foundation
import Merce.Theme

/**
 * MDialog - modal dialog chrome.
 *
 * Owns the scrim, surface, header, divider and action row. The body is a slot:
 * anything declared inside an MDialog lands in a ColumnLayout between the message
 * and the actions, so a product card, a candidate list and a PIN keypad all reuse
 * the same chrome without the chrome knowing what they are.
 *
 * The request/result contract is uniform. Callers pass a requestId and receive
 * exactly one result() for it, whether the user confirmed, cancelled or dismissed.
 *
 * Deliberately an Item and not a Popup. Popup gives stacking, close policies and
 * exit transitions; a cart flow needs none of them — one flow is open at a time
 * and it ends only on a decision or its timeout. What Popup did give us was two
 * lifecycle bugs: a reused instance had the next request swallowed by the
 * previous exit transition, and a per-request instance crashed on destruction.
 * Opening is `visible = true`.
 */
Item {
    id: root

    enum Variant {
        Default,
        Warning,
        Destructive
    }

    enum Size {
        Small,
        Medium,
        Large
    }

    // Body slot for declarative use. Children get Layout attached properties, as
    // in any ColumnLayout.
    default property alias body: bodySlot.data

    // Body slot for dynamic use, when the dialog is created per request and the
    // caller has a Component rather than children to hand over.
    property Component bodyComponent: null

    property string requestId: ""
    property string title: ""
    property string message: ""
    property string confirmText: qsTr("Confirm")
    property string cancelText: qsTr("Cancel")
    property bool showConfirm: true
    property bool showCancel: true
    property int variant: MDialog.Default
    property int size: MDialog.Medium

    /**
     * A blocking dialog demands a decision: no escape, no click-outside, no close
     * button. Used for fraud alerts, where dismissing is not an acceptable answer.
     */
    property bool blocking: false

    /**
     * Milliseconds before the flow ends itself. 0 disables the timeout.
     * A timeout counts as not accepted, and is reported separately so the caller
     * can tell "the customer said no" from "the customer walked away".
     */
    property int autoDismissMs: 0

    /** Payload echoed back in result(), so callers need no side channel. */
    property var payload: null

    /** True between request() and the outcome. */
    readonly property bool opened: root.visible

    /** Emitted exactly once per request(), whatever the outcome. */
    signal result(string requestId, bool accepted, var data)

    /** Emitted before result() when the flow ended on its timeout. */
    signal timedOut(string requestId)

    /** Emitted after the dialog leaves the screen. */
    signal closed()

    anchors.fill: parent
    visible: false
    // Above application content; the host owns the only instance on screen.
    z: 1000

    // Guards the contract: exactly one result per request, never zero, never two.
    property bool _settled: true

    function request(id, data) {
        if (id !== undefined)
            root.requestId = id
        if (data !== undefined)
            root.payload = data
        root._settled = false
        root.visible = true
        surface.forceActiveFocus()
        if (root.autoDismissMs > 0)
            autoDismissTimer.restart()
    }

    function confirm() {
        root._settle(true)
    }

    function cancel() {
        root._settle(false)
    }

    function dismiss() {
        root._settle(false)
    }

    function _settle(accepted) {
        if (root._settled)
            return
        root._settled = true
        autoDismissTimer.stop()
        root.result(root.requestId, accepted, root.payload)
        root.visible = false
        root.closed()
    }

    function dialogWidth(value) {
        switch (value) {
        case MDialog.Small:
            return Theme.size.dialog.small
        case MDialog.Large:
            return Theme.size.dialog.large
        default:
            return Theme.size.dialog.medium
        }
    }

    Timer {
        id: autoDismissTimer

        interval: root.autoDismissMs
        running: false
        repeat: false
        onTriggered: {
            // Reported before the result, so a caller can tell "the customer
            // said no" from "the customer walked away".
            root.timedOut(root.requestId)
            root.dismiss()
        }
    }

    // Scrim. Also swallows every press, which is what makes this modal.
    Rectangle {
        anchors.fill: parent
        color: Theme.colors.surface.scrim

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (!root.blocking)
                    root.dismiss()
            }
        }
    }

    Rectangle {
        id: surface

        objectName: root.objectName + ".surface"
        anchors.centerIn: parent
        width: Math.min(root.dialogWidth(root.size),
                        root.width - Theme.spacing.xl2)
        implicitHeight: dialogContent.implicitHeight + Theme.spacing.xl * 2
        height: Math.min(implicitHeight, root.height - Theme.spacing.xl2)
        color: Theme.colors.surface.floating
        radius: Theme.radius.dialog
        focus: root.visible

        Keys.onEscapePressed: (event) => {
            if (root.blocking) {
                event.accepted = false
                return
            }
            root.dismiss()
            event.accepted = true
        }

        Keys.onReturnPressed: (event) => {
            if (!root.showConfirm) {
                event.accepted = false
                return
            }
            root.confirm()
            event.accepted = true
        }

        // Presses on the surface must not reach the scrim below it.
        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            id: dialogContent

            objectName: root.objectName + ".content"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.spacing.xl
            spacing: Theme.spacing.lg
            Accessible.role: Accessible.Dialog
            Accessible.name: root.title + (root.title !== "" && root.message !== "" ? ": " : "") + root.message

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.md
                visible: root.title !== "" || root.variant !== MDialog.Default || !root.blocking

                AppIcon {
                    visible: root.variant !== MDialog.Default
                    name: root.variant === MDialog.Destructive ? "material:error" : "material:warning"
                    size: Theme.icons.large
                    color: root.variant === MDialog.Destructive
                        ? Theme.colors.status.error.content
                        : Theme.colors.status.warning.content
                }

                AppLabel {
                    Layout.fillWidth: true
                    visible: root.title !== ""
                    text: root.title
                    textType: AppLabel.H3
                    wrapMode: Text.WordWrap
                    color: Theme.colors.content.primary
                }

                SK.ToolButton {
                    objectName: root.objectName + ".close"
                    // A blocking dialog offers no way out but the actions.
                    visible: !root.blocking
                    Layout.preferredWidth: Theme.spacing.touchTargetCompact
                    Layout.preferredHeight: Theme.spacing.touchTargetCompact
                    text: "×"
                    Accessible.name: qsTr("Close")
                    onClicked: root.dismiss()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                visible: root.title !== ""
                implicitHeight: Theme.size.outline.hairline
                color: Theme.colors.outline.subtle
            }

            AppLabel {
                Layout.fillWidth: true
                visible: root.message !== ""
                text: root.message
                textType: AppLabel.Body
                wrapMode: Text.WordWrap
                color: Theme.colors.content.secondary
            }

            ColumnLayout {
                id: bodySlot

                objectName: root.objectName + ".body"
                Layout.fillWidth: true
                spacing: Theme.spacing.md
                // An empty slot must not add a gap between message and actions.
                visible: bodySlot.children.length > 0

                Loader {
                    Layout.fillWidth: true
                    active: root.bodyComponent !== null
                    sourceComponent: root.bodyComponent
                    onLoaded: {
                        if (item && "payload" in item)
                            item["payload"] = root.payload
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.sm
                visible: root.showConfirm || root.showCancel

                Item {
                    Layout.fillWidth: true
                }

                SK.Button {
                    objectName: root.objectName + ".cancel"
                    visible: root.showCancel
                    text: root.cancelText
                    SK.StyleVariation.variations: ["outline"]
                    onClicked: root.cancel()
                }

                SK.Button {
                    objectName: root.objectName + ".confirm"
                    visible: root.showConfirm
                    text: root.confirmText
                    SK.StyleVariation.variations: root.variant === MDialog.Destructive
                        ? ["destructive"]
                        : []
                    onClicked: root.confirm()
                }
            }
        }
    }
}
