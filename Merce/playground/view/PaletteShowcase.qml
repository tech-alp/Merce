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

    component SectionTitle: ThemedText {
        type: "h4"
        textColor: Theme.colors.text.primary
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

            ThemedText {
                width: parent.width
                type: "caption"
                text: label
                textColor: Theme.colors.text.primary
                wrap: "word"
            }

            ThemedText {
                width: parent.width
                type: "caption"
                text: root.colorLabel(swatchColor)
                textColor: Theme.colors.text.secondary
                wrap: "word"
            }
        }
    }

    component PaletteGroup: Surface {
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

            ColorTile { label: "button.primary.bg"; swatchColor: Theme.colors.action.primary }
            ColorTile { label: "button.primary.hover"; swatchColor: Theme.colors.action.primaryPressed }
            ColorTile { label: "button.secondary.bg"; swatchColor: Theme.colors.action.secondary }
            ColorTile { label: "button.secondary.hover"; swatchColor: Theme.colors.action.secondaryPressed }
            ColorTile { label: "button.outline.border"; swatchColor: Theme.colors.action.primary }
            ColorTile { label: "button.destructive.bg"; swatchColor: Theme.colors.status.error }
        }

        PaletteGroup {
            title: "Semantic palette"

            ColorTile { label: "backgroundBase"; swatchColor: Theme.colors.background.base }
            ColorTile { label: "backgroundSurface"; swatchColor: Theme.colors.background.surface }
            ColorTile { label: "backgroundElevated"; swatchColor: Theme.colors.background.elevated }
            ColorTile { label: "textPrimary"; swatchColor: Theme.colors.text.primary }
            ColorTile { label: "textSecondary"; swatchColor: Theme.colors.text.secondary }
            ColorTile { label: "borderBase"; swatchColor: Theme.colors.border.base }
            ColorTile { label: "borderFocus"; swatchColor: Theme.colors.border.focus }
        }

        PaletteGroup {
            title: "Status palette"

            ColorTile { label: "success"; swatchColor: Theme.colors.status.success }
            ColorTile { label: "warning"; swatchColor: Theme.colors.status.warning }
            ColorTile { label: "error"; swatchColor: Theme.colors.status.error }
            ColorTile { label: "info"; swatchColor: Theme.colors.status.info }
        }
    }
}
