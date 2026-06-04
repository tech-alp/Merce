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
        IconRegistry.qml
        MaterialIcon.qml
        Surface.qml
        ThemedText.qml
    RESOURCES
        fonts/Inter/Inter-Black.otf
        fonts/Inter/Inter-Bold.otf
        fonts/Inter/Inter-ExtraBold.otf
        fonts/Inter/Inter-ExtraLight.otf
        fonts/Inter/Inter-Light.otf
        fonts/Inter/Inter-Medium.otf
        fonts/Inter/Inter-Regular.otf
        fonts/Inter/Inter-Thin.otf
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
