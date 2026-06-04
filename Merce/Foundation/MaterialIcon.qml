import QtQuick

Item {
    id: root

    property string name: ""
    property real size: 24
    property color color: "#111111"
    property bool filled: false
    property real fill: filled ? 1.0 : 0.0
    property int grade: 0
    property int weight: filled ? 500 : 400
    property real opticalSize: size

    readonly property int roundedSize: Math.round(size)

    implicitWidth: roundedSize
    implicitHeight: roundedSize
    width: roundedSize
    height: roundedSize
    Accessible.ignored: true

    Text {
        anchors.fill: parent
        text: root.name
        color: root.color
        font.family: FoundationFonts.materialSymbolsRoundedFamily
        font.pixelSize: root.size
        font.weight: root.weight
        font.variableAxes: {
            "FILL": root.fill,
            "GRAD": root.grade,
            "opsz": root.opticalSize,
            "wght": root.weight
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        antialiasing: true
    }
}
