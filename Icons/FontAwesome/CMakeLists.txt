set_source_files_properties(
    FontAwesomeRegistry.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

# Backing target first: qt_add_library honours BUILD_SHARED_LIBS (policy QTP0003),
# while qt_add_qml_module deliberately does not when it creates the target itself.
qt_add_library(MerceIconsFontAwesome)

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
