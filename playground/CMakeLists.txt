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
    view/PlaygroundPagesExport.qml
    view/ShadowsShowcase.qml
    view/SpacingRadiusPage.qml
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

# Reference palettes belong to the playground, not to the theme library: they
# exist to be looked at, and an application should not be able to resolve one.
# addThemeSource takes a filesystem path by design, so they are copied beside
# the binary rather than compiled into it.
set(MERCE_REFERENCE_INDEX "${CMAKE_CURRENT_SOURCE_DIR}/../generated/themes/reference-index.json")
if(EXISTS "${MERCE_REFERENCE_INDEX}")
    set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${MERCE_REFERENCE_INDEX}")
    file(READ "${MERCE_REFERENCE_INDEX}" MERCE_REFERENCE_JSON)
    set(MERCE_REFERENCE_FILES "reference-index.json")
    string(JSON REF_BRAND_COUNT LENGTH "${MERCE_REFERENCE_JSON}" brands)
    math(EXPR REF_BRAND_LAST "${REF_BRAND_COUNT} - 1")
    foreach(REF_INDEX RANGE 0 ${REF_BRAND_LAST})
        string(JSON REF_BRAND MEMBER "${MERCE_REFERENCE_JSON}" brands ${REF_INDEX})
        string(JSON REF_MODE_COUNT LENGTH "${MERCE_REFERENCE_JSON}" brands "${REF_BRAND}" modes)
        math(EXPR REF_MODE_LAST "${REF_MODE_COUNT} - 1")
        foreach(REF_MODE_INDEX RANGE 0 ${REF_MODE_LAST})
            string(JSON REF_MODE MEMBER
                "${MERCE_REFERENCE_JSON}" brands "${REF_BRAND}" modes ${REF_MODE_INDEX})
            string(JSON REF_FILE GET
                "${MERCE_REFERENCE_JSON}" brands "${REF_BRAND}" modes "${REF_MODE}")
            list(APPEND MERCE_REFERENCE_FILES "${REF_FILE}")
        endforeach()
    endforeach()
    list(REMOVE_DUPLICATES MERCE_REFERENCE_FILES)
    foreach(REF_FILE IN LISTS MERCE_REFERENCE_FILES)
        add_custom_command(TARGET MercePlayground POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                "${CMAKE_CURRENT_SOURCE_DIR}/../generated/themes/${REF_FILE}"
                "$<TARGET_FILE_DIR:MercePlayground>/themes/${REF_FILE}")
    endforeach()
endif()

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
