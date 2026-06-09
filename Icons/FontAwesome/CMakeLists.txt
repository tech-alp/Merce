set_source_files_properties(
    FontAwesomeRegistry.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(MerceIconsFontAwesome
    URI "Merce.Icons.FontAwesome"
    VERSION 1.0
    QML_FILES
        FontAwesomeIcon.qml
        FontAwesomeRegistry.qml
    RESOURCES
        LICENSE.txt
)

target_link_libraries(MerceIconsFontAwesome PRIVATE MerceTheme)
