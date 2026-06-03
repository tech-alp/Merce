# Merce Design System Configuration

# Find dependencies
include(CMakeFindDependencyMacro)
find_dependency(Qt6 REQUIRED COMPONENTS Core Quick Qml)

# Include module targets
include("${CMAKE_CURRENT_LIST_DIR}/MerceTargets.cmake")

# Alias for convenience
if(NOT TARGET Merce::Core)
    add_library(Merce::Core ALIAS MerceCore)
endif()

if(NOT TARGET Merce::Foundation)
    add_library(Merce::Foundation ALIAS MerceFoundation)
endif()

if(NOT TARGET Merce::Controls)
    add_library(Merce::Controls ALIAS MerceControls)
endif()

if(NOT TARGET Merce::Notifications)
    add_library(Merce::Notifications ALIAS MerceNotifications)
endif()
