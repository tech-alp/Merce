import QtQuick

Main {
    id: root

    function fail(message, values) {
        console.error("fontawesome-grid-probe failed", message, values)
        Qt.exit(1)
    }

    function findObject(item, name, depth) {
        if (!item || depth > 24)
            return null
        if (item.objectName === name)
            return item

        const children = item.children || []
        for (let i = 0; i < children.length; ++i) {
            const found = root.findObject(children[i], name, depth + 1)
            if (found)
                return found
        }

        if (item.contentItem && item.contentItem !== item) {
            const contentChildren = item.contentItem.children || []
            for (let i = 0; i < contentChildren.length; ++i) {
                const found = root.findObject(contentChildren[i], name, depth + 1)
                if (found)
                    return found
            }
        }

        return null
    }

    function findNamed(name) {
        return root.findObject(root, name, 0)
                || root.findObject(root.header, name, 0)
                || root.findObject(root.footer, name, 0)
                || root.findObject(root.contentItem, name, 0)
    }

    function verifyFirstFontAwesomeIcon(expectedPrefix, iconsGrid) {
        const firstIcon = root.findNamed("merce.icons.fontawesome.icon")
        if (!firstIcon) {
            root.fail("fontawesome icon lookup", [iconsGrid.count, iconsGrid.contentItem.children.length])
            return null
        }

        console.log("fontawesome-grid-probe first-icon",
                    firstIcon.name,
                    firstIcon.visible,
                    firstIcon.width,
                    firstIcon.height,
                    firstIcon.hasIcon,
                    firstIcon.contentScale,
                    firstIcon.iconSpec ? firstIcon.iconSpec.path.length : 0)

        if (firstIcon.name.indexOf(expectedPrefix) !== 0 || !firstIcon.hasIcon) {
            root.fail("fontawesome icon state", [
                          expectedPrefix,
                          firstIcon.name,
                          firstIcon.hasIcon,
                          firstIcon.iconSpec ? firstIcon.iconSpec.path.length : 0
                      ])
            return null
        }

        return firstIcon
    }

    Timer {
        id: stepTimer
        interval: 180
        running: true
        repeat: false

        property int step: 0

        onTriggered: {
            if (step === 0) {
                root.selectedPage = "icons"
                step = 1
                restart()
                return
            }

            const iconsShowcase = root.findNamed("merce.playground.iconsShowcase")
            const iconsGrid = root.findNamed("merce.playground.icons.grid")
            if (!iconsShowcase || !iconsGrid) {
                root.fail("icons lookup", [iconsShowcase !== null, iconsGrid !== null])
                return
            }

            if (step === 1) {
                iconsShowcase.searchQuery = ""
                iconsShowcase.selectedIconFont = "fa-solid"
                step = 2
                interval = 350
                restart()
                return
            }

            if (iconsShowcase.iconCount <= 0) {
                root.fail("solid icon count", [iconsShowcase.iconCount, iconsShowcase.fontAwesomeSolidIconCount])
                return
            }

            if (step === 2) {
                const firstIcon = root.verifyFirstFontAwesomeIcon("fa-solid:", iconsGrid)
                if (!firstIcon)
                    return

                firstIcon.grabToImage(function(iconResult) {
                    if (!iconResult.saveToFile("/private/tmp/merce-fontawesome-grid-first.png")) {
                        root.fail("first icon save", [])
                        return
                    }

                    iconsGrid.grabToImage(function(result) {
                        if (!result.saveToFile("/private/tmp/merce-fontawesome-grid.png")) {
                            root.fail("grid save", [])
                            return
                        }

                        console.log("fontawesome-grid-probe solid ok",
                                    iconsShowcase.iconCount,
                                    iconsShowcase.fontAwesomeSolidIconCount)
                        iconsShowcase.selectedIconFont = "fa-brands"
                        step = 3
                        interval = 350
                        restart()
                    })
                })
                return
            }

            if (iconsShowcase.iconCount !== iconsShowcase.fontAwesomeBrandsIconCount
                    || iconsShowcase.iconCount < 100) {
                root.fail("brands icon count", [iconsShowcase.iconCount, iconsShowcase.fontAwesomeBrandsIconCount])
                return
            }

            const firstBrandIcon = root.verifyFirstFontAwesomeIcon("fa-brands:", iconsGrid)
            if (!firstBrandIcon)
                return

            firstBrandIcon.grabToImage(function(iconResult) {
                if (!iconResult.saveToFile("/private/tmp/merce-fontawesome-grid-brands-first.png")) {
                    root.fail("first brands icon save", [])
                    return
                }

                iconsGrid.grabToImage(function(result) {
                    if (!result.saveToFile("/private/tmp/merce-fontawesome-grid-brands.png")) {
                        root.fail("brands grid save", [])
                        return
                    }

                    console.log("fontawesome-grid-probe ok",
                                iconsShowcase.iconCount,
                                iconsShowcase.fontAwesomeBrandsIconCount)
                    Qt.exit(0)
                })
            })
        }
    }
}
