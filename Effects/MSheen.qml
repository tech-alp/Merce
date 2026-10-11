import QtQuick

// A source-free, decorative sweep. The caller owns progress and its lifetime.
ShaderEffect {
    id: root

    property color color: "white"
    property real progress: 0
    property real intensity: 0.28
    property real bandWidth: 0.24
    property real radius: 0
    property real topLeftRadius: root.radius
    property real topRightRadius: root.radius
    property real bottomRightRadius: root.radius
    property real bottomLeftRadius: root.radius

    readonly property vector2d surfaceSize: Qt.vector2d(root.width, root.height)
    readonly property vector4d cornerRadii: Qt.vector4d(root.topLeftRadius,
                                                       root.topRightRadius,
                                                       root.bottomRightRadius,
                                                       root.bottomLeftRadius)
    readonly property real pixelSize: 1 / Math.max(0.1, Screen.devicePixelRatio)

    Accessible.ignored: true
    fragmentShader: "qrc:/qt/qml/Merce/Effects/shaders/sheen.frag.qsb"
}
