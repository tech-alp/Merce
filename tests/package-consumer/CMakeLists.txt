cmake_minimum_required(VERSION 3.30)

project(MercePackageConsumer LANGUAGES CXX)

find_package(Qt6 6.11 REQUIRED COMPONENTS
    Core
    Gui
    Quick
    Qml
    QuickControls2
    LabsStyleKit
    QuickEffects
)
find_package(Merce 1.0 CONFIG REQUIRED)

qt_standard_project_setup(REQUIRES 6.11)

foreach(required_target IN ITEMS
    Merce::Core
    Merce::Platform
    Merce::Theme
    Merce::Foundation
    Merce::Style
    Merce::Effects
    Merce::Controls
    Merce::IconsFontAwesome
)
    if(NOT TARGET "${required_target}")
        message(FATAL_ERROR "Missing installed target: ${required_target}")
    endif()
endforeach()

if(TARGET Merce::Notifications)
    message(FATAL_ERROR "Merce::Notifications must remain source-integration only")
endif()

qt_add_executable(merce_package_consumer
    main.cpp
)

qt_add_qml_module(merce_package_consumer
    URI Merce.PackageConsumer
    VERSION 1.0
    QML_FILES
        Main.qml
)

target_link_libraries(merce_package_consumer PRIVATE
    Qt6::Quick
    Qt6::LabsStyleKit
    Merce::Theme
    Merce::Foundation
    Merce::Style
    Merce::Effects
    Merce::Controls
    Merce::IconsFontAwesome
)

qt_import_qml_plugins(merce_package_consumer)
