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
        AppLabel.qml
    RESOURCES
        fonts/MaterialSymbolsRounded/MaterialSymbolsRounded.ttf
        fonts/MaterialSymbolsRounded/MaterialSymbolsRounded.codepoints
        fonts/MaterialSymbolsRounded/LICENSE
        fonts/MaterialSymbolsRounded/README.md
)

target_link_libraries(MerceFoundation PRIVATE MerceTheme)
