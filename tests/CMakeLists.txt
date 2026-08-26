set(MERCE_TEST_ENVIRONMENT
    "QT_QPA_PLATFORM=offscreen"
    "QT_QUICK_BACKEND=software"
    "QML_IMPORT_PATH=${QT_QML_OUTPUT_DIRECTORY}"
)

add_subdirectory(Core)
add_subdirectory(Theme)
add_subdirectory(Style)
if(MERCE_BUILD_NOTIFICATIONS)
    add_subdirectory(Notifications)
endif()
