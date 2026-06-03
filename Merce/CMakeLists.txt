cmake_minimum_required(VERSION 3.30)

project(Merce VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Qt 6.11+ required
find_package(Qt6 6.11 REQUIRED COMPONENTS Core Gui Quick Qml)

qt_standard_project_setup(REQUIRES 6.11)
set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/qml")

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
option(BUILD_MERCE_PLAYGROUND "Build Merce playground application" ON)

if(BUILD_MERCE_PLAYGROUND)
    add_subdirectory(playground)
endif()

# ========================================================================
# Installation
# ========================================================================

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

set(MERCE_QML_MODULE_TARGETS
    MerceCore
    MerceCoreEffects
    MerceCoreBase
    MerceCoreUtils
    MerceFoundation
    MerceControls
    MerceNotifications
)

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
