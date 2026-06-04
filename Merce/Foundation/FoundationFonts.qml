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

    FontLoader { id: interStatusBlack; source: "fonts/InterStatus/InterStatus-Black.otf" }
    FontLoader { id: interStatusBold; source: "fonts/InterStatus/InterStatus-Bold.otf" }
    FontLoader { id: interStatusExtraBold; source: "fonts/InterStatus/InterStatus-ExtraBold.otf" }
    FontLoader { id: interStatusExtraBoldItalic; source: "fonts/InterStatus/InterStatus-ExtraBoldItalic.otf" }
    FontLoader { id: interStatusExtraLight; source: "fonts/InterStatus/InterStatus-ExtraLight.otf" }
    FontLoader { id: interStatusLight; source: "fonts/InterStatus/InterStatus-Light.otf" }
    FontLoader { id: interStatusMedium; source: "fonts/InterStatus/InterStatus-Medium.otf" }
    FontLoader { id: interStatusRegular; source: "fonts/InterStatus/InterStatus-Regular.otf" }
    FontLoader { id: interStatusThin; source: "fonts/InterStatus/InterStatus-Thin.otf" }

    FontLoader { id: fontAwesomeSolid; source: "fonts/FontAwesome/FontAwesomeFree-Solid-900.otf" }
    FontLoader { id: fontAwesomeRegular; source: "fonts/FontAwesome/FontAwesomeFree-Regular-400.otf" }
    FontLoader { id: fontAwesomeBrands; source: "fonts/FontAwesome/FontAwesomeBrands-Regular-400.otf" }

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
    readonly property string interStatusFamily: interStatusRegular.name !== "" ? interStatusRegular.name : "InterStatus"
    readonly property string fontAwesomeSolidFamily: fontAwesomeSolid.name !== "" ? fontAwesomeSolid.name : "Font Awesome 7 Free"
    readonly property string fontAwesomeRegularFamily: fontAwesomeRegular.name !== "" ? fontAwesomeRegular.name : "Font Awesome 7 Free"
    readonly property string fontAwesomeBrandsFamily: fontAwesomeBrands.name !== "" ? fontAwesomeBrands.name : "Font Awesome 7 Brands"
    readonly property string monoFamily: robotoMonoRegular.name !== "" ? robotoMonoRegular.name : "Roboto Mono"
    readonly property string materialSymbolsRoundedFamily: materialSymbolsRounded.name !== "" ? materialSymbolsRounded.name : "Material Symbols Rounded"

    readonly property string bodyFamily: interFamily
    readonly property string displayFamily: interFamily
    readonly property string statusFamily: interStatusFamily
    readonly property string iconFamily: materialSymbolsRoundedFamily

    function resolveFamily(family) {
        const requested = String(family || "").trim()
        if (requested === "" || requested === "Inter" || requested === "DM Sans")
            return bodyFamily
        if (requested === "InterStatus" || requested === "Inter Status")
            return statusFamily
        if (requested === "Font Awesome 7 Free Solid" ||
                requested === "Font Awesome Free Solid")
            return fontAwesomeSolidFamily
        if (requested === "Font Awesome 7 Free Regular" ||
                requested === "Font Awesome Free Regular")
            return fontAwesomeRegularFamily
        if (requested === "Font Awesome 7 Brands" ||
                requested === "Font Awesome Brands")
            return fontAwesomeBrandsFamily
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
