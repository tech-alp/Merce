cmake_minimum_required(VERSION 3.30)

project(Merce VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Optional design-token build tooling. This stays off by default so normal
# Qt configure/build paths never require Node or npm.
option(MERCE_ENABLE_TOKEN_BUILD "Enable the design-token manifest build target" OFF)
option(MERCE_ENABLE_FONTAWESOME "Build the optional Font Awesome SVG QML module" ON)
option(MERCE_BUILD_NOTIFICATIONS "Build the notification and dialog QML module" OFF)
option(MERCE_BUILD_TESTS "Build Merce tests" ${PROJECT_IS_TOP_LEVEL})
option(BUILD_MERCE_PLAYGROUND "Build Merce playground application" OFF)

if(MERCE_ENABLE_TOKEN_BUILD)
    find_program(NPM_EXECUTABLE npm)
    if(NOT NPM_EXECUTABLE)
        message(FATAL_ERROR "MERCE_ENABLE_TOKEN_BUILD=ON requires npm, but npm was not found.")
    endif()

    add_custom_target(merce_tokens
        COMMAND "${NPM_EXECUTABLE}" run build
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/tools/design-tokens"
        COMMENT "Generating Merce theme manifests"
        VERBATIM
    )
endif()

# Qt 6.11+ / Qt.labs.StyleKit baseline required
find_package(Qt6 6.11 REQUIRED COMPONENTS Core Gui Quick Qml QuickControls2 LabsStyleKit QuickEffects)

if(MERCE_BUILD_NOTIFICATIONS)
    find_package(Qt6 6.11 REQUIRED COMPONENTS QuickVectorImage QuickVectorImageHelpers)
endif()

qt_standard_project_setup(REQUIRES 6.11)
qt_policy(SET QTP0005 NEW)
if(MERCE_BUILD_TESTS)
    include(CTest)
endif()
include(FetchContent)
set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/qml")

# External QML modules
if(MERCE_BUILD_NOTIFICATIONS AND NOT TARGET Toastify)
    set(MERCE_QTTOASTIFY_GIT_REVISION
        "b0a3b5f28870bbe76781579c0ba208b3ae384297"
        CACHE STRING "Pinned QtToastify revision"
    )
    FetchContent_Declare(QtToastify
        GIT_REPOSITORY https://github.com/tech-alp/QtToastify.git
        GIT_TAG ${MERCE_QTTOASTIFY_GIT_REVISION}
    )

    # QtToastify currently uses generic option names. Keep the overrides local
    # so embedding Merce does not mutate the parent project's cache options.
    block(SCOPE_FOR VARIABLES)
        set(BUILD_PLAYGROUND OFF)
        set(BUILD_TESTS OFF)
        FetchContent_MakeAvailable(QtToastify)
    endblock()
endif()

# ========================================================================
# Merce Design System Modules
# ========================================================================

add_subdirectory(Core)
add_subdirectory(Platform)
add_subdirectory(Theme)
add_subdirectory(Foundation)
add_subdirectory(Style)
add_subdirectory(Effects)
if(MERCE_ENABLE_FONTAWESOME)
    add_subdirectory(Icons/FontAwesome)
endif()
add_subdirectory(Controls)
if(MERCE_BUILD_NOTIFICATIONS)
    add_subdirectory(Notifications)
endif()

# Keep the public target names identical for FetchContent/add_subdirectory and
# installed find_package consumers.
add_library(Merce::Core ALIAS MerceCore)
add_library(Merce::Platform ALIAS MercePlatform)
add_library(Merce::Theme ALIAS MerceTheme)
add_library(Merce::Foundation ALIAS MerceFoundation)
add_library(Merce::Style ALIAS MerceStyle)
add_library(Merce::Effects ALIAS MerceEffects)
add_library(Merce::Controls ALIAS MerceControls)
if(MERCE_ENABLE_FONTAWESOME)
    add_library(Merce::IconsFontAwesome ALIAS MerceIconsFontAwesome)
endif()
if(MERCE_BUILD_NOTIFICATIONS)
    add_library(Merce::Notifications ALIAS MerceNotifications)
endif()

if(MERCE_BUILD_TESTS AND BUILD_TESTING)
    find_package(Qt6 6.11 REQUIRED COMPONENTS Test)
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/tests/CMakeLists.txt")
        add_subdirectory(tests)
    endif()
endif()

# ========================================================================
# Example Application (optional, for testing)
# ========================================================================
if(BUILD_MERCE_PLAYGROUND)
    if(NOT MERCE_ENABLE_FONTAWESOME)
        message(FATAL_ERROR "BUILD_MERCE_PLAYGROUND=ON requires MERCE_ENABLE_FONTAWESOME=ON for the Icons gallery.")
    endif()
    if(NOT MERCE_BUILD_NOTIFICATIONS)
        message(FATAL_ERROR "BUILD_MERCE_PLAYGROUND=ON requires MERCE_BUILD_NOTIFICATIONS=ON for the Feedback gallery.")
    endif()
    add_subdirectory(playground)
endif()

# ========================================================================
# Installation
# ========================================================================

if(PROJECT_IS_TOP_LEVEL)
    include(cmake/InstallMerce.cmake)
endif()

# ========================================================================
# Summary
# ========================================================================

message(STATUS "")
message(STATUS "Merce Design System v${PROJECT_VERSION}")
message(STATUS "  Qt Version: ${Qt6_VERSION}")
message(STATUS "  Build Type: ${CMAKE_BUILD_TYPE}")
message(STATUS "  Install Prefix: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "  Build Playground: ${BUILD_MERCE_PLAYGROUND}")
message(STATUS "")
message(STATUS "Module Dependency Tree:")
message(STATUS "  Application")
message(STATUS "    ├── Qt.labs.StyleKit controls")
message(STATUS "    │       └── Merce.Style")
message(STATUS "    │               ├── Merce.Foundation")
message(STATUS "    │               └── Merce.Theme")
message(STATUS "    ├── Merce.Controls (optional)")
message(STATUS "    │       ├── Merce.Foundation")
message(STATUS "    │       └── Merce.Theme")
if(MERCE_BUILD_NOTIFICATIONS)
    message(STATUS "    └── Merce.Notifications")
    message(STATUS "            ├── Merce.Controls")
    message(STATUS "            ├── Merce.Foundation")
    message(STATUS "            └── Merce.Theme")
endif()
message(STATUS "")
