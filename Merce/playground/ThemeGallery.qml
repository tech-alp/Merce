import QtQuick
import Merce.Core
import Merce.Foundation
import Merce.Controls
import Merce.Notifications

Item {
    id: root
    objectName: "merce.playground.gallery"

    implicitHeight: galleryColumn.implicitHeight
    height: implicitHeight

    readonly property string displayMode: Theme.activeMode === "" ? "default" : Theme.activeMode
    readonly property color observedButtonColor: primaryButton.backgroundColor
    readonly property color observedTextColor: bodySample.textColor
    readonly property color observedInputBorderColor: emailInput.borderColor
    readonly property color observedToggleColor: switchSample.trackColor
    readonly property color observedSelectColor: selectSample.observedPaletteColor
    readonly property color observedToastColor: galleryToast.variantConfig[galleryToast.variant].color
    readonly property color observedDialogColor: galleryDialog.observedSurfaceColor
    readonly property bool hasRequiredAnchors: activeThemeSection.objectName === "merce.playground.gallery.activeTheme"
                                            && paletteSection.objectName === "merce.playground.gallery.palette"
                                            && typographySection.objectName === "merce.playground.gallery.typography"
                                            && spacingRadiusSection.objectName === "merce.playground.gallery.spacingRadius"
                                            && componentsSection.objectName === "merce.playground.gallery.components"
                                            && exportStatusSection.objectName === "merce.playground.gallery.exportStatus"

    function setMerceLight() {
        const previousBrand = Theme.activeBrand
        const previousMode = Theme.activeMode
        const ok = Theme.setTheme("merce", "light")
        if (!ok)
            exportState.text = "Tema korunuyor: " + previousBrand + "/" + (previousMode === "" ? "default" : previousMode)
        return ok
    }

    function setMerceDark() {
        const previousBrand = Theme.activeBrand
        const previousMode = Theme.activeMode
        const ok = Theme.setTheme("merce", "dark")
        if (!ok)
            exportState.text = "Tema korunuyor: " + previousBrand + "/" + (previousMode === "" ? "default" : previousMode)
        return ok
    }

    function setStripeReference() {
        const previousBrand = Theme.activeBrand
        const previousMode = Theme.activeMode
        const ok = Theme.setTheme("stripe")
        if (!ok)
            exportState.text = "Tema korunuyor: " + previousBrand + "/" + (previousMode === "" ? "default" : previousMode)
        return ok
    }

    function colorLabel(value) {
        return String(value).toUpperCase()
    }

    component SectionTitle: MText {
        type: "h4"
        textColor: Theme.palette.textPrimary
        wrap: "word"
    }

    component FieldLabel: MText {
        type: "caption"
        textColor: Theme.palette.text.secondary
        wrap: "word"
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
            border.color: Theme.palette.borderBase
        }

        Column {
            anchors {
                left: swatch.right
                right: parent.right
                verticalCenter: swatch.verticalCenter
                leftMargin: Theme.spacing.sm
            }
            spacing: Theme.spacing.xxs

            MText {
                width: parent.width
                type: "caption"
                text: label
                textColor: Theme.palette.textPrimary
                wrap: "word"
            }

            MText {
                width: parent.width
                type: "caption"
                text: root.colorLabel(swatchColor)
                textColor: Theme.palette.text.secondary
                wrap: "word"
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
            color: Theme.palette.actionPrimary
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

        MSurface {
            id: activeThemeSection
            objectName: "merce.playground.gallery.activeTheme"
            width: parent.width
            height: activeThemeColumn.implicitHeight + Theme.spacing.xl2
            surfaceType: types["default"]
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
                        width: parent.width - selectorRow.width - parent.spacing
                        spacing: Theme.spacing.xxs

                        SectionTitle {
                            width: parent.width
                            text: "Tema doğrulama galerisi"
                        }

                        MText {
                            width: parent.width
                            type: "body"
                            text: Theme.activeBrand + " / " + root.displayMode
                            textColor: Theme.palette.text.secondary
                            wrap: "word"
                        }
                    }

                    Row {
                        id: selectorRow
                        spacing: Theme.spacing.sm
                        anchors.verticalCenter: parent.verticalCenter

                        MButton {
                            objectName: "merce.playground.gallery.selector.merceLight"
                            text: "Merce Light"
                            variant: Theme.activeBrand === "merce" && Theme.activeMode === "light" ? "primary" : "outline"
                            onClicked: root.setMerceLight()
                        }

                        MButton {
                            objectName: "merce.playground.gallery.selector.merceDark"
                            text: "Merce Dark"
                            variant: Theme.activeBrand === "merce" && Theme.activeMode === "dark" ? "primary" : "outline"
                            onClicked: root.setMerceDark()
                        }

                        MButton {
                            objectName: "merce.playground.gallery.selector.stripe"
                            text: "Stripe Reference"
                            variant: Theme.activeBrand === "stripe" ? "primary" : "outline"
                            onClicked: root.setStripeReference()
                        }
                    }
                }
            }
        }

        MSurface {
            id: paletteSection
            objectName: "merce.playground.gallery.palette"
            width: parent.width
            height: paletteColumn.implicitHeight + Theme.spacing.xl2
            surfaceType: types["default"]
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

                    TokenSwatch { label: "backgroundBase"; swatchColor: Theme.palette.backgroundBase }
                    TokenSwatch { label: "backgroundSurface"; swatchColor: Theme.palette.backgroundSurface }
                    TokenSwatch { label: "textPrimary"; swatchColor: Theme.palette.textPrimary }
                    TokenSwatch { label: "actionPrimary"; swatchColor: Theme.palette.actionPrimary }
                    TokenSwatch { label: "borderBase"; swatchColor: Theme.palette.borderBase }
                    TokenSwatch { label: "borderFocus"; swatchColor: Theme.palette.border.focus }
                    TokenSwatch { label: "statusError"; swatchColor: Theme.palette.statusError }
                    TokenSwatch { label: "statusSuccess"; swatchColor: Theme.palette.status.success }
                }
            }
        }

        MSurface {
            id: typographySection
            objectName: "merce.playground.gallery.typography"
            width: parent.width
            height: typographyColumn.implicitHeight + Theme.spacing.xl2
            surfaceType: types["default"]
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

                MText {
                    objectName: "merce.playground.gallery.typography.titleSample"
                    width: parent.width
                    type: "h2"
                    text: "Başlık örneği"
                    textColor: Theme.palette.textPrimary
                    wrap: "word"
                }

                MText {
                    id: bodySample
                    objectName: "merce.playground.gallery.typography.bodySample"
                    width: parent.width
                    type: "body"
                    text: "Body metni " + Theme.typography.fontBody + " / " + Theme.typography.sizeMedium + " px"
                    textColor: Theme.palette.textPrimary
                    wrap: "word"
                }

                MText {
                    width: parent.width
                    type: "caption"
                    text: "Label " + Theme.typography.sizeSmall + " px / " + Theme.typography.weightSemibold
                    textColor: Theme.palette.text.secondary
                    wrap: "word"
                }
            }
        }

        MSurface {
            id: spacingRadiusSection
            objectName: "merce.playground.gallery.spacingRadius"
            width: parent.width
            height: spacingRadiusColumn.implicitHeight + Theme.spacing.xl2
            surfaceType: types["default"]
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
                        color: Theme.palette.backgroundSurface
                        border.width: 1
                        border.color: Theme.palette.borderBase
                    }

                    Rectangle {
                        width: 96
                        height: 54
                        radius: Theme.radius.input
                        color: Theme.palette.backgroundSurface
                        border.width: 1
                        border.color: Theme.palette.border.focus
                    }

                    Rectangle {
                        width: 96
                        height: 54
                        radius: Theme.radius.dialog
                        color: Theme.palette.background.elevated
                        border.width: 1
                        border.color: Theme.palette.borderBase
                    }
                }
            }
        }

        MSurface {
            id: componentsSection
            objectName: "merce.playground.gallery.components"
            width: parent.width
            height: componentsColumn.implicitHeight + Theme.spacing.xl2
            surfaceType: types["default"]
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
                        variant: "primary"
                        onClicked: galleryToast.show()
                    }

                    MButton {
                        objectName: "merce.playground.gallery.secondaryButton"
                        text: "Secondary"
                        variant: "secondary"
                    }

                    MButton {
                        objectName: "merce.playground.gallery.outlineButton"
                        text: "Outline"
                        variant: "outline"
                    }

                    MButton {
                        objectName: "merce.playground.gallery.destructiveButton"
                        text: "Destructive"
                        variant: "destructive"
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
                    property color observedPaletteColor: Theme.palette.textPrimary
                    options: [
                        { "value": "runtime", "label": "Runtime theme" },
                        { "value": "gallery", "label": "Gallery proof" },
                        { "value": "export", "label": "Export evidence" }
                    ]
                }
            }
        }

        MSurface {
            id: exportStatusSection
            objectName: "merce.playground.gallery.exportStatus"
            width: parent.width
            height: exportStatusColumn.implicitHeight + Theme.spacing.xl2
            surfaceType: types["default"]
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
                        variant: "primary"
                        onClicked: exportState.text = "Galeri görselleri hazır"
                    }

                    MButton {
                        objectName: "merce.playground.gallery.changeThemeButton"
                        text: "Temayı değiştir"
                        variant: "outline"
                        onClicked: root.setMerceDark()
                    }
                }

                MText {
                    id: exportState
                    objectName: "merce.playground.gallery.exportStateText"
                    width: parent.width
                    type: "body"
                    text: "Galeri görselleri hazır"
                    textColor: Theme.palette.text.secondary
                    wrap: "word"
                }
            }
        }
    }

    MToast {
        id: galleryToast
        objectName: "merce.playground.gallery.toast"
        title: "Merce"
        message: "Galeri örneği yüklendi."
        variant: "success"
    }

    MDialog {
        id: galleryDialog
        objectName: "merce.playground.gallery.dialog"
        title: "Galeri örneği"
        message: "Tema değerleri okunuyor."
        confirmText: "OK"
        showCancel: false
        property color observedSurfaceColor: Theme.palette.backgroundSurface
        onConfirmed: isOpen = false
    }
}
