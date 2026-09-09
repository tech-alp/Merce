import QtQuick
import Qt.labs.StyleKit as SK
import Merce.Theme
import Merce.Foundation
import Merce.Icons.FontAwesome

Item {
    id: root
    objectName: "merce.playground.showcase.icons"

    implicitHeight: page.implicitHeight
    height: implicitHeight

    property string searchQuery: ""
    property string selectedIconFont: "material"
    property var materialIcons: []
    property var materialIconList: []
    readonly property var fontAwesomeSolidIconList: FontAwesomeRegistry.iconNames("solid")
    readonly property var fontAwesomeRegularIconList: FontAwesomeRegistry.iconNames("regular")
    readonly property var fontAwesomeBrandsIconList: FontAwesomeRegistry.iconNames("brands")
    readonly property var iconFontOptions: [
        { "value": "material", "label": "Material Symbols" },
        { "value": "fa-solid", "label": "Font Awesome Solid" },
        { "value": "fa-regular", "label": "Font Awesome Regular" },
        { "value": "fa-brands", "label": "Font Awesome Brands" }
    ]
    readonly property string activeIconPrefix: iconPrefix(selectedIconFont)
    readonly property string activeIconFontLabel: iconFontLabel(selectedIconFont)
    readonly property int iconCount: filteredIcons.count
    readonly property int fontAwesomeSolidIconCount: fontAwesomeSolidIconList.length
    readonly property int fontAwesomeRegularIconCount: fontAwesomeRegularIconList.length
    readonly property int fontAwesomeBrandsIconCount: fontAwesomeBrandsIconList.length
    property string activeTooltip: ""
    property real activeTooltipX: 0
    property real activeTooltipY: 0

    ListModel {
        id: filteredIcons
    }

    function normalizeIconEntries(iconEntries) {
        const entries = []
        for (let i = 0; i < iconEntries.length; ++i) {
            const icon = iconEntries[i]
            const name = String(icon.name || icon || "").trim()
            if (name.length > 0)
                entries.push({
                    "name": name,
                    "codepoint": String(icon.codepoint || "").trim().toLowerCase()
                })
        }

        return entries
    }

    function setMaterialIcons(iconEntries) {
        root.materialIconList = normalizeIconEntries(iconEntries)
        if (root.selectedIconFont === "material")
            refreshFilteredIcons()
    }

    function wildcardToRegExp(query) {
        const escaped = query.replace(/[.+?^${}()|[\]\\]/g, "\\$&").replace(/\*/g, ".*")
        return new RegExp(escaped, "i")
    }

    function matchesQuery(iconEntry, query) {
        if (query.length === 0)
            return true
        const haystack = iconEntry.name + " " + String(iconEntry.codepoint || "") + " " + String(iconEntry.style || "")
        if (query.indexOf("*") >= 0)
            return wildcardToRegExp(query).test(haystack)
        return haystack.toLowerCase().indexOf(query.toLowerCase()) >= 0
    }

    function iconFontLabel(iconFont) {
        for (let i = 0; i < root.iconFontOptions.length; ++i) {
            const option = root.iconFontOptions[i]
            if (option.value === iconFont)
                return option.label
        }
        return "Material Symbols"
    }

    function iconPrefix(iconFont) {
        if (iconFont === "fa-solid")
            return "fa-solid:"
        if (iconFont === "fa-regular")
            return "fa-regular:"
        if (iconFont === "fa-brands")
            return "fa-brands:"
        return "material:"
    }

    function iconEntriesForSelectedFont() {
        if (root.selectedIconFont === "fa-solid")
            return root.fontAwesomeSolidIconList
        if (root.selectedIconFont === "fa-regular")
            return root.fontAwesomeRegularIconList
        if (root.selectedIconFont === "fa-brands")
            return root.fontAwesomeBrandsIconList
        return root.materialIconList
    }

    function iconValueForEntry(iconEntry) {
        if (root.selectedIconFont === "material")
            return "material:" + iconEntry.name
        return iconPrefix(root.selectedIconFont) + iconEntry.name
    }

    function tooltipForEntry(iconEntry) {
        const codepoint = String(iconEntry.codepoint || "")
        if (codepoint.length === 0)
            return iconEntry.name
        return iconEntry.name + " / U+" + codepoint.toUpperCase()
    }

    function showTooltip(item, text) {
        const point = item.mapToItem(root, item.width / 2, 0)
        activeTooltip = String(text || "")
        activeTooltipX = point.x
        activeTooltipY = point.y
    }

    function hideTooltip() {
        activeTooltip = ""
    }

    function refreshFilteredIcons() {
        filteredIcons.clear()
        const query = String(root.searchQuery || "").trim()
        const iconEntries = iconEntriesForSelectedFont()
        for (let i = 0; i < iconEntries.length; ++i) {
            const iconEntry = iconEntries[i]
            if (matchesQuery(iconEntry, query)) {
                filteredIcons.append({
                    "iconName": iconEntry.name,
                    "iconValue": iconValueForEntry(iconEntry),
                    "tooltip": tooltipForEntry(iconEntry)
                })
            }
        }
    }

    onSearchQueryChanged: refreshFilteredIcons()
    onSelectedIconFontChanged: refreshFilteredIcons()
    onMaterialIconsChanged: setMaterialIcons(materialIcons)
    Component.onCompleted: {
        root.materialIconList = normalizeIconEntries(materialIcons)
        refreshFilteredIcons()
    }

    component SectionTitle: AppLabel {
        textType: AppLabel.H4
        color: Theme.colors.content.primary
        wrapMode: Text.WordWrap
    }

    Column {
        id: page
        width: root.width
        spacing: Theme.spacing.lg

        Surface {
            width: parent.width
            height: iconsColumn.implicitHeight + Theme.spacing.xl2
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large

            Column {
                id: iconsColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.xl
                }
                spacing: Theme.spacing.lg

                Flow {
                    objectName: "merce.playground.icons.headerLayout"
                    width: parent.width
                    height: childrenRect.height
                    spacing: Theme.spacing.lg

                    SectionTitle {
                        id: titleText
                        width: Math.min(160, parent.width)
                        text: "Icons"
                    }

                    SK.ComboBox {
                        id: fontSelect
                        objectName: "merce.playground.icons.fontSelect"
                        width: Math.min(260, parent.width)
                        SK.StyleVariation.variations: ["small"]
                        model: root.iconFontOptions
                        textRole: "label"
                        valueRole: "value"
                        currentValue: root.selectedIconFont
                        displayText: currentIndex < 0 ? qsTr("Font") : currentText
                        onActivated: {
                            root.selectedIconFont = String(currentValue)
                        }
                    }

                    SK.TextField {
                        id: searchField
                        objectName: "merce.playground.icons.search"
                        width: Math.min(320, parent.width)
                        placeholderText: qsTr("Search icons")
                        text: root.searchQuery
                        leftPadding: Theme.spacing.xl2

                        AppIcon {
                            anchors {
                                left: parent.left
                                leftMargin: Theme.spacing.md
                                verticalCenter: parent.verticalCenter
                            }
                            name: "material:search"
                            size: Theme.icons.small
                            color: Theme.colors.content.secondary
                        }

                        onTextEdited: {
                            root.searchQuery = text
                        }
                    }
                }

                GridView {
                    id: iconsGrid
                    objectName: "merce.playground.icons.grid"
                    width: parent.width
                    height: Math.max(360, Math.min(620, Math.ceil(filteredIcons.count / Math.max(1, Math.floor(width / cellWidth))) * cellHeight))
                    model: filteredIcons
                    cellWidth: 72
                    cellHeight: 70
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Item {
                        id: iconTile

                        required property string iconName
                        required property string iconValue
                        required property string tooltip

                        width: iconsGrid.cellWidth
                        height: iconsGrid.cellHeight

                        Rectangle {
                            anchors.centerIn: parent
                            width: 52
                            height: 52
                            radius: Theme.radius.medium
                            color: tileMouse.containsMouse
                                ? Qt.tint(Theme.colors.surface.container,
                                          Qt.alpha(Theme.colors.content.primary,
                                                   Theme.state.layer.hover))
                                : "transparent"

                            AppIcon {
                                anchors.centerIn: parent
                                visible: root.selectedIconFont === "material"
                                name: iconTile.iconValue
                                size: Theme.icons.large
                                color: Theme.colors.content.primary
                            }

                            FontAwesomeIcon {
                                anchors.centerIn: parent
                                visible: root.selectedIconFont !== "material"
                                name: iconTile.iconValue
                                size: Theme.icons.large
                                color: Theme.colors.content.primary
                            }
                        }

                        MouseArea {
                            id: tileMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onContainsMouseChanged: {
                                if (containsMouse)
                                    root.showTooltip(iconTile, iconTile.tooltip)
                                else
                                    root.hideTooltip()
                            }
                        }
                    }
                }

                AppLabel {
                    width: parent.width
                    textType: AppLabel.Caption
                    text: root.activeIconFontLabel + " / " + filteredIcons.count + " icons"
                    color: Theme.colors.content.tertiary
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    Rectangle {
        id: tooltipBubble
        z: 20
        visible: root.activeTooltip.length > 0
        x: Math.max(Theme.spacing.sm,
                    Math.min(root.width - width - Theme.spacing.sm,
                             root.activeTooltipX - width / 2))
        y: Math.max(Theme.spacing.sm,
                    root.activeTooltipY - height - Theme.spacing.xs)
        implicitWidth: Math.min(280, tooltipLabel.implicitWidth + Theme.spacing.md)
        implicitHeight: tooltipLabel.implicitHeight + Theme.spacing.xs
        width: implicitWidth
        height: implicitHeight
        radius: Theme.radius.tooltip
        color: Theme.colors.surface.inverse
        border.width: 1
        border.color: Theme.colors.outline.strong

        AppLabel {
            id: tooltipLabel
            anchors.centerIn: parent
            width: Math.min(260, implicitWidth)
            textType: AppLabel.Caption
            text: root.activeTooltip
            color: Theme.colors.content.inverse
            wrapMode: Text.NoWrap
            maximumLineCount: 1
        }
    }
}
