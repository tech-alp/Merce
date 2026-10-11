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
if(NOT TARGET Merce::Core)
    find_package(Merce 1.0 CONFIG REQUIRED)
endif()

option(MERCE_EXPECT_STYLE_EFFECTS "Expect the optional StyleEffects package" ON)
if(MERCE_EXPECT_STYLE_EFFECTS AND NOT TARGET Merce::StyleEffects)
    message(FATAL_ERROR "Missing consumer target: Merce::StyleEffects")
elseif(NOT MERCE_EXPECT_STYLE_EFFECTS AND TARGET Merce::StyleEffects)
    message(FATAL_ERROR "Disabled StyleEffects must not expose a target")
endif()

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

set(consumer_qml Main.qml)
if(MERCE_EXPECT_STYLE_EFFECTS)
    list(APPEND consumer_qml EffectsProbe.qml)
    target_compile_definitions(merce_package_consumer PRIVATE MERCE_CONSUMER_STYLE_EFFECTS)
    target_link_libraries(merce_package_consumer PRIVATE Merce::StyleEffects)
endif()

qt_add_qml_module(merce_package_consumer
    URI Merce.PackageConsumer
    VERSION 1.0
    QML_FILES
        ${consumer_qml}
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
