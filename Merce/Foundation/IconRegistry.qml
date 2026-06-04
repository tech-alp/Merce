pragma Singleton
import QtQuick

QtObject {
    id: root

    readonly property var statusGlyphs: ({
        "check": "\u2713",
        "close": "\u2717",
        "warning": "\u26A0",
        "heart": "\u2665",
        "star": "\u2605",
        "sun": "\u2600",
        "circle": "\u25CF",
        "diamond": "\u25C6",
        "arrowLeft": "\u2190",
        "arrowUp": "\u2191",
        "arrowRight": "\u2192",
        "arrowDown": "\u2193"
    })

    readonly property var materialAliases: ({
        "success": "check_circle",
        "warning": "warning",
        "error": "error",
        "info": "info",
        "wallet": "account_balance_wallet",
        "theme": "palette",
        "mode": "dark_mode",
        "search": "search",
        "mail": "mail",
        "lock": "lock",
        "visibility": "visibility",
        "visibilityOff": "visibility_off"
    })

    function glyphFromCodepoint(value) {
        let text = String(value || "").trim()
        if (text.indexOf("uni") === 0)
            text = text.substring(3)
        else if (text.indexOf("u+") === 0 || text.indexOf("U+") === 0)
            text = text.substring(2)
        else if (text.indexOf("0x") === 0 || text.indexOf("0X") === 0)
            text = text.substring(2)

        if (!/^[0-9a-fA-F]{2,6}$/.test(text))
            return ""

        const codepoint = parseInt(text, 16)
        if (!isFinite(codepoint) || codepoint <= 0)
            return ""

        return codepoint <= 0xffff
               ? String.fromCharCode(codepoint)
               : String.fromCodePoint(codepoint)
    }

    function resolve(name) {
        const value = String(name || "").trim()
        if (value.length === 0)
            return { "kind": "none", "glyph": "", "source": "", "family": "" }

        if (value.indexOf("image:") === 0)
            return { "kind": "image", "glyph": "", "source": value.substring(6), "family": "" }

        if (value.indexOf("material:") === 0) {
            const materialName = value.substring(9)
            return {
                "kind": "material",
                "glyph": materialAliases[materialName] || materialName,
                "source": "",
                "family": "material"
            }
        }

        if (value.indexOf("status:") === 0) {
            const statusName = value.substring(7)
            const materialFallback = materialAliases[statusName] || statusName
            return {
                "kind": "material",
                "glyph": materialFallback,
                "source": "",
                "family": "material"
            }
        }

        if (value.indexOf(":") >= 0)
            return { "kind": "none", "glyph": "", "source": "", "family": "" }

        return { "kind": "material", "glyph": value, "source": "", "family": "material" }
    }
}
