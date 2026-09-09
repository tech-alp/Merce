pragma Singleton
import QtQuick

/**
 * Text families come from the active theme, which ships its own font files and
 * refuses to load if a family it names is missing (MerceTheme::registerManifestFonts).
 * By the time QML asks, Theme.typography.fontBody is a family that is registered,
 * so there is nothing left here to alias or substitute — the alias table that used
 * to live in resolveFamily is exactly what kept every brand rendering in Inter
 * while its manifest asked for Lexend.
 *
 * Icons are different: Material Symbols is Merce's own glyph set rather than a
 * brand typeface, so it stays bundled here and is not something a theme picks.
 */
Item {
    id: root

    visible: false
    width: 0
    height: 0

    FontLoader {
        id: materialSymbolsRounded
        source: "fonts/MaterialSymbolsRounded/MaterialSymbolsRounded.ttf"
    }

    readonly property string materialSymbolsRoundedFamily:
        materialSymbolsRounded.name !== "" ? materialSymbolsRounded.name
                                           : "Material Symbols Rounded"
    readonly property string iconFamily: materialSymbolsRoundedFamily

    /**
     * Passes a theme family through untouched. Only the icon names still map,
     * because those name a bundled glyph set rather than a theme choice.
     */
    function resolveFamily(family) {
        const requested = String(family || "").trim()
        if (requested === "Material Symbols Rounded" ||
                requested === "Material Symbols Outlined" ||
                requested === "Material Symbols")
            return materialSymbolsRoundedFamily
        return requested
    }
}
