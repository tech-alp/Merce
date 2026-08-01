import QtQuick
import Merce.Theme
import Merce.Foundation
import Toastify.Style

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

    containerSizes: ({
        minimum: 280,
        preferred: 400,
        maximum: 520
    })

    cornerRadius: Theme.radius.large
    iconSize: Theme.icons.medium

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
        radius: 2
    })
}
