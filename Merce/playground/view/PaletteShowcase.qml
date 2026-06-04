import QtQuick
import Merce.Core
import Merce.Foundation

Item {
    id: root
    objectName: "merce.playground.showcase.palette"

    implicitHeight: page.implicitHeight
    height: implicitHeight

    function colorLabel(value) {
        return String(value).toUpperCase()
    }

    component SectionTitle: MText {
        type: "h4"
        textColor: Theme.palette.textPrimary
        wrap: "word"
    }

    component ColorTile: Item {
        required property string label
        required property color swatchColor
        property int tileWidth: 200

        width: tileWidth
        height: 86

        Rectangle {
            id: swatch
            width: 52
            height: 52
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

    component PaletteGroup: MSurface {
        required property string title
        default property alias content: groupFlow.data

        width: page.width
        height: groupColumn.implicitHeight + Theme.spacing.xl2
        surfaceType: types["default"]
        radiusValue: Theme.radius.large

        Column {
            id: groupColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Theme.spacing.xl
            }
            spacing: Theme.spacing.lg

            SectionTitle {
                width: parent.width
                text: title
            }

            Flow {
                id: groupFlow
                width: parent.width
                spacing: Theme.spacing.md
            }
        }
    }

    Column {
        id: page
        width: root.width
        spacing: Theme.spacing.xl

        PaletteGroup {
            title: "Button variants"

            ColorTile { label: "button.primary.bg"; swatchColor: Theme.palette.actionPrimary }
            ColorTile { label: "button.primary.hover"; swatchColor: Theme.palette.action.primaryDark }
            ColorTile { label: "button.secondary.bg"; swatchColor: Theme.palette.actionSecondary }
            ColorTile { label: "button.secondary.hover"; swatchColor: Theme.palette.action.secondaryDark }
            ColorTile { label: "button.outline.border"; swatchColor: Theme.palette.actionPrimary }
            ColorTile { label: "button.destructive.bg"; swatchColor: Theme.palette.statusError }
        }

        PaletteGroup {
            title: "Semantic palette"

            ColorTile { label: "backgroundBase"; swatchColor: Theme.palette.backgroundBase }
            ColorTile { label: "backgroundSurface"; swatchColor: Theme.palette.backgroundSurface }
            ColorTile { label: "backgroundElevated"; swatchColor: Theme.palette.background.elevated }
            ColorTile { label: "textPrimary"; swatchColor: Theme.palette.textPrimary }
            ColorTile { label: "textSecondary"; swatchColor: Theme.palette.text.secondary }
            ColorTile { label: "borderBase"; swatchColor: Theme.palette.borderBase }
            ColorTile { label: "borderFocus"; swatchColor: Theme.palette.border.focus }
        }

        PaletteGroup {
            title: "Status palette"

            ColorTile { label: "success"; swatchColor: Theme.palette.status.success }
            ColorTile { label: "warning"; swatchColor: Theme.palette.status.warning }
            ColorTile { label: "error"; swatchColor: Theme.palette.statusError }
            ColorTile { label: "info"; swatchColor: Theme.palette.status.info }
        }
    }
}
