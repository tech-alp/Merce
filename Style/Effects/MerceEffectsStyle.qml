// Qt 6.11 StyleKit instantiates delegates in the control's context.
// A bound factory is rejected there; the delegate resolves the active policy.
pragma ComponentBehavior: Unbound

import QtQuick
import Qt.labs.StyleKit
import Merce.Style

MerceStyle {
    id: style

    property EffectPolicy effectPolicy: EffectPolicy {}

    readonly property Component sheenDelegate: SheenBackground {}

    StyleVariation {
        name: "sheen"
        button.background.delegate: style.sheenDelegate
        flatButton.background.delegate: style.sheenDelegate
    }
}
