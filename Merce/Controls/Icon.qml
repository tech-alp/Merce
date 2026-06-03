import QtQuick

Item {
    id: root

    property url source: ""
    property int size: 24
    property color color: "transparent"

    implicitWidth: size
    implicitHeight: size
    width: size
    height: size

    Image {
        anchors.fill: parent
        source: root.source
        sourceSize.width: root.size
        sourceSize.height: root.size
        fillMode: Image.PreserveAspectFit
        visible: root.source !== ""
    }
}
