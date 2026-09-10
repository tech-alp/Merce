qt_add_executable(tst_merce_notification_host
    tst_merce_notification_host.cpp
)

qt_add_qml_module(tst_merce_notification_host
    URI "Merce.Tests.Notifications"
    VERSION 1.0
    QML_FILES
        NotificationHostProbe.qml
)

target_link_libraries(tst_merce_notification_host
    PRIVATE
        MerceNotifications
        MerceStyle
        MerceTheme
        Qt6::Core
        Qt6::Gui
        Qt6::LabsStyleKit
        Qt6::Qml
        Qt6::Quick
        Qt6::Test
        Toastify
        ToastifyStyle
        Toastifyplugin
        ToastifyStyleplugin
)

add_test(NAME tst_merce_notification_host
    COMMAND tst_merce_notification_host
)

set_tests_properties(tst_merce_notification_host PROPERTIES
    ENVIRONMENT "${MERCE_TEST_ENVIRONMENT}"
)
