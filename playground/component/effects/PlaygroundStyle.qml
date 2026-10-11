pragma ComponentBehavior: Bound

import QtQuick
import Merce.Style.Effects

MerceEffectsStyle {
    id: style

    readonly property Component effectsPage: PlaygroundPage {
        objectName: "merce.playground.stack.effects"
        sourceComponent: EffectsShowcase {
            objectName: "merce.playground.effectsShowcase"
            effectPolicy: style.effectPolicy
        }
    }
}
