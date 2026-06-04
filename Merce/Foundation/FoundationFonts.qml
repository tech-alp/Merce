pragma Singleton
import QtQuick

Item {
    id: root

    visible: false
    width: 0
    height: 0

    FontLoader { id: interBlack; source: "fonts/Inter/Inter-Black.otf" }
    FontLoader { id: interBold; source: "fonts/Inter/Inter-Bold.otf" }
    FontLoader { id: interExtraBold; source: "fonts/Inter/Inter-ExtraBold.otf" }
    FontLoader { id: interExtraLight; source: "fonts/Inter/Inter-ExtraLight.otf" }
    FontLoader { id: interLight; source: "fonts/Inter/Inter-Light.otf" }
    FontLoader { id: interMedium; source: "fonts/Inter/Inter-Medium.otf" }
    FontLoader { id: interRegular; source: "fonts/Inter/Inter-Regular.otf" }
    FontLoader { id: interThin; source: "fonts/Inter/Inter-Thin.otf" }

    FontLoader {
        id: materialSymbolsRounded
        source: "fonts/MaterialSymbolsRounded/MaterialSymbolsRounded.ttf"
    }

    FontLoader { id: robotoMonoBold; source: "fonts/RobotoMono/RobotoMono-Bold.ttf" }
    FontLoader { id: robotoMonoExtraLight; source: "fonts/RobotoMono/RobotoMono-ExtraLight.ttf" }
    FontLoader { id: robotoMonoLight; source: "fonts/RobotoMono/RobotoMono-Light.ttf" }
    FontLoader { id: robotoMonoMedium; source: "fonts/RobotoMono/RobotoMono-Medium.ttf" }
    FontLoader { id: robotoMonoRegular; source: "fonts/RobotoMono/RobotoMono-Regular.ttf" }
    FontLoader { id: robotoMonoThin; source: "fonts/RobotoMono/RobotoMono-Thin.ttf" }

    readonly property string interFamily: interRegular.name !== "" ? interRegular.name : "Inter"
    readonly property string monoFamily: robotoMonoRegular.name !== "" ? robotoMonoRegular.name : "Roboto Mono"
    readonly property string materialSymbolsRoundedFamily: materialSymbolsRounded.name !== "" ? materialSymbolsRounded.name : "Material Symbols Rounded"

    readonly property string bodyFamily: interFamily
    readonly property string displayFamily: interFamily
    readonly property string iconFamily: materialSymbolsRoundedFamily

    function resolveFamily(family) {
        const requested = String(family || "").trim()
        if (requested === "" || requested === "Inter" || requested === "DM Sans")
            return bodyFamily
        if (requested === "Playfair Display")
            return displayFamily
        if (requested === "SF Mono" || requested === "Roboto Mono" ||
                requested === "RobotoMono")
            return monoFamily
        if (requested === "Material Symbols Rounded" ||
                requested === "Material Symbols Outlined" ||
                requested === "Material Symbols")
            return materialSymbolsRoundedFamily
        return requested
    }
}
