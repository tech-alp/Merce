import QtQuick
import QtQuick.Controls.Basic as Basic
import Merce.Theme
import Merce.Foundation
import Merce.Icons.FontAwesome
import Merce.Controls

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
        color: Theme.colors.text.primary
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

                Row {
                    width: parent.width
                    height: Math.max(titleText.implicitHeight, searchField.implicitHeight, fontSelect.implicitHeight)
                    spacing: Theme.spacing.lg

                    SectionTitle {
                        id: titleText
                        width: Math.max(160, parent.width - fontSelect.width - searchField.width - parent.spacing * 2)
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Icons"
                    }

                    MSelect {
                        id: fontSelect
                        objectName: "merce.playground.icons.fontSelect"
                        width: 260
                        anchors.verticalCenter: parent.verticalCenter
                        size: "small"
                        placeholder: "Font"
                        options: root.iconFontOptions
                        selectedValue: root.selectedIconFont
                        onSelected: function(value) {
                            root.selectedIconFont = String(value)
                        }
                    }

                    MInput {
                        id: searchField
                        objectName: "merce.playground.icons.search"
                        width: 320
                        anchors.verticalCenter: parent.verticalCenter
                        placeholder: "Search icons"
                        inputType: "search"
                        icon: "material:search"
                        text: root.searchQuery
                        onInputTextChanged: function(text) {
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

                        Basic.ToolTip.delay: 250
                        Basic.ToolTip.timeout: 4000
                        Basic.ToolTip.visible: tileMouse.containsMouse
                        Basic.ToolTip.text: tooltip

                        Rectangle {
                            anchors.centerIn: parent
                            width: 52
                            height: 52
                            radius: Theme.radius.medium
                            color: tileMouse.containsMouse ? Theme.colors.background.hover : "transparent"

                            AppIcon {
                                anchors.centerIn: parent
                                visible: root.selectedIconFont === "material"
                                name: iconTile.iconValue
                                size: Theme.icons.large
                                color: Theme.colors.text.primary
                            }

                            FontAwesomeIcon {
                                anchors.centerIn: parent
                                visible: root.selectedIconFont !== "material"
                                name: iconTile.iconValue
                                size: Theme.icons.large
                                color: Theme.colors.text.primary
                            }
                        }

                        MouseArea {
                            id: tileMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }

                AppLabel {
                    width: parent.width
                    textType: AppLabel.Caption
                    text: root.activeIconFontLabel + " / " + filteredIcons.count + " icons"
                    color: Theme.colors.text.tertiary
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
