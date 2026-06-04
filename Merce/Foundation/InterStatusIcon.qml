import QtQuick

Item {
    id: root

    property string glyph: ""
    property real size: 24
    property color color: "#111111"
    property int weight: 400

    readonly property int roundedSize: Math.round(size)

    implicitWidth: roundedSize
    implicitHeight: roundedSize
    width: roundedSize
    height: roundedSize
    Accessible.ignored: true

    Text {
        anchors.fill: parent
        text: root.glyph
        color: root.color
        font.family: FoundationFonts.statusFamily
        font.pixelSize: root.size
        font.weight: root.weight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        antialiasing: true
    }
}
