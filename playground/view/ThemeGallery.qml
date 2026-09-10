import QtQuick
import QtQuick.Layouts
import Qt.labs.StyleKit as SK
import Merce.Theme
import Merce.Foundation
import Merce.Notifications

Item {
    id: root
    objectName: "merce.playground.gallery"

    implicitHeight: galleryColumn.implicitHeight
    height: implicitHeight

    readonly property string displayMode: Theme.activeMode === "" ? "default" : Theme.activeMode
    readonly property var themeOptions: Theme.availableThemes
    readonly property var modeOptions: root.modeOptionsFor(Theme.activeBrand)
    readonly property color observedButtonColor: primaryButton.observedContainerColor
    readonly property color observedTextColor: bodySample.color
    readonly property color observedInputBorderColor: emailInput.observedBorderColor
    readonly property color observedToggleColor: switchSample.observedTrackColor
    readonly property color observedSelectColor: selectSample.observedPaletteColor
    readonly property color observedToastColor: toastStyle.colors.success
    readonly property color observedToastSurfaceColor: toastStyle.backgroundColor
    readonly property color observedToastTextColor: toastStyle.textColors.color
    readonly property color observedToastCloseColor: toastStyle.closeButtonStyle.color
    readonly property color observedDialogColor: Theme.colors.surface.container
    readonly property bool hasRequiredAnchors: activeThemeSection.objectName === "merce.playground.gallery.activeTheme"
                                            && paletteSection.objectName === "merce.playground.gallery.palette"
                                            && typographySection.objectName === "merce.playground.gallery.typography"
                                            && spacingRadiusSection.objectName === "merce.playground.gallery.spacingRadius"
                                            && componentsSection.objectName === "merce.playground.gallery.components"
                                            && exportStatusSection.objectName === "merce.playground.gallery.exportStatus"

    function themeOptionFor(brand) {
        for (let i = 0; i < root.themeOptions.length; ++i) {
            const option = root.themeOptions[i]
            if (option.value === brand)
                return option
        }
        return null
    }

    function modeOptionsFor(brand) {
        const option = root.themeOptionFor(brand)
        if (!option || !option.modes)
            return []
        return option.modes
    }

    function defaultModeFor(brand) {
        const option = root.themeOptionFor(brand)
        if (!option)
            return ""
        if (option.defaultMode && String(option.defaultMode).length > 0)
            return String(option.defaultMode)
        const modes = root.modeOptionsFor(brand)
        if (modes.length > 0)
            return String(modes[0].value)
        return ""
    }

    function applyTheme(brand, mode) {
        const previousBrand = Theme.activeBrand
        const previousMode = Theme.activeMode
        const modes = root.modeOptionsFor(brand)
        const effectiveMode = modes.length > 0
                ? (mode && String(mode).length > 0 ? String(mode) : root.defaultModeFor(brand))
                : ""
        const ok = modes.length > 0 ? Theme.setTheme(brand, effectiveMode) : Theme.setTheme(brand)
        if (!ok)
            exportState.text = "Tema korunuyor: " + previousBrand + "/" + (previousMode === "" ? "default" : previousMode)
        return ok
    }

    function setMerceLight() {
        return root.applyTheme("merce", "light")
    }

    function setMerceDark() {
        return root.applyTheme("merce", "dark")
    }

    function setStripeReference() {
        return root.applyTheme("stripe", "")
    }

    function colorLabel(value) {
        return String(value).toUpperCase()
    }

    function wrappedRowHeight(availableWidth, itemGap, widths, heights) {
        let totalHeight = 0
        let rowWidth = 0
        let rowHeight = 0

        for (let i = 0; i < widths.length; ++i) {
            const itemWidth = Math.min(availableWidth, Number(widths[i] || 0))
            const itemHeight = Number(heights[i] || 0)
            if (itemWidth <= 0 || itemHeight <= 0)
                continue
            if (rowWidth > 0 && rowWidth + itemGap + itemWidth > availableWidth + 1) {
                totalHeight += rowHeight + itemGap
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += (rowWidth > 0 ? itemGap : 0) + itemWidth
            rowHeight = Math.max(rowHeight, itemHeight)
        }

        return totalHeight + rowHeight
    }

    function uniformWrappedHeight(availableWidth, itemGap, itemCount, itemWidth, itemHeight) {
        const columns = Math.max(1, Math.floor((availableWidth + itemGap) / (itemWidth + itemGap)))
        const rows = Math.ceil(itemCount / columns)
        return rows * itemHeight + Math.max(0, rows - 1) * itemGap
    }

    function showDestructiveDialog() {
        return NotificationCenter.ask({
            owner: root,
            requestId: "gallery-destructive",
            title: qsTr("Galeri örneği"),
            message: qsTr("Tema değerleri okunuyor."),
            confirmText: qsTr("OK"),
            showCancel: false,
            variant: MDialog.Destructive,
            onAccepted: function() {
                exportState.text = qsTr("Yıkıcı işlem onaylandı")
            },
            onRefused: function(activeRequestId) {
                exportState.text = qsTr("Dialog meşgul: %1").arg(activeRequestId)
            }
        })
    }

    component SectionTitle: AppLabel {
        textType: AppLabel.H4
        color: Theme.colors.content.primary
        wrapMode: Text.WordWrap
    }

    component FieldLabel: AppLabel {
        textType: AppLabel.Caption
        color: Theme.colors.content.secondary
        wrapMode: Text.WordWrap
    }

    component TokenSwatch: Item {
        required property string label
        required property color swatchColor

        objectName: "merce.playground.gallery.swatchItem." + label
        implicitWidth: 220
        implicitHeight: 84
        Layout.minimumWidth: Math.min(220, root.width)
        Layout.preferredWidth: Math.min(260, root.width)
        Layout.maximumWidth: root.width
        Layout.fillWidth: true

        Rectangle {
            id: swatch
            objectName: "merce.playground.gallery.swatch." + label
            width: 44
            height: 44
            radius: Theme.radius.medium
            color: swatchColor
            border.width: 1
            border.color: Theme.colors.outline.subtle
        }

        Column {
            anchors {
                left: swatch.right
                right: parent.right
                verticalCenter: swatch.verticalCenter
                leftMargin: Theme.spacing.sm
            }
            spacing: Theme.spacing.xxs

            AppLabel {
                width: parent.width
                textType: AppLabel.Caption
                text: label
                color: Theme.colors.content.primary
                wrapMode: Text.WordWrap
            }

            AppLabel {
                width: parent.width
                textType: AppLabel.Caption
                text: root.colorLabel(swatchColor)
                color: Theme.colors.content.secondary
                wrapMode: Text.WordWrap
            }
        }
    }

    component ScaleSample: Row {
        required property string label
        required property int tokenValue

        width: parent ? parent.width : 320
        height: Math.max(Theme.spacing.touchTargetCompact, bar.height)
        spacing: Theme.spacing.md

        FieldLabel {
            width: 94
            anchors.verticalCenter: parent.verticalCenter
            text: label
        }

        Rectangle {
            id: bar
            width: Math.max(32, tokenValue * 2)
            height: Math.max(8, Math.min(28, tokenValue))
            anchors.verticalCenter: parent.verticalCenter
            radius: Theme.radius.small
            color: Theme.colors.action.primary.container
        }

        FieldLabel {
            anchors.verticalCenter: parent.verticalCenter
            text: tokenValue + " px"
        }
    }

    Column {
        id: galleryColumn
        width: root.width
        spacing: Theme.spacing.xl

        Surface {
            id: activeThemeSection
            objectName: "merce.playground.gallery.activeTheme"
            width: parent.width
            height: activeThemeColumn.implicitHeight + Theme.spacing.xl2
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large

            Column {
                id: activeThemeColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.xl
                }
                spacing: Theme.spacing.md

                FlexboxLayout {
                    objectName: "merce.playground.gallery.activeThemeLayout"
                    width: parent.width
                    height: root.wrappedRowHeight(width, gap,
                                                  [Math.min(320, width), Math.min(472, width)],
                                                  [activeTitleColumn.implicitHeight, selectorRow.height])
                    direction: FlexboxLayout.Row
                    wrap: FlexboxLayout.Wrap
                    gap: Theme.spacing.md
                    alignItems: FlexboxLayout.AlignCenter

                    Column {
                        id: activeTitleColumn
                        Layout.minimumWidth: Math.min(260, parent.width)
                        Layout.preferredWidth: 320
                        Layout.maximumWidth: parent.width
                        Layout.fillWidth: true
                        spacing: Theme.spacing.xxs

                        SectionTitle {
                            width: parent.width
                            text: "Tema doğrulama galerisi"
                        }

                        AppLabel {
                            width: parent.width
                            textType: AppLabel.Body
                            text: Theme.activeBrand + " / " + root.displayMode
                            color: Theme.colors.content.secondary
                            wrapMode: Text.WordWrap
                        }
                    }

                    Flow {
                        id: selectorRow
                        Layout.minimumWidth: Math.min(400, parent.width)
                        Layout.preferredWidth: 472
                        Layout.maximumWidth: parent.width
                        Layout.fillWidth: true
                        spacing: Theme.spacing.sm

                        Column {
                            id: themeSelectorField
                            width: !modeSelectorField.visible || selectorRow.width < 412
                                   ? selectorRow.width
                                   : Math.max(240, selectorRow.width - 180 - selectorRow.spacing)
                            spacing: Theme.spacing.xxs

                            FieldLabel {
                                width: parent.width
                                text: "Tasarım sistemi"
                            }

                            SK.ComboBox {
                                objectName: "merce.playground.gallery.selector.theme"
                                width: parent.width
                                model: root.themeOptions
                                textRole: "label"
                                valueRole: "value"
                                currentValue: Theme.activeBrand
                                onActivated: {
                                    const brand = String(currentValue)
                                    root.applyTheme(brand, root.defaultModeFor(brand))
                                }
                            }
                        }

                        Column {
                            id: modeSelectorField
                            width: selectorRow.width < 412 ? selectorRow.width : 180
                            spacing: Theme.spacing.xxs
                            visible: root.modeOptions.length > 0

                            FieldLabel {
                                width: parent.width
                                text: "Mode"
                            }

                            SK.ComboBox {
                                objectName: "merce.playground.gallery.selector.mode"
                                width: parent.width
                                model: root.modeOptions
                                textRole: "label"
                                valueRole: "value"
                                currentValue: Theme.activeMode
                                onActivated: {
                                    root.applyTheme(Theme.activeBrand, String(currentValue))
                                }
                            }
                        }
                    }
                }
            }
        }

        Surface {
            id: paletteSection
            objectName: "merce.playground.gallery.palette"
            width: parent.width
            height: paletteColumn.implicitHeight + Theme.spacing.xl2
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large

            Column {
                id: paletteColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.xl
                }
                spacing: Theme.spacing.lg

                SectionTitle {
                    width: parent.width
                    text: "Palette"
                }

                FlexboxLayout {
                    objectName: "merce.playground.gallery.paletteLayout"
                    width: parent.width
                    height: root.uniformWrappedHeight(width, gap, 10,
                                                      Math.min(260, width), 84)
                    direction: FlexboxLayout.Row
                    wrap: FlexboxLayout.Wrap
                    gap: Theme.spacing.md
                    alignItems: FlexboxLayout.AlignStart

                    TokenSwatch { label: "surface.canvas"; swatchColor: Theme.colors.surface.canvas }
                    TokenSwatch { label: "surface.container"; swatchColor: Theme.colors.surface.container }
                    TokenSwatch { label: "content.primary"; swatchColor: Theme.colors.content.primary }
                    TokenSwatch { label: "action.primary.container"; swatchColor: Theme.colors.action.primary.container }
                    TokenSwatch { label: "action.primary.content"; swatchColor: Theme.colors.action.primary.content }
                    TokenSwatch { label: "action.secondary.container"; swatchColor: Theme.colors.action.secondary.container }
                    TokenSwatch { label: "outline.subtle"; swatchColor: Theme.colors.outline.subtle }
                    TokenSwatch { label: "outline.focus"; swatchColor: Theme.colors.outline.focus }
                    TokenSwatch { label: "status.error.content"; swatchColor: Theme.colors.status.error.content }
                    TokenSwatch { label: "status.success.content"; swatchColor: Theme.colors.status.success.content }
                }
            }
        }

        Surface {
            id: typographySection
            objectName: "merce.playground.gallery.typography"
            width: parent.width
            height: typographyColumn.implicitHeight + Theme.spacing.xl2
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large

            Column {
                id: typographyColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.xl
                }
                spacing: Theme.spacing.md

                SectionTitle {
                    width: parent.width
                    text: "Typography"
                }

                AppLabel {
                    objectName: "merce.playground.gallery.typography.titleSample"
                    width: parent.width
                    textType: AppLabel.H2
                    text: "Başlık örneği"
                    color: Theme.colors.content.primary
                    wrapMode: Text.WordWrap
                }

                AppLabel {
                    id: bodySample
                    objectName: "merce.playground.gallery.typography.bodySample"
                    width: parent.width
                    textType: AppLabel.Body
                    text: "Body metni " + Theme.typography.fontBody + " / " + Theme.typography.sizeMedium + " px"
                    color: Theme.colors.content.primary
                    wrapMode: Text.WordWrap
                }

                AppLabel {
                    width: parent.width
                    textType: AppLabel.Caption
                    text: "Label " + Theme.typography.sizeSmall + " px / " + Theme.typography.weightSemibold
                    color: Theme.colors.content.secondary
                    wrapMode: Text.WordWrap
                }
            }
        }

        Surface {
            id: spacingRadiusSection
            objectName: "merce.playground.gallery.spacingRadius"
            width: parent.width
            height: spacingRadiusColumn.implicitHeight + Theme.spacing.xl2
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large

            Column {
                id: spacingRadiusColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.xl
                }
                spacing: Theme.spacing.md

                SectionTitle {
                    width: parent.width
                    text: "Spacing / Radius"
                }

                ScaleSample { label: "xs"; tokenValue: Theme.spacing.xs }
                ScaleSample { label: "md"; tokenValue: Theme.spacing.md }
                ScaleSample { label: "xl"; tokenValue: Theme.spacing.xl }

                Flow {
                    width: parent.width
                    spacing: Theme.spacing.lg

                    Rectangle {
                        width: 96
                        height: 54
                        radius: Theme.radius.button
                        color: Theme.colors.surface.container
                        border.width: 1
                        border.color: Theme.colors.outline.subtle
                    }

                    Rectangle {
                        width: 96
                        height: 54
                        radius: Theme.radius.input
                        color: Theme.colors.surface.container
                        border.width: 1
                        border.color: Theme.colors.outline.focus
                    }

                    Rectangle {
                        width: 96
                        height: 54
                        radius: Theme.radius.dialog
                        color: Theme.colors.surface.containerRaised
                        border.width: 1
                        border.color: Theme.colors.outline.subtle
                    }
                }
            }
        }

        Surface {
            id: componentsSection
            objectName: "merce.playground.gallery.components"
            width: parent.width
            height: componentsColumn.implicitHeight + Theme.spacing.xl2
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large

            Column {
                id: componentsColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.xl
                }
                spacing: Theme.spacing.lg

                SectionTitle {
                    width: parent.width
                    text: "Components"
                }

                Flow {
                    width: parent.width
                    spacing: Theme.spacing.md

                    SK.Button {
                        id: primaryButton
                        objectName: "merce.playground.gallery.primaryButton"
                        text: "Primary"
                        property color observedContainerColor: Theme.colors.action.primary.container
                        onClicked: NotificationCenter.success("Galeri örneği yüklendi.", "", 4000)
                    }

                    SK.Button {
                        objectName: "merce.playground.gallery.secondaryButton"
                        text: "Secondary"
                        SK.StyleVariation.variations: ["secondary"]
                    }

                    SK.Button {
                        objectName: "merce.playground.gallery.outlineButton"
                        text: "Outline"
                        SK.StyleVariation.variations: ["outline"]
                    }

                    SK.Button {
                        objectName: "merce.playground.gallery.destructiveButton"
                        text: "Destructive"
                        SK.StyleVariation.variations: ["destructive"]
                        onClicked: root.showDestructiveDialog()
                    }
                }

                SK.TextField {
                    id: emailInput
                    objectName: "merce.playground.gallery.input"
                    width: Math.min(360, parent.width)
                    placeholderText: "Email"
                    inputMethodHints: Qt.ImhEmailCharactersOnly
                    text: "theme@merce.local"
                    property color observedBorderColor: Theme.colors.outline.subtle

                    validator: RegularExpressionValidator {
                        regularExpression: /.+@.+\..+/
                    }
                }

                Flow {
                    width: parent.width
                    spacing: Theme.spacing.xl

                    SK.CheckBox {
                        objectName: "merce.playground.gallery.checkbox"
                        text: "Checkbox"
                        checked: true
                    }

                    SK.RadioButton {
                        objectName: "merce.playground.gallery.radio"
                        text: "Radio"
                        checked: true
                    }

                    SK.Switch {
                        id: switchSample
                        objectName: "merce.playground.gallery.switch"
                        text: "Switch"
                        checked: true
                        property color observedTrackColor: Theme.colors.action.primary.container
                    }
                }

                SK.ComboBox {
                    id: selectSample
                    objectName: "merce.playground.gallery.select"
                    width: Math.min(360, parent.width)
                    property color observedPaletteColor: Theme.colors.content.primary
                    model: [
                        { "value": "runtime", "label": "Runtime theme" },
                        { "value": "gallery", "label": "Gallery proof" },
                        { "value": "export", "label": "Export evidence" }
                    ]
                    textRole: "label"
                    valueRole: "value"
                    currentValue: "runtime"
                }
            }
        }

        Surface {
            id: exportStatusSection
            objectName: "merce.playground.gallery.exportStatus"
            width: parent.width
            height: exportStatusColumn.implicitHeight + Theme.spacing.xl2
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large

            Column {
                id: exportStatusColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.xl
                }
                spacing: Theme.spacing.md

                SectionTitle {
                    width: parent.width
                    text: "Evidence"
                }

                Flow {
                    width: parent.width
                    spacing: Theme.spacing.md

                    SK.Button {
                        objectName: "merce.playground.gallery.exportButton"
                        text: "Tema galerisini dışa aktar"
                        onClicked: exportState.text = "Galeri görselleri hazır"
                    }

                    SK.Button {
                        objectName: "merce.playground.gallery.changeThemeButton"
                        text: "Temayı değiştir"
                        SK.StyleVariation.variations: ["outline"]
                        onClicked: root.setMerceDark()
                    }
                }

                AppLabel {
                    id: exportState
                    objectName: "merce.playground.gallery.exportStateText"
                    width: parent.width
                    textType: AppLabel.Body
                    text: "Galeri görselleri hazır"
                    color: Theme.colors.content.secondary
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    MerceToastifyStyleProvider {
        id: toastStyle
    }
}
