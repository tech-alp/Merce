qt_add_executable(MercePlayground
    main.cpp
    PlaygroundThemeBuilder.cpp
    PlaygroundThemeBuilder.h
)

set(MERCE_PLAYGROUND_VIEW_QML
    view/Main.qml
    view/ControlsShowcase.qml
    view/FeedbackShowcase.qml
    view/FormsShowcase.qml
    view/IconsShowcase.qml
    view/MotionShowcase.qml
    view/PaletteShowcase.qml
    view/ShadowsShowcase.qml
    view/SpacingRadiusShowcase.qml
    view/StatesShowcase.qml
    view/ThemeGalleryExport.qml
    view/ThemeGallery.qml
    view/ThemeBuilderShowcase.qml
    view/TypographyShowcase.qml
)

set(MERCE_PLAYGROUND_COMPONENT_QML
    component/ColorPicker.qml
    component/ColorTokenCard.qml
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
    probe/ThemeBuilderProbe.qml
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

set(MERCE_MATERIAL_SYMBOLS_DIR
    "${CMAKE_CURRENT_SOURCE_DIR}/../Foundation/fonts/MaterialSymbolsRounded"
)
qt_add_resources(MercePlayground merce_playground_icon_data
    PREFIX "/merce/playground"
    BASE "${MERCE_MATERIAL_SYMBOLS_DIR}"
    FILES
        "${MERCE_MATERIAL_SYMBOLS_DIR}/MaterialSymbolsRounded.codepoints"
)

target_link_libraries(MercePlayground
    PRIVATE
        Qt6::Core
        Qt6::LabsStyleKit
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::Qml
        MerceCore
        MercePlatform
        MerceStyle
        MerceTheme
        MerceEffects
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
        $<$<CONFIG:Debug>:QT_QML_DEBUG>
)
