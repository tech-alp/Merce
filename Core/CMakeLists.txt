set(MERCE_CORE_SOURCES
    BuildInfo/MerceBuildInfo.cpp
    BuildInfo/MerceBuildInfo.h
    Resources/MerceModuleRegistry.cpp
    Resources/MerceModuleRegistry.h
    Utils/MerceResult.h
)

# Backing target first: qt_add_library honours BUILD_SHARED_LIBS (policy QTP0003),
# while qt_add_qml_module deliberately does not when it creates the target itself.
qt_add_library(MerceCore)

qt_add_qml_module(MerceCore
    URI "Merce.Core"
    VERSION 1.0
    SOURCES
        ${MERCE_CORE_SOURCES}
)

if(CMAKE_BUILD_TYPE)
    set(MERCE_CORE_BUILD_TYPE "${CMAKE_BUILD_TYPE}")
else()
    set(MERCE_CORE_BUILD_TYPE "unknown")
endif()

target_compile_definitions(MerceCore
    PRIVATE
        MERCE_VERSION="${PROJECT_VERSION}"
        MERCE_BUILD_TYPE="${MERCE_CORE_BUILD_TYPE}"
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
        ${CMAKE_CURRENT_SOURCE_DIR}/BuildInfo
        ${CMAKE_CURRENT_SOURCE_DIR}/Resources
        ${CMAKE_CURRENT_SOURCE_DIR}/Utils
)
