set(_MERCE_MCU_ROOT "${CMAKE_CURRENT_LIST_DIR}/../third_party/material-color-utilities")

add_library(MerceMcuSubset STATIC
    "${_MERCE_MCU_ROOT}/cpp/utils/utils.cc"
    "${_MERCE_MCU_ROOT}/cpp/cam/cam.cc"
    "${_MERCE_MCU_ROOT}/cpp/cam/hct_solver.cc"
    "${_MERCE_MCU_ROOT}/cpp/cam/hct.cc"
    "${_MERCE_MCU_ROOT}/cpp/cam/viewing_conditions.cc"
    "${_MERCE_MCU_ROOT}/cpp/palettes/tones.cc"
    "${_MERCE_MCU_ROOT}/cpp/contrast/contrast.cc"
)

target_include_directories(MerceMcuSubset
    PUBLIC
        "${_MERCE_MCU_ROOT}"
)

target_compile_features(MerceMcuSubset PUBLIC cxx_std_17)
set_target_properties(MerceMcuSubset PROPERTIES POSITION_INDEPENDENT_CODE ON)

