import QtQuick

Item {
    id: root

    property int size: 24
    property color color: "#000000"
    property bool running: false

    implicitWidth: size
    implicitHeight: size
    width: size
    height: size

    Canvas {
        id: canvas
        anchors.fill: parent
        opacity: root.running ? 1.0 : 0.0
        onPaint: {
            const ctx = getContext("2d")
            const lineWidth = Math.max(2, root.size / 8)
            const radius = root.size / 2 - lineWidth

            ctx.clearRect(0, 0, width, height)
            ctx.beginPath()
            ctx.lineWidth = lineWidth
            ctx.lineCap = "round"
            ctx.strokeStyle = root.color
            ctx.arc(width / 2, height / 2, radius, -Math.PI / 2, Math.PI * 0.9)
            ctx.stroke()
        }

        RotationAnimator on rotation {
            from: 0
            to: 360
            duration: 900
            loops: Animation.Infinite
            running: root.running
        }
    }

    onColorChanged: canvas.requestPaint()
    onSizeChanged: canvas.requestPaint()
}
