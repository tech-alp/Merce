qt_add_qml_module(MerceCoreEffects
    URI "Merce.Core.Effects"
    VERSION 1.0
    QML_FILES
        ElevationEffect.qml
)

target_link_libraries(MerceCoreEffects PRIVATE Qt6::Quick Qt6::Qml)
