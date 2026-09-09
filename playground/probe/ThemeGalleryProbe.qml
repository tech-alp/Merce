import QtQuick
import Qt.labs.StyleKit as SK
import Merce.Style
import Merce.Theme

SK.ApplicationWindow {
    id: root
    width: 1100
    height: 760
    visible: true

    SK.StyleKit.style: MerceStyle {}

    ThemeGallery {
        id: gallery
        width: 980
        anchors.centerIn: parent
    }

    property string lightText: ""

    function colorKey(value) {
        return String(value).toLowerCase()
    }

    function fail(message, values) {
        console.error("theme-gallery-probe failed", message, values)
        Qt.exit(1)
    }

    function assertSamples(label) {
        if (colorKey(gallery.observedButtonColor) !== colorKey(Theme.colors.action.primary.container)
                || colorKey(gallery.observedTextColor) !== colorKey(Theme.colors.content.primary)
                || colorKey(gallery.observedInputBorderColor) !== colorKey(Theme.colors.outline.subtle)
                || colorKey(gallery.observedToggleColor) !== colorKey(Theme.colors.action.primary.container)
                || colorKey(gallery.observedSelectColor) !== colorKey(Theme.colors.content.primary)
                || colorKey(gallery.observedToastColor) !== colorKey(Theme.colors.status.success.content)
                || colorKey(gallery.observedToastSurfaceColor) !== colorKey(Theme.colors.surface.floating)
                || colorKey(gallery.observedToastTextColor) !== colorKey(Theme.colors.content.primary)
                || colorKey(gallery.observedToastCloseColor) !== colorKey(Theme.colors.content.primary)
                || colorKey(gallery.observedToastTextColor) === colorKey(gallery.observedToastSurfaceColor)
                || colorKey(gallery.observedDialogColor) !== colorKey(Theme.colors.surface.container)) {
            fail(label + " sample observations",
                 [gallery.observedButtonColor,
                  gallery.observedTextColor,
                  gallery.observedInputBorderColor,
                  gallery.observedToggleColor,
                  gallery.observedSelectColor,
                  gallery.observedToastColor,
                  gallery.observedToastSurfaceColor,
                  gallery.observedToastTextColor,
                  gallery.observedToastCloseColor,
                  gallery.observedDialogColor,
                  Theme.colors.action.primary.container,
                  Theme.colors.content.primary,
                  Theme.colors.outline.subtle,
                  Theme.colors.status.success.content,
                  Theme.colors.surface.floating,
                  Theme.colors.content.primary,
                  Theme.colors.surface.container])
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

                if (Theme.activeBrand !== "algit" || Theme.activeMode !== "light") {
                    root.fail("default theme state", [Theme.activeBrand, Theme.activeMode])
                    return
                }

                if (!root.assertSamples("light"))
                    return

                root.lightText = root.colorKey(gallery.observedTextColor)
                if (!Theme.setTheme("algit", "dark")) {
                    root.fail("dark switch returned false", [])
                    return
                }

                step = 1
                interval = 260
                restart()
                return
            }

            if (step === 1) {
                if (Theme.activeBrand !== "algit" || Theme.activeMode !== "dark") {
                    root.fail("dark theme state", [Theme.activeBrand, Theme.activeMode])
                    return
                }

                if (!root.assertSamples("dark"))
                    return

                if (root.colorKey(gallery.observedTextColor) === root.lightText) {
                    root.fail("dark sample changes", [root.lightText, gallery.observedTextColor])
                    return
                }

                console.log("theme-gallery-probe ok",
                            Theme.activeBrand,
                            Theme.activeMode,
                            Theme.colors.surface.canvas)
                Qt.quit()
            }
        }

        property int step: 0
    }
}
