import QtQuick
import Merce.Theme
import Merce.Foundation
import Toastify.Style

/**
 * MToastStyle - binds Toastify to the Merce semantic token vocabulary.
 *
 * Moved out of the playground so applications can consume it. Toast styling is
 * design-system policy: which status role a toast kind maps to, how long it
 * dwells, how it enters and leaves. What a toast says is application policy.
 *
 * Values inlined here rather than tokenised are component tier: they have one
 * consumer today. Promote them to a profile token on the second consumer that
 * needs a different value, not before.
 */
ToastifyStyleProvider {
    colors: ({
        info: Theme.colors.status.info.content,
        success: Theme.colors.status.success.content,
        warning: Theme.colors.status.warning.content,
        error: Theme.colors.status.error.content
    })

    backgroundColor: Theme.colors.surface.floating

    fonts: ({
        family: FoundationFonts.resolveFamily(Theme.typography.fontBody),
        size: Theme.typography.sizeSmall,
        weight: Font.Normal
    })

    spacing: ({
        main: Theme.spacing.md,
        content: Theme.spacing.sm,
        text: Theme.spacing.xxs,
        container: Theme.spacing.md,
        closeButton: {
            padding: Theme.spacing.xs,
            size: Theme.icons.xSmall,
            width: Theme.icons.xSmall,
            height: Theme.icons.xSmall
        },
        totalHorizontal: function() {
            return Theme.spacing.md + Theme.spacing.md * 2
        },
        closeButtonTotal: function() {
            return Theme.icons.xSmall
        }
    })

    // Component tier: a toast is read at a glance, so its width is bounded by
    // line length rather than by the surface it sits on.
    containerSizes: ({
        minimum: 280,
        preferred: 400,
        maximum: 520,
        minimumHeight: 64
    })

    cornerRadius: Theme.radius.large
    iconSize: Theme.icons.medium
    toastOffset: Theme.spacing.md
    toastSpacing: Theme.spacing.md
    collapsedToastOffset: Theme.spacing.md
    collapsedToastScaleStep: 0.05
    stackTransitionDuration: Theme.motion.enter.duration

    // Colour is themed; the geometry is component tier because Theme.shadows.*
    // is not manifest-driven yet and still carries its C++ defaults.
    shadow: ({
        blurRadius: 16,
        spread: 0,
        color: Theme.colors.surface.shadow,
        opacity: 0.16,
        horizontalOffset: 0,
        verticalOffset: 3
    })

    animation: ({
        enterDuration: Theme.motion.enter.duration,
        exitDuration: Theme.motion.exit.duration
    })

    textColors: ({
        color: Theme.colors.content.primary
    })

    closeButtonStyle: ({
        color: Theme.colors.content.primary,
        opacity: 0.3,
        hoveredOpacity: 1.0
    })

    progressBar: ({
        height: 4,
        radius: Theme.radius.large,
        opacity: 0.7,
        backgroundOpacity: 0.2
    })
}
