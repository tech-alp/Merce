import QtQuick
import QtQuick.Layouts
import Qt.labs.StyleKit as SK
import Merce.Theme
import Merce.Foundation

ColumnLayout {
    id: root
    objectName: "merce.playground.profiles"
    spacing: Theme.spacing.lg

    AppLabel {
        Layout.fillWidth: true
        textType: AppLabel.H2
        text: qsTr("Profiles")
        wrapMode: Text.WordWrap
    }
    AppLabel {
        Layout.fillWidth: true
        textType: AppLabel.Body
        text: qsTr("Desktop uses compact mouse and keyboard controls. Kiosk uses larger text and touch targets. Your brand and color mode stay unchanged.")
        wrapMode: Text.WordWrap
    }
    ProfileSelector {
        objectName: "merce.playground.profiles.select"
        Layout.fillWidth: true
    }
    AppLabel {
        Layout.fillWidth: true
        textType: AppLabel.BodySmall
        text: qsTr("Runtime profile: %1. Desktop maps to ops; Kiosk maps to cart. Selection applies to every playground page for this session.").arg(Theme.activeProfile)
        wrapMode: Text.WordWrap
    }
    Repeater {
        model: [
            qsTr("Control height · %1 / %2 / %3 px").arg(Theme.size.control.small).arg(Theme.size.control.medium).arg(Theme.size.control.large),
            qsTr("Icon size · %1 / %2 / %3 px").arg(Theme.size.icon.small).arg(Theme.size.icon.medium).arg(Theme.size.icon.large),
            qsTr("Body text · %1 px").arg(Theme.typography.sizeMedium),
            qsTr("Touch target · %1 px").arg(Theme.spacing.touchTarget)
        ]
        AppLabel {
            required property string modelData
            Layout.fillWidth: true
            textType: AppLabel.Body
            text: modelData
            wrapMode: Text.WordWrap
        }
    }
    SK.TextField {
        Layout.fillWidth: true
        placeholderText: qsTr("Preview input")
        Accessible.name: qsTr("Preview input")
    }
    SK.Button {
        text: qsTr("Preview button")
    }
}
