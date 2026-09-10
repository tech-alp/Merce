set_source_files_properties(
    NotificationCenter.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

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
