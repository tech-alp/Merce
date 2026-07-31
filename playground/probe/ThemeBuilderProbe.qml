import QtQml
import Merce.Theme

ThemeBuilderShowcase {
    Timer {
        interval: 0
        running: true
        repeat: false
        onTriggered: {
            const result = playgroundThemeBuilder.saveTheme({})
            if (result.ok
                    || !String(result.error).includes("tenant-brand v1")
                    || Theme.activeBrand !== "algit"
                    || Theme.activeMode !== "light") {
                console.error("theme-builder-probe failed",
                              result.error,
                              Theme.activeBrand,
                              Theme.activeMode)
                Qt.exit(1)
                return
            }

            console.log("theme-builder-probe ok read-only",
                        Theme.activeBrand,
                        Theme.activeMode)
            Qt.quit()
        }
    }
}
