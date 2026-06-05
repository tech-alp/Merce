import QtQml
import QtQuick
import Merce.Core

QtObject {
    property color observedBackground: Theme.colors.background.base

    function fail(message, values) {
        console.error("theme-switch-probe failed", message, values)
        Qt.exit(1)
    }

    Component.onCompleted: {
        const palette = Theme.colors
        const spacing = Theme.spacing
        const radius = Theme.radius
        const typography = Theme.typography

        if (Theme.activeBrand !== "merce"
                || Theme.activeMode !== "light"
                || String(observedBackground).toLowerCase() !== "#faf8f6") {
            fail("default state",
                 [Theme.activeBrand, Theme.activeMode, String(observedBackground)])
            return
        }

        if (!Theme.setTheme("merce", "dark")) {
            fail("dark switch returned false", [])
            return
        }

        if (String(observedBackground).toLowerCase() !== "#1f1510"
                || Theme.activeBrand !== "merce"
                || Theme.activeMode !== "dark"
                || Theme.colors !== palette
                || Theme.spacing !== spacing
                || Theme.radius !== radius
                || Theme.typography !== typography) {
            fail("dark switch state",
                 [Theme.activeBrand, Theme.activeMode, String(observedBackground)])
            return
        }

        if (Theme.setTheme("unknown", "dark")) {
            fail("invalid switch returned true", [])
            return
        }

        if (String(observedBackground).toLowerCase() !== "#1f1510"
                || Theme.activeBrand !== "merce"
                || Theme.activeMode !== "dark") {
            fail("invalid switch preservation",
                 [Theme.activeBrand, Theme.activeMode, String(observedBackground)])
            return
        }

        if (!Theme.setTheme("stripe")) {
            fail("stripe switch returned false", [])
            return
        }

        if (String(observedBackground).toLowerCase() !== "#f6f9fc"
                || Theme.activeBrand !== "stripe"
                || Theme.activeMode !== ""
                || Theme.colors !== palette
                || Theme.spacing !== spacing
                || Theme.radius !== radius
                || Theme.typography !== typography) {
            fail("stripe switch state",
                 [Theme.activeBrand, Theme.activeMode, String(observedBackground)])
            return
        }

        console.log("theme-switch-probe ok",
                    Theme.activeBrand,
                    Theme.activeMode,
                    Theme.colors.background.base)
        Qt.quit()
    }
}
