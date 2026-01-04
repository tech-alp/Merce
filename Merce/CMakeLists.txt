cmake_minimum_required(VERSION 3.24)

project(Merce VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Qt 6.11+ required
find_package(Qt6 REQUIRED COMPONENTS Core Quick Qml)

# Qt 6.11 feature check
if(CMAKE_VERSION VERSION_LESS "3.24")
    message(FATAL_ERROR "CMake 3.24+ is required for Qt 6.11+ property semantics")
endif()

# ========================================================================
# Merce Design System Modules
# ========================================================================

add_subdirectory(Core)
add_subdirectory(Foundation)
add_subdirectory(Controls)
add_subdirectory(Notifications)

# ========================================================================
# Example Application (optional, for testing)
# ========================================================================
option(BUILD_MERCE_EXAMPLES "Build Merce example applications" OFF)

if(BUILD_MERCE_EXAMPLES)
    qt_add_executable(MerceExample
        examples/Main.qml
    )

    qt_add_qml_module(MerceExample
        URI "MerceExample"
        VERSION 1.0
        QML_FILES
            examples/Main.qml
    )

    target_link_libraries(MerceExample
        PRIVATE
            Qt6::Core
            Qt6::Quick
            MerceControls
            MerceNotifications
    )
endif()

# ========================================================================
# Installation
# ========================================================================

install(TARGETS
    MerceCore
    MerceFoundation
    MerceControls
    MerceNotifications
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

# Install QML modules
install(QML_MODULE
    MerceCore
    MerceFoundation
    MerceControls
    MerceNotifications
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/qml
)

# ========================================================================
# Exports
# ========================================================================

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/MerceConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/MerceConfigVersion.cmake"
    "${CMAKE_CURRENT_SOURCE_DIR}/MerceConfig.cmake"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Merce
)

# ========================================================================
# Summary
# ========================================================================

message(STATUS "")
message(STATUS "Merce Design System v${PROJECT_VERSION}")
message(STATUS "  Qt Version: ${Qt6_VERSION}")
message(STATUS "  Build Type: ${CMAKE_BUILD_TYPE}")
message(STATUS "  Install Prefix: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "  Build Examples: ${BUILD_MERCE_EXAMPLES}")
message(STATUS "")
message(STATUS "Module Dependency Tree:")
message(STATUS "  Application")
message(STATUS "    ├── Merce.Controls")
message(STATUS "    │       └── Merce.Foundation")
message(STATUS "    │               └── Merce.Core")
message(STATUS "    └── Merce.Notifications")
message(STATUS "            └── Merce.Foundation")
message(STATUS "                    └── Merce.Core")
message(STATUS "")
