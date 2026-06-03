function(merce_add_qtest target source)
    qt_add_executable(${target}
        ${source}
    )

    target_link_libraries(${target}
        PRIVATE
            MerceCore
            Qt6::Core
            Qt6::Test
    )

    target_include_directories(${target}
        PRIVATE
            "${CMAKE_CURRENT_SOURCE_DIR}/../../Core/Theme"
    )

    add_test(NAME ${target}
        COMMAND ${target}
    )
endfunction()

merce_add_qtest(tst_merce_test_harness tst_merce_test_harness.cpp)
merce_add_qtest(tst_merce_theme_manifest_loader tst_merce_theme_manifest_loader.cpp)
