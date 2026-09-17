# Backing target first: qt_add_library honours BUILD_SHARED_LIBS (policy QTP0003),
# while qt_add_qml_module deliberately does not when it creates the target itself.
qt_add_library(MercePlatform)

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
