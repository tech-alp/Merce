import QtQuick
import QtQuick.Controls.Basic as Basic
import QtQml.Models
import Merce.Core

Basic.ApplicationWindow {
    id: root
    objectName: "merce.playground.window"

    width: 1180
    height: 760
    visible: true
    color: Theme.palette.backgroundBase
    title: "Merce Playground"

    property string selectedPage: "theme"
    readonly property var materialIcons: playgroundMaterialIcons
    readonly property var fontAwesomeSolidIcons: playgroundFontAwesomeSolidIcons
    readonly property var fontAwesomeRegularIcons: playgroundFontAwesomeRegularIcons
    readonly property var fontAwesomeBrandsIcons: playgroundFontAwesomeBrandsIcons

    ListModel {
        id: pageModel

        ListElement {
            key: "theme"
            label: "Theme Gallery"
            category: "Core"
            icon: "material:palette"
        }
        ListElement {
            key: "palette"
            label: "Palette"
            category: "Core"
            icon: "material:format_color_fill"
        }
        ListElement {
            key: "typography"
            label: "Typography"
            category: "Core"
            icon: "material:text_fields"
        }
        ListElement {
            key: "controls"
            label: "Controls"
            category: "Components"
            icon: "material:tune"
        }
        ListElement {
            key: "icons"
            label: "Icons"
            category: "Components"
            icon: "material:apps"
        }
        ListElement {
            key: "feedback"
            label: "Feedback"
            category: "Components"
            icon: "material:notifications"
        }
    }

    function pageTitle(key) {
        for (let i = 0; i < pageModel.count; ++i) {
            const page = pageModel.get(i)
            if (page.key === key)
                return page.label
        }
        return ""
    }

    function pageComponent(key) {
        if (key === "palette")
            return palettePage
        if (key === "typography")
            return typographyPage
        if (key === "controls")
            return controlsPage
        if (key === "icons")
            return iconsPage
        if (key === "feedback")
            return feedbackPage
        return themePage
    }

    function themeOptionFor(brand) {
        for (let i = 0; i < Theme.availableThemes.length; ++i) {
            const option = Theme.availableThemes[i]
            if (option.value === brand)
                return option
        }
        return null
    }

    function modeOptionsFor(brand) {
        const option = themeOptionFor(brand)
        if (!option || !option.modes)
            return []
        return option.modes
    }

    function defaultModeFor(brand) {
        const option = themeOptionFor(brand)
        if (!option)
            return ""
        if (option.defaultMode && String(option.defaultMode).length > 0)
            return String(option.defaultMode)
        const modes = modeOptionsFor(brand)
        if (modes.length > 0)
            return String(modes[0].value)
        return ""
    }

    function applyTheme(brand, mode) {
        const modes = modeOptionsFor(brand)
        if (modes.length > 0)
            return Theme.setTheme(brand, mode && String(mode).length > 0 ? String(mode) : defaultModeFor(brand))
        return Theme.setTheme(brand)
    }

    function navigateTo(key) {
        if (selectedPage === key && pageStack.depth > 0)
            return

        selectedPage = key
    }

    function replaceCurrentPage(key, operation) {
        const component = pageComponent(key)
        if (!component || pageStack.empty)
            return

        pageStack.replace(component, operation || Basic.StackView.ReplaceTransition)
    }

    onSelectedPageChanged: replaceCurrentPage(selectedPage)

    header: PlaygroundHeader {
        objectName: "merce.playground.header"
        height: 76
        pageTitle: root.pageTitle(root.selectedPage)
        themeOptions: Theme.availableThemes
        modeOptions: root.modeOptionsFor(Theme.activeBrand)
        onThemeSelected: function(value) {
            const brand = String(value)
            root.applyTheme(brand, root.defaultModeFor(brand))
        }
        onModeSelected: function(value) {
            root.applyTheme(Theme.activeBrand, String(value))
        }
    }

    footer: PlaygroundFooter {
        objectName: "merce.playground.footer"
        height: 44
        activePage: root.pageTitle(root.selectedPage)
        activeTheme: Theme.activeBrand + " / " + (Theme.activeMode === "" ? "default" : Theme.activeMode)
        stackDepth: pageStack.depth
    }

    Item {
        id: contentShell
        objectName: "merce.playground.content"
        anchors.fill: parent

        NavigationBar {
            id: navigationBar
            objectName: "merce.playground.sidebar"
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: 260
            pages: pageModel
            selectedPage: root.selectedPage
            activeTheme: Theme.activeBrand + " / " + (Theme.activeMode === "" ? "default" : Theme.activeMode)
            onPageRequested: function(key) {
                root.navigateTo(key)
            }
        }

        Basic.StackView {
            id: pageStack
            objectName: "merce.playground.pageStack"
            anchors {
                left: navigationBar.right
                top: parent.top
                right: parent.right
                bottom: parent.bottom
            }
            clip: true
            initialItem: root.pageComponent(root.selectedPage)
        }
    }

    Component {
        id: themePage
        PlaygroundPage {
            objectName: "merce.playground.stack.theme"
            sourceComponent: themeShowcase
        }
    }

    Component {
        id: palettePage
        PlaygroundPage {
            objectName: "merce.playground.stack.palette"
            sourceComponent: paletteShowcase
        }
    }

    Component {
        id: typographyPage
        PlaygroundPage {
            objectName: "merce.playground.stack.typography"
            sourceComponent: typographyShowcase
        }
    }

    Component {
        id: controlsPage
        PlaygroundPage {
            objectName: "merce.playground.stack.controls"
            sourceComponent: controlsShowcase
        }
    }

    Component {
        id: iconsPage
        PlaygroundPage {
            objectName: "merce.playground.stack.icons"
            sourceComponent: iconsShowcase
        }
    }

    Component {
        id: feedbackPage
        PlaygroundPage {
            objectName: "merce.playground.stack.feedback"
            sourceComponent: feedbackShowcase
        }
    }

    Component {
        id: themeShowcase
        ThemeGallery {
            objectName: "merce.playground.themeGallery"
        }
    }

    Component {
        id: paletteShowcase
        PaletteShowcase {
            objectName: "merce.playground.paletteShowcase"
        }
    }

    Component {
        id: typographyShowcase
        TypographyShowcase {
            objectName: "merce.playground.typographyShowcase"
        }
    }

    Component {
        id: controlsShowcase
        ControlsShowcase {
            objectName: "merce.playground.controlsShowcase"
        }
    }

    Component {
        id: iconsShowcase
        IconsShowcase {
            objectName: "merce.playground.iconsShowcase"
            materialIcons: root.materialIcons
            fontAwesomeSolidIcons: root.fontAwesomeSolidIcons
            fontAwesomeRegularIcons: root.fontAwesomeRegularIcons
            fontAwesomeBrandsIcons: root.fontAwesomeBrandsIcons
        }
    }

    Component {
        id: feedbackShowcase
        FeedbackShowcase {
            objectName: "merce.playground.feedbackShowcase"
        }
    }
}
