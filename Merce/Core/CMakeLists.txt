set(MERCE_CORE_TOKEN_QML_FILES
    Palette.qml
    Spacing.qml
    Typography.qml
    Radius.qml
    Shadows.qml
    Motion.qml
    Iconography.qml
    ZIndex.qml
    Breakpoints.qml
)

set(MERCE_CORE_THEME_SOURCES
    Theme/MerceThemeManifest.h
    Theme/MerceThemeRegistry.cpp
    Theme/MerceThemeRegistry.h
    Theme/MerceTheme.cpp
    Theme/MerceTheme.h
    Theme/MercePalette.h
    Theme/MerceSpacing.h
    Theme/MerceRadius.h
    Theme/MerceTypography.h
    Theme/MerceMotion.h
    Theme/MerceIconography.h
    Theme/MerceZIndex.h
    Theme/MerceBreakpoints.h
    Theme/MerceShadows.h
)

set(MERCE_THEME_MANIFEST_DIR "${CMAKE_CURRENT_LIST_DIR}/../generated/themes")
set(MERCE_THEME_INDEX_FILE "${MERCE_THEME_MANIFEST_DIR}/index.json")

if(NOT EXISTS "${MERCE_THEME_INDEX_FILE}")
    message(FATAL_ERROR "Missing generated theme index: ${MERCE_THEME_INDEX_FILE}")
endif()

file(READ "${MERCE_THEME_INDEX_FILE}" MERCE_THEME_INDEX_JSON)
set(MERCE_THEME_MANIFEST_RELATIVE_FILES index.json)

function(merce_collect_theme_manifest_path out_var path_value)
    if(NOT path_value)
        message(FATAL_ERROR "Theme manifest path in ${MERCE_THEME_INDEX_FILE} must not be empty.")
    endif()

    if(IS_ABSOLUTE "${path_value}" OR path_value MATCHES "^:" OR path_value MATCHES "(^|/)\\.\\.(/|$)")
        message(FATAL_ERROR "Theme manifest path '${path_value}' in ${MERCE_THEME_INDEX_FILE} must stay inside ${MERCE_THEME_MANIFEST_DIR}.")
    endif()

    set(path_file "${MERCE_THEME_MANIFEST_DIR}/${path_value}")
    if(NOT EXISTS "${path_file}")
        message(FATAL_ERROR "Missing generated theme manifest listed by ${MERCE_THEME_INDEX_FILE}: ${path_file}")
    endif()

    set(${out_var} "${${out_var}};${path_value}" PARENT_SCOPE)
endfunction()

string(JSON MERCE_THEME_COUNT ERROR_VARIABLE MERCE_THEME_INDEX_ERROR LENGTH "${MERCE_THEME_INDEX_JSON}" themes)
if(MERCE_THEME_INDEX_ERROR)
    message(FATAL_ERROR "Unable to read themes from generated theme index ${MERCE_THEME_INDEX_FILE}: ${MERCE_THEME_INDEX_ERROR}")
endif()

if(MERCE_THEME_COUNT LESS 1)
    message(FATAL_ERROR "Generated theme index ${MERCE_THEME_INDEX_FILE} must declare at least one theme.")
endif()

math(EXPR MERCE_THEME_LAST_INDEX "${MERCE_THEME_COUNT} - 1")
foreach(MERCE_THEME_INDEX RANGE 0 ${MERCE_THEME_LAST_INDEX})
    string(JSON MERCE_THEME_NAME MEMBER "${MERCE_THEME_INDEX_JSON}" themes ${MERCE_THEME_INDEX})

    string(JSON MERCE_THEME_BASE_PATH ERROR_VARIABLE MERCE_THEME_BASE_PATH_ERROR GET "${MERCE_THEME_INDEX_JSON}" themes "${MERCE_THEME_NAME}" basePath)
    if(NOT MERCE_THEME_BASE_PATH_ERROR)
        merce_collect_theme_manifest_path(MERCE_THEME_MANIFEST_RELATIVE_FILES "${MERCE_THEME_BASE_PATH}")
    endif()

    string(JSON MERCE_THEME_PATH ERROR_VARIABLE MERCE_THEME_PATH_ERROR GET "${MERCE_THEME_INDEX_JSON}" themes "${MERCE_THEME_NAME}" path)
    if(NOT MERCE_THEME_PATH_ERROR)
        merce_collect_theme_manifest_path(MERCE_THEME_MANIFEST_RELATIVE_FILES "${MERCE_THEME_PATH}")
    endif()

    string(JSON MERCE_THEME_VARIANT_COUNT ERROR_VARIABLE MERCE_THEME_VARIANT_COUNT_ERROR LENGTH "${MERCE_THEME_INDEX_JSON}" themes "${MERCE_THEME_NAME}" variants)
    if(NOT MERCE_THEME_VARIANT_COUNT_ERROR)
        math(EXPR MERCE_THEME_VARIANT_LAST_INDEX "${MERCE_THEME_VARIANT_COUNT} - 1")
        foreach(MERCE_THEME_VARIANT_INDEX RANGE 0 ${MERCE_THEME_VARIANT_LAST_INDEX})
            string(JSON MERCE_THEME_VARIANT_NAME MEMBER "${MERCE_THEME_INDEX_JSON}" themes "${MERCE_THEME_NAME}" variants ${MERCE_THEME_VARIANT_INDEX})
            string(JSON MERCE_THEME_VARIANT_PATH GET "${MERCE_THEME_INDEX_JSON}" themes "${MERCE_THEME_NAME}" variants "${MERCE_THEME_VARIANT_NAME}")
            merce_collect_theme_manifest_path(MERCE_THEME_MANIFEST_RELATIVE_FILES "${MERCE_THEME_VARIANT_PATH}")
        endforeach()
    endif()
endforeach()

list(REMOVE_DUPLICATES MERCE_THEME_MANIFEST_RELATIVE_FILES)
set(MERCE_THEME_MANIFEST_FILES)
foreach(MERCE_THEME_MANIFEST_RELATIVE_FILE IN LISTS MERCE_THEME_MANIFEST_RELATIVE_FILES)
    list(APPEND MERCE_THEME_MANIFEST_FILES "${MERCE_THEME_MANIFEST_DIR}/${MERCE_THEME_MANIFEST_RELATIVE_FILE}")
endforeach()

set_source_files_properties(
    ${MERCE_CORE_TOKEN_QML_FILES}
    PROPERTIES
        QT_QML_INTERNAL_TYPE TRUE
)

qt_add_qml_module(MerceCore
    URI "Merce.Core"
    VERSION 1.0
    SOURCES
        ${MERCE_CORE_THEME_SOURCES}
    QML_FILES
        ${MERCE_CORE_TOKEN_QML_FILES}
)

qt_add_resources(MerceCore "merce_theme_manifests"
    PREFIX "/merce/themes"
    BASE "${MERCE_THEME_MANIFEST_DIR}"
    FILES
        ${MERCE_THEME_MANIFEST_FILES}
)

target_link_libraries(MerceCore
    PUBLIC
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
)

target_include_directories(MerceCore
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_CURRENT_SOURCE_DIR}/Theme
)

# Add Core submodules
add_subdirectory(Effects)
add_subdirectory(Base)
add_subdirectory(Utils)
