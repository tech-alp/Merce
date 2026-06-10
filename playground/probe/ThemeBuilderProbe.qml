import QtQml
import Merce.Theme

ThemeBuilderShowcase {
    id: root

    themeName: "Probe Theme"

    function findByObjectName(item, objectName) {
        if (!item)
            return null
        if (item.objectName === objectName)
            return item

        const children = item.children || []
        for (let i = 0; i < children.length; ++i) {
            const match = findByObjectName(children[i], objectName)
            if (match)
                return match
        }

        return null
    }

    Timer {
        interval: 0
        running: true
        repeat: false
        onTriggered: {
            const primaryCard = root.findByObjectName(root, "merce.playground.colorTokenCard.action.primary")
            if (!primaryCard) {
                console.error("theme-builder-probe failed missing action.primary card")
                Qt.exit(1)
                return
            }

            primaryCard.colorEdited("#3366FF")
            root.bodyFont = "Roboto Mono"
            root.saveAndApply()

            if (!root.statusOk
                    || Theme.activeBrand !== "probe-theme"
                    || Theme.activeMode !== "custom"
                    || String(Theme.colors.action.primary).toLowerCase() !== "#3366ff"
                    || Theme.typography.fontBody !== "Roboto Mono") {
                console.error("theme-builder-probe failed",
                              root.statusMessage,
                              Theme.activeBrand,
                              Theme.activeMode,
                              Theme.colors.action.primary,
                              Theme.typography.fontBody)
                Qt.exit(1)
                return
            }

            console.log("theme-builder-probe ok", Theme.activeBrand, Theme.activeMode, Theme.colors.action.primary)
            Qt.quit()
        }
    }
}
