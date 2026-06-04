import QtQuick
import Merce.Core

Item {
    id: root

    property string name: ""
    property real size: Theme.icons.medium
    property color color: Theme.colors.text.primary
    property bool filled: false
    property real fill: filled ? 1.0 : 0.0
    property int grade: 0
    property int weight: filled ? 500 : 400
    property real opticalSize: size

    readonly property int roundedSize: Math.round(size)
    readonly property var iconSpec: IconRegistry.resolve(name)

    implicitWidth: roundedSize
    implicitHeight: roundedSize
    width: roundedSize
    height: roundedSize
    Accessible.ignored: true

    MaterialIcon {
        anchors.fill: parent
        visible: root.iconSpec.kind === "material"
        name: root.iconSpec.glyph
        size: root.size
        color: root.color
        filled: root.filled
        fill: root.fill
        grade: root.grade
        weight: root.weight
        opticalSize: root.opticalSize
    }

    Image {
        anchors.fill: parent
        visible: root.iconSpec.kind === "image" && root.iconSpec.source !== ""
        source: root.iconSpec.source
        sourceSize.width: root.roundedSize
        sourceSize.height: root.roundedSize
        fillMode: Image.PreserveAspectFit
    }
}
