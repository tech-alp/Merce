function(merce_add_qtest target source)
    qt_add_executable(${target}
        ${source}
    )

    target_link_libraries(${target}
        PRIVATE
            Qt6::Core
            Qt6::Test
    )

    add_test(NAME ${target}
        COMMAND ${target}
    )
endfunction()

merce_add_qtest(tst_merce_test_harness tst_merce_test_harness.cpp)
