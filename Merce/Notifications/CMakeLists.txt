qt_add_qml_module(MerceNotifications
    URI "Merce.Notifications"
    VERSION 1.0
    QML_FILES
        MDialog.qml
)

target_link_libraries(MerceNotifications PRIVATE MerceControls MerceEffects MerceFoundation MerceTheme)
