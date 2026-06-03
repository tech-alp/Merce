import QtQml
import Merce.Core

QtObject {
    Component.onCompleted: {
        const backgroundBase = String(Theme.palette.backgroundBase).toLowerCase()
        const compatibilityBase = String(Theme.colors.background.base).toLowerCase()
        const bodyFont = String(Theme.typography.fontBody)

        if (backgroundBase !== "#faf8f6"
                || compatibilityBase !== "#faf8f6"
                || Theme.spacing.md !== 16
                || Theme.radius.button !== 12
                || bodyFont !== "DM Sans"
                || Theme.icons.small !== 20
                || !Theme.palette.textPrimary
                || !Theme.colors.action.base("primary")) {
            console.error("theme-probe failed",
                          backgroundBase,
                          compatibilityBase,
                          Theme.spacing.md,
                          Theme.radius.button,
                          bodyFont,
                          Theme.icons.small)
            Qt.exit(1)
            return
        }

        console.log("theme-probe ok",
                    Theme.palette.backgroundBase,
                    Theme.colors.background.base,
                    Theme.spacing.md,
                    Theme.radius.button,
                    bodyFont,
                    Theme.icons.small)
        Qt.quit()
    }
}
