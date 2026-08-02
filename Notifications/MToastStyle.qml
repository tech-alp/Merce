import QtQuick
import Merce.Theme
import Merce.Foundation
import Toastify.Style

/**
 * MToastStyle - binds Toastify to the AlGit token vocabulary.
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
            size: Theme.icons.small
        },
        totalHorizontal: function() {
            return Theme.spacing.md + Theme.spacing.md * 2
        },
        closeButtonTotal: function() {
            return Theme.icons.small
        }
    })

    // Component tier: a toast is read at a glance, so its width is bounded by
    // line length rather than by the surface it sits on.
    containerSizes: ({
        minimum: 280,
        preferred: 400,
        maximum: 520
    })

    cornerRadius: Theme.radius.large
    iconSize: Theme.icons.medium

    // Colour is themed; the geometry is component tier because Theme.shadows.*
    // is not manifest-driven yet and still carries its C++ defaults.
    shadow: ({
        blur: 0.5,
        color: Theme.colors.surface.shadow,
        opacity: 0.16,
        horizontalOffset: 0,
        verticalOffset: 3
    })

    animation: ({
        enterDuration: Theme.motion.durationNormal,
        exitDuration: Theme.motion.durationNormal
    })

    textColors: ({
        color: Theme.colors.content.inverse
    })

    progressBar: ({
        height: 4,
        radius: Theme.radius.full
    })
}
