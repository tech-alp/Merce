qt_add_qml_module(MerceCoreBase
    URI "Merce.Core.Base"
    VERSION 1.0
    # QML_FILES - placeholder for future base components
)

target_link_libraries(MerceCoreBase PRIVATE Qt6::Quick Qt6::Qml)
