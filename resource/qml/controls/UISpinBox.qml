import QtQuick
import QtQuick.Controls

SpinBox {
    id: control

    editable: true
    property string suffix: ""

    contentItem: TextInput {
        id: textInput
        z: 2
        text: control.textFromValue(control.value, control.locale)

        color: "#eeeeee"
        selectionColor: "#4b4b4b"
        selectedTextColor: "#ffffff"
        horizontalAlignment: Qt.AlignLeft
        verticalAlignment: Qt.AlignVCenter

        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: Qt.ImhFormattedNumbersOnly
    }

    up.indicator: Item {}

    down.indicator: Item {}

    background: Rectangle {
        color: "black"
        radius: 4
    }

    UIText {
        id: txtBackground
        text: textInput.text
        font: textInput.font
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        opacity: 0
    }

    UIText {
        text: control.suffix
        font: textInput.font
        anchors.left: txtBackground.right
        anchors.leftMargin: 5
        anchors.verticalCenter: parent.verticalCenter
        color: textInput.color
    }

    MouseArea {
        anchors.fill: parent
        z: textInput.z + 1
        acceptedButtons: Qt.NoButton
        enabled: true
        onWheel: (wheel)=>{
            if (wheel.angleDelta.y < 0)
                control.value -= control.stepSize
            else
                control.value += control.stepSize
        }
    }
}
