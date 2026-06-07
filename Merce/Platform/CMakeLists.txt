qt_add_qml_module(MercePlatform
    URI "Merce.Platform"
    VERSION 1.0
    SOURCES
        MercePlatformCapabilities.cpp
        MercePlatformCapabilities.h
)

target_link_libraries(MercePlatform
    PUBLIC
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
)

target_include_directories(MercePlatform
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
)
