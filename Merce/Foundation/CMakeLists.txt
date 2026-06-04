set_source_files_properties(
    FoundationFonts.qml
    IconRegistry.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(MerceFoundation
    URI "Merce.Foundation"
    VERSION 1.0
    QML_FILES
        AppIcon.qml
        FoundationFonts.qml
        FontAwesomeIcon.qml
        IconRegistry.qml
        InterStatusIcon.qml
        MaterialIcon.qml
        MSurface.qml
        MText.qml
        MBaseControl.qml
    RESOURCES
        fonts/Inter/Inter-Black.otf
        fonts/Inter/Inter-Bold.otf
        fonts/Inter/Inter-ExtraBold.otf
        fonts/Inter/Inter-ExtraLight.otf
        fonts/Inter/Inter-Light.otf
        fonts/Inter/Inter-Medium.otf
        fonts/Inter/Inter-Regular.otf
        fonts/Inter/Inter-Thin.otf
        fonts/InterStatus/InterStatus-Black.otf
        fonts/InterStatus/InterStatus-Bold.otf
        fonts/InterStatus/InterStatus-ExtraBold.otf
        fonts/InterStatus/InterStatus-ExtraBoldItalic.otf
        fonts/InterStatus/InterStatus-ExtraLight.otf
        fonts/InterStatus/InterStatus-Light.otf
        fonts/InterStatus/InterStatus-Medium.otf
        fonts/InterStatus/InterStatus-Regular.otf
        fonts/InterStatus/InterStatus-Thin.otf
        fonts/InterStatus/InterStatus.codepoints
        fonts/FontAwesome/FontAwesomeBrands-Regular-400.otf
        fonts/FontAwesome/FontAwesomeBrands.codepoints
        fonts/FontAwesome/FontAwesomeFree-Regular-400.otf
        fonts/FontAwesome/FontAwesomeFree-Solid-900.otf
        fonts/FontAwesome/FontAwesomeRegular.codepoints
        fonts/FontAwesome/FontAwesomeSolid.codepoints
        fonts/FontAwesome/LICENSE.txt
        fonts/MaterialSymbolsRounded/MaterialSymbolsRounded.ttf
        fonts/MaterialSymbolsRounded/MaterialSymbolsRounded.codepoints
        fonts/MaterialSymbolsRounded/LICENSE
        fonts/MaterialSymbolsRounded/README.md
        fonts/RobotoMono/RobotoMono-Bold.ttf
        fonts/RobotoMono/RobotoMono-ExtraLight.ttf
        fonts/RobotoMono/RobotoMono-Light.ttf
        fonts/RobotoMono/RobotoMono-Medium.ttf
        fonts/RobotoMono/RobotoMono-Regular.ttf
        fonts/RobotoMono/RobotoMono-Thin.ttf
)

target_link_libraries(MerceFoundation PRIVATE MerceCore)
