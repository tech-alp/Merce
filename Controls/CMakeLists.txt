# Backing target first: qt_add_library honours BUILD_SHARED_LIBS (policy QTP0003),
# while qt_add_qml_module deliberately does not when it creates the target itself.
qt_add_library(MerceControls)

qt_add_qml_module(MerceControls
    URI "Merce.Controls"
    VERSION 1.0
    QML_FILES
        MButton.qml
        MBadge.qml
        LoadingIndicator.qml
)

target_link_libraries(MerceControls PRIVATE MerceFoundation MerceTheme Qt6::LabsStyleKit)
