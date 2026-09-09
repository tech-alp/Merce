import QtQuick

Main {
    id: root

    visible: true
    width: auditWidths[widthIndex]
    height: auditHeights[widthIndex]

    readonly property string outputDirectory: typeof playgroundPagesOutputDir === "undefined"
                                              ? ""
                                              : String(playgroundPagesOutputDir)
    readonly property var pageKeys: [
        "theme",
        "palette",
        "typography",
        "spacing",
        "shadows",
        "motion",
        "theme-builder",
        "controls",
        "icons",
        "feedback",
        "forms",
        "states"
    ]
    readonly property var auditWidths: [1180, 760]
    readonly property var auditHeights: [760, 620]
    property int widthIndex: 0
    property int pageIndex: 0
    property bool heightAdjusted: false

    function fail(message, values) {
        console.error("playground-pages-export failed", message, values)
        Qt.exit(1)
    }

    function findNamed(item, name) {
        if (!item)
            return null
        if (String(item.objectName) === name)
            return item

        const visualChildren = item.children || []
        for (let i = 0; i < visualChildren.length; ++i) {
            const match = findNamed(visualChildren[i], name)
            if (match)
                return match
        }
        return null
    }

    function safePageName(key) {
        return String(key).replace(/[^a-z0-9]+/g, "-")
    }

    function outputPath() {
        return outputDirectory + "/" + auditWidths[widthIndex] + "-"
                + safePageName(pageKeys[pageIndex]) + ".png"
    }

    function currentFlickable() {
        const stack = findNamed(root.contentItem, "merce.playground.pageStack")
        if (!stack || !stack.currentItem)
            return null
        return findNamed(stack.currentItem, String(stack.currentItem.objectName) + ".flickable")
    }

    function captureCurrentPage() {
        const flickable = currentFlickable()
        if (!flickable) {
            fail("page flickable missing", [pageKeys[pageIndex]])
            return
        }

        if (!heightAdjusted) {
            const chromeHeight = (root.header ? root.header.height : 0)
                    + (root.footer ? root.footer.height : 0)
            root.height = Math.max(auditHeights[widthIndex],
                                   Math.ceil(flickable.contentHeight + chromeHeight))
            heightAdjusted = true
            settleTimer.restart()
            return
        }

        const path = outputPath()
        const captureTarget = findNamed(root.contentItem, "merce.playground.content")
        if (!captureTarget) {
            fail("capture target missing", [pageKeys[pageIndex]])
            return
        }

        captureTarget.grabToImage(function(result) {
            if (!result.saveToFile(path)) {
                fail("save failed", [path])
                return
            }

            pageIndex += 1
            if (pageIndex >= pageKeys.length) {
                pageIndex = 0
                widthIndex += 1
            }
            exportTimer.restart()
        }, Qt.size(captureTarget.width, captureTarget.height))
    }

    Timer {
        id: settleTimer
        interval: 420
        repeat: false
        onTriggered: root.captureCurrentPage()
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

            if (root.widthIndex >= root.auditWidths.length) {
                console.log("playground-pages-export ok", root.outputDirectory)
                Qt.quit()
                return
            }

            root.width = root.auditWidths[root.widthIndex]
            root.height = root.auditHeights[root.widthIndex]
            root.heightAdjusted = false
            root.selectedPage = root.pageKeys[root.pageIndex]
            settleTimer.restart()
        }
    }
}
