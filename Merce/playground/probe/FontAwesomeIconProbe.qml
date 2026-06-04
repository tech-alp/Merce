import QtQuick
import QtQuick.Window
import Merce.Icons.FontAwesome

Window {
    id: root

    width: 96
    height: 96
    visible: true

    FontAwesomeIcon {
        id: icon
        anchors.centerIn: parent
        name: "fa-solid:audio-description"
        size: 64
        color: "#000000"
    }

    Timer {
        id: grabTimer
        interval: 250
        running: true
        repeat: true
        property int attempts: 0

        onTriggered: {
            ++attempts
            if (icon.Window.window === null && attempts < 12)
                return
            if (icon.Window.window === null) {
                console.error("fontawesome-icon-probe failed", "window")
                Qt.exit(1)
                return
            }

            stop()
            icon.grabToImage(function(result) {
                if (!result.saveToFile("/private/tmp/merce-fontawesome-probe.png")) {
                    console.error("fontawesome-icon-probe failed", "save")
                    Qt.exit(1)
                    return
                }

                console.log("fontawesome-icon-probe ok",
                            icon.hasIcon,
                            icon.viewBoxWidth,
                            icon.viewBoxHeight,
                            icon.contentScale,
                            icon.iconSpec ? icon.iconSpec.path.length : 0)
                Qt.quit()
            })
        }
    }
}
