import QtQuick
import Merce.Core

Item {
    id: root

    property Component sourceComponent

    Flickable {
        id: pageFlickable
        objectName: root.objectName + ".flickable"
        anchors.fill: parent
        contentWidth: width
        contentHeight: Math.max(height, pageLoader.item ? pageLoader.item.implicitHeight + Theme.spacing.xl2 * 2 : height)
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Loader {
            id: pageLoader
            objectName: root.objectName + ".loader"
            x: Theme.spacing.xl
            y: Theme.spacing.xl
            width: Math.max(0, pageFlickable.width - Theme.spacing.xl * 2)
            sourceComponent: root.sourceComponent
        }
    }
}
