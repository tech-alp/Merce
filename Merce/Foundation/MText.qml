import QtQuick
import Merce.Core

/**
 * MText - Typography component
 * Provides consistent text styling with preset types
 */
Text {
    id: root

    // Text type presets
    readonly property var types: {
        "display": Theme.typography.display,
        "h1": Theme.typography.h1,
        "h2": Theme.typography.h2,
        "h3": Theme.typography.h3,
        "h4": Theme.typography.h4,
        "body": Theme.typography.body,
        "bodyLarge": Theme.typography.bodyLarge,
        "bodySmall": Theme.typography.bodySmall,
        "caption": Theme.typography.caption,
        "overline": Theme.typography.overline,
        "button": Theme.typography.button,
        "price": Theme.typography.price
    }

    // Required properties
    required property string type

    // Customizable properties
    virtual property color textColor: Theme.colors.text.primary
    virtual property color textBackgroundColor: "transparent"
    virtual property real textLineHeight: (types[type]?.leading || Theme.typography.leadingNormal) * font.pixelSize

    // Final properties
    final property int minTouchArea: Theme.spacing.touchTarget

    // Apply typography preset based on type
    font.family: FoundationFonts.resolveFamily(types[type]?.family || Theme.typography.fontBody)
    font.pixelSize: types[type]?.size || Theme.typography.sizeMedium
    font.weight: types[type]?.weight || Theme.typography.weightRegular
    font.capitalization: types[type]?.uppercase ? Font.AllUppercase : Font.MixedCase
    lineHeightMode: Text.FixedHeight
    lineHeight: textLineHeight

    // Apply colors
    color: textColor
    styleColor: textBackgroundColor

    // Text alignment
    property string align: "left"
    horizontalAlignment: align === "center" ? Text.AlignHCenter :
                         align === "right" ? Text.AlignRight :
                         Text.AlignLeft

    // Wrap mode
    property string wrap: "wrap"
    wrapMode: wrap === "nowrap" ? Text.NoWrap :
              wrap === "word" ? Text.WordWrap :
              Text.Wrap

    // Truncation
    property int maxLines: 0
    maximumLineCount: maxLines
    elide: maxLines > 0 ? Text.ElideRight : Text.ElideNone

    // Selectable
    property bool selectable: false
    textFormat: Text.RichText  // Support rich text for links

    // Link styling
    linkColor: Theme.colors.text.link

    onLinkActivated: (link) => {
        Qt.openUrlExternally(link)
    }

    // Mouse area for links
    MouseArea {
        anchors.fill: parent
        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.NoButton
        enabled: parent.selectable
    }
}
