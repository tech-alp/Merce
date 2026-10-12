pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt.labs.qmlmodels
import Qt.labs.StyleKit as SK
import Merce.Theme
import Merce.Foundation
import Merce.Controls

Item {
    id: root
    objectName: "merce.playground.showcase.devices"
    implicitHeight: page.implicitHeight
    height: implicitHeight

    property string query: ""
    property bool descending: false
    property var selectedIds: []
    property string detailText: ""
    readonly property var devices: [
        {deviceId: "K-001", name: "Entrance kiosk", status: "online", seen: "2026-09-22 10:42"},
        {deviceId: "K-002", name: "Ticket kiosk", status: "offline", seen: "2026-09-21 18:15"},
        {deviceId: "P-003", name: "Payment terminal", status: "online", seen: "2026-09-22 10:41"},
        {deviceId: "D-004", name: "Platform display", status: "maintenance", seen: "2026-09-22 09:30"},
        {deviceId: "K-005", name: "Exit kiosk", status: "online", seen: "2026-09-22 10:40"},
        {deviceId: "S-006", name: "Service terminal", status: "offline", seen: "2026-09-20 16:05"}
    ]
    readonly property var visibleDevices: {
        const term = query.trim().toLowerCase()
        return devices.filter(d => (d.name + " " + d.deviceId).toLowerCase().includes(term))
            .sort((a, b) => (descending ? -1 : 1) * a.name.localeCompare(b.name))
            .map(d => ({deviceId: d.deviceId, name: d.name, status: d.status, seen: d.seen, action: d.deviceId}))
    }
    readonly property int visibleSelectedCount: visibleDevices.filter(d => selectedIds.includes(d.deviceId)).length
    readonly property real rowHeight: Math.max(56, Theme.size.control.medium + Theme.spacing.sm * 2)
    readonly property real tableWidth: Math.max(760, width)
    readonly property var columnWidths: [64, tableWidth - 64 - 180 - 200 - 80, 180, 200, 80]

    function selectDevice(deviceId, checked) {
        selectedIds = checked ? [...selectedIds.filter(id => id !== deviceId), deviceId]
                              : selectedIds.filter(id => id !== deviceId)
    }

    function selectVisible(checked) {
        const visibleIds = visibleDevices.map(d => d.deviceId)
        selectedIds = checked ? [...new Set([...selectedIds, ...visibleIds])]
                              : selectedIds.filter(id => !visibleIds.includes(id))
    }

    function statusLabel(status) {
        if (status === "online") return qsTr("Online")
        if (status === "offline") return qsTr("Offline")
        return qsTr("Maintenance")
    }

    ColumnLayout {
        id: page
        width: root.width
        spacing: Theme.spacing.md

        AppLabel { text: qsTr("Devices"); textType: AppLabel.H3 }
        AppLabel {
            Layout.fillWidth: true
            text: qsTr("Sample device data. Search, sort and select rows to explore the active theme.")
            textType: AppLabel.BodySmall
            color: Theme.colors.content.secondary
            wrapMode: Text.WordWrap
        }
        SK.TextField {
            Layout.fillWidth: true
            placeholderText: qsTr("Search by device name or ID")
            Accessible.name: placeholderText
            onTextChanged: root.query = text
        }
        RowLayout {
            Layout.fillWidth: true
            AppLabel {
                Layout.fillWidth: true
                text: qsTr("%1 devices · %2 selected").arg(root.visibleDevices.length).arg(root.selectedIds.length)
                textType: AppLabel.BodySmall
                wrapMode: Text.WordWrap
            }
            MButton {
                text: qsTr("Clear selection")
                variant: MButton.Ghost
                enabled: root.selectedIds.length > 0
                onClicked: root.selectedIds = []
            }
        }
        Flickable {
            id: viewport
            Layout.fillWidth: true
            Layout.preferredHeight: header.height + Math.max(1, root.visibleDevices.length) * root.rowHeight + Theme.spacing.md
            contentWidth: root.tableWidth
            contentHeight: height
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.HorizontalFlick
            SK.ScrollBar.horizontal: SK.ScrollBar {
                visible: viewport.contentWidth > viewport.width
                policy: visible ? SK.ScrollBar.AsNeeded : SK.ScrollBar.AlwaysOff
            }

            Row {
                id: header
                width: root.tableWidth
                height: root.rowHeight
                Item {
                    width: root.columnWidths[0]; height: header.height
                    SK.CheckBox {
                        anchors.centerIn: parent
                        width: Theme.size.control.medium
                        height: Theme.size.control.medium
                        Accessible.name: qsTr("Select visible devices")
                        enabled: root.visibleDevices.length > 0
                        checkState: root.visibleSelectedCount === 0 ? Qt.Unchecked
                            : root.visibleSelectedCount === root.visibleDevices.length ? Qt.Checked : Qt.PartiallyChecked
                        nextCheckState: function() { return checkState === Qt.Checked ? Qt.Unchecked : Qt.Checked }
                        onClicked: root.selectVisible(checkState === Qt.Checked)
                    }
                }
                MButton {
                    width: root.columnWidths[1]; height: header.height
                    text: root.descending ? qsTr("Device ↓") : qsTr("Device ↑")
                    variant: MButton.Ghost
                    onClicked: root.descending = !root.descending
                }
                AppLabel {
                    width: root.columnWidths[2]; height: header.height
                    text: qsTr("Status"); verticalAlignment: Text.AlignVCenter
                    textType: AppLabel.BodySmall
                }
                AppLabel {
                    width: root.columnWidths[3]; height: header.height
                    text: qsTr("Last seen"); verticalAlignment: Text.AlignVCenter
                    textType: AppLabel.BodySmall
                }
                AppLabel {
                    width: root.columnWidths[4]; height: header.height
                    text: qsTr("Actions"); textType: AppLabel.Caption
                    verticalAlignment: Text.AlignVCenter
                }
            }

            TableView {
                id: table
                y: header.height
                width: root.tableWidth
                height: root.visibleDevices.length * root.rowHeight
                interactive: false
                columnWidthProvider: function(column) { return root.columnWidths[column] }
                rowHeightProvider: function() { return root.rowHeight }
                onWidthChanged: forceLayout()
                onVisibleChanged: if (visible) Qt.callLater(forceLayout)
                Component.onCompleted: Qt.callLater(forceLayout)
                model: TableModel {
                    rows: root.visibleDevices
                    onRowsChanged: Qt.callLater(table.forceLayout)
                    TableModelColumn { display: "deviceId" }
                    TableModelColumn { display: "name" }
                    TableModelColumn { display: "status" }
                    TableModelColumn { display: "seen" }
                    TableModelColumn { display: "action" }
                }
                delegate: Rectangle {
                    id: cell
                    required property int row
                    required property int column
                    required property var display
                    readonly property var device: root.visibleDevices[row] || ({deviceId: "", name: "", status: "", seen: ""})
                    implicitWidth: root.columnWidths[column]
                    implicitHeight: root.rowHeight
                    color: root.selectedIds.includes(device.deviceId)
                        ? Qt.alpha(Theme.colors.action.primary.container, Theme.state.layer.selected)
                        : "transparent"
                    Rectangle {
                        width: parent.width; height: Theme.size.outline.hairline
                        color: Theme.colors.outline.subtle
                    }
                    SK.CheckBox {
                        anchors.centerIn: parent
                        width: Theme.size.control.medium
                        height: Theme.size.control.medium
                        visible: cell.column === 0
                        checked: root.selectedIds.includes(cell.device.deviceId)
                        Accessible.name: qsTr("Select %1").arg(cell.device.name)
                        onClicked: root.selectDevice(cell.device.deviceId, checked)
                    }
                    AppLabel {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacing.xs
                        anchors.rightMargin: Theme.spacing.sm
                        visible: cell.column === 1 || cell.column === 3
                        text: cell.column === 1 ? cell.device.name + "\n" + cell.device.deviceId : cell.device.seen
                        textType: AppLabel.BodySmall
                        textFormat: Text.PlainText
                        maximumLineCount: 2
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    MBadge {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: cell.column === 2
                        text: root.statusLabel(cell.device.status)
                        variant: cell.device.status === "online" ? MBadge.Success
                            : cell.device.status === "offline" ? MBadge.Error : MBadge.Warning
                        icon: cell.device.status === "online" ? "material:check_circle"
                            : cell.device.status === "offline" ? "material:cancel" : "material:build"
                    }
                    SK.ToolButton {
                        anchors.centerIn: parent
                        width: Theme.size.control.medium
                        height: Theme.size.control.medium
                        visible: cell.column === 4
                        contentItem: AppIcon {
                            name: "material:info"
                            color: Theme.colors.content.primary
                            size: Theme.icons.medium
                        }
                        Accessible.name: qsTr("Details for %1").arg(cell.device.name)
                        onClicked: root.detailText = qsTr("%1 (%2) · %3 · Last seen: %4")
                            .arg(cell.device.name).arg(cell.device.deviceId)
                            .arg(root.statusLabel(cell.device.status)).arg(cell.device.seen)
                    }
                }
            }
            AppLabel {
                y: header.height
                width: viewport.width
                height: root.rowHeight
                visible: root.visibleDevices.length === 0
                text: qsTr("No devices match your search.")
                textType: AppLabel.BodySmall
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
        AppLabel {
            Layout.fillWidth: true
            visible: root.detailText.length > 0
            text: root.detailText
            wrapMode: Text.WordWrap
            textType: AppLabel.BodySmall
        }
    }
}
