qt_add_qml_module(MerceEffects
    URI "Merce.Effects"
    VERSION 1.0
    QML_FILES
        ElevationEffect.qml
)

target_link_libraries(MerceEffects PRIVATE MerceTheme Qt6::Quick Qt6::Qml)
