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
