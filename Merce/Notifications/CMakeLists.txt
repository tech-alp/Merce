qt_add_qml_module(MerceNotifications
    URI "Merce.Notifications"
    VERSION 1.0
    QML_FILES
        MToast.qml
        MDialog.qml
)

target_link_libraries(MerceNotifications PRIVATE MerceFoundation MerceCore)
