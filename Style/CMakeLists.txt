qt_add_qml_module(MerceStyle
    URI "Merce.Style"
    VERSION 1.0
    QML_FILES
        MerceStyle.qml
)

target_link_libraries(MerceStyle PRIVATE MerceFoundation MerceTheme Qt6::LabsStyleKit)
