import QtQuick
import Qt.labs.StyleKit as SK

import Merce.Controls
import Merce.Effects
import Merce.Foundation
import Merce.Icons.FontAwesome
import Merce.Style
import Merce.Theme

SK.ApplicationWindow {
    width: 320
    height: 240
    visible: true

    SK.StyleKit.style: MerceStyle {}

    MShadow {
        anchors.fill: button
        layers: Theme.shadows.card
        surfaceRadius: Theme.radius.button
    }

    MButton {
        id: button
        anchors.centerIn: parent
        text: "Merce"
        iconName: "material:check"
    }

    FontAwesomeIcon {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        name: "fa-solid:check"
        width: 16
        height: 16
    }
}
