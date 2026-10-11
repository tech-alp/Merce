pragma ComponentBehavior: Bound

import QtQuick
import Qt.labs.StyleKit as SK
import Merce.Controls
import Merce.Style.Effects
import Merce.Theme

SK.ApplicationWindow {
    id: root
    width: 520
    height: 320
    visible: true

    property alias effectPolicy: effectsStyle.effectPolicy

    SK.StyleKit.style: MerceEffectsStyle { id: effectsStyle }
    SK.StyleKit.transitionsEnabled: false

    Item {
        objectName: "focusSink"
        activeFocusOnTab: true
        focus: true
    }

    MButton {
        id: effectButton
        objectName: "effectButton"
        x: 40
        y: 40
        width: 180
        text: "Action"
        variant: MButton.Secondary
        size: MButton.Small
        extraVariations: ["sheen"]
        hoverEnabled: true
    }

    MButton {
        objectName: "plainButton"
        x: 280
        y: 40
        width: 180
        text: effectButton.text
        variant: effectButton.variant
        size: effectButton.size
        loading: effectButton.loading
        enabled: effectButton.enabled
    }

    SK.Button {
        objectName: "rawButton"
        x: 40
        y: 120
        width: 180
        text: "StyleKit"
        SK.StyleVariation.variations: ["sheen"]
        hoverEnabled: true
    }

    MButton {
        objectName: "flatButton"
        x: 280
        y: 120
        width: 180
        text: "Flat"
        flat: true
        extraVariations: ["sheen"]
        hoverEnabled: true
    }
}
