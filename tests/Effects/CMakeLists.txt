qt_add_executable(tst_merce_effects tst_merce_effects.cpp)

qt_add_qml_module(tst_merce_effects
    URI "Merce.Tests.Effects"
    VERSION 1.0
    QML_FILES EffectsProbe.qml SheenRenderProbe.qml
)

target_link_libraries(tst_merce_effects PRIVATE
    MerceStyleEffects MerceStyle MerceEffects MerceControls MerceTheme
    Qt6::Core Qt6::Gui Qt6::LabsStyleKit Qt6::Qml Qt6::Quick Qt6::Test
)
target_include_directories(tst_merce_effects PRIVATE "${PROJECT_SOURCE_DIR}/Theme")

add_test(NAME tst_merce_effects COMMAND tst_merce_effects)
set_tests_properties(tst_merce_effects PROPERTIES ENVIRONMENT "${MERCE_TEST_ENVIRONMENT}")

# Use a display-capable RHI backend, e.g. Xvfb + Mesa OpenGL in Linux CI.
# Do not inherit the normal suite's Qt Quick software renderer for this test.
option(MERCE_TEST_EFFECTS_RENDERING "Require shader pixel and animation tests on RHI" OFF)
if(MERCE_TEST_EFFECTS_RENDERING)
    add_test(NAME tst_merce_effects_rendering
        COMMAND tst_merce_effects sweepLifecycle shaderPixels)
    set_tests_properties(tst_merce_effects_rendering PROPERTIES
        ENVIRONMENT "QML_IMPORT_PATH=${QT_QML_OUTPUT_DIRECTORY};MERCE_REQUIRE_SHADER_RENDERING=1"
    )
endif()
