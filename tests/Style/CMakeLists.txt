qt_add_executable(tst_merce_style_runtime_switch
    tst_merce_style_runtime_switch.cpp
)

qt_add_qml_module(tst_merce_style_runtime_switch
    URI "Merce.Tests.StyleKit"
    VERSION 1.0
    QML_FILES
        StyleRuntimeProbe.qml
)

target_link_libraries(tst_merce_style_runtime_switch
    PRIVATE
        MerceStyle
        MerceControls
        MerceTheme
        Qt6::Core
        Qt6::Gui
        Qt6::LabsStyleKit
        Qt6::Qml
        Qt6::Quick
        Qt6::Test
)

target_include_directories(tst_merce_style_runtime_switch
    PRIVATE
        "${CMAKE_CURRENT_SOURCE_DIR}/../../Theme"
)

add_test(NAME tst_merce_style_runtime_switch
    COMMAND tst_merce_style_runtime_switch
)

set_tests_properties(tst_merce_style_runtime_switch PROPERTIES
    ENVIRONMENT "QT_QPA_PLATFORM=offscreen;QT_QUICK_BACKEND=software"
)
