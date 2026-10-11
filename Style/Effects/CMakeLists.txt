qt_add_library(MerceStyleEffects)

qt_add_qml_module(MerceStyleEffects
    URI "Merce.Style.Effects"
    VERSION 1.0
    QML_FILES
        EffectPolicy.qml
        MerceEffectsStyle.qml
        SheenBackground.qml
)

target_link_libraries(MerceStyleEffects PRIVATE
    MerceStyle MerceEffects MerceTheme
    Qt6::Quick Qt6::Qml Qt6::LabsStyleKit Qt6::QuickTemplates2
)
