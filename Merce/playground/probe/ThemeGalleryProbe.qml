import QtQuick
import Merce.Core

Window {
    id: root
    width: 1100
    height: 760
    visible: true
    color: Theme.palette.backgroundBase

    ThemeGallery {
        id: gallery
        width: 980
        anchors.centerIn: parent
    }

    property string lightText: ""
    property string darkButton: ""

    function colorKey(value) {
        return String(value).toLowerCase()
    }

    function fail(message, values) {
        console.error("theme-gallery-probe failed", message, values)
        Qt.exit(1)
    }

    function assertSamples(label) {
        if (colorKey(gallery.observedButtonColor) !== colorKey(Theme.palette.actionPrimary)
                || colorKey(gallery.observedTextColor) !== colorKey(Theme.palette.textPrimary)
                || colorKey(gallery.observedInputBorderColor) !== colorKey(Theme.palette.borderBase)
                || colorKey(gallery.observedToggleColor) !== colorKey(Theme.palette.actionPrimary)
                || colorKey(gallery.observedSelectColor) !== colorKey(Theme.palette.textPrimary)
                || colorKey(gallery.observedToastColor) !== colorKey(Theme.palette.status.success)
                || colorKey(gallery.observedDialogColor) !== colorKey(Theme.palette.backgroundSurface)) {
            fail(label + " sample observations",
                 [gallery.observedButtonColor,
                  gallery.observedTextColor,
                  gallery.observedInputBorderColor,
                  gallery.observedToggleColor,
                  gallery.observedSelectColor,
                  gallery.observedToastColor,
                  gallery.observedDialogColor,
                  Theme.palette.actionPrimary,
                  Theme.palette.textPrimary,
                  Theme.palette.borderBase,
                  Theme.palette.status.success,
                  Theme.palette.backgroundSurface])
            return false
        }

        return true
    }

    Timer {
        id: verifyTimer
        interval: 60
        running: true
        repeat: false

        onTriggered: {
            if (step === 0) {
                if (gallery.objectName !== "merce.playground.gallery" || !gallery.hasRequiredAnchors) {
                    root.fail("required gallery anchors", [gallery.objectName, gallery.hasRequiredAnchors])
                    return
                }

                if (Theme.activeBrand !== "merce" || Theme.activeMode !== "light") {
                    root.fail("default theme state", [Theme.activeBrand, Theme.activeMode])
                    return
                }

                if (!root.assertSamples("light"))
                    return

                root.lightText = root.colorKey(gallery.observedTextColor)
                if (!Theme.setTheme("merce", "dark")) {
                    root.fail("dark switch returned false", [])
                    return
                }

                step = 1
                interval = 260
                restart()
                return
            }

            if (step === 1) {
                if (Theme.activeBrand !== "merce" || Theme.activeMode !== "dark") {
                    root.fail("dark theme state", [Theme.activeBrand, Theme.activeMode])
                    return
                }

                if (!root.assertSamples("dark"))
                    return

                if (root.colorKey(gallery.observedTextColor) === root.lightText) {
                    root.fail("dark sample changes", [root.lightText, gallery.observedTextColor])
                    return
                }

                root.darkButton = root.colorKey(gallery.observedButtonColor)
                if (!Theme.setTheme("stripe")) {
                    root.fail("stripe switch returned false", [])
                    return
                }

                step = 2
                interval = 260
                restart()
                return
            }

            if (Theme.activeBrand !== "stripe" || Theme.activeMode !== "") {
                root.fail("stripe theme state", [Theme.activeBrand, Theme.activeMode])
                return
            }

            if (!root.assertSamples("stripe"))
                return

            if (root.colorKey(gallery.observedButtonColor) === root.darkButton) {
                root.fail("stripe sample changes", [root.darkButton, gallery.observedButtonColor])
                return
            }

            console.log("theme-gallery-probe ok", Theme.activeBrand, Theme.activeMode, Theme.palette.backgroundBase)
            Qt.quit()
        }

        property int step: 0
    }
}
