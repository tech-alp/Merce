qt_add_qml_module(MerceControls
    URI "Merce.Controls"
    VERSION 1.0
    QML_FILES
        MButton.qml
        MInput.qml
)

target_link_libraries(MerceControls PRIVATE MerceFoundation MerceCore)
