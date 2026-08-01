import QtQuick
import Qt.labs.StyleKit as SK
import Merce.Style
import Merce.Controls

SK.ApplicationWindow {
    id: root

    property alias activeStyle: merceStyle
    readonly property real styleButtonHeight: merceStyle.button.background.implicitHeight
    readonly property color styleButtonColor: merceStyle.button.background.color
    readonly property real styleSwitchHeight: merceStyle.switchControl.background.implicitHeight
    readonly property color disabledCheckedButtonColor:
        merceStyle.button.disabled.checked.background.color
    readonly property color disabledCheckedCheckBoxColor:
        merceStyle.checkBox.disabled.checked.indicator.color
    readonly property color disabledCheckedRadioColor:
        merceStyle.radioButton.disabled.checked.indicator.foreground.color
    readonly property color disabledCheckedSwitchColor:
        merceStyle.switchControl.disabled.checked.indicator.color
    readonly property color disabledCheckedItemDelegateColor:
        merceStyle.itemDelegate.disabled.checked.background.color
    readonly property color styleComboBoxColor: !comboBox.enabled
                                                 ? merceStyle.comboBox.disabled.background.color
                                               : comboBox.down
                                                 ? merceStyle.comboBox.pressed.background.color
                                               : comboBox.hovered
                                                 ? merceStyle.comboBox.hovered.background.color
                                               : comboBox.highlighted
                                                 ? merceStyle.comboBox.highlighted.background.color
                                               : comboBox.activeFocus
                                                 ? merceStyle.comboBox.focused.background.color
                                                 : merceStyle.comboBox.background.color
    readonly property var merceButtonVariations: merceButton.styleVariations

    width: 640
    height: 530
    visible: true

    SK.StyleKit.style: MerceStyle { id: merceStyle }
    SK.StyleKit.transitionsEnabled: false

    SK.Button {
        objectName: "styleButton"
        x: 24
        y: 20
        width: 200
        text: ""
    }

    SK.TextField {
        objectName: "styleTextField"
        x: 24
        y: 140
        width: 200
        placeholderText: ""
    }

    SK.Switch {
        objectName: "styleSwitch"
        x: 260
        y: 20
        width: 160
        text: ""
        checked: false
    }

    SK.ComboBox {
        id: comboBox

        objectName: "styleComboBox"
        x: 260
        y: 140
        width: 200
        model: [""]
        focusPolicy: Qt.NoFocus
    }

    SK.Button {
        objectName: "disabledCheckedButton"
        x: 24
        y: 260
        width: 200
        text: ""
        checkable: true
        checked: true
        enabled: false
    }

    SK.CheckBox {
        objectName: "disabledCheckedCheckBox"
        x: 260
        y: 260
        text: ""
        checked: true
        enabled: false
    }

    SK.RadioButton {
        objectName: "disabledCheckedRadio"
        x: 420
        y: 260
        text: ""
        checked: true
        enabled: false
    }

    SK.Switch {
        objectName: "disabledCheckedSwitch"
        x: 260
        y: 350
        width: 160
        text: ""
        checked: true
        enabled: false
    }

    SK.ItemDelegate {
        objectName: "disabledCheckedItemDelegate"
        x: 420
        y: 350
        width: 180
        text: ""
        checkable: true
        checked: true
        enabled: false
    }

    MButton {
        id: merceButton

        objectName: "merceButton"
        x: 24
        y: 440
        width: 200
        text: ""
        variant: MButton.Secondary
        size: MButton.Small
    }
}
