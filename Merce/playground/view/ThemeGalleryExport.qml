import QtQuick
import Merce.Theme

Window {
    id: root
    width: 1100
    height: Math.ceil(captureFrame.height)
    visible: true
    color: Theme.colors.background.base

    readonly property string outputDirectory: typeof themeGalleryOutputDir === "undefined" ? "" : String(themeGalleryOutputDir)
    property int exportIndex: 0
    readonly property var exportStates: [
        { "brand": "merce", "mode": "light", "fileName": "merce-light.png" },
        { "brand": "merce", "mode": "dark", "fileName": "merce-dark.png" },
        { "brand": "stripe", "mode": "", "fileName": "stripe-reference.png" }
    ]

    Rectangle {
        id: captureFrame
        width: root.width
        height: gallery.implicitHeight + Theme.spacing.xl2 * 2
        color: Theme.colors.background.base

        ThemeGallery {
            id: gallery
            width: 980
            x: (parent.width - width) / 2
            y: Theme.spacing.xl2
        }
    }

    function fail(message, values) {
        console.error("theme-gallery-export failed", message, values)
        Qt.exit(1)
    }

    function outputPath(fileName) {
        return root.outputDirectory + "/" + fileName
    }

    function switchTheme(state) {
        if (state.brand === "stripe")
            return Theme.setTheme("stripe")
        return Theme.setTheme(state.brand, state.mode)
    }

    function exportCurrentState() {
        const state = exportStates[exportIndex]
        const path = outputPath(state.fileName)
        captureFrame.grabToImage(function(result) {
            if (!result.saveToFile(path)) {
                root.fail("save failed", [path])
                return
            }

            exportIndex += 1
            exportTimer.restart()
        }, Qt.size(captureFrame.width, captureFrame.height))
    }

    Timer {
        id: settleTimer
        interval: 320
        repeat: false
        onTriggered: root.exportCurrentState()
    }

    Timer {
        id: exportTimer
        interval: 80
        running: true
        repeat: false

        onTriggered: {
            if (root.outputDirectory.length === 0) {
                root.fail("missing output directory", [])
                return
            }

            if (exportIndex >= exportStates.length) {
                console.log("theme-gallery-export ok", root.outputDirectory)
                Qt.quit()
                return
            }

            const state = exportStates[exportIndex]
            if (!root.switchTheme(state)) {
                root.fail("theme switch failed", [state.brand, state.mode])
                return
            }

            settleTimer.restart()
        }
    }
}
