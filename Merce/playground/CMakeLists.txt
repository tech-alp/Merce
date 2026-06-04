qt_add_executable(MercePlayground
    main.cpp
)

qt_add_qml_module(MercePlayground
    URI "Merce.Playground"
    VERSION 1.0
    QML_FILES
        Main.qml
        ThemeGallery.qml
        ThemeGalleryProbe.qml
        ThemeProbe.qml
        ThemeSwitchProbe.qml
)

target_link_libraries(MercePlayground
    PRIVATE
        Qt6::Core
        Qt6::Quick
        Qt6::Qml
        MerceCore
        MerceCoreEffects
        MerceFoundation
        MerceControls
        MerceNotifications
)

target_compile_definitions(MercePlayground
    PRIVATE
        QT_QML_DEBUG
)
