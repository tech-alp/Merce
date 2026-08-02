qt_add_qml_module(MerceNotifications
    URI "Merce.Notifications"
    VERSION 1.0
    QML_FILES
        MDialog.qml
        MToastStyle.qml
        NotificationHost.qml
    DEPENDENCIES
        TARGET Toastify
        TARGET ToastifyStyle
)

target_link_libraries(MerceNotifications
    PRIVATE
        MerceFoundation
        MerceTheme
        Qt6::LabsStyleKit
)
