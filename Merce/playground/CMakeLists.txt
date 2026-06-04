qt_add_executable(MercePlayground
    main.cpp
)

set(MERCE_PLAYGROUND_VIEW_QML
    view/Main.qml
    view/ControlsShowcase.qml
    view/FeedbackShowcase.qml
    view/IconsShowcase.qml
    view/PaletteShowcase.qml
    view/ThemeGalleryExport.qml
    view/ThemeGallery.qml
    view/TypographyShowcase.qml
)

set(MERCE_PLAYGROUND_COMPONENT_QML
    component/MerceToastifyStyleProvider.qml
    component/MerceLogo.qml
    component/NavigationBar.qml
    component/NavigationButton.qml
    component/PlaygroundFooter.qml
    component/PlaygroundHeader.qml
    component/PlaygroundPage.qml
)

set(MERCE_PLAYGROUND_PROBE_QML
    probe/FontAwesomeGridProbe.qml
    probe/FontAwesomeIconProbe.qml
    probe/PlaygroundProbe.qml
    probe/ThemeGalleryProbe.qml
    probe/ThemeProbe.qml
    probe/ThemeSwitchProbe.qml
)

set(MERCE_PLAYGROUND_QML_FILES
    ${MERCE_PLAYGROUND_VIEW_QML}
    ${MERCE_PLAYGROUND_COMPONENT_QML}
    ${MERCE_PLAYGROUND_PROBE_QML}
)

foreach(qml_file IN LISTS MERCE_PLAYGROUND_QML_FILES)
    get_filename_component(qml_alias "${qml_file}" NAME)
    set_source_files_properties("${qml_file}" PROPERTIES
        QT_RESOURCE_ALIAS "${qml_alias}"
    )
endforeach()

qt_add_qml_module(MercePlayground
    URI "Merce.Playground"
    VERSION 1.0
    QML_FILES
        ${MERCE_PLAYGROUND_QML_FILES}
)

target_link_libraries(MercePlayground
    PRIVATE
        Qt6::Core
        Qt6::Quick
        Qt6::Qml
        MerceCore
        MerceCoreEffects
        MerceFoundation
        MerceIconsFontAwesome
        MerceControls
        MerceNotifications
        Toastify
        ToastifyStyle
        Toastifyplugin
        ToastifyStyleplugin
)

target_compile_definitions(MercePlayground
    PRIVATE
        QT_QML_DEBUG
)
