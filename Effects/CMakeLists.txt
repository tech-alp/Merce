qt_add_qml_module(MerceEffects
    ${MERCE_QML_MODULE_TYPE}
    URI "Merce.Effects"
    VERSION 1.0
    QML_FILES
        MShadow.qml
)

target_link_libraries(MerceEffects PRIVATE MerceTheme Qt6::Quick Qt6::Qml Qt6::QuickEffects)
