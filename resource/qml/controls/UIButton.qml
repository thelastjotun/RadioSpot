import QtQuick
import QtQuick.Controls

BasicButton {
    id: root

    property color unpressedFillColor: "#616161"
    property color unpressedBorderColor: "#1d1d1d"
    property color unpressedTextColor: "#e0e0e0"

    property color pressedFillColor: "#424242"
    property color pressedBorderColor: "#1d1d1d"
    property color pressedTextColor: "#bdbdbd"

    property bool pushed: root.pressed || root.checked
    property alias fillOpacity: fillRect.opacity
    property alias label: textElement
    property bool useToolTip: false
    property alias toolTipObj: toolTip
    property alias backgroundRect: fillRect

    flat: true
    highlighted: false
    width: 1.62 * height
    opacity: enabled ? 1.0 : 0.5

    background: Rectangle {
        id: fillRect
        color: root.pushed ? root.pressedFillColor : root.unpressedFillColor
        border.color: root.pushed ? root.pressedBorderColor : root.unpressedBorderColor
        border.width: 1
        radius: 5
    }

    contentItem: UIText {
        id: textElement
        text: root.text
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: root.pushed ? root.pressedTextColor : root.unpressedTextColor
        font: root.font
    }

    UIToolTip {
        id: toolTip
        visible: root.hovered && useToolTip
        parent: root
        enabled: useToolTip
        delay: 1000
        timeout: 5000
    }
}
