import QtQuick
import Merce.Core
import Merce.Foundation

Rectangle {
    id: root

    property var pages: []
    property string selectedPage: ""
    property string activeTheme: ""

    signal pageRequested(string key)

    color: Theme.palette.backgroundSurface
    border.width: 1
    border.color: Theme.palette.borderBase
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
                color: Theme.palette.background.base
                border.width: 1
                border.color: Theme.palette.borderBase

                MerceLogo {
                    objectName: "merce.playground.logo"
                    anchors.centerIn: parent
                    width: 26
                    height: 24
                    color: Theme.palette.actionPrimary
                }
            }

            Column {
                width: parent.width - 44 - parent.spacing
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacing.xxs

                MText {
                    width: parent.width
                    type: "bodyLarge"
                    text: "Merce"
                    textColor: Theme.palette.textPrimary
                    wrap: "word"
                }

                MText {
                    width: parent.width
                    type: "caption"
                    text: root.activeTheme
                    textColor: Theme.palette.text.secondary
                    wrap: "word"
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
            color: Theme.palette.borderBase
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

                    MText {
                        width: parent.width
                        text: category
                        type: "caption"
                        textColor: Theme.palette.text.tertiary
                        visible: showCategory
                        height: visible ? implicitHeight : 0
                        wrap: "word"
                    }

                    NavigationButton {
                        objectName: "merce.playground.nav." + pageDelegate.key
                        width: parent.width
                        text: pageDelegate.label
                        icon: pageDelegate.icon
                        checked: root.selectedPage === pageDelegate.key
                        onClicked: root.pageRequested(pageDelegate.key)
                    }
                }
            }
        }
    }
}
