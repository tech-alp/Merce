import QtQuick
import QtQuick.Shapes
import Merce.Theme

Item {
    id: root

    property real size: Theme.icons.medium

    readonly property var colors: Theme.colors
    property color color: root.colors.action.primary.content
    property bool running: false

    implicitWidth: size
    implicitHeight: size

    Shape {
        anchors.fill: parent
        visible: root.running

        ShapePath {
            id: spinnerPath

            readonly property real lineWidth: Math.max(2, root.size / 8)
            readonly property real arcRadius: Math.max(0, Math.min(root.width, root.height) / 2 - lineWidth)

            fillColor: "transparent"
            strokeColor: root.color
            strokeWidth: lineWidth
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: spinnerPath.arcRadius
                radiusY: spinnerPath.arcRadius
                startAngle: -90
                sweepAngle: 252
            }
        }

        RotationAnimator on rotation {
            from: 0
            to: 360
            duration: Theme.motion.durationSlowest
            loops: Animation.Infinite
            running: root.running
        }
    }
}
