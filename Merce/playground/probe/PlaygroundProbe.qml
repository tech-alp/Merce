import QtQuick
import Merce.Core

Main {
    id: root

    function fail(message, values) {
        console.error("playground-probe failed", message, values)
        Qt.exit(1)
    }

    function findObject(item, name, depth) {
        if (!item || depth > 24)
            return null
        if (item.objectName === name)
            return item

        const children = item.children || []
        for (let i = 0; i < children.length; ++i) {
            const child = children[i]
            const found = root.findObject(child, name, depth + 1)
            if (found)
                return found
        }

        if (item.contentItem && item.contentItem !== item) {
            const contentChildren = item.contentItem.children || []
            for (let i = 0; i < contentChildren.length; ++i) {
                const child = contentChildren[i]
                const found = root.findObject(child, name, depth + 1)
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

    Timer {
        id: verifyTimer
        interval: 80
        running: true
        repeat: false

        property int step: 0

        onTriggered: {
            if (step === 0) {
                const themeSelect = root.findNamed("merce.playground.header.themeSelect")
                if (!themeSelect) {
                    root.fail("header theme select lookup", [])
                    return
                }

                themeSelect.openDropdown()
                step = 1
                interval = 120
                restart()
                return
            }

            if (step === 1) {
                const themeSelect = root.findNamed("merce.playground.header.themeSelect")
                if (!themeSelect || !themeSelect.isOpen || !themeSelect.popup.visible) {
                    root.fail("header theme select popup", [
                                  themeSelect ? themeSelect.isOpen : null,
                                  themeSelect && themeSelect.popup ? themeSelect.popup.visible : null
                              ])
                    return
                }

                themeSelect.closeDropdown()
                step = 2
                interval = 80
                restart()
                return
            }

            if (step === 2) {
                if (root.objectName !== "merce.playground.window"
                        || root.selectedPage !== "theme"
                        || root.pageTitle(root.selectedPage) !== "Theme Gallery"
                        || Theme.availableThemes.length < 2) {
                    root.fail("default shell state", [
                                  root.objectName,
                                  root.selectedPage,
                                  root.pageTitle(root.selectedPage),
                                  Theme.availableThemes.length
                              ])
                    return
                }

                root.selectedPage = "palette"
                step = 3
                restart()
                return
            }

            if (step === 3) {
                if (root.selectedPage !== "palette"
                        || root.pageTitle(root.selectedPage) !== "Palette") {
                    root.fail("palette page switch", [root.selectedPage, root.pageTitle(root.selectedPage)])
                    return
                }

                root.selectedPage = "typography"
                step = 4
                interval = 120
                restart()
                return
            }

            if (step === 4) {
                const typographyShowcase = root.findNamed("merce.playground.typographyShowcase")
                const typographyScale = root.findNamed("merce.playground.typography.scale")
                if (root.selectedPage !== "typography"
                        || root.pageTitle(root.selectedPage) !== "Typography"
                        || !typographyShowcase
                        || typographyShowcase.specimenCount !== 14
                        || !typographyScale) {
                    root.fail("typography page switch", [
                                  root.selectedPage,
                                  root.pageTitle(root.selectedPage),
                                  typographyShowcase ? typographyShowcase.specimenCount : null,
                                  typographyScale !== null
                              ])
                    return
                }

                root.selectedPage = "icons"
                step = 5
                interval = 260
                restart()
                return
            }

            if (step === 5) {
                const iconsShowcase = root.findNamed("merce.playground.iconsShowcase")
                const iconsGrid = root.findNamed("merce.playground.icons.grid")
                const iconsSearch = root.findNamed("merce.playground.icons.search")
                const iconsFontSelect = root.findNamed("merce.playground.icons.fontSelect")
                if (root.selectedPage !== "icons"
                        || root.pageTitle(root.selectedPage) !== "Icons"
                        || !iconsShowcase
                        || iconsShowcase.iconCount <= 0
                        || !iconsGrid
                        || !iconsSearch
                        || !iconsFontSelect) {
                    root.fail("icons page switch", [
                                  root.selectedPage,
                                  root.pageTitle(root.selectedPage),
                                  iconsShowcase ? iconsShowcase.iconCount : null,
                                  iconsGrid !== null,
                                  iconsSearch !== null,
                                  iconsFontSelect !== null
                              ])
                    return
                }

                const iconCount = iconsShowcase.iconCount
                iconsShowcase.searchQuery = "account"
                if (iconsShowcase.iconCount <= 0 || iconsShowcase.iconCount >= iconCount) {
                    root.fail("icons search filter", [iconCount, iconsShowcase.iconCount])
                    return
                }
                iconsShowcase.searchQuery = ""
                iconsShowcase.selectedIconFont = "fa-solid"
                if (iconsShowcase.activeIconPrefix !== "fa-solid:"
                        || iconsShowcase.iconCount !== iconsShowcase.fontAwesomeSolidIconCount
                        || iconsShowcase.iconCount < 1000) {
                    root.fail("icons solid font switch", [
                                  iconsShowcase.activeIconPrefix,
                                  iconsShowcase.iconCount,
                                  iconsShowcase.fontAwesomeSolidIconCount
                              ])
                    return
                }
                iconsShowcase.selectedIconFont = "fa-brands"
                if (iconsShowcase.activeIconPrefix !== "fa-brands:"
                        || iconsShowcase.iconCount !== iconsShowcase.fontAwesomeBrandsIconCount
                        || iconsShowcase.iconCount < 100) {
                    root.fail("icons brands font switch", [
                                  iconsShowcase.activeIconPrefix,
                                  iconsShowcase.iconCount,
                                  iconsShowcase.fontAwesomeBrandsIconCount
                              ])
                    return
                }
                iconsShowcase.selectedIconFont = "material"

                root.selectedPage = "controls"
                step = 6
                interval = 80
                restart()
                return
            }

            if (root.selectedPage !== "controls"
                    || root.pageTitle(root.selectedPage) !== "Controls") {
                root.fail("controls page switch", [root.selectedPage, root.pageTitle(root.selectedPage)])
                return
            }

            console.log("playground-probe ok", root.selectedPage, Theme.activeBrand, Theme.activeMode)
            Qt.quit()
        }
    }
}
