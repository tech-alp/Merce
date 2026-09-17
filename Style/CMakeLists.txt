# Backing target first: qt_add_library honours BUILD_SHARED_LIBS (policy QTP0003),
# while qt_add_qml_module deliberately does not when it creates the target itself.
qt_add_library(MerceStyle)

qt_add_qml_module(MerceStyle
    URI "Merce.Style"
    VERSION 1.0
    QML_FILES
        MerceStyle.qml
)

target_link_libraries(MerceStyle PRIVATE MerceFoundation MerceTheme Qt6::LabsStyleKit)
