import QtQuick
import Merce.Core

Item {
    id: root

    property string glyph: ""
    property string iconStyle: "solid"
    property real size: Theme.icons.medium
    property color color: Theme.colors.text.primary

    readonly property int roundedSize: Math.round(size)
    readonly property int iconWeight: iconStyle === "solid" ? 900 : 400
    readonly property string iconFamily: iconStyle === "brands"
                                         ? FoundationFonts.fontAwesomeBrandsFamily
                                         : (iconStyle === "regular"
                                            ? FoundationFonts.fontAwesomeRegularFamily
                                            : FoundationFonts.fontAwesomeSolidFamily)

    implicitWidth: roundedSize
    implicitHeight: roundedSize
    width: roundedSize
    height: roundedSize

    Text {
        anchors.centerIn: parent
        text: root.glyph
        color: root.color
        font.family: root.iconFamily
        font.pixelSize: root.size
        font.weight: root.iconWeight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        renderType: Text.QtRendering
    }
}
