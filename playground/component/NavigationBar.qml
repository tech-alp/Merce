import QtQuick
import Merce.Theme
import Merce.Foundation

Rectangle {
    id: root

    property var pages: []
    property string selectedPage: ""
    property string activeTheme: ""

    signal pageRequested(string key)

    color: Theme.colors.surface.container
    border.width: 1
    border.color: Theme.colors.outline.subtle
    clip: true

    function pageAt(index) {
        if (!pages || index < 0)
            return null
        if (pages.get)
            return pages.get(index)
        if (index >= pages.length)
            return null
        return pages[index]
    }

    function categoryStarts(index, category) {
        if (index === 0)
            return true

        const previous = pageAt(index - 1)
        return !previous || previous.category !== category
    }

    Item {
        id: contentItem
        anchors {
            fill: parent
            margins: Theme.spacing.lg
        }

        Row {
            id: brandRow
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            height: 52
            spacing: Theme.spacing.sm

            Rectangle {
                width: 44
                height: 44
                radius: Theme.radius.medium
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.colors.surface.canvas
                border.width: 1
                border.color: Theme.colors.outline.subtle

                MerceLogo {
                    objectName: "merce.playground.logo"
                    anchors.centerIn: parent
                    width: 26
                    height: 24
                    color: Theme.colors.action.primary.container
                }
            }

            Column {
                width: parent.width - 44 - parent.spacing
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacing.xxs

                AppLabel {
                    width: parent.width
                    textType: AppLabel.BodyLarge
                    text: "Merce"
                    color: Theme.colors.content.primary
                    wrapMode: Text.WordWrap
                }

                AppLabel {
                    width: parent.width
                    textType: AppLabel.Caption
                    text: root.activeTheme
                    color: Theme.colors.content.secondary
                    wrapMode: Text.WordWrap
                }
            }
        }

        Rectangle {
            id: separator
            anchors {
                left: parent.left
                right: parent.right
                top: brandRow.bottom
                topMargin: Theme.spacing.md
            }
            height: 1
            color: Theme.colors.outline.subtle
        }

        ListView {
            id: pageListView
            objectName: "merce.playground.nav.list"
            anchors {
                left: parent.left
                right: parent.right
                top: separator.bottom
                topMargin: Theme.spacing.md
                bottom: parent.bottom
            }
            model: root.pages
            spacing: Theme.spacing.xs
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            delegate: Item {
                id: pageDelegate

                required property string key
                required property string label
                required property string category
                required property string icon
                required property int index

                readonly property bool showCategory: root.categoryStarts(index, category)

                width: pageListView.width
                height: delegateColumn.implicitHeight

                Column {
                    id: delegateColumn
                    width: parent.width
                    spacing: Theme.spacing.xs

                    AppLabel {
                        width: parent.width
                        text: category
                        textType: AppLabel.Caption
                        color: Theme.colors.content.tertiary
                        visible: showCategory
                        height: visible ? implicitHeight : 0
                        wrapMode: Text.WordWrap
                    }

                    NavigationButton {
                        objectName: "merce.playground.nav." + pageDelegate.key
                        width: parent.width
                        text: pageDelegate.label
                        icon.name: pageDelegate.icon
                        current: root.selectedPage === pageDelegate.key
                        onClicked: root.pageRequested(pageDelegate.key)
                    }
                }
            }
        }
    }
}
