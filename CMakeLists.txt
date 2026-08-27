cmake_minimum_required(VERSION 3.30)

project(Merce VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Optional design-token build tooling. This stays off by default so normal
# Qt configure/build paths never require Node or npm.
option(MERCE_ENABLE_TOKEN_BUILD "Enable the design-token manifest build target" OFF)
option(MERCE_ENABLE_FONTAWESOME "Build the optional Font Awesome SVG QML module" ON)
option(MERCE_BUILD_NOTIFICATIONS "Build the notification and dialog QML module" OFF)
option(MERCE_BUILD_TESTS "Build Merce tests" ${PROJECT_IS_TOP_LEVEL})
option(BUILD_MERCE_PLAYGROUND "Build Merce playground application" OFF)
option(MERCE_INSTALL "Generate Merce installation and package export rules" ${PROJECT_IS_TOP_LEVEL})

if(MERCE_ENABLE_TOKEN_BUILD)
    find_program(NPM_EXECUTABLE npm)
    if(NOT NPM_EXECUTABLE)
        message(FATAL_ERROR "MERCE_ENABLE_TOKEN_BUILD=ON requires npm, but npm was not found.")
    endif()

    add_custom_target(merce_tokens
        COMMAND "${NPM_EXECUTABLE}" run build
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/tools/design-tokens"
        COMMENT "Generating Merce theme manifests"
        VERBATIM
    )
endif()

# Qt 6.11+ / Qt.labs.StyleKit baseline required
find_package(Qt6 6.11 REQUIRED COMPONENTS Core Gui Quick Qml QuickControls2 LabsStyleKit QuickEffects)

if(MERCE_BUILD_NOTIFICATIONS)
    find_package(Qt6 6.11 REQUIRED COMPONENTS QuickVectorImage QuickVectorImageHelpers)
endif()

qt_standard_project_setup(REQUIRES 6.11)
qt_policy(SET QTP0005 NEW)
if(MERCE_BUILD_TESTS)
    include(CTest)
endif()
include(FetchContent)
set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/qml")

# External QML modules
if(MERCE_BUILD_NOTIFICATIONS AND NOT TARGET Toastify)
    set(MERCE_QTTOASTIFY_GIT_REVISION
        "b0a3b5f28870bbe76781579c0ba208b3ae384297"
        CACHE STRING "Pinned QtToastify revision"
    )
    FetchContent_Declare(QtToastify
        GIT_REPOSITORY https://github.com/tech-alp/QtToastify.git
        GIT_TAG ${MERCE_QTTOASTIFY_GIT_REVISION}
    )

    # QtToastify currently uses generic option names. Keep the overrides local
    # so embedding Merce does not mutate the parent project's cache options.
    block(SCOPE_FOR VARIABLES)
        set(BUILD_PLAYGROUND OFF)
        set(BUILD_TESTS OFF)
        FetchContent_MakeAvailable(QtToastify)
    endblock()
endif()

# ========================================================================
# Merce Design System Modules
# ========================================================================

add_subdirectory(Core)
add_subdirectory(Platform)
add_subdirectory(Theme)
add_subdirectory(Foundation)
add_subdirectory(Style)
add_subdirectory(Effects)
if(MERCE_ENABLE_FONTAWESOME)
    add_subdirectory(Icons/FontAwesome)
endif()
add_subdirectory(Controls)
if(MERCE_BUILD_NOTIFICATIONS)
    add_subdirectory(Notifications)
endif()

# Keep the public target names identical for FetchContent/add_subdirectory and
# installed find_package consumers.
add_library(Merce::Core ALIAS MerceCore)
add_library(Merce::Platform ALIAS MercePlatform)
add_library(Merce::Theme ALIAS MerceTheme)
add_library(Merce::Foundation ALIAS MerceFoundation)
add_library(Merce::Style ALIAS MerceStyle)
add_library(Merce::Effects ALIAS MerceEffects)
add_library(Merce::Controls ALIAS MerceControls)
if(MERCE_ENABLE_FONTAWESOME)
    add_library(Merce::IconsFontAwesome ALIAS MerceIconsFontAwesome)
endif()
if(MERCE_BUILD_NOTIFICATIONS)
    add_library(Merce::Notifications ALIAS MerceNotifications)
endif()

if(MERCE_BUILD_TESTS AND BUILD_TESTING)
    find_package(Qt6 6.11 REQUIRED COMPONENTS Test)
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/tests/CMakeLists.txt")
        add_subdirectory(tests)
    endif()
endif()

# ========================================================================
# Example Application (optional, for testing)
# ========================================================================
if(BUILD_MERCE_PLAYGROUND)
    if(NOT MERCE_ENABLE_FONTAWESOME)
        message(FATAL_ERROR "BUILD_MERCE_PLAYGROUND=ON requires MERCE_ENABLE_FONTAWESOME=ON for the Icons gallery.")
    endif()
    if(NOT MERCE_BUILD_NOTIFICATIONS)
        message(FATAL_ERROR "BUILD_MERCE_PLAYGROUND=ON requires MERCE_BUILD_NOTIFICATIONS=ON for the Feedback gallery.")
    endif()
    add_subdirectory(playground)
endif()

# ========================================================================
# Installation
# ========================================================================

if(NOT MERCE_INSTALL)
    return()
endif()

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

install(FILES
    LICENSE
    README.md
    CHANGELOG.md
    DESTINATION "${CMAKE_INSTALL_DOCDIR}"
)
install(FILES third_party/material-color-utilities/LICENSE
    DESTINATION "${CMAKE_INSTALL_DOCDIR}/licenses"
    RENAME material-color-utilities-Apache-2.0.txt
)
install(FILES Foundation/fonts/MaterialSymbolsRounded/LICENSE
    DESTINATION "${CMAKE_INSTALL_DOCDIR}/licenses"
    RENAME material-symbols-Apache-2.0.txt
)
if(MERCE_ENABLE_FONTAWESOME)
    install(FILES Icons/FontAwesome/LICENSE.txt
        DESTINATION "${CMAKE_INSTALL_DOCDIR}/licenses"
        RENAME font-awesome-free.txt
    )
endif()
install(FILES tools/design-tokens/tokens/core/fonts/OFL-JetBrainsMono.txt
    DESTINATION "${CMAKE_INSTALL_DOCDIR}/licenses"
    RENAME jetbrains-mono-OFL-1.1.txt
)
install(FILES tools/design-tokens/tokens/core/fonts/OFL-Lexend.txt
    DESTINATION "${CMAKE_INSTALL_DOCDIR}/licenses"
    RENAME lexend-OFL-1.1.txt
)

set(MERCE_QML_MODULE_TARGETS
    MerceCore
    MercePlatform
    MerceTheme
    MerceFoundation
    MerceStyle
    MerceEffects
    MerceControls
)

if(MERCE_ENABLE_FONTAWESOME)
    list(APPEND MERCE_QML_MODULE_TARGETS MerceIconsFontAwesome)
endif()

# Merce.Notifications imports the source-integrated static Toastify modules.
# Until QtToastify provides an installable QML package, keep Notifications out
# of the installed Merce package rather than publishing a target that fails at
# runtime with "module Toastify is not installed".

function(merce_install_qml_module_files module_dir files deploy_paths)
    list(LENGTH files file_count)
    if(file_count EQUAL 0)
        return()
    endif()

    list(LENGTH deploy_paths deploy_path_count)
    math(EXPR last_index "${file_count} - 1")
    foreach(index RANGE 0 ${last_index})
        list(GET files ${index} src_file)

        if(index LESS deploy_path_count)
            list(GET deploy_paths ${index} deploy_path)
        else()
            set(deploy_path "")
        endif()

        if(NOT deploy_path)
            continue()
        endif()

        get_filename_component(dst_name "${deploy_path}" NAME)
        get_filename_component(dst_dir "${deploy_path}" DIRECTORY)
        install(FILES "${src_file}" DESTINATION "${module_dir}/${dst_dir}" RENAME "${dst_name}")
    endforeach()
endfunction()

function(merce_install_qml_module target)
    qt_query_qml_module(${target}
        PLUGIN_TARGET module_plugin_target
        TARGET_PATH module_target_path
        QMLDIR module_qmldir
        TYPEINFO module_typeinfo
        QML_FILES module_qml_files
        QML_FILES_DEPLOY_PATHS module_qml_file_deploy_paths
        RESOURCES module_resources
        RESOURCES_DEPLOY_PATHS module_resource_deploy_paths
    )

    set(module_dir "${CMAKE_INSTALL_LIBDIR}/qml/${module_target_path}")

    install(TARGETS ${target}
        EXPORT MerceTargets
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    )

    if(module_plugin_target AND NOT module_plugin_target STREQUAL target)
        install(TARGETS ${module_plugin_target}
            RUNTIME DESTINATION ${module_dir}
            LIBRARY DESTINATION ${module_dir}
            ARCHIVE DESTINATION ${module_dir}
        )
    endif()

    if(module_qmldir)
        install(FILES "${module_qmldir}" DESTINATION "${module_dir}")
    endif()

    if(module_typeinfo)
        install(FILES "${module_typeinfo}" DESTINATION "${module_dir}")
    endif()

    merce_install_qml_module_files(
        "${module_dir}"
        "${module_qml_files}"
        "${module_qml_file_deploy_paths}"
    )
    merce_install_qml_module_files(
        "${module_dir}"
        "${module_resources}"
        "${module_resource_deploy_paths}"
    )
endfunction()

foreach(module_target IN LISTS MERCE_QML_MODULE_TARGETS)
    merce_install_qml_module(${module_target})
endforeach()

# ========================================================================
# Exports
# ========================================================================

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

install(EXPORT MerceTargets
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
message(STATUS "  Build Playground: ${BUILD_MERCE_PLAYGROUND}")
message(STATUS "")
message(STATUS "Module Dependency Tree:")
message(STATUS "  Application")
message(STATUS "    ├── Qt.labs.StyleKit controls")
message(STATUS "    │       └── Merce.Style")
message(STATUS "    │               ├── Merce.Foundation")
message(STATUS "    │               └── Merce.Theme")
message(STATUS "    ├── Merce.Controls (optional)")
message(STATUS "    │       ├── Merce.Foundation")
message(STATUS "    │       └── Merce.Theme")
if(MERCE_BUILD_NOTIFICATIONS)
    message(STATUS "    └── Merce.Notifications")
    message(STATUS "            ├── Merce.Controls")
    message(STATUS "            ├── Merce.Foundation")
    message(STATUS "            └── Merce.Theme")
endif()
message(STATUS "")
