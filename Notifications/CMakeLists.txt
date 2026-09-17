set_source_files_properties(
    NotificationCenter.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

# Backing target first: qt_add_library honours BUILD_SHARED_LIBS (policy QTP0003),
# while qt_add_qml_module deliberately does not when it creates the target itself.
qt_add_library(MerceNotifications)

qt_add_qml_module(MerceNotifications
    URI "Merce.Notifications"
    VERSION 1.0
    QML_FILES
        MDialog.qml
        NotificationCenter.qml
        MToastStyle.qml
        NotificationHost.qml
    DEPENDENCIES
        TARGET MerceControls
        TARGET Toastify
        TARGET ToastifyStyle
)

target_link_libraries(MerceNotifications
    PRIVATE
        MerceControls
        MerceFoundation
        MerceTheme
        Qt6::LabsStyleKit
)
