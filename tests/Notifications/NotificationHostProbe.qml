import QtQuick
import Qt.labs.StyleKit as SK
import Merce.Style
import Merce.Notifications

SK.ApplicationWindow {
    id: root

    property alias host: notifications

    // Result log, so the test can assert the contract rather than the visuals.
    property var results: []
    property var refusals: []
    property var timeouts: []
    property int toastCount: 0

    width: 1024
    height: 600
    visible: true

    SK.StyleKit.style: MerceStyle {}

    function reset() {
        notifications.dismissAllToasts()
        notifications.cancelActive()
        root.results = []
        root.refusals = []
        root.timeouts = []
        root.toastCount = 0
    }

    function ask(id, blocking) {
        return notifications.ask({
            requestId: id,
            content: probeBody,
            payload: { tag: id },
            title: id,
            blocking: blocking === true
        })
    }

    function askWithTimeout(id, timeoutMs) {
        return notifications.ask({
            requestId: id,
            content: probeBody,
            payload: { tag: id },
            title: id,
            timeoutMs: timeoutMs
        })
    }

    function notify(kind, text) {
        root.toastCount += 1
        return notifications.notify(kind, text, "")
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

    NotificationHost {
        id: notifications

        objectName: "notificationHost"

        onRefused: (requestId, activeRequestId) => {
            root.refusals = root.refusals.concat([{
                requestId: requestId,
                activeRequestId: activeRequestId
            }])
        }

        onTimedOut: (requestId) => {
            root.timeouts = root.timeouts.concat([requestId])
        }

        onResult: (requestId, accepted, data) => {
            root.results = root.results.concat([{
                requestId: requestId,
                accepted: accepted,
                tag: data ? data.tag : ""
            }])
        }
    }
}
