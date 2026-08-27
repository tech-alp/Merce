import QtQuick
import Qt.labs.StyleKit as SK
import Merce.Style
import Merce.Controls

SK.ApplicationWindow {
    width: 320
    height: 180
    visible: true

    SK.StyleKit.style: MerceStyle {}
    SK.StyleKit.transitionsEnabled: false

    Item {
        objectName: "focusSink"
        activeFocusOnTab: true
        focus: true
    }

    MButton {
        objectName: "button"
        x: 60
        y: 60
        width: 200
        text: "Action"
    }
}
