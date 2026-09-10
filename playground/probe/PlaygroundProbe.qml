import QtQuick
import Merce.Controls
import Merce.Theme
import Merce.Icons.FontAwesome

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
                || root.findObject(root.notificationLayer, name, 0)
    }

    function activateComboValue(comboBox, value) {
        const index = comboBox.indexOfValue(value)
        if (index < 0)
            return false
        comboBox.currentIndex = index
        comboBox.activated(index)
        return true
    }

    function rectInContent(item) {
        if (!item || !root.contentItem)
            return null
        const point = item.mapToItem(root.contentItem, 0, 0)
        return Qt.rect(point.x, point.y, item.width, item.height)
    }

    function includesVariation(item, name) {
        if (!item || !item.styleVariations)
            return false
        return item.styleVariations.indexOf(name) >= 0
    }

    function verifyShowcasePage(key, title, objectName, anchorObjectName) {
        const showcase = root.findNamed(objectName)
        const anchor = root.findNamed(anchorObjectName)
        if (root.selectedPage !== key
                || root.pageTitle(root.selectedPage) !== title
                || !showcase
                || !anchor) {
            root.fail(title + " showcase page switch", [
                          root.selectedPage,
                          root.pageTitle(root.selectedPage),
                          showcase !== null,
                          anchor !== null
                      ])
            return false
        }

        return true
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

                themeSelect.popup.open()
                step = 1
                interval = 120
                restart()
                return
            }

            if (step === 1) {
                const themeSelect = root.findNamed("merce.playground.header.themeSelect")
                if (!themeSelect || !themeSelect.popup.visible) {
                    root.fail("header theme select popup", [
                                  themeSelect && themeSelect.popup ? themeSelect.popup.visible : null
                              ])
                    return
                }

                themeSelect.popup.close()
                step = 2
                interval = 80
                restart()
                return
            }

            if (step === 2) {
                const galleryPrimaryButton = root.findNamed("merce.playground.gallery.primaryButton")
                if (root.objectName !== "merce.playground.window"
                        || root.selectedPage !== "theme"
                        || root.pageTitle(root.selectedPage) !== "Overview"
                        || Theme.availableThemes.length !== 10
                        || Theme.availableProfiles.length !== 3
                        || !galleryPrimaryButton) {
                    root.fail("default shell state", [
                                  root.objectName,
                                  root.selectedPage,
                                  root.pageTitle(root.selectedPage),
                                  Theme.availableThemes.length,
                                  Theme.availableProfiles.length,
                                  galleryPrimaryButton !== null
                              ])
                    return
                }

                galleryPrimaryButton.clicked()
                step = 20
                interval = 100
                restart()
                return
            }

            if (step === 20) {
                const notificationHost = root.findNamed("merce.playground.notifications")
                const destructiveButton = root.findNamed(
                                            "merce.playground.gallery.destructiveButton")
                const toastIds = notificationHost
                    ? Object.keys(notificationHost.m_toasts)
                    : []
                if (!notificationHost
                        || notificationHost.parent !== root.notificationLayer
                        || toastIds.length !== 1 || !destructiveButton) {
                    root.fail("theme gallery toast routing", [
                                  notificationHost !== null,
                                  notificationHost
                                      ? notificationHost.parent === root.notificationLayer
                                      : false,
                                  toastIds,
                                  destructiveButton !== null
                              ])
                    return
                }

                notificationHost.dismissAllToasts()
                destructiveButton.clicked()
                step = 21
                interval = 80
                restart()
                return
            }

            if (step === 21) {
                const notificationHost = root.findNamed("merce.playground.notifications")
                const localDialog = root.findNamed("merce.playground.gallery.dialog")
                const hostedDialog = root.findNamed("notificationHost.dialog")
                if (!notificationHost || !notificationHost.busy || localDialog
                        || !hostedDialog) {
                    root.fail("theme gallery dialog routing", [
                                  notificationHost !== null,
                                  notificationHost ? notificationHost.busy : null,
                                  localDialog !== null,
                                  hostedDialog !== null
                              ])
                    return
                }

                hostedDialog.confirm()
                step = 22
                interval = 80
                restart()
                return
            }

            if (step === 22) {
                const notificationHost = root.findNamed("merce.playground.notifications")
                const exportState = root.findNamed("merce.playground.gallery.exportStateText")
                if (!notificationHost || notificationHost.busy || !exportState
                        || exportState.text !== "Yıkıcı işlem onaylandı") {
                    root.fail("theme gallery dialog callback", [
                                  notificationHost !== null,
                                  notificationHost ? notificationHost.busy : null,
                                  exportState ? exportState.text : null
                              ])
                    return
                }

                root.selectedPage = "palette"
                step = 3
                interval = 80
                restart()
                return
            }

            if (step === 3) {
                if (root.selectedPage !== "palette"
                        || root.pageTitle(root.selectedPage) !== "Colors") {
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
                        || typographyShowcase.specimenCount !== 10
                        || !typographyScale
                        || !typographyShowcase.typeTableFits(typographyScale.width)) {
                    root.fail("typography page switch", [
                                  root.selectedPage,
                                  root.pageTitle(root.selectedPage),
                                  typographyShowcase ? typographyShowcase.specimenCount : null,
                                  typographyScale !== null,
                                  typographyShowcase && typographyScale ? typographyShowcase.typeTableFits(typographyScale.width) : null
                              ])
                    return
                }

                root.width = 760
                root.height = 620
                step = 40
                interval = 160
                restart()
                return
            }

            if (step === 40) {
                const typographyShowcase = root.findNamed("merce.playground.typographyShowcase")
                const typographyScale = root.findNamed("merce.playground.typography.scale")
                if (!typographyShowcase
                        || !typographyScale
                        || !typographyShowcase.compactLayout
                        || !typographyShowcase.typeTableFits(typographyScale.width)
                        || typographyScale.width > typographyShowcase.width + 1) {
                    root.fail("typography responsive layout", [
                                  typographyShowcase ? typographyShowcase.width : null,
                                  typographyShowcase ? typographyShowcase.compactLayout : null,
                                  typographyScale ? typographyScale.width : null,
                                  typographyShowcase && typographyScale ? typographyShowcase.typeTableFits(typographyScale.width) : null
                              ])
                    return
                }

                root.width = 1180
                root.height = 760
                root.selectedPage = "spacing"
                step = 5
                interval = 260
                restart()
                return
            }

            if (step === 5) {
                const spacingShowcase = root.findNamed("merce.playground.spacingRadiusShowcase")
                const spacingPatterns = root.findNamed("merce.playground.spacingRadius.patterns")
                const tokenReference = root.findNamed("merce.playground.spacingRadius.tokenReference")
                const touchChecklist = root.findNamed("merce.playground.spacingRadius.touchChecklist")
                if (root.selectedPage !== "spacing"
                        || root.pageTitle(root.selectedPage) !== "Spacing & Radius"
                        || !spacingShowcase
                        || spacingShowcase.patternCount !== 6
                        || !spacingShowcase.tokenReferenceReady
                        || !spacingShowcase.touchTargetReady
                        || !spacingPatterns
                        || !tokenReference
                        || !touchChecklist) {
                    root.fail("spacing showcase page switch", [
                                  root.selectedPage,
                                  root.pageTitle(root.selectedPage),
                                  spacingShowcase ? spacingShowcase.patternCount : null,
                                  spacingShowcase ? spacingShowcase.tokenReferenceReady : null,
                                  spacingShowcase ? spacingShowcase.touchTargetReady : null,
                                  spacingPatterns !== null,
                                  tokenReference !== null,
                                  touchChecklist !== null
                              ])
                    return
                }

                root.selectedPage = "shadows"
                step = 6
                interval = 120
                restart()
                return
            }

            if (step === 6) {
                if (!root.verifyShowcasePage("shadows", "Shadows",
                                             "merce.playground.shadowsShowcase",
                                             "merce.playground.shadows.scale"))
                    return

                root.selectedPage = "motion"
                step = 7
                interval = 120
                restart()
                return
            }

            if (step === 7) {
                if (!root.verifyShowcasePage("motion", "Motion",
                                             "merce.playground.motionShowcase",
                                             "merce.playground.motion.easingPreview"))
                    return

                root.selectedPage = "theme-builder"
                step = 8
                interval = 160
                restart()
                return
            }

            if (step === 8) {
                const themeBuilder = root.findNamed("merce.playground.themeBuilderShowcase")
                if (root.selectedPage !== "theme-builder"
                        || root.pageTitle(root.selectedPage) !== "Theme Builder"
                        || !themeBuilder) {
                    root.fail("theme builder page switch", [
                                  root.selectedPage,
                                  root.pageTitle(root.selectedPage),
                                  themeBuilder !== null
                              ])
                    return
                }

                root.selectedPage = "forms"
                step = 9
                interval = 120
                restart()
                return
            }

            if (step === 9) {
                if (!root.verifyShowcasePage("forms", "Forms",
                                             "merce.playground.formsShowcase",
                                             "merce.playground.forms.fieldStates"))
                    return

                root.selectedPage = "states"
                step = 10
                interval = 120
                restart()
                return
            }

            if (step === 10) {
                if (!root.verifyShowcasePage("states", "States",
                                             "merce.playground.statesShowcase",
                                             "merce.playground.states.matrix"))
                    return

                root.selectedPage = "icons"
                step = 11
                interval = 160
                restart()
                return
            }

            if (step === 11) {
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
                if (!root.activateComboValue(iconsFontSelect, "fa-solid")) {
                    root.fail("icons solid option lookup", [])
                    return
                }
                const audioDescriptionIcon = FontAwesomeRegistry.resolve("fa-solid:audio-description")
                if (iconsShowcase.activeIconPrefix !== "fa-solid:"
                        || iconsShowcase.selectedIconFont !== "fa-solid"
                        || iconsShowcase.iconCount !== iconsShowcase.fontAwesomeSolidIconCount
                        || iconsShowcase.iconCount < 1000
                        || audioDescriptionIcon === null
                        || audioDescriptionIcon.path.length === 0) {
                    root.fail("icons solid font switch", [
                                  iconsShowcase.activeIconPrefix,
                                  iconsShowcase.selectedIconFont,
                                  iconsShowcase.iconCount,
                                  iconsShowcase.fontAwesomeSolidIconCount,
                                  audioDescriptionIcon !== null
                              ])
                    return
                }
                if (!root.activateComboValue(iconsFontSelect, "fa-brands")) {
                    root.fail("icons brands option lookup", [])
                    return
                }
                if (iconsShowcase.activeIconPrefix !== "fa-brands:"
                        || iconsShowcase.selectedIconFont !== "fa-brands"
                        || iconsShowcase.iconCount !== iconsShowcase.fontAwesomeBrandsIconCount
                        || iconsShowcase.iconCount < 100) {
                    root.fail("icons brands font switch", [
                                  iconsShowcase.activeIconPrefix,
                                  iconsShowcase.selectedIconFont,
                                  iconsShowcase.iconCount,
                                  iconsShowcase.fontAwesomeBrandsIconCount
                              ])
                    return
                }
                iconsShowcase.selectedIconFont = "material"

                root.selectedPage = "controls"
                step = 12
                interval = 80
                restart()
                return
            }

            if (step === 13) {
                const feedbackShowcase = root.findNamed("merce.playground.feedbackShowcase")
                const notificationHost = root.findNamed("merce.playground.notifications")
                const nestedHost = root.findNamed("merce.playground.feedback.notifications")
                const infoButton = root.findNamed("merce.playground.feedback.toast.info")
                if (root.selectedPage !== "feedback"
                        || root.pageTitle(root.selectedPage) !== "Feedback"
                        || !feedbackShowcase
                        || !notificationHost
                        || nestedHost
                        || !infoButton) {
                    root.fail("feedback notification host", [
                                  root.selectedPage,
                                  root.pageTitle(root.selectedPage),
                                  feedbackShowcase !== null,
                                  notificationHost !== null,
                                  nestedHost !== null,
                                  infoButton !== null
                              ])
                    return
                }

                infoButton.clicked()
                step = 14
                interval = 100
                restart()
                return
            }

            if (step === 14) {
                const notificationHost = root.findNamed("merce.playground.notifications")
                const dialogButton = root.findNamed(
                                         "merce.playground.feedback.dialog.default")
                const toastIds = notificationHost
                    ? Object.keys(notificationHost.m_toasts)
                    : []
                if (!notificationHost
                        || toastIds.length !== 1
                        || !toastIds[0].startsWith("toast-")
                        || !dialogButton) {
                    root.fail("feedback toast routing", [
                                  notificationHost !== null,
                                  toastIds,
                                  dialogButton !== null
                              ])
                    return
                }

                notificationHost.dismissAllToasts()
                dialogButton.clicked()
                step = 15
                interval = 80
                restart()
                return
            }

            if (step === 15) {
                const notificationHost = root.findNamed("merce.playground.notifications")
                const localDialog = root.findNamed("merce.playground.feedback.dialog")
                const hostedDialog = root.findNamed("notificationHost.dialog")
                if (!notificationHost || !notificationHost.busy || localDialog
                        || !hostedDialog) {
                    root.fail("feedback dialog routing", [
                                  notificationHost !== null,
                                  notificationHost ? notificationHost.busy : null,
                                  localDialog !== null,
                                  hostedDialog !== null
                              ])
                    return
                }

                hostedDialog.confirm()
                step = 16
                interval = 80
                restart()
                return
            }

            if (step === 16) {
                const notificationHost = root.findNamed("merce.playground.notifications")
                const dialogState = root.findNamed("merce.playground.feedback.dialog.state")
                if (!notificationHost || notificationHost.busy || !dialogState
                        || dialogState.text !== "Dialog sample: confirmed") {
                    root.fail("feedback dialog callback", [
                                  notificationHost !== null,
                                  notificationHost ? notificationHost.busy : null,
                                  dialogState ? dialogState.text : null
                              ])
                    return
                }

                console.log("playground-probe ok", root.selectedPage,
                            Theme.activeBrand, Theme.activeMode)
                Qt.quit()
                return
            }

            const header = root.findNamed("merce.playground.header")
            const footer = root.findNamed("merce.playground.footer")
            const content = root.findNamed("merce.playground.content")
            const headerRect = root.rectInContent(header)
            const footerRect = root.rectInContent(footer)
            const contentRect = root.rectInContent(content)
            const controlsShowcase = root.findNamed("merce.playground.controlsShowcase")
            const secondaryButton = root.findNamed("merce.playground.controls.button.secondary")
            const outlineButton = root.findNamed("merce.playground.controls.button.outline")
            const ghostButton = root.findNamed("merce.playground.controls.button.ghost")
            const destructiveButton = root.findNamed("merce.playground.controls.button.destructive")
            const smallButton = root.findNamed("merce.playground.controls.button.small")
            const primaryBadge = root.findNamed("merce.playground.controls.badge.primary")
            const successBadge = root.findNamed("merce.playground.controls.badge.success")
            const smallBadge = root.findNamed("merce.playground.controls.badge.small")
            if (root.selectedPage !== "controls"
                    || root.pageTitle(root.selectedPage) !== "Controls"
                    || !headerRect
                    || !footerRect
                    || !contentRect
                    || contentRect.y < headerRect.y + headerRect.height - 1
                    || contentRect.y + contentRect.height > footerRect.y + 1
                    || !controlsShowcase
                    || !root.includesVariation(secondaryButton, "secondary")
                    || !root.includesVariation(outlineButton, "outline")
                    || !root.includesVariation(ghostButton, "ghost")
                    || !root.includesVariation(destructiveButton, "destructive")
                    || !root.includesVariation(smallButton, "small")
                    || !primaryBadge
                    || primaryBadge.variant !== MBadge.Primary
                    || primaryBadge.icon !== "material:palette"
                    || !successBadge
                    || successBadge.variant !== MBadge.Success
                    || !smallBadge
                    || smallBadge.size !== MBadge.Small) {
                root.fail("controls page switch", [
                              root.selectedPage,
                              root.pageTitle(root.selectedPage),
                              headerRect,
                              footerRect,
                              contentRect,
                              controlsShowcase !== null,
                              secondaryButton ? secondaryButton.styleVariations : null,
                              outlineButton ? outlineButton.styleVariations : null,
                              ghostButton ? ghostButton.styleVariations : null,
                              destructiveButton ? destructiveButton.styleVariations : null,
                              smallButton ? smallButton.styleVariations : null,
                              primaryBadge ? primaryBadge.variant : null,
                              primaryBadge ? primaryBadge.icon : null,
                              successBadge ? successBadge.variant : null,
                              smallBadge ? smallBadge.size : null
                          ])
                return
            }

            root.selectedPage = "feedback"
            step = 13
            interval = 120
            restart()
        }
    }
}
