import QtQuick
import Toastify

/**
 * NotificationHost - the single surface every notification goes through.
 *
 * One flow at a time. While a flow is open a new one does not start: it is
 * refused, not queued. Queuing would mean the customer scans an item, nothing
 * appears, and twenty seconds later a dialog about that item shows up on its
 * own. A flow ends only by the customer's decision or by its timeout.
 *
 *   host.notify("success", qsTr("Added"), productName)
 *   host.ask({ requestId: "removal-42",
 *              content: removalCandidates,   // a Component
 *              payload: { candidates: [...] },
 *              timeoutMs: 20000,
 *              variant: MDialog.Destructive })
 *
 * A content Component may declare `property var payload`; the host assigns the
 * request's payload to it once loaded.
 *
 * The dialog is created per request and destroyed with it. Reusing one Popup
 * instance across close/open cycles was unreliable: the next request opened and
 * was immediately swallowed by the previous one's pending exit transition.
 */
Item {
    id: host

    /** Emitted once per started flow, whatever the outcome. */
    signal result(string requestId, bool accepted, var data)

    /** Emitted when a flow ends on its timeout rather than on a decision. */
    signal timedOut(string requestId)

    /** Emitted when a request is refused because a flow is already open. */
    signal refused(string requestId, string activeRequestId)

    /** Emitted when a toast with a click action is clicked. */
    signal toastClicked(string toastId)

    /** The flow currently on screen, or "" when idle. */
    readonly property string activeRequestId: host.m_dialog ? host.m_dialog.requestId : ""
    readonly property bool busy: host.m_dialog !== null

    anchors.fill: parent

    // ── Toasts ──────────────────────────────────────────────────────────

    /** Component tier: how long a toast stays readable at arm's length. */
    property int defaultDwellMs: 5000

    /**
     * kind: "info" | "success" | "warning" | "error"
     * dwellMs: 0 keeps the toast up until dismissed.
     *
     * Toasts are not flows: they never block and are never refused.
     */
    function notify(kind, title, message, dwellMs, onClicked) {
        const text = title && message ? (title + ": " + message)
                                      : (title || message || "")
        const options = {
            autoClose: dwellMs === undefined ? host.defaultDwellMs : dwellMs,
            position: Toastify.TopCenter
        }

        const toastId = "toast-" + (++host.m_sequence)
        if (onClicked) {
            options.clickAction = function() {
                host.toastClicked(toastId)
                onClicked(toastId)
            }
        }

        let handle = null
        switch (kind) {
        case "success":
            handle = toastify.success(text, options)
            break
        case "error":
            handle = toastify.error(text, options)
            break
        case "warning":
            handle = toastify.warning(text, options)
            break
        default:
            handle = toastify.info(text, options)
            break
        }

        if (handle)
            host.m_toasts[toastId] = handle
        return toastId
    }

    function dismissToast(toastId) {
        const handle = host.m_toasts[toastId]
        if (handle && handle.close)
            handle.close()
        delete host.m_toasts[toastId]
    }

    function dismissAllToasts() {
        for (const id in host.m_toasts) {
            const handle = host.m_toasts[id]
            if (handle && handle.close)
                handle.close()
        }
        host.m_toasts = ({})
    }

    // ── Flows ───────────────────────────────────────────────────────────

    /**
     * request fields: requestId, content (Component), payload, title, message,
     * confirmText, cancelText, showConfirm, showCancel, variant, size,
     * blocking, timeoutMs.
     *
     * Returns the requestId when the flow starts, "" when it is refused.
     *
     * A blocking request is the one exception: it takes over, and the flow it
     * interrupted settles as not accepted rather than vanishing without a result.
     */
    function ask(request) {
        if (!request || !request.requestId) {
            console.warn("NotificationHost.ask: requestId is required")
            return ""
        }

        if (host.m_dialog) {
            if (!request.blocking) {
                host.refused(request.requestId, host.m_dialog.requestId)
                return ""
            }
            host.m_pending = request
            host.m_dialog.cancel()
            return request.requestId
        }

        host.m_start(request)
        return request.requestId
    }

    /** Ends the open flow. It still settles, so no caller waits on a lost result. */
    function cancelActive() {
        if (host.m_dialog)
            host.m_dialog.cancel()
    }

    property var m_toasts: ({})
    property int m_sequence: 0
    property MDialog m_dialog: null
    property var m_pending: null

    function m_start(request) {
        const dialog = dialogComponent.createObject(host, {
            requestId: request.requestId,
            payload: request.payload !== undefined ? request.payload : null,
            bodyComponent: request.content || null,
            title: request.title || "",
            message: request.message || "",
            confirmText: request.confirmText !== undefined ? request.confirmText
                                                           : qsTr("Confirm"),
            cancelText: request.cancelText !== undefined ? request.cancelText
                                                         : qsTr("Cancel"),
            showConfirm: request.showConfirm !== undefined ? request.showConfirm : true,
            showCancel: request.showCancel !== undefined ? request.showCancel : true,
            variant: request.variant !== undefined ? request.variant : MDialog.Default,
            size: request.size !== undefined ? request.size : MDialog.Medium,
            blocking: request.blocking === true,
            autoDismissMs: request.timeoutMs || 0
        }) as MDialog

        if (!dialog) {
            console.warn("NotificationHost: could not create a dialog for "
                         + request.requestId)
            return
        }

        host.m_dialog = dialog
        dialog.result.connect(host.m_onResult)
        dialog.timedOut.connect(host.timedOut)
        dialog.closed.connect(host.m_onClosed)
        dialog.request(request.requestId, dialog.payload)
    }

    function m_onResult(requestId, accepted, data) {
        host.result(requestId, accepted, data)
    }

    function m_onClosed() {
        const finished = host.m_dialog
        host.m_dialog = null
        if (finished) {
            finished.objectName = ""
            // Deleted on a later tick: this runs inside the dialog's own closed()
            // emission, and Popup still touches itself after the handlers return.
            finished.result.disconnect(host.m_onResult)
            finished.closed.disconnect(host.m_onClosed)
            finished.destroy(1)
        }

        // Only a blocking request can be waiting here, and only because it took
        // over from the flow that just closed.
        const next = host.m_pending
        host.m_pending = null
        if (next)
            host.m_start(next)
    }

    Component {
        id: dialogComponent

        MDialog {
            objectName: "notificationHost.dialog"
        }
    }

    Toastify {
        id: toastify

        anchors.fill: parent
        style: MToastStyle {}
    }
}
