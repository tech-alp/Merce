pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit
import Merce.Effects
import Merce.Theme

StyledItem {
    id: root

    required property T.Button control
    readonly property MerceEffectsStyle effectsStyle: root.StyleKit.style as MerceEffectsStyle
    readonly property EffectPolicy effectPolicy: root.effectsStyle ? root.effectsStyle.effectPolicy : null

    readonly property bool shaderSupported: root.GraphicsInfo.api === GraphicsInfo.OpenGL
                                           || root.GraphicsInfo.api === GraphicsInfo.Vulkan
                                           || root.GraphicsInfo.api === GraphicsInfo.Metal
                                           || root.GraphicsInfo.api === GraphicsInfo.Direct3D11
                                           || root.GraphicsInfo.api === GraphicsInfo.Direct3D12
    readonly property bool canAnimate: root.shaderSupported
                                       && root.effectPolicy && root.effectPolicy.enabled
                                       && !root.effectPolicy.reducedMotion
                                       && root.control.enabled && !root.control.down
                                       && root.control.visible && root.visible
                                       && root.width > 0 && root.height > 0
                                       && root.Window.window && root.Window.window.visible
                                       && root.Window.window.visibility !== Window.Minimized
    readonly property bool sweepRunning: sweep.running
    readonly property bool shaderLoaded: sheenLoader.item !== null
    property real sweepProgress: 0

    objectName: "merce.sheen.background"
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    Accessible.ignored: true

    // Keep the base StyledItem's plate, border, implicit sizes and transforms.
    // Its delegateStyle.opacity affects the plate, not added visual children.
    Connections {
        target: root.control
        function onHoveredChanged() {
            if (root.control.hovered && root.canAnimate)
                sweep.restart()
            else
                sweep.stop()
        }
    }

    // Flat backgrounds are first created by StyleKit after hover has entered.
    Component.onCompleted: {
        if (root.control.hovered && root.canAnimate)
            sweep.start()
    }

    // Re-enabling a policy or releasing a press does not replay a hover.
    onCanAnimateChanged: {
        if (!root.canAnimate)
            sweep.stop()
    }

    NumberAnimation {
        id: sweep
        target: root
        property: "sweepProgress"
        from: 0
        to: 1
        duration: Theme.motion.durationSlower
        easing.type: Theme.motion.easingDefault
        onStopped: root.sweepProgress = 0
    }

    Loader {
        id: sheenLoader
        readonly property real inset: Math.max(0, root.delegateStyle.border.width)
        anchors.fill: parent
        anchors.margins: inset
        active: sweep.running

        sourceComponent: MSheen {
            progress: root.sweepProgress
            opacity: root.delegateStyle.opacity
            topLeftRadius: Math.max(0, root.delegateStyle.topLeftRadius - sheenLoader.inset)
            topRightRadius: Math.max(0, root.delegateStyle.topRightRadius - sheenLoader.inset)
            bottomRightRadius: Math.max(0, root.delegateStyle.bottomRightRadius - sheenLoader.inset)
            bottomLeftRadius: Math.max(0, root.delegateStyle.bottomLeftRadius - sheenLoader.inset)
        }
    }
}
