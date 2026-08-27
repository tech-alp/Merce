include_guard(GLOBAL)

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
