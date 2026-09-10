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
 *   NotificationCenter.success(qsTr("Added"), productName)
 *   NotificationCenter.ask({ requestId: "removal-42",
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

    /** Component tier: how long a toast stays readable at arm's length. */
    property int defaultDwellMs: 5000
    property bool expandToasts: true
    property int visibleToastLimit: 5
    property var m_toasts: ({})
    property MDialog m_dialog: null
    property var m_pending: null
    property bool m_centerAttached: false

    /** The flow currently on screen, or "" when idle. */
    readonly property string activeRequestId: host.m_dialog ? host.m_dialog.requestId : ""
    readonly property bool busy: host.m_dialog !== null

    /** Emitted once per started flow, whatever the outcome. */
    signal result(string requestId, bool accepted, var data)

    /** Emitted when a flow ends on its timeout rather than on a decision. */
    signal timedOut(string requestId)

    /** Emitted when a request is refused because a flow is already open. */
    signal refused(string requestId, string activeRequestId)

    /** Emitted when a toast with a click action is clicked. */
    signal toastClicked(string toastId)

    anchors.fill: parent

    // ── Toasts ──────────────────────────────────────────────────────────

    /**
     * type: a NotificationCenter.Type enum value. Legacy string kinds remain
     * accepted by this wrapper; new code should call NotificationCenter.
     * dwellMs: 0 keeps the toast up until dismissed.
     *
     * Toasts are not flows: they never block and are never refused.
     */
    function notify(type, title, message, dwellMs, onClicked, owner) {
        return NotificationCenter.notify(host.m_notificationType(type), title,
                                         message, dwellMs, onClicked, owner)
    }

    function m_notificationType(type) {
        switch (type) {
        case "success":
            return NotificationCenter.Success
        case "warning":
            return NotificationCenter.Warning
        case "error":
            return NotificationCenter.Error
        case "info":
            return NotificationCenter.Info
        default:
            return type
        }
    }

    function m_presentToast(request) {
        const text = request.title && request.message
            ? (request.title + ": " + request.message)
            : (request.title || request.message || "")
        const options = {
            autoClose: request.dwellMs === undefined
                ? host.defaultDwellMs
                : request.dwellMs,
            position: Toastify.TopCenter
        }

        const toastId = request.toastId
        if (request.hasClickAction) {
            options.clickAction = function() {
                host.toastClicked(toastId)
                NotificationCenter.publishToastClicked(toastId)
            }
        }

        let handle = null
        switch (request.type) {
        case NotificationCenter.Success:
            handle = toastify.success(text, options)
            break
        case NotificationCenter.Error:
            handle = toastify.error(text, options)
            break
        case NotificationCenter.Warning:
            handle = toastify.warning(text, options)
            break
        default:
            handle = toastify.info(text, options)
            break
        }

        if (handle) {
            host.m_toasts[toastId] = handle
            handle.closingChanged.connect(function() {
                if (!handle.closing)
                    return
                delete host.m_toasts[toastId]
                NotificationCenter.releaseToastRequest(toastId)
            })
        } else {
            NotificationCenter.releaseToastRequest(toastId)
        }
        return toastId
    }

    function dismissToast(toastId) {
        NotificationCenter.dismissToast(toastId)
    }

    function m_dismissToast(toastId) {
        const handle = host.m_toasts[toastId]
        if (handle && handle.close)
            handle.close()
        delete host.m_toasts[toastId]
        NotificationCenter.releaseToastRequest(toastId)
    }

    function dismissAllToasts() {
        NotificationCenter.dismissAllToasts()
    }

    function m_dismissAllToasts() {
        for (const id in host.m_toasts) {
            const handle = host.m_toasts[id]
            if (handle && handle.close)
                handle.close()
            NotificationCenter.releaseToastRequest(id)
        }
        host.m_toasts = ({})
    }

    // ── Flows ───────────────────────────────────────────────────────────

    /**
     * request fields: requestId, owner, content (Component), payload, title,
     * message, confirmText, cancelText, showConfirm, showCancel, variant, size,
     * blocking, timeoutMs, onAccepted, onCancelled, onTimedOut, onRefused,
     * onClosed. NotificationCenter owns callback settlement; the host only owns
     * the visual lifecycle.
     *
     * Returns the requestId when the flow starts, "" when it is refused.
     *
     * A blocking request is the one exception: it takes over, and the flow it
     * interrupted settles as not accepted rather than vanishing without a result.
     */
    function ask(request) {
        return NotificationCenter.ask(request)
    }

    function m_ask(request) {
        if (!request || !request.requestId) {
            console.warn("NotificationHost.ask: requestId is required")
            return ""
        }

        if (host.m_pending)
            return host.m_refuse(request, host.m_pending.requestId)

        if (host.m_dialog) {
            if (!request.blocking) {
                return host.m_refuse(request, host.m_dialog.requestId)
            }
            host.m_pending = request
            host.m_dialog.cancel()
            return request.requestId
        }

        if (!host.m_start(request))
            return host.m_refuse(request, "")
        return request.requestId
    }

    function m_refuse(request, activeRequestId) {
        host.refused(request.requestId, activeRequestId)
        NotificationCenter.publishRefused(request.requestId, activeRequestId)
        return ""
    }

    /** Ends the open flow. It still settles, so no caller waits on a lost result. */
    function cancelActive() {
        NotificationCenter.cancelActive()
    }

    function m_cancelActive() {
        if (host.m_dialog)
            host.m_dialog.cancel()
    }

    Component.onCompleted: {
        host.m_centerAttached = NotificationCenter.attachHost()
    }

    Component.onDestruction: {
        if (host.m_centerAttached) {
            host.m_centerAttached = false
            NotificationCenter.detachHost()
        }
        if (host.m_dialog) {
            host.result(host.m_dialog.requestId, false, host.m_dialog.payload)
            NotificationCenter.abortRequest(host.m_dialog.requestId,
                                            host.m_dialog.payload)
        }
        if (host.m_pending) {
            const pendingPayload = host.m_pending.payload !== undefined
                ? host.m_pending.payload
                : null
            host.result(host.m_pending.requestId, false,
                        pendingPayload)
            NotificationCenter.abortRequest(host.m_pending.requestId,
                                            pendingPayload)
        }
    }

    Connections {
        target: NotificationCenter
        enabled: host.m_centerAttached

        function onToastRequested(request) {
            host.m_presentToast(request)
        }

        function onDismissToastRequested(toastId) {
            host.m_dismissToast(toastId)
        }

        function onDismissAllToastsRequested() {
            host.m_dismissAllToasts()
        }

        function onDialogRequested(command) {
            command.result = host.m_ask(command.request)
        }

        function onCancelActiveRequested() {
            host.m_cancelActive()
        }
    }

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
            return false
        }

        host.m_dialog = dialog
        dialog.result.connect(host.m_onResult)
        dialog.timedOut.connect(host.m_onTimedOut)
        dialog.closed.connect(host.m_onClosed)
        dialog.request(request.requestId, dialog.payload)
        return true
    }

    function m_onResult(requestId, accepted, data) {
        host.result(requestId, accepted, data)
        NotificationCenter.publishResult(requestId, accepted, data)
    }

    function m_onTimedOut(requestId) {
        host.timedOut(requestId)
        NotificationCenter.publishTimedOut(requestId)
    }

    function m_onClosed() {
        const finished = host.m_dialog
        const finishedRequestId = finished ? finished.requestId : ""
        host.m_dialog = null
        if (finished) {
            finished.objectName = ""
            // Deleted on a later tick because this handler runs inside the
            // dialog's own closed() emission.
            finished.result.disconnect(host.m_onResult)
            finished.timedOut.disconnect(host.m_onTimedOut)
            finished.closed.disconnect(host.m_onClosed)
            finished.destroy(1)
        }

        // Keep the pending request visible to m_ask while the old request's
        // onClosed callback runs. This prevents a reentrant blocking request
        // from replacing it.
        const next = host.m_pending
        if (finishedRequestId !== "")
            NotificationCenter.publishClosed(finishedRequestId)

        host.m_pending = null
        if (next && !host.m_start(next))
            host.m_refuse(next, "")
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
        expand: host.expandToasts
        visibleToasts: host.visibleToastLimit
        style: MToastStyle {}
    }
}
