pragma Singleton
pragma ComponentBehavior: Bound

import QtQml

/**
 * Application-wide notification command surface.
 *
 * The application owns one visual NotificationHost. Feature code calls this
 * singleton and keeps the action next to the request that caused it:
 *
 *   NotificationCenter.notify(NotificationCenter.Info, qsTr("Ready"))
 *
 *   NotificationCenter.ask({
 *       owner: page,
 *       requestId: "delete-42",
 *       title: qsTr("Delete item?"),
 *       onAccepted: function(data) { viewModel.remove(data.id) }
 *   })
 *
 * `owner` is optional but recommended. If it is destroyed while the dialog is
 * open, its callbacks are suppressed. A started request settles exactly once:
 * onAccepted(data), onCancelled(data), or onTimedOut(); then
 * onClosed("accepted" | "cancelled" | "timedOut", data). A request which never
 * opens calls onRefused(activeRequestId) and does not call onClosed().
 *
 * Toast click callbacks accept the same optional owner as the final argument.
 * Prefer the toastClicked signal when the caller already has lifecycle-bound
 * Connections.
 */
QtObject {
    id: root

    enum Type {
        Info,
        Success,
        Warning,
        Error
    }

    readonly property QtObject m_state: QtObject {
        property bool hostAttached: false
        property int sequence: 0
        readonly property var requests: ({})
        readonly property var toastCallbacks: ({})
    }

    readonly property Component m_ownerGuardFactory: Component {
        QtObject {
            required property string callbackRequestId

            Component.onDestruction: root.m_ownerDestroyed(callbackRequestId)
        }
    }

    readonly property Component m_toastOwnerGuardFactory: Component {
        QtObject {
            required property string toastId

            Component.onDestruction: root.m_toastOwnerDestroyed(toastId)
        }
    }

    signal toastRequested(var request)
    signal dismissToastRequested(string toastId)
    signal dismissAllToastsRequested()
    signal dialogRequested(var command)
    signal cancelActiveRequested()

    signal result(string requestId, bool accepted, var data)
    signal timedOut(string requestId)
    signal refused(string requestId, string activeRequestId)
    signal toastClicked(string toastId)

    function attachHost() {
        if (root.m_state.hostAttached) {
            console.warn("NotificationCenter: only one NotificationHost can be attached")
            return false
        }

        root.m_state.hostAttached = true
        return true
    }

    function detachHost() {
        root.m_state.hostAttached = false
    }

    function notify(type, title, message, dwellMs, onClicked, owner) {
        if (!root.m_state.hostAttached) {
            console.warn("NotificationCenter.notify: no NotificationHost is attached")
            return ""
        }
        if (typeof type !== "number" || !Number.isInteger(type)
                || type < NotificationCenter.Info
                || type > NotificationCenter.Error) {
            console.warn("NotificationCenter.notify: invalid notification type")
            return ""
        }

        const hasOwner = typeof onClicked === "function"
                      && owner !== undefined && owner !== null
        const toastId = "toast-" + (++root.m_state.sequence)
        const request = {
            toastId: toastId,
            type: type,
            title: title || "",
            message: message || "",
            dwellMs: dwellMs,
            hasClickAction: typeof onClicked === "function"
        }
        if (request.hasClickAction) {
            const entry = {
                hasOwner: hasOwner,
                ownerAlive: true,
                ownerGuard: null,
                onClicked: onClicked
            }
            root.m_state.toastCallbacks[root.m_toastKey(toastId)] = entry
            if (hasOwner) {
                entry.ownerGuard = root.m_toastOwnerGuardFactory.createObject(
                            owner, { toastId: toastId })
            }
        }

        root.toastRequested(request)
        return toastId
    }

    function info(title, message, dwellMs, onClicked, owner) {
        return root.notify(NotificationCenter.Info, title, message, dwellMs,
                           onClicked, owner)
    }

    function success(title, message, dwellMs, onClicked, owner) {
        return root.notify(NotificationCenter.Success, title, message, dwellMs,
                           onClicked, owner)
    }

    function warning(title, message, dwellMs, onClicked, owner) {
        return root.notify(NotificationCenter.Warning, title, message, dwellMs,
                           onClicked, owner)
    }

    function error(title, message, dwellMs, onClicked, owner) {
        return root.notify(NotificationCenter.Error, title, message, dwellMs,
                           onClicked, owner)
    }

    function dismissToast(toastId) {
        if (root.m_state.hostAttached)
            root.dismissToastRequested(toastId)
    }

    function dismissAllToasts() {
        if (root.m_state.hostAttached)
            root.dismissAllToastsRequested()
    }

    function ask(request) {
        if (!request || !request.requestId) {
            console.warn("NotificationCenter.ask: requestId is required")
            return ""
        }
        if (!root.m_state.hostAttached) {
            console.warn("NotificationCenter.ask: no NotificationHost is attached")
            return ""
        }

        const activeEntry = root.m_requestEntry(request.requestId)
        if (activeEntry) {
            root.refused(request.requestId, request.requestId)
            root.m_invokeRequestCallback(request, request.onRefused,
                                         [request.requestId])
            return ""
        }

        root.m_registerRequest(request)

        const command = {
            request: request,
            result: ""
        }
        root.dialogRequested(command)
        return command.result
    }

    function cancelActive() {
        if (root.m_state.hostAttached)
            root.cancelActiveRequested()
    }

    function abortRequest(requestId, data) {
        const entry = root.m_requestEntry(requestId)
        if (!entry)
            return
        if (!entry.settled)
            root.publishResult(requestId, false, data)
        root.publishClosed(requestId)
    }

    function publishResult(requestId, accepted, data) {
        const entry = root.m_requestEntry(requestId)
        if (entry && !entry.settled) {
            entry.settled = true
            entry.outcome = entry.timedOut
                ? "timedOut"
                : (accepted ? "accepted" : "cancelled")
            entry.data = data
            if (accepted)
                root.m_invoke(entry, entry.onAccepted, [data])
            else if (!entry.timedOut)
                root.m_invoke(entry, entry.onCancelled, [data])
        }
        root.result(requestId, accepted, data)
    }

    function publishClosed(requestId) {
        const key = root.m_requestKey(requestId)
        const entry = root.m_state.requests[key]
        if (!entry)
            return

        delete root.m_state.requests[key]
        root.m_invoke(entry, entry.onClosed, [entry.outcome, entry.data])
        root.m_releaseOwnerGuard(entry)
    }

    function publishTimedOut(requestId) {
        const entry = root.m_requestEntry(requestId)
        if (entry && !entry.settled && !entry.timedOut) {
            entry.timedOut = true
            entry.outcome = "timedOut"
            root.m_invoke(entry, entry.onTimedOut, [])
        }
        root.timedOut(requestId)
    }

    function publishRefused(requestId, activeRequestId) {
        const key = root.m_requestKey(requestId)
        const entry = root.m_state.requests[key]
        if (entry)
            delete root.m_state.requests[key]
        root.refused(requestId, activeRequestId)
        if (entry) {
            root.m_invoke(entry, entry.onRefused, [activeRequestId])
            root.m_releaseOwnerGuard(entry)
        }
    }

    function publishToastClicked(toastId) {
        root.toastClicked(toastId)
        const entry = root.m_state.toastCallbacks[root.m_toastKey(toastId)]
        if (!entry) {
            return
        }
        root.m_invoke(entry, entry.onClicked, [toastId])
    }

    function releaseToastRequest(toastId) {
        const key = root.m_toastKey(toastId)
        const entry = root.m_state.toastCallbacks[key]
        if (!entry)
            return
        delete root.m_state.toastCallbacks[key]
        root.m_releaseToastOwnerGuard(entry)
    }

    function m_requestKey(requestId) {
        return "request:" + String(requestId)
    }

    function m_toastKey(toastId) {
        return "toast:" + String(toastId)
    }

    function m_requestEntry(requestId) {
        return root.m_state.requests[root.m_requestKey(requestId)] || null
    }

    function m_registerRequest(request) {
        const hasCallback = typeof request.onAccepted === "function"
                         || typeof request.onCancelled === "function"
                         || typeof request.onTimedOut === "function"
                         || typeof request.onRefused === "function"
                         || typeof request.onClosed === "function"
        const hasOwner = hasCallback
                      && request.owner !== undefined && request.owner !== null
        const entry = {
            owner: hasOwner ? request.owner : null,
            hasOwner: hasOwner,
            ownerAlive: true,
            ownerGuard: null,
            onAccepted: request.onAccepted,
            onCancelled: request.onCancelled,
            onTimedOut: request.onTimedOut,
            onRefused: request.onRefused,
            onClosed: request.onClosed,
            settled: false,
            timedOut: false,
            outcome: "",
            data: null
        }
        root.m_state.requests[root.m_requestKey(request.requestId)] = entry
        if (hasOwner) {
            entry.ownerGuard = root.m_ownerGuardFactory.createObject(
                        request.owner, { callbackRequestId: request.requestId })
        }
    }

    function m_invoke(entry, callback, args) {
        if (typeof callback !== "function"
                || (entry.hasOwner && !entry.ownerAlive)) {
            return
        }

        try {
            callback.apply(null, args)
        } catch (error) {
            console.error("NotificationCenter callback failed: " + error)
        }
    }

    function m_invokeRequestCallback(request, callback, args) {
        root.m_invoke({
            hasOwner: request.owner !== undefined && request.owner !== null,
            ownerAlive: true
        }, callback, args)
    }

    function m_releaseOwnerGuard(entry) {
        if (!entry.ownerGuard)
            return

        entry.ownerGuard.callbackRequestId = ""
        entry.ownerGuard.destroy()
        entry.ownerGuard = null
    }

    function m_releaseToastOwnerGuard(entry) {
        if (!entry.ownerGuard)
            return

        entry.ownerGuard.toastId = ""
        entry.ownerGuard.destroy()
        entry.ownerGuard = null
    }

    function m_ownerDestroyed(requestId) {
        if (requestId === "")
            return

        const entry = root.m_requestEntry(requestId)
        if (!entry)
            return
        entry.ownerAlive = false
        entry.owner = null
        entry.ownerGuard = null
    }

    function m_toastOwnerDestroyed(toastId) {
        if (toastId === "")
            return

        const key = root.m_toastKey(toastId)
        const entry = root.m_state.toastCallbacks[key]
        if (!entry)
            return
        delete root.m_state.toastCallbacks[key]
        entry.ownerAlive = false
        entry.ownerGuard = null
    }

}
