# Merce Design System Configuration

# Find dependencies
include(CMakeFindDependencyMacro)
find_dependency(Qt6 REQUIRED COMPONENTS Core Gui Quick Qml)

# Include module targets
include("${CMAKE_CURRENT_LIST_DIR}/MerceTargets.cmake")

# Alias for convenience
if(NOT TARGET Merce::Core)
    add_library(Merce::Core ALIAS MerceCore)
endif()

if(NOT TARGET Merce::Platform)
    add_library(Merce::Platform ALIAS MercePlatform)
endif()

if(NOT TARGET Merce::Theme)
    add_library(Merce::Theme ALIAS MerceTheme)
endif()

if(NOT TARGET Merce::Foundation)
    add_library(Merce::Foundation ALIAS MerceFoundation)
endif()

if(NOT TARGET Merce::Effects)
    add_library(Merce::Effects ALIAS MerceEffects)
endif()

if(NOT TARGET Merce::Controls)
    add_library(Merce::Controls ALIAS MerceControls)
endif()

if(NOT TARGET Merce::Notifications)
    add_library(Merce::Notifications ALIAS MerceNotifications)
endif()
