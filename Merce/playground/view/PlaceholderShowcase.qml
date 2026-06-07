import QtQuick
import Merce.Core
import Merce.Foundation

Item {
    id: root

    required property string title

    implicitHeight: page.implicitHeight
    height: implicitHeight

    Surface {
        id: page
        width: root.width
        height: contentColumn.implicitHeight + Theme.spacing.xl2
        surfaceType: types["default"]
        radiusValue: Theme.radius.large

        Column {
            id: contentColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Theme.spacing.xl
            }
            spacing: Theme.spacing.sm

            ThemedText {
                width: parent.width
                type: "h4"
                text: root.title
                textColor: Theme.colors.text.primary
                wrap: "word"
            }

            ThemedText {
                width: parent.width
                type: "body"
                text: "Content pending."
                textColor: Theme.colors.text.secondary
                wrap: "word"
            }
        }
    }
}
