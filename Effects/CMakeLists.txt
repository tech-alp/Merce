# Backing target first: qt_add_library honours BUILD_SHARED_LIBS (policy QTP0003),
# while qt_add_qml_module deliberately does not when it creates the target itself.
qt_add_library(MerceEffects)

qt_add_qml_module(MerceEffects
    URI "Merce.Effects"
    VERSION 1.0
    QML_FILES
        MShadow.qml
)

target_link_libraries(MerceEffects PRIVATE MerceTheme Qt6::Quick Qt6::Qml Qt6::QuickEffects)
