import QtQuick
import QtQuick.Shapes
import Merce.Core

Item {
    id: root
    objectName: "merce.icons.fontawesome.icon"

    property string name: ""
    property real size: Theme.icons.medium
    property color color: Theme.colors.text.primary

    readonly property int roundedSize: Math.round(size)
    readonly property var iconSpec: FontAwesomeRegistry.resolve(name)
    readonly property bool hasIcon: iconSpec !== null
    readonly property var viewBox: hasIcon ? iconSpec.viewBox : [0, 0, 1, 1]
    readonly property real viewBoxWidth: Math.max(1, Number(viewBox[2] || 1))
    readonly property real viewBoxHeight: Math.max(1, Number(viewBox[3] || 1))
    readonly property real contentScale: Math.min(width / viewBoxWidth, height / viewBoxHeight)

    implicitWidth: roundedSize
    implicitHeight: roundedSize
    width: roundedSize
    height: roundedSize
    Accessible.ignored: true

    Item {
        id: vectorCanvas
        width: root.viewBoxWidth
        height: root.viewBoxHeight
        anchors.centerIn: parent
        scale: root.contentScale
        visible: root.hasIcon

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                fillColor: root.color
                strokeColor: "transparent"
                fillRule: ShapePath.WindingFill

                PathSvg {
                    path: root.hasIcon ? root.iconSpec.path : ""
                }
            }
        }
    }
}
