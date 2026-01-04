qt_add_qml_module(MerceFoundation
    URI "Merce.Foundation"
    VERSION 1.0
    QML_FILES
        MSurface.qml
        MText.qml
        MBaseControl.qml
)

target_link_libraries(MerceFoundation PRIVATE MerceCore)
