cmake_minimum_required(VERSION 3.30)

project(MerceSourceConsumer LANGUAGES CXX)

set(MERCE_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(BUILD_MERCE_PLAYGROUND OFF CACHE BOOL "" FORCE)
set(MERCE_BUILD_NOTIFICATIONS OFF CACHE BOOL "" FORCE)
set(MERCE_ENABLE_FONTAWESOME ON CACHE BOOL "" FORCE)

add_subdirectory("../.." merce)

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
        message(FATAL_ERROR "Missing source-tree target: ${required_target}")
    endif()
endforeach()

if(MERCE_BUILD_STYLE_EFFECTS AND NOT TARGET Merce::StyleEffects)
    message(FATAL_ERROR "Missing source-tree target: Merce::StyleEffects")
elseif(NOT MERCE_BUILD_STYLE_EFFECTS AND TARGET Merce::StyleEffects)
    message(FATAL_ERROR "Disabled StyleEffects must not expose a target")
endif()

set(MERCE_EXPECT_STYLE_EFFECTS ${MERCE_BUILD_STYLE_EFFECTS})
# Exercise the same QML and qrc paths as an installed-package consumer.
add_subdirectory("../package-consumer" consumer)
