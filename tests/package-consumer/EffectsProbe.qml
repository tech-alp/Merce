import QtQuick
import Qt.labs.StyleKit as SK
import Merce.Controls
import Merce.Style.Effects

SK.ApplicationWindow {
    width: 320
    height: 180
    visible: true
    SK.StyleKit.style: MerceEffectsStyle {}

    MButton {
        anchors.centerIn: parent
        text: "Sheen"
        extraVariations: ["sheen"]
    }
}
