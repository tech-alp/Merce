import QtQuick
import Merce.Core
import Merce.Foundation

Item {
    id: root
    objectName: "merce.playground.showcase.typography"

    implicitHeight: page.implicitHeight
    height: implicitHeight

    readonly property int specimenCount: 14
    readonly property int labelColumnWidth: 78
    readonly property bool darkMode: Theme.activeMode === "dark"
    readonly property color specimenBackground: darkMode ? Theme.palette.backgroundSurface : Theme.palette.textPrimary
    readonly property color specimenForeground: darkMode ? Theme.palette.textPrimary : Theme.palette.backgroundSurface
    readonly property color specimenMuted: Qt.rgba(specimenForeground.r, specimenForeground.g, specimenForeground.b, 0.64)

    component ScaleRow: Item {
        required property string roleName
        required property string sampleText
        required property int pixelSize
        property string family: Theme.typography.fontBody
        property int sampleWeight: Theme.typography.weightRegular
        property bool uppercase: false

        width: scaleColumn.width
        height: Math.max(roleLabel.implicitHeight, sampleLabel.implicitHeight)

        Text {
            id: roleLabel
            width: root.labelColumnWidth
            anchors.verticalCenter: sampleLabel.verticalCenter
            text: roleName
            color: root.specimenMuted
            font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
            font.pixelSize: Theme.typography.sizeXSmall
            font.weight: Theme.typography.weightMedium
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            id: sampleLabel
            x: root.labelColumnWidth
            width: Math.max(0, parent.width - x)
            text: uppercase ? sampleText.toUpperCase() : sampleText
            color: root.specimenForeground
            font.family: FoundationFonts.resolveFamily(family)
            font.pixelSize: pixelSize
            font.weight: sampleWeight
            font.capitalization: uppercase ? Font.AllUppercase : Font.MixedCase
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
        }
    }

    Column {
        id: page
        width: root.width
        spacing: Theme.spacing.lg

        Surface {
            objectName: "merce.playground.typography.scale"
            width: parent.width
            height: scaleColumn.implicitHeight + Theme.spacing.xl2
            surfaceType: types["default"]
            backgroundColor: root.specimenBackground
            borderColor: "transparent"
            borderWidth: 0
            radiusValue: Theme.radius.large

            Column {
                id: scaleColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.lg
                }
                spacing: 0

                ScaleRow {
                    roleName: "headline1"
                    sampleText: "headline1 " + Theme.typography.size7XLarge + "px"
                    pixelSize: Theme.typography.size7XLarge
                    family: Theme.typography.fontDisplay
                    sampleWeight: Theme.typography.weightRegular
                }

                ScaleRow {
                    roleName: "headline2"
                    sampleText: "headline2 " + Theme.typography.size6XLarge + "px"
                    pixelSize: Theme.typography.size6XLarge
                    family: Theme.typography.fontDisplay
                    sampleWeight: Theme.typography.weightRegular
                }

                ScaleRow {
                    roleName: "headline3"
                    sampleText: "headline3 " + Theme.typography.size5XLarge + "px"
                    pixelSize: Theme.typography.size5XLarge
                    family: Theme.typography.fontDisplay
                    sampleWeight: Theme.typography.weightRegular
                }

                ScaleRow {
                    roleName: "headline4"
                    sampleText: "headline4 " + Theme.typography.size4XLarge + "px"
                    pixelSize: Theme.typography.size4XLarge
                    family: Theme.typography.fontDisplay
                    sampleWeight: Theme.typography.weightRegular
                }

                ScaleRow {
                    roleName: "headline5"
                    sampleText: "headline5 " + Theme.typography.size2XLarge + "px"
                    pixelSize: Theme.typography.size2XLarge
                    family: Theme.typography.fontDisplay
                    sampleWeight: Theme.typography.weightRegular
                }

                ScaleRow {
                    roleName: "headline6"
                    sampleText: "headline6 " + Theme.typography.sizeXLarge + "px"
                    pixelSize: Theme.typography.sizeXLarge
                    family: Theme.typography.fontDisplay
                    sampleWeight: Theme.typography.weightSemibold
                }

                ScaleRow {
                    roleName: "subtitle1"
                    sampleText: "subtitle1 " + Theme.typography.sizeMedium + "px"
                    pixelSize: Theme.typography.sizeMedium
                    sampleWeight: Theme.typography.weightRegular
                }

                ScaleRow {
                    roleName: "subtitle2"
                    sampleText: "subtitle2 " + Theme.typography.sizeSmall + "px"
                    pixelSize: Theme.typography.sizeSmall
                    sampleWeight: Theme.typography.weightSemibold
                }

                ScaleRow {
                    roleName: "body1"
                    sampleText: "body1 " + Theme.typography.sizeMedium + "px"
                    pixelSize: Theme.typography.sizeMedium
                }

                ScaleRow {
                    roleName: "body2"
                    sampleText: "body2 " + Theme.typography.sizeSmall + "px"
                    pixelSize: Theme.typography.sizeSmall
                }

                ScaleRow {
                    roleName: "button"
                    sampleText: "button " + Theme.typography.sizeSmall + "px"
                    pixelSize: Theme.typography.sizeSmall
                    sampleWeight: Theme.typography.weightSemibold
                    uppercase: true
                }

                ScaleRow {
                    roleName: "overline"
                    sampleText: "overline " + Theme.typography.sizeXSmall + "px"
                    pixelSize: Theme.typography.sizeXSmall
                    sampleWeight: Theme.typography.weightSemibold
                    uppercase: true
                }

                ScaleRow {
                    roleName: "caption"
                    sampleText: "caption " + Theme.typography.sizeXSmall + "px"
                    pixelSize: Theme.typography.sizeXSmall
                    sampleWeight: Theme.typography.weightRegular
                }

                ScaleRow {
                    roleName: "hint"
                    sampleText: "hint " + Theme.typography.sizeXSmall + "px"
                    pixelSize: Theme.typography.sizeXSmall
                    sampleWeight: Theme.typography.weightRegular
                }
            }
        }
    }
}
