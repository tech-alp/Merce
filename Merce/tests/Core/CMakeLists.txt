qt_add_executable(tst_merce_core_runtime
    tst_merce_test_harness.cpp
)

target_link_libraries(tst_merce_core_runtime
    PRIVATE
        MerceCore
        Qt6::Core
        Qt6::Test
)

target_include_directories(tst_merce_core_runtime
    PRIVATE
        "${CMAKE_CURRENT_SOURCE_DIR}/../../Core/BuildInfo"
        "${CMAKE_CURRENT_SOURCE_DIR}/../../Core/Resources"
)

add_test(NAME tst_merce_core_runtime
    COMMAND tst_merce_core_runtime
)
