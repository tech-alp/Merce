import QtQuick
import Qt.labs.StyleKit
import Merce.Theme

ComboBox {
    id: root
    Accessible.name: qsTr("Profile")
    textRole: "label"
    valueRole: "value"
    currentValue: Theme.activeProfile
    model: Theme.availableProfiles.map(function(profile) {
        return { value: profile.value,
                 label: profile.value === "ops" ? qsTr("Desktop")
                      : profile.value === "cart" ? qsTr("Kiosk") : profile.label }
    })

    function selectProfile(value) {
        return Theme.setContext(Theme.activeBrand, Theme.activeMode, String(value))
    }

    onActivated: {
        if (!selectProfile(currentValue))
            console.warn("Profile selection failed", currentValue)
    }
}
