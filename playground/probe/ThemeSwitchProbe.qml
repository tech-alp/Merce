import QtQml
import QtQuick
import Merce.Theme

QtObject {
    property color observedBackground: Theme.colors.surface.canvas

    function fail(message, values) {
        console.error("theme-switch-probe failed", message, values)
        Qt.exit(1)
    }

    Component.onCompleted: {
        const lightColors = Theme.colors
        const lightSpacing = Theme.spacing
        const lightRadius = Theme.radius
        const lightTypography = Theme.typography
        const lightSize = Theme.size

        if (Theme.activeBrand !== "algit"
                || Theme.activeMode !== "light"
                || Theme.activeProfile !== "cart"
                || Theme.availableThemes.length !== 8
                || String(observedBackground).toLowerCase() !== "#f6f4ee") {
            fail("default state",
                 [Theme.activeBrand, Theme.activeMode, Theme.activeProfile,
                  Theme.availableThemes.length, String(observedBackground)])
            return
        }

        if (!Theme.setTheme("happy-center", "light")
                || Theme.activeBrand !== "happy-center"
                || Theme.activeMode !== "light"
                || String(observedBackground).toLowerCase() !== "#f5f4ed"
                || String(Theme.colors.action.primary.container).toLowerCase() !== "#c96442") {
            fail("Happy Center theme switch",
                 [Theme.activeBrand, Theme.activeMode, String(observedBackground),
                  String(Theme.colors.action.primary.container)])
            return
        }

        const testThemes = [
            ["merce", "light"],
            ["merce", "dark"],
            ["apple", "light"],
            ["claude", "light"],
            ["airbnb", "light"],
            ["stripe", "light"],
            ["linear", "dark"],
            ["linear", "light"]
        ]
        for (let i = 0; i < testThemes.length; ++i) {
            const brand = testThemes[i][0]
            const mode = testThemes[i][1]
            if (!Theme.setTheme(brand, mode)
                    || Theme.activeBrand !== brand
                    || Theme.activeMode !== mode) {
                fail("reference theme switch", [brand, mode, Theme.activeBrand, Theme.activeMode])
                return
            }
        }
        if (!Theme.setTheme("algit", "light")) {
            fail("default theme restore", [])
            return
        }

        if (!Theme.setTheme("algit", "dark")) {
            fail("dark switch returned false", [])
            return
        }

        if (String(observedBackground).toLowerCase() !== "#0e1514"
                || Theme.activeBrand !== "algit"
                || Theme.activeMode !== "dark"
                || Theme.colors === lightColors
                || Theme.spacing === lightSpacing
                || Theme.radius === lightRadius
                || Theme.typography === lightTypography
                || Theme.size === lightSize) {
            fail("dark switch state",
                 [Theme.activeBrand, Theme.activeMode, String(observedBackground)])
            return
        }

        if (Theme.setTheme("unknown", "dark")) {
            fail("invalid switch returned true", [])
            return
        }

        if (String(observedBackground).toLowerCase() !== "#0e1514"
                || Theme.activeBrand !== "algit"
                || Theme.activeMode !== "dark") {
            fail("invalid switch preservation",
                 [Theme.activeBrand, Theme.activeMode, String(observedBackground)])
            return
        }

        const darkColors = Theme.colors
        if (!Theme.setContext("algit", "light", "ops")) {
            fail("profile switch returned false", [])
            return
        }

        if (String(observedBackground).toLowerCase() !== "#f6f4ee"
                || Theme.activeBrand !== "algit"
                || Theme.activeMode !== "light"
                || Theme.activeProfile !== "ops"
                || Theme.size.control.minimum !== 40
                || Theme.colors === darkColors) {
            fail("profile switch state",
                 [Theme.activeBrand, Theme.activeMode, Theme.activeProfile,
                  String(observedBackground), Theme.size.control.minimum])
            return
        }

        console.log("theme-switch-probe ok",
                    Theme.activeBrand,
                    Theme.activeMode,
                    Theme.activeProfile,
                    Theme.colors.surface.canvas)
        Qt.quit()
    }
}
