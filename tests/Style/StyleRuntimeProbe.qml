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
    readonly property real styleSwitchWidth: merceStyle.switchControl.indicator.implicitWidth
    readonly property real styleSpinBoxHeight: merceStyle.spinBox.background.implicitHeight
    readonly property color styleSpinBoxColor: merceStyle.spinBox.background.color
    readonly property real styleSpinBoxIndicatorSize:
        merceStyle.spinBox.indicator.foreground.implicitWidth
    readonly property color styleSpinBoxIndicatorColor:
        merceStyle.spinBox.indicator.foreground.image.color
    readonly property real styleTextAreaHeight: merceStyle.textArea.background.implicitHeight
    readonly property color styleTextAreaColor: merceStyle.textArea.background.color
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
    height: 620
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

    SK.SpinBox {
        objectName: "styleSpinBox"
        x: 24
        y: 200
        width: 150
        height: implicitHeight
        from: 0
        to: 10000
        value: 5000
        editable: true
        locale: Qt.locale("tr_TR")
    }

    SK.SpinBox {
        objectName: "compactStyleSpinBox"
        x: 480
        y: 200
        width: 136
        height: implicitHeight
        from: 1
        to: 10
        value: 3
        editable: true
    }

    SK.TextArea {
        objectName: "styleTextArea"
        x: 260
        y: 200
        width: 200
        height: implicitHeight
        text: ""
        placeholderText: ""
    }

    SK.Button {
        objectName: "disabledCheckedButton"
        x: 24
        y: 330
        width: 200
        text: ""
        checkable: true
        checked: true
        enabled: false
    }

    SK.CheckBox {
        objectName: "disabledCheckedCheckBox"
        x: 260
        y: 330
        text: ""
        checked: true
        enabled: false
    }

    SK.RadioButton {
        objectName: "disabledCheckedRadio"
        x: 420
        y: 330
        text: ""
        checked: true
        enabled: false
    }

    SK.Switch {
        objectName: "disabledCheckedSwitch"
        x: 260
        y: 420
        width: 160
        text: ""
        checked: true
        enabled: false
    }

    SK.ItemDelegate {
        objectName: "disabledCheckedItemDelegate"
        x: 420
        y: 420
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
        y: 510
        width: 200
        text: ""
        variant: MButton.Secondary
        size: MButton.Small
    }

    MButton {
        id: rightIconButton

        objectName: "rightIconButton"
        x: 240
        y: 440
        width: 200
        text: "Right icon"
        iconName: "go-next"
        iconPosition: MButton.IconRight
    }

    MButton {
        id: loadingButton

        objectName: "loadingButton"
        x: 456
        y: 440
        width: 200
        text: "Loading"
        loading: true
    }

    MButton {
        objectName: "checkedOutlineButton"
        x: 260
        y: 510
        width: 200
        text: ""
        variant: MButton.Outline
        checkable: true
        checked: true
    }
}
