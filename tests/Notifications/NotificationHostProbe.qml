import QtQuick
import Qt.labs.StyleKit as SK
import Merce.Style
import Merce.Notifications

SK.ApplicationWindow {
    id: root

    // Result log, so the test can assert the contract rather than the visuals.
    property var results: []
    property var refusals: []
    property var timeouts: []
    property var callbackEvents: []
    property var disposableCallbackOwner: null
    property NotificationHost notifications: null
    property int toastCount: 0

    width: 1024
    height: 600
    visible: true

    SK.StyleKit.style: MerceStyle {}

    Component.onCompleted: root.createHost()

    function reset() {
        NotificationCenter.dismissAllToasts()
        NotificationCenter.cancelActive()
        root.results = []
        root.refusals = []
        root.timeouts = []
        root.callbackEvents = []
        root.toastCount = 0
    }

    function recordCallback(kind, requestId, detail) {
        root.callbackEvents = root.callbackEvents.concat([{
            kind: kind,
            requestId: requestId,
            detail: detail || ""
        }])
    }

    function askWithCallbacks(id, timeoutMs, blocking) {
        return NotificationCenter.ask({
            owner: root,
            requestId: id,
            content: probeBody,
            payload: { tag: id },
            title: id,
            timeoutMs: timeoutMs || 0,
            blocking: blocking === true,
            onAccepted: function(data) {
                root.recordCallback("accepted", id, data ? data.tag : "")
            },
            onCancelled: function(data) {
                root.recordCallback("cancelled", id, data ? data.tag : "")
            },
            onTimedOut: function() {
                root.recordCallback("timedOut", id, "")
            },
            onRefused: function(activeRequestId) {
                root.recordCallback("refused", id, activeRequestId)
            },
            onClosed: function(outcome, data) {
                root.recordCallback("closed", id,
                                    outcome + ":" + (data ? data.tag : ""))
            }
        })
    }

    function askWithReentrantBlocking(id, reentrantId) {
        return NotificationCenter.ask({
            owner: root,
            requestId: id,
            content: probeBody,
            payload: { tag: id },
            title: id,
            onCancelled: function() {
                root.recordCallback("cancelled", id, "")
                NotificationCenter.ask({
                    owner: root,
                    requestId: reentrantId,
                    content: probeBody,
                    payload: { tag: reentrantId },
                    title: reentrantId,
                    blocking: true,
                    onRefused: function(activeRequestId) {
                        root.recordCallback("reentrantRefused", reentrantId,
                                            activeRequestId)
                    }
                })
            }
        })
    }

    function askWithDisposableOwner(id) {
        root.disposableCallbackOwner = callbackOwnerFactory.createObject(root)
        return NotificationCenter.ask({
            owner: root.disposableCallbackOwner,
            requestId: id,
            content: probeBody,
            payload: { tag: id },
            title: id,
            onAccepted: function(data) {
                root.recordCallback("accepted", id, data ? data.tag : "")
            },
            onClosed: function(outcome, data) {
                root.recordCallback("closed", id,
                                    outcome + ":" + (data ? data.tag : ""))
            }
        })
    }

    function destroyDisposableOwner() {
        if (root.disposableCallbackOwner)
            root.disposableCallbackOwner.destroy()
        root.disposableCallbackOwner = null
    }

    function ask(id, blocking) {
        return NotificationCenter.ask({
            requestId: id,
            content: probeBody,
            payload: { tag: id },
            title: id,
            blocking: blocking === true
        })
    }

    function askWithTimeout(id, timeoutMs) {
        return NotificationCenter.ask({
            requestId: id,
            content: probeBody,
            payload: { tag: id },
            title: id,
            timeoutMs: timeoutMs
        })
    }

    function askDestructive(id) {
        return NotificationCenter.ask({
            requestId: id,
            content: probeBody,
            payload: { tag: id },
            title: id,
            variant: MDialog.Destructive
        })
    }

    function notify(type, text) {
        root.toastCount += 1
        return NotificationCenter.notify(type, text, "")
    }

    function notifyByType(type, text) {
        root.toastCount += 1
        return NotificationCenter.notify(type, text, "", 0)
    }

    function notifyPersistent(type, text) {
        root.toastCount += 1
        return NotificationCenter.notify(type, text, "", 0)
    }

    function notifyLegacy(kind, text) {
        root.toastCount += 1
        return notifications.notify(kind, text, "", 0)
    }

    function notifyWithDisposableOwner(type, text) {
        root.disposableCallbackOwner = callbackOwnerFactory.createObject(root)
        return NotificationCenter.notify(
                    type, text, "", 0,
                    function(toastId) {
                        root.recordCallback("toastClicked", toastId, "")
                    },
                    root.disposableCallbackOwner)
    }

    function clickToast(toastId) {
        const handle = notifications.m_toasts[toastId]
        if (handle && handle.clickAction)
            handle.clickAction()
    }

    function destroyHost() {
        const oldHost = root.notifications
        root.notifications = null
        if (oldHost)
            oldHost.destroy()
    }

    function createHost() {
        if (root.notifications)
            return
        root.notifications = notificationHostFactory.createObject(root)
    }

    function notifyPersistentShortcut(kind, text) {
        switch (kind) {
        case "success":
            return NotificationCenter.success(text, "", 0)
        case "warning":
            return NotificationCenter.warning(text, "", 0)
        case "error":
            return NotificationCenter.error(text, "", 0)
        default:
            return NotificationCenter.info(text, "", 0)
        }
    }

    function toastType(toastId) {
        const handle = notifications.m_toasts[toastId]
        return handle ? handle.type : -1
    }

    Component {
        id: probeBody

        Rectangle {
            property var payload: null

            objectName: "probeBody"
            implicitWidth: 100
            implicitHeight: 40
            color: "transparent"
        }
    }

    Component {
        id: callbackOwnerFactory

        QtObject {}
    }

    Component {
        id: notificationHostFactory

        NotificationHost {
            objectName: "notificationHost"
        }
    }

    Connections {
        target: NotificationCenter

        function onRefused(requestId, activeRequestId) {
            root.refusals = root.refusals.concat([{
                requestId: requestId,
                activeRequestId: activeRequestId
            }])
        }

        function onTimedOut(requestId) {
            root.timeouts = root.timeouts.concat([requestId])
        }

        function onResult(requestId, accepted, data) {
            root.results = root.results.concat([{
                requestId: requestId,
                accepted: accepted,
                tag: data ? data.tag : ""
            }])
        }
    }
}
