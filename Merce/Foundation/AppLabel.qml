import QtQuick
import QtQuick.Templates as T
import Merce.Theme

/**
 * AppLabel - Theme-aware text label
 * Applies Merce typography presets to a Qt Quick Controls text template.
 */
T.Label {
    id: root

    enum Type {
        Display,
        H1,
        H2,
        H3,
        H4,
        Body,
        BodyLarge,
        BodySmall,
        Caption,
        Overline,
        Button,
        Price
    }

    required property int textType
    property bool selectable: false

    property int minTouchArea: Theme.spacing.touchTarget

    font.family: FoundationFonts.resolveFamily(typographyStyle.family || Theme.typography.fontBody)
    font.pixelSize: typographyStyle.size || Theme.typography.sizeMedium
    font.weight: typographyStyle.weight || Theme.typography.weightRegular
    font.capitalization: typographyStyle.uppercase ? Font.AllUppercase : Font.MixedCase
    lineHeightMode: Text.FixedHeight
    lineHeight: (typographyStyle.leading || Theme.typography.leadingNormal) * root.font.pixelSize
    color: Theme.colors.text.primary
    styleColor: "transparent"
    wrapMode: Text.NoWrap
    maximumLineCount: 0
    elide: root.maximumLineCount > 0 ? Text.ElideRight : Text.ElideNone
    textFormat: Text.RichText
    linkColor: Theme.colors.text.link

    onLinkActivated: (link) => {
        Qt.openUrlExternally(link)
    }

    QtObject {
        id: typographyStyle

        property string family: Theme.typography.body.family
        property real size: Theme.typography.body.size
        property int weight: Theme.typography.body.weight
        property real leading: Theme.typography.body.leading
        property bool uppercase: Theme.typography.body.uppercase === true
    }

    StateGroup {
        states: [
            State {
                when: root.textType === AppLabel.Display
                PropertyChanges {
                    typographyStyle.family: Theme.typography.display.family
                    typographyStyle.size: Theme.typography.display.size
                    typographyStyle.weight: Theme.typography.display.weight
                    typographyStyle.leading: Theme.typography.display.leading
                    typographyStyle.uppercase: Theme.typography.display.uppercase === true
                }
            },
            State {
                when: root.textType === AppLabel.H1
                PropertyChanges {
                    typographyStyle.family: Theme.typography.h1.family
                    typographyStyle.size: Theme.typography.h1.size
                    typographyStyle.weight: Theme.typography.h1.weight
                    typographyStyle.leading: Theme.typography.h1.leading
                    typographyStyle.uppercase: Theme.typography.h1.uppercase === true
                }
            },
            State {
                when: root.textType === AppLabel.H2
                PropertyChanges {
                    typographyStyle.family: Theme.typography.h2.family
                    typographyStyle.size: Theme.typography.h2.size
                    typographyStyle.weight: Theme.typography.h2.weight
                    typographyStyle.leading: Theme.typography.h2.leading
                    typographyStyle.uppercase: Theme.typography.h2.uppercase === true
                }
            },
            State {
                when: root.textType === AppLabel.H3
                PropertyChanges {
                    typographyStyle.family: Theme.typography.h3.family
                    typographyStyle.size: Theme.typography.h3.size
                    typographyStyle.weight: Theme.typography.h3.weight
                    typographyStyle.leading: Theme.typography.h3.leading
                    typographyStyle.uppercase: Theme.typography.h3.uppercase === true
                }
            },
            State {
                when: root.textType === AppLabel.H4
                PropertyChanges {
                    typographyStyle.family: Theme.typography.h4.family
                    typographyStyle.size: Theme.typography.h4.size
                    typographyStyle.weight: Theme.typography.h4.weight
                    typographyStyle.leading: Theme.typography.h4.leading
                    typographyStyle.uppercase: Theme.typography.h4.uppercase === true
                }
            },
            State {
                when: root.textType === AppLabel.BodyLarge
                PropertyChanges {
                    typographyStyle.family: Theme.typography.bodyLarge.family
                    typographyStyle.size: Theme.typography.bodyLarge.size
                    typographyStyle.weight: Theme.typography.bodyLarge.weight
                    typographyStyle.leading: Theme.typography.bodyLarge.leading
                    typographyStyle.uppercase: Theme.typography.bodyLarge.uppercase === true
                }
            },
            State {
                when: root.textType === AppLabel.BodySmall
                PropertyChanges {
                    typographyStyle.family: Theme.typography.bodySmall.family
                    typographyStyle.size: Theme.typography.bodySmall.size
                    typographyStyle.weight: Theme.typography.bodySmall.weight
                    typographyStyle.leading: Theme.typography.bodySmall.leading
                    typographyStyle.uppercase: Theme.typography.bodySmall.uppercase === true
                }
            },
            State {
                when: root.textType === AppLabel.Caption
                PropertyChanges {
                    typographyStyle.family: Theme.typography.caption.family
                    typographyStyle.size: Theme.typography.caption.size
                    typographyStyle.weight: Theme.typography.caption.weight
                    typographyStyle.leading: Theme.typography.caption.leading
                    typographyStyle.uppercase: Theme.typography.caption.uppercase === true
                }
            },
            State {
                when: root.textType === AppLabel.Overline
                PropertyChanges {
                    typographyStyle.family: Theme.typography.overline.family
                    typographyStyle.size: Theme.typography.overline.size
                    typographyStyle.weight: Theme.typography.overline.weight
                    typographyStyle.leading: Theme.typography.overline.leading
                    typographyStyle.uppercase: Theme.typography.overline.uppercase === true
                }
            },
            State {
                when: root.textType === AppLabel.Button
                PropertyChanges {
                    typographyStyle.family: Theme.typography.button.family
                    typographyStyle.size: Theme.typography.button.size
                    typographyStyle.weight: Theme.typography.button.weight
                    typographyStyle.leading: Theme.typography.button.leading
                    typographyStyle.uppercase: Theme.typography.button.uppercase === true
                }
            },
            State {
                when: root.textType === AppLabel.Price
                PropertyChanges {
                    typographyStyle.family: Theme.typography.price.family
                    typographyStyle.size: Theme.typography.price.size
                    typographyStyle.weight: Theme.typography.price.weight
                    typographyStyle.leading: Theme.typography.price.leading
                    typographyStyle.uppercase: Theme.typography.price.uppercase === true
                }
            }
        ]
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: root.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.NoButton
        enabled: root.selectable
    }
}
