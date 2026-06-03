qt_add_qml_module(MerceCoreUtils
    URI "Merce.Core.Utils"
    VERSION 1.0
    # QML_FILES - placeholder for future utility components
)

target_link_libraries(MerceCoreUtils PRIVATE Qt6::Quick Qt6::Qml)
