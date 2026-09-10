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
