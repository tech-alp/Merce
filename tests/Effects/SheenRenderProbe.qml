import QtQuick
import Merce.Effects

Window {
    width: 240
    height: 160
    visible: true
    color: "#204060"

    MSheen {
        objectName: "primitive"
        x: 24
        y: 24
        width: 192
        height: 112
        progress: 0.5
        intensity: 0.5
        color: Qt.rgba(1, 0.4, 0.2, 0.5)
        topLeftRadius: 40
        topRightRadius: 0
        bottomLeftRadius: 12
        bottomRightRadius: 28
    }
}
