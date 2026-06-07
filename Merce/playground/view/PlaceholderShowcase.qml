import QtQuick
import Merce.Theme
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
        surfaceType: Surface.Default
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

            AppLabel {
                width: parent.width
                textType: AppLabel.H4
                text: root.title
                color: Theme.colors.text.primary
                wrapMode: Text.WordWrap
            }

            AppLabel {
                width: parent.width
                textType: AppLabel.Body
                text: "Content pending."
                color: Theme.colors.text.secondary
                wrapMode: Text.WordWrap
            }
        }
    }
}
