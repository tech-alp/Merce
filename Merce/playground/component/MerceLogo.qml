import QtQuick
import QtQuick.Shapes
import Merce.Theme

Item {
    id: root

    property color color: Theme.colors.action.primary

    implicitWidth: 24
    implicitHeight: 20

    Shape {
        id: logoShape
        width: 24
        height: 20
        anchors.centerIn: parent
        preferredRendererType: Shape.CurveRenderer
        asynchronous: true
        scale: Math.min(root.width / width, root.height / height)

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            fillRule: ShapePath.WindingFill
            pathHints: ShapePath.PathQuadratic | ShapePath.PathNonIntersecting | ShapePath.PathNonOverlappingControlPointTriangles
            PathSvg { path: "M 7.42336 0 L 0 0 L 0 12.7525 L 7.42336 19.9456 L 7.42336 0" }
        }

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            fillRule: ShapePath.WindingFill
            pathHints: ShapePath.PathQuadratic | ShapePath.PathNonIntersecting | ShapePath.PathNonOverlappingControlPointTriangles
            PathSvg { path: "M 24.0005 0 L 16.5771 0 L 16.5771 19.9456 L 24.0005 12.7525 L 24.0005 0" }
        }

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            fillRule: ShapePath.WindingFill
            pathHints: ShapePath.PathQuadratic | ShapePath.PathNonIntersecting | ShapePath.PathNonOverlappingControlPointTriangles
            PathSvg { path: "M 0 0 L 7.42383 11.6208 L 7.42383 0 L 0 0" }
        }

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            fillRule: ShapePath.WindingFill
            pathHints: ShapePath.PathQuadratic | ShapePath.PathNonIntersecting | ShapePath.PathNonOverlappingControlPointTriangles
            PathSvg { path: "M 24.0005 0 L 16.5771 0 L 16.5771 11.6208 L 24.0005 0" }
        }

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            fillRule: ShapePath.WindingFill
            pathHints: ShapePath.PathQuadratic | ShapePath.PathNonIntersecting | ShapePath.PathNonOverlappingControlPointTriangles
            PathSvg { path: "M 24 0 L 12 12.9435 L 8.27734 8.9331 L 16.5766 0 L 24 0" }
        }

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            fillRule: ShapePath.WindingFill
            pathHints: ShapePath.PathQuadratic | ShapePath.PathNonIntersecting | ShapePath.PathNonOverlappingControlPointTriangles
            PathSvg { path: "M 0 0 L 12 12.9435 L 15.7226 8.9331 L 7.42336 0 L 0 0" }
        }

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            fillRule: ShapePath.WindingFill
            pathHints: ShapePath.PathQuadratic | ShapePath.PathNonIntersecting | ShapePath.PathNonOverlappingControlPointTriangles
            PathSvg { path: "M 12 4.92273 L 15.7226 8.93308 L 12.6788 4.20129 L 12 4.92273" }
        }
    }
}
