function(merce_add_theme_qtest target source)
    qt_add_executable(${target}
        ${source}
    )

    target_link_libraries(${target}
        PRIVATE
            MerceTheme
            Qt6::Core
            Qt6::Gui
            Qt6::Qml
            Qt6::Test
    )

    target_include_directories(${target}
        PRIVATE
            "${CMAKE_CURRENT_SOURCE_DIR}/../../Theme"
    )

    add_test(NAME ${target}
        COMMAND ${target}
    )

    set_tests_properties(${target} PROPERTIES
        ENVIRONMENT "${MERCE_TEST_ENVIRONMENT}"
    )
endfunction()

merce_add_theme_qtest(tst_merce_theme_manifest_loader tst_merce_theme_manifest_loader.cpp)
merce_add_theme_qtest(tst_merce_theme_runtime_switch tst_merce_theme_runtime_switch.cpp)
merce_add_theme_qtest(tst_merce_brand_derivation tst_merce_brand_derivation.cpp)
target_link_libraries(tst_merce_brand_derivation PRIVATE MerceMcuSubset)
