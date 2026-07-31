import QtQuick
import Merce.Theme
import Merce.Foundation
import Merce.Controls
import Merce.Notifications
import Toastify

Item {
    id: root
    objectName: "merce.playground.gallery"

    implicitHeight: galleryColumn.implicitHeight
    height: implicitHeight

    readonly property string displayMode: Theme.activeMode === "" ? "default" : Theme.activeMode
    readonly property var themeOptions: Theme.availableThemes
    readonly property var modeOptions: root.modeOptionsFor(Theme.activeBrand)
    readonly property color observedButtonColor: primaryButton.backgroundColor
    readonly property color observedTextColor: bodySample.color
    readonly property color observedInputBorderColor: emailInput.borderColor
    readonly property color observedToggleColor: switchSample.trackColor
    readonly property color observedSelectColor: selectSample.observedPaletteColor
    readonly property color observedToastColor: toastStyle.colors.success
    readonly property color observedDialogColor: galleryDialog.observedSurfaceColor
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

    component SectionTitle: AppLabel {
        textType: AppLabel.H4
        color: Theme.colors.text.primary
        wrapMode: Text.WordWrap
    }

    component FieldLabel: AppLabel {
        textType: AppLabel.Caption
        color: Theme.colors.text.secondary
        wrapMode: Text.WordWrap
    }

    component TokenSwatch: Item {
        required property string label
        required property color swatchColor

        width: 180
        height: 76

        Rectangle {
            id: swatch
            objectName: "merce.playground.gallery.swatch." + label
            width: 44
            height: 44
            radius: Theme.radius.medium
            color: swatchColor
            border.width: 1
            border.color: Theme.colors.border.base
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
                color: Theme.colors.text.primary
                wrapMode: Text.WordWrap
            }

            AppLabel {
                width: parent.width
                textType: AppLabel.Caption
                text: root.colorLabel(swatchColor)
                color: Theme.colors.text.secondary
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
            color: Theme.colors.action.primary
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

                Row {
                    width: parent.width
                    spacing: Theme.spacing.md

                    Column {
                        width: Math.max(260, parent.width - selectorRow.width - parent.spacing)
                        spacing: Theme.spacing.xxs

                        SectionTitle {
                            width: parent.width
                            text: "Tema doğrulama galerisi"
                        }

                        AppLabel {
                            width: parent.width
                            textType: AppLabel.Body
                            text: Theme.activeBrand + " / " + root.displayMode
                            color: Theme.colors.text.secondary
                            wrapMode: Text.WordWrap
                        }
                    }

                    Row {
                        id: selectorRow
                        width: implicitWidth
                        spacing: Theme.spacing.sm
                        anchors.verticalCenter: parent.verticalCenter

                        Column {
                            id: themeSelectorField
                            width: 280
                            spacing: Theme.spacing.xxs

                            FieldLabel {
                                width: parent.width
                                text: "Tasarım sistemi"
                            }

                            MSelect {
                                objectName: "merce.playground.gallery.selector.theme"
                                width: parent.width
                                selectedValue: Theme.activeBrand
                                options: root.themeOptions
                                onSelected: function(value) {
                                    const brand = String(value)
                                    root.applyTheme(brand, root.defaultModeFor(brand))
                                }
                            }
                        }

                        Column {
                            id: modeSelectorField
                            width: 180
                            spacing: Theme.spacing.xxs
                            visible: root.modeOptions.length > 0

                            FieldLabel {
                                width: parent.width
                                text: "Mode"
                            }

                            MSelect {
                                objectName: "merce.playground.gallery.selector.mode"
                                width: parent.width
                                selectedValue: Theme.activeMode
                                options: root.modeOptions
                                onSelected: function(value) {
                                    root.applyTheme(Theme.activeBrand, String(value))
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

                Flow {
                    width: parent.width
                    spacing: Theme.spacing.md

                    TokenSwatch { label: "backgroundBase"; swatchColor: Theme.colors.background.base }
                    TokenSwatch { label: "surfaceBase"; swatchColor: Theme.colors.surface.base }
                    TokenSwatch { label: "textPrimary"; swatchColor: Theme.colors.text.primary }
                    TokenSwatch { label: "actionPrimary"; swatchColor: Theme.colors.action.primary }
                    TokenSwatch { label: "actionPrimaryDark"; swatchColor: Theme.colors.action.primaryPressed }
                    TokenSwatch { label: "actionSecondary"; swatchColor: Theme.colors.action.secondary }
                    TokenSwatch { label: "actionSecondaryDark"; swatchColor: Theme.colors.action.secondaryPressed }
                    TokenSwatch { label: "borderBase"; swatchColor: Theme.colors.border.base }
                    TokenSwatch { label: "borderFocus"; swatchColor: Theme.colors.border.focus }
                    TokenSwatch { label: "statusError"; swatchColor: Theme.colors.status.error.foreground }
                    TokenSwatch { label: "statusSuccess"; swatchColor: Theme.colors.status.success.foreground }
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
                    color: Theme.colors.text.primary
                    wrapMode: Text.WordWrap
                }

                AppLabel {
                    id: bodySample
                    objectName: "merce.playground.gallery.typography.bodySample"
                    width: parent.width
                    textType: AppLabel.Body
                    text: "Body metni " + Theme.typography.fontBody + " / " + Theme.typography.sizeMedium + " px"
                    color: Theme.colors.text.primary
                    wrapMode: Text.WordWrap
                }

                AppLabel {
                    width: parent.width
                    textType: AppLabel.Caption
                    text: "Label " + Theme.typography.sizeSmall + " px / " + Theme.typography.weightSemibold
                    color: Theme.colors.text.secondary
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

                Row {
                    spacing: Theme.spacing.lg

                    Rectangle {
                        width: 96
                        height: 54
                        radius: Theme.radius.button
                        color: Theme.colors.surface.base
                        border.width: 1
                        border.color: Theme.colors.border.base
                    }

                    Rectangle {
                        width: 96
                        height: 54
                        radius: Theme.radius.input
                        color: Theme.colors.surface.base
                        border.width: 1
                        border.color: Theme.colors.border.focus
                    }

                    Rectangle {
                        width: 96
                        height: 54
                        radius: Theme.radius.dialog
                        color: Theme.colors.surface.raised
                        border.width: 1
                        border.color: Theme.colors.border.base
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

                    MButton {
                        id: primaryButton
                        objectName: "merce.playground.gallery.primaryButton"
                        text: "Primary"
                        variant: MButton.Primary
                        onClicked: galleryToast.success("Galeri örneği yüklendi.", {
                            position: Toastify.BottomRightCorner,
                            autoClose: 4000,
                            closeOnClick: true,
                            hideProgressBar: false
                        })
                    }

                    MButton {
                        objectName: "merce.playground.gallery.secondaryButton"
                        text: "Secondary"
                        variant: MButton.Secondary
                    }

                    MButton {
                        objectName: "merce.playground.gallery.outlineButton"
                        text: "Outline"
                        variant: MButton.Outline
                    }

                    MButton {
                        objectName: "merce.playground.gallery.destructiveButton"
                        text: "Destructive"
                        variant: MButton.Destructive
                        onClicked: galleryDialog.isOpen = true
                    }
                }

                MInput {
                    id: emailInput
                    objectName: "merce.playground.gallery.input"
                    width: 360
                    placeholder: "Email"
                    inputType: "email"
                    text: "theme@merce.local"
                }

                Flow {
                    width: parent.width
                    spacing: Theme.spacing.xl

                    MCheckbox {
                        objectName: "merce.playground.gallery.checkbox"
                        label: "Checkbox"
                        checked: true
                    }

                    MRadio {
                        objectName: "merce.playground.gallery.radio"
                        label: "Radio"
                        checked: true
                    }

                    MSwitch {
                        id: switchSample
                        objectName: "merce.playground.gallery.switch"
                        label: "Switch"
                        checked: true
                    }
                }

                MSelect {
                    id: selectSample
                    objectName: "merce.playground.gallery.select"
                    width: 360
                    selectedValue: "runtime"
                    property color observedPaletteColor: Theme.colors.text.primary
                    options: [
                        { "value": "runtime", "label": "Runtime theme" },
                        { "value": "gallery", "label": "Gallery proof" },
                        { "value": "export", "label": "Export evidence" }
                    ]
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

                Row {
                    spacing: Theme.spacing.md

                    MButton {
                        objectName: "merce.playground.gallery.exportButton"
                        text: "Tema galerisini dışa aktar"
                        variant: MButton.Primary
                        onClicked: exportState.text = "Galeri görselleri hazır"
                    }

                    MButton {
                        objectName: "merce.playground.gallery.changeThemeButton"
                        text: "Temayı değiştir"
                        variant: MButton.Outline
                        onClicked: root.setMerceDark()
                    }
                }

                AppLabel {
                    id: exportState
                    objectName: "merce.playground.gallery.exportStateText"
                    width: parent.width
                    textType: AppLabel.Body
                    text: "Galeri görselleri hazır"
                    color: Theme.colors.text.secondary
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    MerceToastifyStyleProvider {
        id: toastStyle
    }

    Toastify {
        id: galleryToast
        objectName: "merce.playground.gallery.toastify"
        style: toastStyle
    }

    MDialog {
        id: galleryDialog
        objectName: "merce.playground.gallery.dialog"
        title: "Galeri örneği"
        message: "Tema değerleri okunuyor."
        confirmText: "OK"
        showCancel: false
        property color observedSurfaceColor: Theme.colors.surface.base
        onConfirmed: isOpen = false
    }
}
