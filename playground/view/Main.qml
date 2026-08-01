import QtQuick
import QtQuick.Controls.Basic as Basic
import Qt.labs.StyleKit
import QtQml.Models
import Merce.Style
import Merce.Theme

ApplicationWindow {
    id: root
    objectName: "merce.playground.window"

    width: 1180
    height: 760
    visible: true
    title: "Merce Playground"

    StyleKit.style: MerceStyle {}

    property string selectedPage: "theme"
    readonly property var materialIcons: playgroundMaterialIcons
    readonly property var themeSourcePaths: playgroundThemeSourcePaths

    ListModel {
        id: pageModel

        ListElement {
            key: "theme"
            label: "Overview"
            category: "Overview"
            icon: "material:home"
        }
        ListElement {
            key: "palette"
            label: "Colors"
            category: "Foundations"
            icon: "material:format_color_fill"
        }
        ListElement {
            key: "typography"
            label: "Typography"
            category: "Foundations"
            icon: "material:text_fields"
        }
        ListElement {
            key: "spacing"
            label: "Spacing & Radius"
            category: "Foundations"
            icon: "material:tune"
        }
        ListElement {
            key: "shadows"
            label: "Shadows"
            category: "Foundations"
            icon: "material:palette"
        }
        ListElement {
            key: "motion"
            label: "Motion"
            category: "Foundations"
            icon: "material:dark_mode"
        }
        ListElement {
            key: "theme-builder"
            label: "Theme Builder"
            category: "Tools"
            icon: "material:design_services"
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
        ListElement {
            key: "forms"
            label: "Forms"
            category: "Patterns"
            icon: "material:check_circle"
        }
        ListElement {
            key: "states"
            label: "States"
            category: "Patterns"
            icon: "material:error"
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
        if (key === "spacing")
            return spacingPage
        if (key === "shadows")
            return shadowsPage
        if (key === "motion")
            return motionPage
        if (key === "theme-builder")
            return themeBuilderPage
        if (key === "controls")
            return controlsPage
        if (key === "icons")
            return iconsPage
        if (key === "feedback")
            return feedbackPage
        if (key === "forms")
            return formsPage
        if (key === "states")
            return statesPage
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

    function loadThemeSources() {
        if (!themeSourcePaths || themeSourcePaths.length === 0)
            return

        let added = false
        for (let i = 0; i < themeSourcePaths.length; ++i) {
            const sourcePath = String(themeSourcePaths[i])
            if (Theme.addThemeSource(sourcePath))
                added = true
            else
                console.warn("theme source rejected", sourcePath)
        }

        if (added && !Theme.reloadThemes())
            console.warn("theme source reload failed", themeSourcePaths)
    }

    function navigateTo(key) {
        if (selectedPage === key && !pageStack.empty)
            return

        selectedPage = key
    }

    function replaceCurrentPage(operation) {
        const component = pageComponent(selectedPage)
        if (!component || pageStack.empty)
            return

        pageStack.replace(component, operation || Basic.StackView.ReplaceTransition)
    }

    onSelectedPageChanged: replaceCurrentPage()

    Component.onCompleted: loadThemeSources()

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
        anchors {
            fill: parent
            topMargin: root.header ? root.header.height : 0
            bottomMargin: root.footer ? root.footer.height : 0
        }

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
        id: spacingPage
        PlaygroundPage {
            objectName: "merce.playground.stack.spacing"
            sourceComponent: spacingShowcase
        }
    }

    Component {
        id: shadowsPage
        PlaygroundPage {
            objectName: "merce.playground.stack.shadows"
            sourceComponent: shadowsShowcase
        }
    }

    Component {
        id: motionPage
        PlaygroundPage {
            objectName: "merce.playground.stack.motion"
            sourceComponent: motionShowcase
        }
    }

    Component {
        id: themeBuilderPage
        PlaygroundPage {
            objectName: "merce.playground.stack.themeBuilder"
            sourceComponent: themeBuilderShowcase
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
        id: formsPage
        PlaygroundPage {
            objectName: "merce.playground.stack.forms"
            sourceComponent: formsShowcase
        }
    }

    Component {
        id: statesPage
        PlaygroundPage {
            objectName: "merce.playground.stack.states"
            sourceComponent: statesShowcase
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
        id: spacingShowcase
        SpacingRadiusShowcase {
            objectName: "merce.playground.spacingRadiusShowcase"
        }
    }

    Component {
        id: shadowsShowcase
        ShadowsShowcase {
            objectName: "merce.playground.shadowsShowcase"
        }
    }

    Component {
        id: motionShowcase
        MotionShowcase {
            objectName: "merce.playground.motionShowcase"
        }
    }

    Component {
        id: themeBuilderShowcase
        ThemeBuilderShowcase {
            objectName: "merce.playground.themeBuilderShowcase"
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
        }
    }

    Component {
        id: feedbackShowcase
        FeedbackShowcase {
            objectName: "merce.playground.feedbackShowcase"
        }
    }

    Component {
        id: formsShowcase
        FormsShowcase {
            objectName: "merce.playground.formsShowcase"
        }
    }

    Component {
        id: statesShowcase
        StatesShowcase {
            objectName: "merce.playground.statesShowcase"
        }
    }
}
