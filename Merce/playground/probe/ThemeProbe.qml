import QtQml
import Merce.Theme

QtObject {
    function fail(message, values) {
        console.error("theme-probe failed", message, values)
        Qt.exit(1)
    }

    Component.onCompleted: {
        const backgroundBase = String(Theme.colors.background.base).toLowerCase()
        const textPrimary = String(Theme.colors.text.primary).toLowerCase()
        const actionPrimary = String(Theme.colors.action.primary).toLowerCase()
        const bodyFont = String(Theme.typography.fontBody)

        if (backgroundBase !== "#faf8f6"
                || textPrimary !== "#1f1510"
                || actionPrimary !== "#c4785a"
                || Theme.spacing.md !== 16
                || Theme.radius.button !== 12
                || bodyFont !== "Inter"
                || Theme.iconography.small !== 20
                || Theme.breakpoints.large !== 1024
                || Theme.activeBrand !== "merce"
                || Theme.activeMode !== "light") {
            fail("default canonical state",
                 [backgroundBase,
                  textPrimary,
                  actionPrimary,
                  Theme.spacing.md,
                  Theme.radius.button,
                  bodyFont,
                  Theme.iconography.small,
                  Theme.breakpoints.large,
                  Theme.activeBrand,
                  Theme.activeMode])
            return
        }

        console.log("theme-probe ok",
                    Theme.colors.background.base,
                    Theme.colors.text.primary,
                    Theme.colors.action.primary,
                    Theme.spacing.md,
                    Theme.radius.button,
                    bodyFont,
                    Theme.iconography.small,
                    Theme.breakpoints.large,
                    Theme.activeBrand,
                    Theme.activeMode)
        Qt.quit()
    }
}
