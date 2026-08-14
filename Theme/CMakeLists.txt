include("${CMAKE_CURRENT_LIST_DIR}/../cmake/McuSubset.cmake")

set(MERCE_THEME_SOURCES
    BrandDerivation.cpp
    BrandDerivation.h
    ThemeValidator.cpp
    ThemeValidator.h
    MerceThemeManifest.h
    MerceThemeManifestLoader.cpp
    MerceThemeManifestLoader.h
    MerceThemeRegistry.cpp
    MerceThemeRegistry.h
    MerceTheme.cpp
    MerceTheme.h
    MerceColors.h
    MerceSpacing.h
    MerceRadius.h
    MerceSize.h
    MerceState.h
    MerceTypography.h
    MerceMotion.h
    MerceIconography.h
    MerceZIndex.h
    MerceBreakpoints.h
    MerceShadows.h
)

set(MERCE_GENERATED_DIR "${CMAKE_CURRENT_LIST_DIR}/../generated")
set(MERCE_THEME_INDEX_FILE "${MERCE_GENERATED_DIR}/themes/index.json")
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${MERCE_THEME_INDEX_FILE}")

if(NOT EXISTS "${MERCE_THEME_INDEX_FILE}")
    message(FATAL_ERROR "Missing generated theme index: ${MERCE_THEME_INDEX_FILE}")
endif()

file(READ "${MERCE_THEME_INDEX_FILE}" MERCE_THEME_INDEX_JSON)
set(MERCE_THEME_MANIFEST_FILES "${MERCE_THEME_INDEX_FILE}")

string(JSON MERCE_BRAND_COUNT LENGTH "${MERCE_THEME_INDEX_JSON}" brands)
math(EXPR MERCE_BRAND_LAST "${MERCE_BRAND_COUNT} - 1")
foreach(BRAND_INDEX RANGE 0 ${MERCE_BRAND_LAST})
    string(JSON BRAND_ID MEMBER "${MERCE_THEME_INDEX_JSON}" brands ${BRAND_INDEX})
    string(JSON MODE_COUNT LENGTH "${MERCE_THEME_INDEX_JSON}" brands "${BRAND_ID}" modes)
    math(EXPR MODE_LAST "${MODE_COUNT} - 1")
    foreach(MODE_INDEX RANGE 0 ${MODE_LAST})
        string(JSON MODE MEMBER
            "${MERCE_THEME_INDEX_JSON}" brands "${BRAND_ID}" modes ${MODE_INDEX})
        string(JSON MANIFEST_FILE GET
            "${MERCE_THEME_INDEX_JSON}" brands "${BRAND_ID}" modes "${MODE}")
        list(APPEND MERCE_THEME_MANIFEST_FILES
            "${MERCE_GENERATED_DIR}/themes/${MANIFEST_FILE}")
    endforeach()
endforeach()

string(JSON MERCE_PROFILE_COUNT LENGTH "${MERCE_THEME_INDEX_JSON}" profiles)
math(EXPR MERCE_PROFILE_LAST "${MERCE_PROFILE_COUNT} - 1")
foreach(PROFILE_INDEX RANGE 0 ${MERCE_PROFILE_LAST})
    string(JSON PROFILE_ID MEMBER "${MERCE_THEME_INDEX_JSON}" profiles ${PROFILE_INDEX})
    string(JSON PROFILE_FILE GET
        "${MERCE_THEME_INDEX_JSON}" profiles "${PROFILE_ID}" path)
    list(APPEND MERCE_THEME_MANIFEST_FILES
        "${MERCE_GENERATED_DIR}/profiles/${PROFILE_FILE}")
endforeach()

# Font files the generator copied next to the manifests. They have to travel in
# the same resource bundle as the manifest that names them, or a device gets a
# theme asking for a typeface that is not on it.
file(GLOB_RECURSE MERCE_THEME_FONT_FILES CONFIGURE_DEPENDS
    "${MERCE_GENERATED_DIR}/themes/fonts/*.ttf"
    "${MERCE_GENERATED_DIR}/themes/fonts/*.otf")
list(APPEND MERCE_THEME_MANIFEST_FILES ${MERCE_THEME_FONT_FILES})

qt_add_qml_module(MerceTheme
    URI "Merce.Theme"
    VERSION 1.0
    DEPENDENCIES
        QtQuick
    SOURCES
        ${MERCE_THEME_SOURCES}
)

qt_add_resources(MerceTheme "merce_theme_manifests"
    PREFIX "/merce"
    BASE "${MERCE_GENERATED_DIR}"
    FILES
        ${MERCE_THEME_MANIFEST_FILES}
)

target_link_libraries(MerceTheme
    PUBLIC
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
    PRIVATE
        MerceMcuSubset
)

target_include_directories(MerceTheme
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
)
