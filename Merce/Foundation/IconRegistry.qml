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

    readonly property var fontAwesomeSolidAliases: ({
        "add": "2b",
        "apps": "f00a",
        "arrowdown": "f063",
        "arrowleft": "f060",
        "arrowright": "f061",
        "arrowup": "f062",
        "arrowDown": "f063",
        "arrowLeft": "f060",
        "arrowRight": "f061",
        "arrowUp": "f062",
        "calendar": "f133",
        "check": "f00c",
        "close": "f00d",
        "download": "f019",
        "error": "f071",
        "heart": "f004",
        "home": "f015",
        "info": "f129",
        "lock": "f023",
        "magnifyingglass": "f002",
        "mail": "f0e0",
        "mode": "f186",
        "palette": "f53f",
        "save": "f0c7",
        "search": "f002",
        "settings": "f013",
        "star": "f005",
        "success": "f058",
        "theme": "f53f",
        "upload": "f093",
        "visibility": "f06e",
        "visibilityoff": "f070",
        "visibilityOff": "f070",
        "wallet": "f555",
        "warning": "f071"
    })

    readonly property var fontAwesomeRegularAliases: ({
        "calendar": "f133",
        "checkcircle": "f058",
        "checkCircle": "f058",
        "circle": "f111",
        "heart": "f004",
        "save": "f0c7",
        "star": "f005",
        "success": "f058"
    })

    readonly property var fontAwesomeBrandsAliases: ({
        "apple": "f179",
        "docker": "f395",
        "github": "f09b",
        "gitlab": "f296",
        "linux": "f17c",
        "npm": "f3d4",
        "react": "f41b",
        "windows": "f17a"
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

    function resolveFontAwesome(iconStyle, iconName) {
        const style = String(iconStyle || "solid").trim()
        const name = String(iconName || "").trim()
        const aliases = style === "brands"
                        ? fontAwesomeBrandsAliases
                        : (style === "regular"
                           ? fontAwesomeRegularAliases
                           : fontAwesomeSolidAliases)
        const compactName = name.replace(/[-_ ]/g, "").toLowerCase()
        const codepoint = aliases[name] || aliases[compactName] || name
        const glyph = glyphFromCodepoint(codepoint)
        if (glyph === "")
            return { "kind": "none", "glyph": "", "source": "", "family": "" }

        return {
            "kind": "fontawesome",
            "glyph": glyph,
            "source": "",
            "family": style
        }
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
            const statusGlyph = statusGlyphs[statusName] || glyphFromCodepoint(statusName)
            if (statusGlyph !== "") {
                return {
                    "kind": "status",
                    "glyph": statusGlyph,
                    "source": "",
                    "family": "status"
                }
            }

            const materialFallback = materialAliases[statusName] || statusName
            return {
                "kind": "material",
                "glyph": materialFallback,
                "source": "",
                "family": "material"
            }
        }

        if (value.indexOf("fa:") === 0)
            return resolveFontAwesome("solid", value.substring(3))

        if (value.indexOf("fa-solid:") === 0)
            return resolveFontAwesome("solid", value.substring(9))

        if (value.indexOf("fa-regular:") === 0)
            return resolveFontAwesome("regular", value.substring(11))

        if (value.indexOf("fa-brands:") === 0)
            return resolveFontAwesome("brands", value.substring(10))

        if (value.indexOf(":") >= 0)
            return { "kind": "none", "glyph": "", "source": "", "family": "" }

        return { "kind": "material", "glyph": value, "source": "", "family": "material" }
    }
}
